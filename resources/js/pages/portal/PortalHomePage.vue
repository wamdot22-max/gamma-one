<template>
  <div>
    <a-card class="portal-welcome">
      <a-typography-title :level="4">Halo, {{ authStore.user?.name }}!</a-typography-title>
      <a-typography-paragraph>Selamat datang di <b>Gamma One</b> — One Step, One Growth. Menu Jadwal, Nilai, dan Tagihan akan aktif bertahap di fase berikutnya.</a-typography-paragraph>
      <a-space>
        <a-tag color="blue">{{ roleLabel }}</a-tag>
      </a-space>
    </a-card>
    <a-row :gutter="12" class="portal-grid">
      <a-col :span="12" v-for="menu in menus" :key="menu.path">
        <router-link :to="menu.path" class="portal-menu">
          <component :is="menu.icon" class="portal-menu-icon" />
          <span>{{ menu.label }}</span>
        </router-link>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { computed, h } from 'vue'
import { CalendarOutlined, TrophyOutlined, WalletOutlined, UserOutlined } from '@ant-design/icons-vue'
import { useAuthStore } from '../../stores/auth'

const authStore = useAuthStore()
const roleLabel = computed(() => authStore.roles[0] === 'orang_tua' ? 'Orang Tua' : 'Siswa')
const menus = computed(() => [
  { path: '/portal/jadwal', label: 'Jadwal', icon: () => h(CalendarOutlined) },
  { path: '/portal/nilai', label: 'Nilai', icon: () => h(TrophyOutlined) },
  { path: '/portal/tagihan', label: 'Tagihan', icon: () => h(WalletOutlined) },
  { path: '/portal/profil', label: 'Profil', icon: () => h(UserOutlined) },
])
</script>

<style scoped>
.portal-welcome { border-radius: 16px; background: linear-gradient(135deg, #0b4da2, #1877c9); color: #fff; }
.portal-welcome :deep(.ant-typography) { color: #fff; }
.portal-welcome :deep(.ant-typography-secondary), .portal-welcome :deep(p) { color: rgba(255, 255, 255, 0.85); }
.portal-grid { margin-top: 12px; row-gap: 12px; }
.portal-menu { display: flex; flex-direction: column; align-items: center; gap: 8px; background: #fff; border-radius: 16px; padding: 20px 8px; color: #0b4da2; font-weight: 700; text-decoration: none; }
.portal-menu-icon { font-size: 28px; }
</style>
