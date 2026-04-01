<script setup lang="ts">
// Login screen — mockup authentication for Lockie

import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/AuthStore'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent } from '@/components/ui/card'
import VantaBackground from '@/components/VantaBackground.vue'

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
  <div class="min-h-screen flex flex-col relative overflow-hidden">
    <VantaBackground color="#dc2626" />

    <!-- Header -->
    <div class="relative z-10 p-8">
      <h1 class="text-3xl font-bold text-white drop-shadow-sm">Lockie</h1>
      <p class="text-sm text-white/60 mt-1">Course content creator for Readlock</p>
    </div>

    <div class="flex-1" />

    <!-- Login card — bottom right -->
    <div class="relative z-10 flex justify-end p-8">
      <Card class="w-full max-w-sm shadow-xl">
        <CardContent class="pt-6">
          <form class="flex flex-col gap-4" @submit.prevent="handleLogin">
            <Input
              v-model="email"
              type="email"
              placeholder="Email"
              class="h-11"
            />

            <Input
              v-model="password"
              type="password"
              placeholder="Password"
              class="h-11"
            />

            <Button type="submit" class="w-full h-11 font-medium">
              Sign in
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
