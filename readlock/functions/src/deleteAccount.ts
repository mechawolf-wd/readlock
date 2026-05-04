// Tears down a user's account and the data attached to it.
//
// AuthService.deleteAccount in the Flutter app calls this after clearing
// the FCM token locally. Account deletion goes through here (not direct
// client writes) so /users deletes stay denied by firestore.rules and so
// the Admin SDK can also drop the auth record in the same step.

import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const USERS_COLLECTION = "users";

export const deleteAccount = onCall(async (request) => {
  const callerNotSignedIn = !request.auth;

  if (callerNotSignedIn) {
    throw new HttpsError(
      "unauthenticated",
      "Must be signed in to delete an account."
    );
  }

  const userId = request.auth!.uid;
  const userDocRef = getFirestore().collection(USERS_COLLECTION).doc(userId);

  try {
    await userDocRef.delete();
  } catch (error) {
    logger.error("deleteAccount: firestore delete failed", { userId, error });

    throw new HttpsError("internal", "Failed to delete profile data.");
  }

  try {
    await getAuth().deleteUser(userId);
  } catch (error) {
    logger.error("deleteAccount: auth delete failed", { userId, error });

    throw new HttpsError("internal", "Failed to delete auth record.");
  }

  return { ok: true };
});
