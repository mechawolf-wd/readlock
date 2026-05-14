// Tears down a user's account and the data attached to it.
//
// AuthService.deleteAccount in the Flutter app calls this after clearing
// the FCM token locally. Account deletion goes through here (not direct
// client writes) so /users deletes stay denied by firestore.rules and so
// the Admin SDK can also drop the auth record in the same step.
//
// Deletion order: auth record first, then Firestore document. If auth
// succeeds but Firestore fails, the user can no longer sign in (correct)
// and the orphaned document can be cleaned up later. The reverse order
// would leave a user who can sign in but has no profile data.

import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const USERS_COLLECTION = "users";

const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === "true";

export const deleteAccount = onCall(
  { enforceAppCheck: !IS_EMULATOR, maxInstances: 10 },
  async (request) => {
  const callerNotSignedIn = !request.auth;

  if (callerNotSignedIn) {
    throw new HttpsError(
      "unauthenticated",
      "Must be signed in to delete an account."
    );
  }

  const userId = request.auth!.uid;

  // * Delete auth record first (prevents re-login on partial failure)

  try {
    await getAuth().deleteUser(userId);
  } catch (error) {
    logger.error("deleteAccount: auth delete failed", { userId, error });

    throw new HttpsError("internal", "Failed to delete auth record.");
  }

  // * Delete Firestore profile data

  try {
    const userDocRef = getFirestore().collection(USERS_COLLECTION).doc(userId);

    await userDocRef.delete();
  } catch (error) {
    // Auth record is already gone, so the user cannot sign in again.
    // Log the failure so the orphaned document can be cleaned up later.
    logger.error("deleteAccount: firestore delete failed (auth already removed)", { userId, error });
  }

  return { ok: true };
});
