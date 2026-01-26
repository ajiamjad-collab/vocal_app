import * as admin from "firebase-admin";
import {onCall, HttpsError, CallableRequest, onRequest} from "firebase-functions/v2/https";
import {getFirestore} from "firebase-admin/firestore";
import * as crypto from "crypto";
import type {Request, Response} from "express";

admin.initializeApp();

// ✅ Region
const REGION = "asia-south1";
// ✅ Multi-db safe
const DATABASE_ID = "default";

// ✅ CHANGED: public profile collection name
const PUBLIC_PROFILE_COLLECTION = "Personal";

function db() {
  return getFirestore(admin.app(), DATABASE_ID);
}

/* function bucket() {
  return admin.storage().bucket();
}*/

// =============================
// ✅ Enterprise auth helpers
// =============================
function requireAuth(request: CallableRequest) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Authentication required.");
  return uid;
}

function requireString(data: any, key: string, minLen = 1, maxLen = 200) {
  const val = (data?.[key] ?? "").toString().trim();
  if (val.length < minLen) throw new HttpsError("invalid-argument", `${key} is required.`);
  if (val.length > maxLen) throw new HttpsError("invalid-argument", `${key} too long.`);
  return val;
}

function optionalString(data: any, key: string, maxLen = 5000) {
  const v = (data?.[key] ?? "").toString().trim();
  if (!v) return "";
  if (v.length > maxLen) throw new HttpsError("invalid-argument", `${key} too long.`);
  return v;
}

function requireEnum<T extends string>(data: any, key: string, allowed: readonly T[]): T {
  const v = (data?.[key] ?? "").toString().trim();
  if (!allowed.includes(v as T)) {
    throw new HttpsError("invalid-argument", `${key} must be one of: ${allowed.join(", ")}`);
  }
  return v as T;
}

function requireBool(data: any, key: string, fallback = false) {
  const v = data?.[key];
  if (typeof v === "boolean") return v;
  return fallback;
}

function requireMap(data: any, key: string): Record<string, any> {
  const v = data?.[key];
  if (!v || typeof v !== "object" || Array.isArray(v)) return {};
  return v as Record<string, any>;
}

function optionalArrayOfStrings(data: any, key: string, maxItems = 50, maxLen = 120): string[] {
  const arr = data?.[key];
  if (!Array.isArray(arr)) return [];
  const out: string[] = [];
  for (const x of arr) {
    const s = (x ?? "").toString().trim();
    if (!s) continue;
    if (s.length > maxLen) throw new HttpsError("invalid-argument", `${key} item too long.`);
    out.push(s);
    if (out.length >= maxItems) break;
  }
  return out;
}

// =============================
// ✅ Crypto-safe random IDs
// =============================
const ALNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

function randomAlphaNumCrypto(len: number): string {
  const bytes = crypto.randomBytes(len);
  let out = "";
  for (let i = 0; i < len; i++) out += ALNUM[bytes[i] % ALNUM.length];
  return out;
}

// -----------------------------
// ✅ User Public ID (U + 11)
// -----------------------------
function generatePublicUserIdCandidate(): string {
  return `U${randomAlphaNumCrypto(11)}`;
}

async function reserveUniquePublicUserIdTx(
  tx: FirebaseFirestore.Transaction,
  data: {
    firstName: string;
    lastName: string;
    createdAt: FirebaseFirestore.FieldValue | FirebaseFirestore.Timestamp;
    updatedAt: FirebaseFirestore.FieldValue | FirebaseFirestore.Timestamp;
  }
): Promise<string> {
  // ✅ CHANGED
  const col = db().collection(PUBLIC_PROFILE_COLLECTION);

  for (let i = 0; i < 25; i++) {
    const candidate = generatePublicUserIdCandidate();
    const ref = col.doc(candidate);

    const snap = await tx.get(ref);
    if (snap.exists) continue;

    tx.create(ref, {
      firstName: data.firstName,
      lastName: data.lastName,
      photoUrl: "",
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    });

    return candidate;
  }

  throw new HttpsError("internal", "Failed to reserve a unique public user id. Please retry.");
}

