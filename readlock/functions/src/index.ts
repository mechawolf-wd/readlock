// Cloud Functions for the Readlock app.
//
// Callable functions for operations that require server-side authority:
// course purchases, resurrections, purchase counting, account deletion,
// referral codes, and lesson content serving. Each lives in its own
// file and is re-exported here.

import { initializeApp } from "firebase-admin/app";

initializeApp();

export { purchaseCourse } from "./purchaseCourse";
export { resurrectCourse } from "./resurrectCourse";
export { incrementTimesPurchased } from "./incrementTimesPurchased";
export { deleteAccount } from "./deleteAccount";
export { generateReferralCode } from "./generateReferralCode";
export { redeemReferralCode } from "./redeemReferralCode";
export { fetchLessonContent } from "./fetchLessonContent";
export { uploadTranslations } from "./uploadTranslations";
