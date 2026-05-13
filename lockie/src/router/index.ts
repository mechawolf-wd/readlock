// Router, login and editor routes with auth guard

import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/AuthStore'
import LoginView from '@/views/LoginView.vue'
import EditorView from '@/views/EditorView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', component: LoginView },
    { path: '/editor', component: EditorView },
  ],
})

// * Auth guard

router.beforeEach(async (to) => {
  const auth = useAuthStore()

  await auth.waitUntilReady()

  const isProtectedRoute = to.path !== '/'
  const isNotAuthenticated = !auth.isAuthenticated
  const isLoginRoute = to.path === '/'
  const isAlreadyAuthenticated = auth.isAuthenticated

  if (isProtectedRoute && isNotAuthenticated) {
    return '/'
  }

  if (isLoginRoute && isAlreadyAuthenticated) {
    return '/editor'
  }
})

export default router