// =====================================================
// ✅ createUserProfile (v2)
// =====================================================
export const createUserProfile = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const firstName = requireString(request.data, "firstName", 1, 80);
  const lastName = requireString(request.data, "lastName", 1, 80);

  const authUser = await admin.auth().getUser(uid);
  const email = authUser.email ?? "";
  const provider = authUser.providerData?.[0]?.providerId ?? "unknown";
  const emailVerified = authUser.emailVerified ?? false;

  const usersRef = db().collection("Users").doc(uid);

  const existing = await usersRef.get().catch(() => null);
  const existingData = existing?.exists ? (existing.data() || {}) : {};

  const now = admin.firestore.FieldValue.serverTimestamp();
  const createdAt = existing?.exists && existingData["createdAt"] ? existingData["createdAt"] : now;

  let publicUserId = (existingData["publicUserId"] ?? "").toString().trim();

  for (let attempt = 0; attempt < 10; attempt++) {
    try {
      await db().runTransaction(async (tx) => {
        if (!publicUserId) {
          publicUserId = await reserveUniquePublicUserIdTx(tx, {
            firstName,
            lastName,
            createdAt,
            updatedAt: now,
          });
        } else {
          tx.set(
            // ✅ CHANGED
            db().collection(PUBLIC_PROFILE_COLLECTION).doc(publicUserId),
            {
              firstName,
              lastName,
              createdAt,
              updatedAt: now,
            },
            {merge: true}
          );
        }

        tx.set(
          usersRef,
          {
            uid,
            firstName,
            lastName,
            publicUserId,
            email,
            provider,
            emailVerified,
            createdAt,
            updatedAt: now,
          },
          {merge: true}
        );
      });

      break;
    } catch (e: any) {
      const msg = (e?.message ?? "").toString().toLowerCase();
      const code = (e?.code ?? "").toString();

      if (code === "already-exists" || msg.includes("already exists") || msg.includes("already_exists")) {
        publicUserId = "";
        continue;
      }
      throw e;
    }
  }

  if (!publicUserId) throw new HttpsError("internal", "Could not allocate a public user id after retries.");
  return {ok: true, publicUserId, emailVerified};
});

export const syncEmailVerificationStatus = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);
  const authUser = await admin.auth().getUser(uid);
  const verified = authUser.emailVerified ?? false;

  await db().collection("Users").doc(uid).set(
    {emailVerified: verified, updatedAt: admin.firestore.FieldValue.serverTimestamp()},
    {merge: true}
  );
  return {ok: true, emailVerified: verified};
});

// =====================================================
// ✅ PROFILE: getMyProfile
// Reads name/photo from public: Personal/{publicUserId}
// =====================================================
export const getMyProfile = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const privateSnap = await db().collection("Users").doc(uid).get();
  if (!privateSnap.exists) throw new HttpsError("not-found", "Private profile not found.");

  const publicUserId = (privateSnap.data()?.publicUserId ?? "").toString().trim();
  if (!publicUserId) throw new HttpsError("failed-precondition", "publicUserId not ready. Call createUserProfile first.");

  // ✅ CHANGED
  const publicSnap = await db().collection(PUBLIC_PROFILE_COLLECTION).doc(publicUserId).get();
  const pub = publicSnap.exists ? (publicSnap.data() || {}) : {};

  return {
    ok: true,
    publicUserId,
    firstName: (pub["firstName"] ?? "").toString(),
    lastName: (pub["lastName"] ?? "").toString(),
    photoUrl: (pub["photoUrl"] ?? "").toString(),
  };
});

