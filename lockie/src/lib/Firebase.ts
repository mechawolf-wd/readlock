// Firebase initialization — shared config for Firestore access
// Uses the same credentials as the Readlock Flutter app

import { initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'

const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyAcKL7UCkGiWASDXBs080RjcVt8pPQfc5k',
  authDomain: 'readlock-production.firebaseapp.com',
  projectId: 'readlock-production',
  storageBucket: 'readlock-production.firebasestorage.app',
  messagingSenderId: '976267746377',
  appId: '1:976267746377:web:8bd98125ac35c3cd507398',
}

const app = initializeApp(FIREBASE_CONFIG)
export const firestore = getFirestore(app)
