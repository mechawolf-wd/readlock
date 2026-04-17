<script setup lang="ts">
// Login screen — hardcoded admin/admin authentication

import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/AuthStore'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from '@/components/ui/card'

// * Store and router

const auth = useAuthStore()
const router = useRouter()

// * State

const username = ref('')
const password = ref('')

// * Methods

function handleLogin() {
  const isSuccess = auth.login(username.value, password.value)

  if (isSuccess) {
    router.push('/editor')
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-background">
    <!-- Blur overlay -->
    <div class="fixed inset-0 bg-black/60 backdrop-blur-sm" />

    <!-- Login dialog -->
    <Card class="relative z-10 w-full max-w-sm mx-4 shadow-xl">
      <CardHeader>
        <CardTitle class="text-2xl">Lockie</CardTitle>
        <CardDescription>Course content creator for Readlock</CardDescription>
      </CardHeader>

      <CardContent>
        <form class="flex flex-col gap-4" @submit.prevent="handleLogin">
          <Input
            v-model="username"
            type="text"
            placeholder="Username"
            class="h-12"
          />

          <Input
            v-model="password"
            type="password"
            placeholder="Password"
            class="h-12"
          />

          <!-- Error message -->
          <p v-if="auth.loginError" class="text-sm text-red-500">
            {{ auth.loginError }}
          </p>

          <Button type="submit" class="w-full h-12 font-medium mt-4">
            Sign in
          </Button>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
