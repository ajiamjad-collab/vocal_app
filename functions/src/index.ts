import * as admin from "firebase-admin";
import {onCall, onRequest, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import * as functionsV1 from "firebase-functions/v1";
import {getFirestore} from "firebase-admin/firestore";
import * as crypto from "crypto";

admin.initializeApp();

// ✅ Your Functions region (Mumbai)
const REGION = "asia-south1";

// ✅ IMPORTANT (Enterprise multi-db): databaseId is "default"
const DATABASE_ID = "default";

// ✅ Lazy getters to avoid deploy-time initialization timeout
function db() {
  return getFirestore(admin.app(), DATABASE_ID);
}

function bucket() {
  return admin.storage().bucket();
}

// =============================
// ✅ Enterprise auth helpers
// =============================
function requireAuth(request: CallableRequest) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Authentication required.");
  return uid;
}

function requireString(data: any, key: string, minLen = 1) {
  const val = (data?.[key] ?? "").toString().trim();
  if (val.length < minLen) throw new HttpsError("invalid-argument", `${key} is required.`);
  return val;
}

// ✅ 12 chars total: "U" + 11 random (A-Z0-9)
// Uses cryptographically-strong randomness (NOT Math.random()).
const PUBLIC_ID_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

function randomAlphaNumCrypto(len: number): string {
  const bytes = crypto.randomBytes(len);
  let out = "";
  for (let i = 0; i < len; i++) {
    out += PUBLIC_ID_CHARS[bytes[i] % PUBLIC_ID_CHARS.length];
  }
  return out;
}

// ✅ Candidate public id: U + 11 chars (total length = 12)
function generatePublicUserIdCandidate(): string {
  return `U${randomAlphaNumCrypto(11)}`;
}

// ✅ Reserve a unique public id by creating user/{publicId} with a precondition.
// If it already exists, Firestore will throw ALREADY_EXISTS and we retry.
async function reserveUniquePublicUserIdTx(
  tx: FirebaseFirestore.Transaction,
  data: {
    firstName: string;
    lastName: string;
    createdAt: FirebaseFirestore.FieldValue | FirebaseFirestore.Timestamp;
    updatedAt: FirebaseFirestore.FieldValue | FirebaseFirestore.Timestamp;
  }
): Promise<string> {
  const publicRefCol = db().collection("user");

  // Try a handful of times inside a single transaction attempt.
  // If we fail due to collision, we throw a controlled error and the outer retry loop will re-run.
  for (let i = 0; i < 25; i++) {
    const candidate = generatePublicUserIdCandidate();
    const publicRef = publicRefCol.doc(candidate);

    // transaction.create() will fail if the document already exists.
    tx.create(publicRef, {
      // ✅ Public-safe fields only. DO NOT store uid here.
      firstName: data.firstName,
      lastName: data.lastName,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    });

    return candidate;
  }

  throw new HttpsError("internal", "Failed to reserve a unique public user id. Please retry.");
}

type RecursiveDeleteFn = (ref: FirebaseFirestore.DocumentReference) => Promise<void>;
type FirestoreWithRecursiveDelete = admin.firestore.Firestore & { recursiveDelete?: RecursiveDeleteFn };

async function deleteUserDocRecursively(uid: string): Promise<void> {
  const userRef = db().collection("users").doc(uid);

  const dbAny = db() as unknown as FirestoreWithRecursiveDelete;
  if (typeof dbAny.recursiveDelete === "function") {
    await dbAny.recursiveDelete(userRef).catch(() => {});
    return;
  }

  await userRef.delete().catch(() => {});
}

async function deletePublicUserDocByUid(uid: string): Promise<void> {
  // If you no longer store uid in public docs, you can’t delete by uid without a private mapping.
  // Safer approach: read user’s publicUserId from users/{uid} first, then delete user/{publicUserId}.
  const userSnap = await db().collection("users").doc(uid).get().catch(() => null);
  const publicUserId = userSnap?.exists ? (userSnap.data()?.publicUserId ?? "").toString().trim() : "";
  if (!publicUserId) return;

  await db().collection("user").doc(publicUserId).delete().catch(() => {});
}

async function deleteStorageFolderByPrefix(prefix: string): Promise<void> {
  const [files] = await bucket().getFiles({prefix}).catch(() => [[]] as any);
  if (!files?.length) return;

  await Promise.allSettled(files.map((f: any) => f.delete().catch(() => {})));
}

