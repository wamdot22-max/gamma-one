<template>
  <div class="portal">
    <div class="portal-header">
      <img v-if="appSettings?.sidebar_logo_url" :src="appSettings.sidebar_logo_url" alt="logo" class="portal-logo" />
      <span class="portal-name">{{ appSettings?.app_name || 'Gamma One' }}</span>
      <a-avatar :src="authStore.user?.avatar_url" class="portal-avatar" @click="logout">{{ authStore.user?.name?.charAt(0) }}</a-avatar>
    </div>
    <div class="portal-content"><router-view /></div>
    <nav class="portal-nav">
      <router-link v-for="item in navItems" :key="item.path" :to="item.path" class="portal-nav-item" active-class="active">
        <component :is="item.icon" />
        <span>{{ item.label }}</span>
      </router-link>
    </nav>
  </div>
</template>

<script setup>
import { computed, h, watchEffect } from 'vue'
import { useRouter } from 'vue-router'
import { useQuery } from '@tanstack/vue-query'
import { HomeOutlined, CalendarOutlined, TrophyOutlined, WalletOutlined, UserOutlined } from '@ant-design/icons-vue'
import api from '../api/client'
import { useAuthStore } from '../stores/auth'
import { applyFavicon } from '../utils/favicon'

const authStore = useAuthStore()
const router = useRouter()

const { data: appSettings } = useQuery({ queryKey: ['app-settings-portal'], queryFn: async () => (await api.get('/app-settings')).data.data })

watchEffect(() => {
  document.title = appSettings.value?.app_name || 'Gamma One'
  applyFavicon(appSettings.value?.favicon_url, appSettings.value?.updated_at)
})

const navItems = computed(() => [
  { path: '/portal', label: 'Beranda', icon: () => h(HomeOutlined) },
  { path: '/portal/jadwal', label: 'Jadwal', icon: () => h(CalendarOutlined) },
  { path: '/portal/nilai', label: 'Nilai', icon: () => h(TrophyOutlined) },
  { path: '/portal/tagihan', label: 'Tagihan', icon: () => h(WalletOutlined) },
  { path: '/portal/profil', label: 'Profil', icon: () => h(UserOutlined) },
])

async function logout() {
  await authStore.logout()
  router.replace('/login')
}
</script>

<style scoped>
.portal { min-height: 100vh; max-width: 640px; margin: 0 auto; background: #f0f2f5; display: flex; flex-direction: column; }
.portal-header { position: sticky; top: 0; z-index: 10; display: flex; align-items: center; gap: 8px; background: #0b4da2; color: #fff; padding: 12px 16px; border-radius: 0 0 16px 16px; }
.portal-logo { width: 32px; height: 32px; object-fit: contain; }
.portal-name { font-weight: 800; font-size: 16px; flex: 1; }
.portal-avatar { cursor: pointer; background: #f9a825; color: #0b4da2; font-weight: 800; }
.portal-content { flex: 1; padding: 16px 12px 84px; }
.portal-nav { position: fixed; bottom: 0; left: 50%; transform: translateX(-50%); width: 100%; max-width: 640px; display: flex; background: #fff; border-top: 1px solid #eee; padding: 6px 0 calc(6px + env(safe-area-inset-bottom)); z-index: 10; }
.portal-nav-item { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 2px; font-size: 11px; color: #888; text-decoration: none; padding: 4px 0; }
.portal-nav-item.active { color: #0b4da2; font-weight: 700; }
.portal-nav-item :deep(.anticon) { font-size: 20px; }
</style>
