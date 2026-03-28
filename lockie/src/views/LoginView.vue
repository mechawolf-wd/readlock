<script setup lang="ts">
// Login screen — mockup authentication for Lockie

import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/AuthStore'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'

// * Store and router

const auth = useAuthStore()
const router = useRouter()

// * State

const email = ref('')
const password = ref('')

// * Methods

function handleLogin() {
  auth.login(email.value, password.value)

  router.push('/editor')
}
</script>

<template>
  <!-- Login container -->
  <div class="min-h-screen flex items-center justify-center bg-background p-6">
    <Card class="w-full max-w-sm">
      <!-- Header -->
      <CardHeader class="text-center">
        <CardTitle class="text-2xl font-bold text-primary">Lockie</CardTitle>
        <CardDescription>Course content creator for Readlock</CardDescription>
      </CardHeader>

      <!-- Form -->
      <CardContent>
        <form class="flex flex-col gap-4" @submit.prevent="handleLogin">
          <Input v-model="email" type="email" placeholder="Email" />

          <Input v-model="password" type="password" placeholder="Password" />

          <Button type="submit" class="w-full">Sign in</Button>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
