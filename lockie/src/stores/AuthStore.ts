// Auth store, Firebase email/password authentication

import { defineStore } from 'pinia'
import { ref } from 'vue'
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
} from 'firebase/auth'
import { firebaseAuth } from '@/lib/Firebase'

export const useAuthStore = defineStore('auth', () => {
  // * State

  const isAuthenticated = ref(false)
  const username = ref('')
  const loginError = ref('')
  const isAuthReady = ref(false)

  // * Auth state listener
  // Fires once on init (restores session), then on every sign-in/sign-out.

  const authReadyPromise = new Promise<void>((resolve) => {
    onAuthStateChanged(firebaseAuth, (user) => {
      isAuthenticated.value = user !== null
      username.value = user?.email ?? ''

      if (!isAuthReady.value) {
        isAuthReady.value = true
        resolve()
      }
    })
  })

  // * Actions

  async function login(email: string, password: string): Promise<boolean> {
    loginError.value = ''

    try {
      await signInWithEmailAndPassword(firebaseAuth, email, password)
      return true
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : 'Login failed'
      loginError.value = message
      return false
    }
  }

  async function logout() {
    await signOut(firebaseAuth)
  }

  async function waitUntilReady() {
    await authReadyPromise
  }

  return { isAuthenticated, username, loginError, isAuthReady, login, logout, waitUntilReady }
})
