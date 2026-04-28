<script setup lang="ts">
// Login screen for Lockie, single card themed with app primary.

import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/AuthStore'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Loader2 } from 'lucide-vue-next'

// * Store and router

const auth = useAuthStore()
const router = useRouter()

// * State

const username = ref('')
const password = ref('')
const isSubmitting = ref(false)

const submitButtonLabel = computed(() => isSubmitting.value ? 'Signing in...' : 'Sign in')

// * Methods

async function handleLogin() {
  isSubmitting.value = true

  const isSuccess = auth.login(username.value, password.value)

  if (isSuccess) {
    router.push('/editor')
  }

  isSubmitting.value = false
}
</script>

<template>
  <div class="relative min-h-screen w-full flex items-center justify-center bg-background p-6 overflow-hidden">
    <!-- Ambient background, two soft color blobs tinted with the app primary -->
    <div class="pointer-events-none absolute inset-0">
      <div class="absolute -top-32 -right-32 w-[520px] h-[520px] rounded-full bg-primary/15 blur-3xl" />
      <div class="absolute -bottom-40 -left-40 w-[520px] h-[520px] rounded-full bg-primary/10 blur-3xl" />
    </div>

    <Card class="relative w-full max-w-md shadow-2xl border-border/60">
      <CardHeader>
        <div class="flex flex-col gap-1.5">
          <CardTitle class="text-2xl font-semibold tracking-tight">Sign in to Lockie</CardTitle>
          <CardDescription>Course content creator for Readlock.</CardDescription>
        </div>
      </CardHeader>

      <CardContent>
        <form class="flex flex-col gap-5" @submit.prevent="handleLogin">
          <!-- Username -->
          <div class="flex flex-col gap-2">
            <label for="login-username" class="text-sm font-medium">Username</label>
            <Input
              id="login-username"
              v-model="username"
              type="text"
              autocomplete="username"
              autofocus
              placeholder="admin"
              class="h-10"
            />
          </div>

          <!-- Password -->
          <div class="flex flex-col gap-2">
            <label for="login-password" class="text-sm font-medium">Password</label>
            <Input
              id="login-password"
              v-model="password"
              type="password"
              autocomplete="current-password"
              placeholder="••••••••"
              class="h-10"
            />
          </div>

          <!-- Error -->
          <p
            v-if="auth.loginError"
            class="text-sm text-destructive -mt-1"
            role="alert"
          >
            {{ auth.loginError }}
          </p>

          <Button type="submit" class="w-full h-10 font-medium mt-1" :disabled="isSubmitting">
            <Loader2 v-if="isSubmitting" class="size-4 animate-spin" />
            {{ submitButtonLabel }}
          </Button>
        </form>
      </CardContent>

      <CardFooter class="justify-center border-t pt-4">
        <p class="text-xs text-muted-foreground">
          Internal tool · Restricted access
        </p>
      </CardFooter>
    </Card>
  </div>
</template>