// =====================================================
// ✅ PROFILE: updateMyName
// Updates BOTH:
// - public Personal/{publicId}
// - private Users/{uid}
// =====================================================
export const updateMyName = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const firstName = requireString(request.data, "firstName", 1, 80);
  const lastName = requireString(request.data, "lastName", 1, 80);

  const usersRef = db().collection("Users").doc(uid);
  const usersSnap = await usersRef.get();
  if (!usersSnap.exists) throw new HttpsError("not-found", "Private profile not found.");

  const publicUserId = (usersSnap.data()?.publicUserId ?? "").toString().trim();
  if (!publicUserId) throw new HttpsError("failed-precondition", "publicUserId not ready.");

  const now = admin.firestore.FieldValue.serverTimestamp();

  await db().runTransaction(async (tx) => {
    tx.set(
      // ✅ CHANGED
      db().collection(PUBLIC_PROFILE_COLLECTION).doc(publicUserId),
      {firstName, lastName, updatedAt: now},
      {merge: true}
    );

    tx.set(
      usersRef,
      {firstName, lastName, updatedAt: now},
      {merge: true}
    );
  });

  return {ok: true};
});

// =====================================================
// ✅ PROFILE: setMyProfilePhotoUrl
// photoUrl stored ONLY in public Personal/{publicId}
// =====================================================
export const setMyProfilePhotoUrl = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const photoUrl = requireString(request.data, "photoUrl", 5, 800);

  const usersRef = db().collection("Users").doc(uid);
  const privateSnap = await usersRef.get();
  if (!privateSnap.exists) throw new HttpsError("not-found", "Private profile not found.");

  const publicUserId = (privateSnap.data()?.publicUserId ?? "").toString().trim();
  if (!publicUserId) throw new HttpsError("failed-precondition", "publicUserId not ready.");

  const now = admin.firestore.FieldValue.serverTimestamp();

  await db().runTransaction(async (tx) => {
    // ✅ public doc: Personal/{publicUserId}
    tx.set(
      db().collection(PUBLIC_PROFILE_COLLECTION).doc(publicUserId),
      {photoUrl, updatedAt: now},
      {merge: true}
    );

    // ✅ private doc: Users/{uid}
    tx.set(
      usersRef,
      {photoUrl, updatedAt: now},
      {merge: true}
    );
  });

  return {ok: true};
});


// =====================================================
// ✅ BRANDS (Enterprise)
// =====================================================

// ✅ 12 chars total: "B" + 11 random (A-Z0-9)
function generateBrandIdCandidate(): string {
  return `B${randomAlphaNumCrypto(11)}`;
}

function buildSearchTokens(title: string): string[] {
  const t = title.toLowerCase().trim().replace(/\s+/g, " ");
  const words = t.split(" ").filter(Boolean);

  const tokens = new Set<string>();
  for (const w of words) {
    const max = Math.min(20, w.length);
    for (let i = 1; i <= max; i++) tokens.add(w.substring(0, i));
  }
  const maxFull = Math.min(25, t.length);
  for (let i = 1; i <= maxFull; i++) tokens.add(t.substring(0, i));

  return Array.from(tokens).slice(0, 80);
}

// ---- validators for old schema blocks ----
function sanitizeUrlList(arr: any, max = 1): string[] {
  if (!Array.isArray(arr)) return [];
  const out: string[] = [];
  for (const x of arr) {
    const s = (x ?? "").toString().trim();
    if (!s) continue;
    if (s.length > 500) continue;
    out.push(s);
    if (out.length >= max) break;
  }
  return out;
}

function sanitizePhones(arr: any, max = 5): Array<{ countryCode: string; number: string }> {
  if (!Array.isArray(arr)) return [];
  const out: Array<{ countryCode: string; number: string }> = [];
  for (const x of arr) {
    if (!x || typeof x !== "object") continue;
    const cc = (x["countryCode"] ?? "").toString().trim() || "+91";
    const num = (x["number"] ?? "").toString().trim();
    if (!num) continue;
    if (num.length > 20) continue;
    out.push({countryCode: cc, number: num});
    if (out.length >= max) break;
  }
  return out;
}

function clampInt(n: number, min: number, max: number): number {
  if (Number.isNaN(n)) return min;
  return Math.max(min, Math.min(max, Math.floor(n)));
}

