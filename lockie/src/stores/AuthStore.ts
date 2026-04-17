// Auth store — hardcoded credential check

import { defineStore } from 'pinia'
import { ref } from 'vue'

const ADMIN_USERNAME = 'admin'
const ADMIN_PASSWORD = 'admin'

export const useAuthStore = defineStore('auth', () => {
  // * State

  const isAuthenticated = ref(false)
  const username = ref('')
  const loginError = ref('')

  // * Actions

  function login(user: string, password: string): boolean {
    const isValidCredentials = user === ADMIN_USERNAME && password === ADMIN_PASSWORD

    if (!isValidCredentials) {
      loginError.value = 'Invalid credentials'
      return false
    }

    username.value = user
    isAuthenticated.value = true
    loginError.value = ''

    return true
  }

  function logout() {
    username.value = ''
    isAuthenticated.value = false
    loginError.value = ''
  }

  return { isAuthenticated, username, loginError, login, logout }
})