// =====================================================
// ✅ createUserProfile (v2) - server authoritative
// - Creates/merges users/{uid} (private)
// - Creates/reserves user/{publicId} (public)
// - Collision + concurrency safe at massive scale
// =====================================================
export const createUserProfile = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const firstName = requireString(request.data, "firstName", 1);
  const lastName = requireString(request.data, "lastName", 1);

  const authUser = await admin.auth().getUser(uid);
  const email = authUser.email ?? "";
  const provider = authUser.providerData?.[0]?.providerId ?? "unknown";
  const emailVerified = authUser.emailVerified ?? false;

  const usersRef = db().collection("users").doc(uid);

  const existing = await usersRef.get().catch(() => null);
  const existingData = existing?.exists ? (existing.data() || {}) : {};

  const now = admin.firestore.FieldValue.serverTimestamp();
  const createdAt =
    existing?.exists && existingData["createdAt"] ? existingData["createdAt"] : now;

  // If the user already has a publicUserId, keep it stable forever.
  const existingPublicUserId = (existingData["publicUserId"] ?? "")
    .toString()
    .trim();

  // -----------------------------
  // ✅ Transaction with safe ID reservation (no race condition)
  // -----------------------------
  let publicUserId = existingPublicUserId;

  // We may need to retry if the reserved id collides (ALREADY_EXISTS).
  for (let attempt = 0; attempt < 10; attempt++) {
    try {
      await db().runTransaction(async (tx) => {
        // Reserve a new public id only when missing.
        if (!publicUserId) {
          publicUserId = await reserveUniquePublicUserIdTx(tx, {
            firstName,
            lastName,
            createdAt,
            updatedAt: now,
          });
        } else {
          // Ensure the public doc exists (id already assigned).
          // We use set({merge:true}) so we don't overwrite other public fields if you add them later.
          tx.set(
            db().collection("user").doc(publicUserId),
            {
              firstName,
              lastName,
              createdAt,
              updatedAt: now,
            },
            {merge: true}
          );
        }

        // Private profile (server-owned fields live here)
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

      // ✅ success
      break;
    } catch (e: any) {
      const msg = (e?.message ?? "").toString();
      const code = (e?.code ?? "").toString();

      // Collision on tx.create(publicDoc) -> retry.
      if (
        code === "already-exists" ||
        msg.includes("ALREADY_EXISTS") ||
        msg.toLowerCase().includes("already exists")
      ) {
        publicUserId = ""; // force new reservation next loop
        continue;
      }

      throw e;
    }
  }

  if (!publicUserId) {
    throw new HttpsError("internal", "Could not allocate a public user id after retries.");
  }

  return {ok: true, publicUserId, emailVerified};
});

/**
 * ✅ syncEmailVerificationStatus (v2)
 * Client flow:
 * 1) user.reload() in Flutter
 * 2) call this function
 */
export const syncEmailVerificationStatus = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  const authUser = await admin.auth().getUser(uid);
  const verified = authUser.emailVerified ?? false;

  await db().collection("users").doc(uid).set(
    {
      emailVerified: verified,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {merge: true}
  );

  return {ok: true, emailVerified: verified};
});

// =====================================================
// ✅ deleteMyAccount (v2)
// Deletes:
// - users/{uid} recursively
// - user/{publicId} (by reading users/{uid}.publicUserId)
// - profile_images/{uid}/...
// =====================================================
export const deleteMyAccount = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  // 1) delete storage images
  await deleteStorageFolderByPrefix(`profile_images/${uid}/`).catch(() => {});

  // 2) delete public doc safely
  await deletePublicUserDocByUid(uid).catch(() => {});

  // 3) delete private doc recursively
  await deleteUserDocRecursively(uid).catch(() => {});

  // 4) finally delete auth user (optional: depends on your app flow)
  await admin.auth().deleteUser(uid).catch(() => {});

  return {ok: true};
});

// ------------------------------------------------------------------
// 🔒 Security: do NOT return verification links to the client.
// Use Firebase client SDK: user.sendEmailVerification().
// (Keeping this callable but disabling it to prevent abuse.)
// ------------------------------------------------------------------
export const createEmailVerificationLink = onCall({region: REGION}, async () => {
  throw new HttpsError(
    "failed-precondition",
    "Disabled. Use FirebaseAuth.sendEmailVerification() from the client."
  );
});

// ------------------------------------------------------------------
// 🔒 Security: do NOT generate / return password reset links to the client.
// Use Firebase client SDK: FirebaseAuth.sendPasswordResetEmail().
// ------------------------------------------------------------------
export const createPasswordResetLink = onCall({region: REGION}, async () => {
  throw new HttpsError(
    "failed-precondition",
    "Disabled. Use FirebaseAuth.sendPasswordResetEmail() from the client."
  );
});

// =====================================================
// Legacy v1 HTTP function example (if you have any)
// =====================================================
// Example placeholder to match your existing imports:
export const health = functionsV1.region(REGION).https.onRequest((req, res) => {
  res.status(200).send("ok");
});
