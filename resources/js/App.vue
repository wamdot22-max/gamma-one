<template>
  <a-config-provider :locale="indonesianLocale" :theme="theme">
    <router-view />
  </a-config-provider>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'
import indonesianLocale from 'ant-design-vue/es/locale/id_ID'
import { useAuthStore } from './stores/auth'
import { getStoredToken } from './utils/authStorage'

// Identitas visual Gamma One: diterapkan lewat token tema Ant Design,
// bukan menimpa CSS satu per satu.
const theme = {
  token: {
    colorPrimary: '#0B4DA2',
    colorInfo: '#1877C9',
    colorWarning: '#F9A825',
    fontFamily: "'Nunito', -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
    borderRadius: 8,
  },
}

const authStore = useAuthStore()

const revalidateSession = async () => {
  if (!getStoredToken()) return

  try {
    await authStore.refreshMe()
  } catch {
    // The axios interceptor handles redirecting on unauthorized responses.
  }
}

const handleVisibilityChange = () => {
  if (document.visibilityState === 'visible') {
    void revalidateSession()
  }
}

onMounted(() => {
  window.addEventListener('focus', revalidateSession)
  window.addEventListener('pageshow', revalidateSession)
  document.addEventListener('visibilitychange', handleVisibilityChange)
})

onUnmounted(() => {
  window.removeEventListener('focus', revalidateSession)
  window.removeEventListener('pageshow', revalidateSession)
  document.removeEventListener('visibilitychange', handleVisibilityChange)
})
</script>

<style>
body {
  margin: 0;
  padding: 0;
  background-color: #f0f2f5;
  font-family: 'Nunito', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}
</style>
