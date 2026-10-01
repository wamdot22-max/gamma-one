<template>
  <a-layout class="app-layout">
    <a-layout-sider v-model:collapsed="collapsed" :trigger="null" collapsible :width="260" :collapsed-width="80" breakpoint="md" class="sider">
      <div class="brand" :class="{ 'brand--collapsed': collapsed }">
        <img v-if="appSettings?.sidebar_logo_url" :src="appSettings.sidebar_logo_url" alt="logo" class="brand-logo" />
        <span v-if="!collapsed" class="brand-name">{{ appSettings?.app_name || 'Gamma One' }}</span>
        <a-button type="text" class="brand-toggle" @click="collapsed = !collapsed">
          <MenuFoldOutlined v-if="!collapsed" /><MenuUnfoldOutlined v-else />
        </a-button>
      </div>
      <div v-if="!collapsed" class="menu-search">
        <a-input v-model:value="menuQuery" placeholder="Cari menu..." allow-clear>
          <template #prefix><SearchOutlined /></template>
        </a-input>
      </div>
      <a-menu theme="dark" mode="inline" :selectedKeys="[route.path]" :openKeys="openKeys" :items="filteredMenus" @click="onMenuClick" @openChange="(keys) => { openKeys = keys }" class="menu" />
    </a-layout-sider>
    <a-layout>
      <a-layout-header class="header">
        <a-dropdown trigger="click">
          <a-space class="profile"><a-avatar :src="authStore.user?.avatar_url">{{ authStore.user?.name?.charAt(0) }}</a-avatar><span>{{ authStore.user?.name }}</span></a-space>
          <template #overlay>
            <a-menu @click="handleUserMenu">
              <a-menu-item key="profile">Edit Profil</a-menu-item>
              <a-menu-item key="logout">Logout</a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
      </a-layout-header>
      <a-layout-content class="content"><router-view /></a-layout-content>
    </a-layout>
      <a-modal v-model:open="profileOpen" title="Edit Profil" @ok="saveProfile">
      <a-form layout="vertical" :model="profile"><a-form-item label="Nama"><a-input v-model:value="profile.name" /></a-form-item><a-form-item label="Email"><a-input v-model:value="profile.email" /></a-form-item><a-form-item label="No. HP"><a-input v-model:value="profile.phone" placeholder="08xxxxxxxxxx" /></a-form-item><a-form-item label="URL Avatar"><a-input v-model:value="profile.avatar_url" /></a-form-item><a-form-item label="Password baru (opsional)"><a-input-password v-model:value="profile.password" /></a-form-item><a-form-item label="Notifikasi WhatsApp"><a-switch v-model:checked="notifPref.wa_enabled" /></a-form-item><a-form-item label="Notifikasi Email"><a-switch v-model:checked="notifPref.email_enabled" /></a-form-item></a-form>
    </a-modal>
  </a-layout>
</template>