function sanitizeWorkingHours(map: any): Record<string, any> {
  if (!map || typeof map !== "object" || Array.isArray(map)) return {};
  const out: Record<string, any> = {};
  const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  for (const d of days) {
    const v = map[d];
    if (!v || typeof v !== "object") continue;
    const isClosed = !!v["isClosed"];
    const open = v["open"] ?? {};
    const close = v["close"] ?? {};
    const oh = Number(open["h"] ?? 9);
    const om = Number(open["m"] ?? 0);
    const ch = Number(close["h"] ?? 18);
    const cm = Number(close["m"] ?? 0);
    out[d] = {
      isClosed,
      open: {h: clampInt(oh, 0, 23), m: clampInt(om, 0, 59)},
      close: {h: clampInt(ch, 0, 23), m: clampInt(cm, 0, 59)},
    };
  }
  return out;
}

function sanitizeBranches(arr: any, max = 10): any[] {
  if (!Array.isArray(arr)) return [];
  const out: any[] = [];
  for (const b of arr) {
    if (!b || typeof b !== "object") continue;
    const type = (b["type"] ?? "store").toString().trim() || "store";
    const name = (b["name"] ?? "").toString().trim();
    const address = (b["address"] ?? "").toString().trim();
    const googleMapUrl = (b["googleMapUrl"] ?? "").toString().trim();
    const phones = sanitizePhones(b["phones"], 3);
    const loc = b["location"] ?? {};
    const location = {
      ...(typeof loc === "object" && !Array.isArray(loc) ? loc : {}),
    };

    for (const k of ["state", "district", "city", "pin", "digiPin"]) {
      if (location[k] != null) location[k] = (location[k] ?? "").toString().trim();
      if (!location[k]) delete location[k];
    }

    const clean: any = {type};
    if (name) clean.name = name;
    if (address) clean.address = address;
    if (phones.length) clean.phones = phones;
    if (googleMapUrl) clean.googleMapUrl = googleMapUrl;
    if (Object.keys(location).length) clean.location = location;

    out.push(clean);
    if (out.length >= max) break;
  }
  return out;
}

