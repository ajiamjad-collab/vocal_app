import * as admin from "firebase-admin";
import {onCall, onRequest, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import * as functionsV1 from "firebase-functions/v1";
import {getFirestore} from "firebase-admin/firestore";

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
  if (!uid) throw new HttpsError("unauthenticated", "Login required.");
  return uid;
}

function requireString(data: any, key: string, minLen = 1) {
  const val = (data?.[key] ?? "").toString().trim();
  if (val.length < minLen) throw new HttpsError("invalid-argument", `${key} is required.`);
  return val;
}

// ✅ 10 chars total: "U" + 9 random (A-Z0-9)
function randomAlphaNum(len: number): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let out = "";
  for (let i = 0; i < len; i++) {
    out += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return out;
}

// ✅ Unique ID in collection: user/{UXXXXXXXXX}
async function generateUniquePublicUserId(): Promise<string> {
  for (let i = 0; i < 15; i++) {
    const id = `U${randomAlphaNum(9)}`;
    const doc = await db().collection("user").doc(id).get();
    if (!doc.exists) return id;
  }
  return `U${randomAlphaNum(9)}`;
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
  const privateSnap = await db().collection("users").doc(uid).get().catch(() => null);
  const publicUserId =
    privateSnap?.exists ? (privateSnap.data()?.publicUserId ?? "").toString().trim() : "";

  if (publicUserId) {
    await db().collection("user").doc(publicUserId).delete().catch(() => {});
    return;
  }

  const q = await db().collection("user").where("uid", "==", uid).limit(5).get().catch(() => null);
  if (!q || q.empty) return;

  await Promise.allSettled(q.docs.map((d) => d.ref.delete()));
}

async function deleteUserStorageFolder(uid: string): Promise<void> {
  const prefix = `profile_images/${uid}/`;
  const [files] = await bucket().getFiles({prefix}).catch(() => [[], null] as any);

  if (files?.length) {
    await Promise.allSettled(files.map((f: any) => f.delete().catch(() => {})));
  }
}

/**
 * ✅ Callable: createUserProfile (v2)
 * Input: { firstName: string, lastName: string }
 */
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

  let publicUserId = (existingData["publicUserId"] ?? "").toString().trim();
  if (!publicUserId) {
    publicUserId = await generateUniquePublicUserId();
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  const createdAt = existing?.exists && existingData["createdAt"] ? existingData["createdAt"] : now;

  await db().runTransaction(async (tx) => {
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

    tx.set(
      db().collection("user").doc(publicUserId),
      {
        uid,
        firstName,
        lastName,
        createdAt,
        updatedAt: now,
      },
      {merge: true}
    );
  });

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
  const emailVerified = authUser.emailVerified ?? false;

  const usersRef = db().collection("users").doc(uid);
  const snap = await usersRef.get().catch(() => null);

  if (!snap?.exists) {
    return {ok: true, emailVerified, profileExists: false};
  }

  const data = snap.data() || {};
  const publicUserId = (data["publicUserId"] ?? "").toString().trim();

  const now = admin.firestore.FieldValue.serverTimestamp();

  await db().runTransaction(async (tx) => {
    tx.set(usersRef, {emailVerified, updatedAt: now}, {merge: true});

    if (publicUserId) {
      tx.set(db().collection("user").doc(publicUserId), {updatedAt: now}, {merge: true});
    }
  });

  return {
    ok: true,
    emailVerified,
    profileExists: true,
    message: emailVerified ? "Synced verified email." : "Email not verified in Auth yet.",
  };
});

/**
 * ✅ CLEANUP ON ACCOUNT DELETE (v1 auth trigger)
 */
export const cleanupOnAccountDelete = functionsV1
  .region(REGION)
  .auth.user()
  .onDelete(async (user: functionsV1.auth.UserRecord) => {
    const uid = user.uid;

    await deletePublicUserDocByUid(uid);
    await deleteUserDocRecursively(uid);
    await deleteUserStorageFolder(uid);
  });

/**
 * ✅ CALLABLE: DELETE MY ACCOUNT (v2)
 */
export const deleteMyAccount = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  await deletePublicUserDocByUid(uid);
  await deleteUserDocRecursively(uid);
  await deleteUserStorageFolder(uid);

  await admin.auth().deleteUser(uid);

  return {ok: true};
});

/**
 * ✅ CALLABLE: CREATE EMAIL VERIFICATION LINK (v2)
 */
export const createEmailVerificationLink = onCall({region: REGION}, async (request) => {
  requireAuth(request);

  const user = await admin.auth().getUser(request.auth!.uid);
  const email = user.email;

  if (!email) {
    throw new HttpsError("failed-precondition", "No email found for this account.");
  }

  const actionCodeSettings = {
    url: "https://example.com/verified",
    handleCodeInApp: false,
  };

  const link = await admin.auth().generateEmailVerificationLink(email, actionCodeSettings);
  return {ok: true, link};
});

/**
 * ✅ CALLABLE: CREATE PASSWORD RESET LINK (v2)
 */
export const createPasswordResetLink = onCall({region: REGION}, async (request) => {
  const email = requireString(request.data, "email", 3);

  const actionCodeSettings = {
    url: "https://example.com/reset-done",
    handleCodeInApp: false,
  };

  const link = await admin.auth().generatePasswordResetLink(email, actionCodeSettings);
  return {ok: true, link};
});

/**
 * ✅ CALLABLE: REVOKE TOKENS (v2)
 */
export const revokeMyRefreshTokens = onCall({region: REGION}, async (request) => {
  const uid = requireAuth(request);

  await admin.auth().revokeRefreshTokens(uid);

  const user = await admin.auth().getUser(uid);
  return {
    ok: true,
    tokensValidAfterTime: user.tokensValidAfterTime ?? null,
  };
});

/**
 * ✅ Health endpoint (v2)
 */
export const health = onRequest({region: REGION}, (_req, res) => {
  res.status(200).send("OK");
});
