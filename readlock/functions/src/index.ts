// Cloud Functions for the Readlock app.
//
// Every write to /courses and every account-deletion path runs here under
// the Admin SDK so firestore.rules can keep direct client writes denied.
// Add new callables in their own file under src/ and re-export from here.

import { initializeApp } from "firebase-admin/app";

initializeApp();

export { incrementTimesPurchased } from "./incrementTimesPurchased";
export { deleteAccount } from "./deleteAccount";
export { generateReferralCode } from "./generateReferralCode";
export { redeemReferralCode } from "./redeemReferralCode";