// ✅ createBrand (ONLY ONE EXPORT) - safe brandId capture
export const createBrand = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const title = requireString(request.data, "title", 2, 120);
  const description = requireString(request.data, "description", 5, 5000);
  const category = requireEnum(request.data, "category", ["personal", "professional"] as const);
  const uiRefs = requireMap(request.data, "uiRefs");

  const contactsIn = requireMap(request.data, "contacts");
  const socialIn = requireMap(request.data, "socialMedia");
  const locationIn = requireMap(request.data, "location");

  const contacts = {
    phones: sanitizePhones(contactsIn["phones"], 5),
    whatsapps: sanitizePhones(contactsIn["whatsapps"], 5),
    emails: optionalArrayOfStrings(contactsIn, "emails", 5, 120),
    websites: sanitizeUrlList(contactsIn["websites"], 1),
  };

  const socialMedia = {
    instagram: sanitizeUrlList(socialIn["instagram"], 1),
    facebook: sanitizeUrlList(socialIn["facebook"], 1),
    youtube: sanitizeUrlList(socialIn["youtube"], 1),
    linkedin: sanitizeUrlList(socialIn["linkedin"], 1),
  };

  const location: any = {};
  for (const k of ["state", "district", "city", "pin", "digiPin", "googleMapUrl", "mainType", "mainName"]) {
    const v = (locationIn?.[k] ?? "").toString().trim();
    if (v) location[k] = v;
  }

  const branches = sanitizeBranches(request.data?.["branches"], 10);
  const showWorkingHours = requireBool(request.data, "showWorkingHours", true);
  const workingHours = sanitizeWorkingHours(request.data?.["workingHours"]);

  const tags = optionalArrayOfStrings(request.data, "tags", 50, 25);
  const languagesKnown = optionalArrayOfStrings(request.data, "languagesKnown", 30, 40);
  const categories = optionalArrayOfStrings(request.data, "categories", 20, 60);
  const subCategories = optionalArrayOfStrings(request.data, "subCategories", 50, 60);

  const businessType = optionalString(request.data, "businessType", 60);
  const offeringsTypes = optionalArrayOfStrings(request.data, "offeringsTypes", 20, 30);
  const serviceModes = optionalArrayOfStrings(request.data, "serviceModes", 30, 40);
  const customerType = optionalString(request.data, "customerType", 20);

  const companyType = optionalString(request.data, "companyType", 80);
  const companyFounded = optionalString(request.data, "companyFounded", 10);
  const gstNumber = optionalString(request.data, "gstNumber", 25);

  const userSnap = await db().collection("Users").doc(uid).get();
  const publicUserId = (userSnap.data()?.publicUserId ?? "").toString().trim();
  if (!publicUserId) {
    throw new HttpsError("failed-precondition", "User profile not ready. Call createUserProfile first.");
  }

  const now = admin.firestore.FieldValue.serverTimestamp();

  let brandId = "";

  for (let attempt = 0; attempt < 10; attempt++) {
    try {
      await db().runTransaction(async (tx) => {
        const candidate = generateBrandIdCandidate();
        const brandRef = db().collection("brands").doc(candidate);

        tx.create(brandRef, {
          id: candidate,
          title,
          description,
          category,

          createdByUid: uid,
          createdByPublicUserId: publicUserId,
          uiRefs,

          logoUrl: "",
          coverUrl: "",

          contacts,
          socialMedia,
          location: Object.keys(location).length ? location : null,
          branches,
          showWorkingHours,
          workingHours,

          tags,
          languagesKnown,
          categories,
          subCategories,
          businessType,
          offeringsTypes,
          serviceModes,
          customerType,
          companyType,
          companyFounded,
          gstNumber: gstNumber || null,

          searchTokens: buildSearchTokens(title),

          createdAt: now,
          updatedAt: now,
          visitsCount: 0,
        });

        brandId = candidate;
      });

      break;
    } catch (e: any) {
      const msg = (e?.message ?? "").toString().toLowerCase();
      const code = (e?.code ?? "").toString();

      if (code === "already-exists" || msg.includes("already exists") || msg.includes("already_exists")) {
        continue;
      }
      throw e;
    }
  }

  if (!brandId) throw new HttpsError("internal", "Could not allocate brand id after retries.");

  return {
    ok: true,
    brandId,
    upload: {
      logoPath: `brand_images/${brandId}/logo.jpg`,
      coverPath: `brand_images/${brandId}/cover.jpg`,
    },
  };
});

// ✅ Update brand media URLs (server-authoritative write)
export const setBrandMedia = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const brandId = requireString(request.data, "brandId", 3, 30);
  const logoUrl = optionalString(request.data, "logoUrl", 500);
  const coverUrl = optionalString(request.data, "coverUrl", 500);

  const brandRef = db().collection("brands").doc(brandId);
  const snap = await brandRef.get();
  if (!snap.exists) throw new HttpsError("not-found", "Brand not found.");

  const createdByUid = (snap.data()?.createdByUid ?? "").toString();
  if (createdByUid !== uid) throw new HttpsError("permission-denied", "Only brand owner can update media.");

  const payload: any = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (logoUrl) payload.logoUrl = logoUrl;
  if (coverUrl) payload.coverUrl = coverUrl;

  await brandRef.set(payload, {merge: true});
  return {ok: true};
});

// ✅ Visits (atomic increment) — baseline
export const incrementBrandVisit = onCall({region: REGION}, async (request) => {
  const brandId = requireString(request.data, "brandId", 3, 30);

  await db()
    .collection("brands")
    .doc(brandId)
    .set(
      {
        visitsCount: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}
    );

  return {ok: true};
});

// =====================================================
// Legacy v1 HTTP function (optional health check)
// =====================================================
export const health = onRequest({region: REGION}, (req: Request, res: Response) => {
  res.status(200).send("ok");
});
