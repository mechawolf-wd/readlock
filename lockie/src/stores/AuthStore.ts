// Auth store — mockup authentication state

import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  // * State

  const isAuthenticated = ref(false)
  const username = ref('')

  // * Actions

  function login(user: string, password: string) {
    username.value = user
    isAuthenticated.value = true
  }

  function logout() {
    username.value = ''
    isAuthenticated.value = false
  }

  return { isAuthenticated, username, login, logout }
})