<script setup>
import { computed, reactive, ref, watchEffect } from 'vue'
import { h } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import * as AntIcons from '@ant-design/icons-vue'
import { MenuFoldOutlined, MenuUnfoldOutlined, SearchOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../api/client'
import { useAuthStore } from '../stores/auth'
import { applyFavicon } from '../utils/favicon'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const collapsed = ref(false)
const profileOpen = ref(false)
const profile = reactive({ name: '', email: '', phone: '', avatar_url: '', password: '' })
const notifPref = reactive({ wa_enabled: true, email_enabled: true })
const menuQuery = ref('')
const openKeys = ref([])

const { data: sidebarData } = useQuery({ queryKey: ['sidebar-menu'], queryFn: async () => (await api.get('/menus/sidebar')).data.data })
const { data: appSettings } = useQuery({ queryKey: ['app-settings-layout'], queryFn: async () => (await api.get('/app-settings')).data.data })

watchEffect(() => {
  document.title = appSettings.value?.app_name || 'Gamma One'
  applyFavicon(appSettings.value?.favicon_url, appSettings.value?.updated_at)
})

const toItems = (menus) => (menus || []).map(function map(menu) {
  const Icon = AntIcons[menu.icon]
  return { key: menu.path || `menu-${menu.id}`, label: menu.name, icon: Icon ? () => h(Icon) : null, children: menu.children?.length ? menu.children.map(map) : undefined }
})

const allMenus = computed(() => toItems(sidebarData.value))

const filteredMenus = computed(() => {
  const query = menuQuery.value.trim().toLowerCase()
  if (!query) return allMenus.value
  const filter = (items) => items
    .map((item) => ({ ...item, children: item.children ? filter(item.children) : undefined }))
    .filter((item) => String(item.label).toLowerCase().includes(query) || (item.children?.length))
  return filter(allMenus.value)
})

watchEffect(() => {
  if (!menuQuery.value.trim()) return
  const keys = []
  const collect = (items) => items.forEach((item) => {
    if (item.children?.length) {
      keys.push(item.key)
      collect(item.children)
    }
  })
  collect(filteredMenus.value)
  openKeys.value = keys
})

function onMenuClick({ key }) {
  if (String(key).startsWith('menu-')) return
  router.push(key)
}

function handleUserMenu({ key }) {
  if (key === 'logout') return authStore.logout().then(() => router.replace('/login'))
  Object.assign(profile, { name: authStore.user?.name || '', email: authStore.user?.email || '', phone: authStore.user?.phone || '', avatar_url: authStore.user?.avatar_url || '', password: '' })
  api.get('/notification-preferences').then(({ data }) => Object.assign(notifPref, { wa_enabled: data.data.wa_enabled, email_enabled: data.data.email_enabled })).catch(() => {})
  profileOpen.value = true
}

async function saveProfile() {
  try {
    const payload = { ...profile }
    if (!payload.password) delete payload.password
    await api.put('/profile', payload)
    await api.put('/notification-preferences', { wa_enabled: notifPref.wa_enabled, email_enabled: notifPref.email_enabled })
    await authStore.refreshMe()
    profileOpen.value = false
    message.success('Profil diperbarui')
  } catch { message.error('Profil gagal diperbarui') }
}
</script>

<style scoped>
.app-layout { min-height: 100vh; }
.sider { background: #0a1c30; }
.sider :deep(.ant-layout-sider-children) { display: flex; flex-direction: column; }
.brand { min-height: 64px; display: flex; align-items: center; gap: 8px; padding: 12px 16px; }
.brand--collapsed { flex-direction: column; justify-content: center; gap: 4px; padding: 12px 0; }
.brand--collapsed .brand-toggle { width: 100%; display: flex; justify-content: center; }
.brand-logo { width: 32px; height: 32px; object-fit: contain; flex-shrink: 0; }
.brand-name { color: #fff; font-size: 17px; font-weight: 800; flex: 1; white-space: nowrap; overflow: hidden; }
.brand-toggle { color: rgba(255, 255, 255, 0.65); flex-shrink: 0; }
.brand-toggle:hover { color: #fff; background: rgba(255, 255, 255, 0.1); }
.menu-search { padding: 0 16px 12px; }
.menu-search :deep(.ant-input-affix-wrapper) { background: rgba(255, 255, 255, 0.08); border-color: transparent; border-radius: 8px; }
.menu-search :deep(.ant-input-affix-wrapper input) { background: transparent; color: #fff; }
.menu-search :deep(.ant-input-affix-wrapper input::placeholder) { color: rgba(255, 255, 255, 0.4); }
.menu-search :deep(.anticon) { color: rgba(255, 255, 255, 0.4); }
.menu { background: transparent; flex: 1; overflow-y: auto; border-inline-end: none; }
.menu :deep(.ant-menu-item-selected) { background-color: #1877c9; border-radius: 8px; }
.menu :deep(.ant-menu-submenu-selected > .ant-menu-submenu-title) { color: #fff; }
.header { display: flex; justify-content: flex-end; align-items: center; background: #fff; padding: 0 24px; }
.profile { cursor: pointer; }
.content { margin: 16px; padding: 24px; background: #fff; border-radius: 8px; }
</style>
