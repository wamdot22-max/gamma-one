<template>
  <a-card title="Profil saya" class="portal-card">
    <a-form layout="vertical" :model="form" @finish="save">
      <a-form-item label="Nama" name="name" :rules="[{ required: true, message: 'Nama wajib diisi' }]">
        <a-input v-model:value="form.name" />
      </a-form-item>
      <a-form-item label="Email" name="email" :rules="[{ required: true, type: 'email', message: 'Email tidak valid' }]">
        <a-input v-model:value="form.email" />
      </a-form-item>
      <a-form-item label="No. HP" name="phone">
        <a-input v-model:value="form.phone" placeholder="08xxxxxxxxxx" />
      </a-form-item>
      <a-form-item label="URL Avatar" name="avatar_url">
        <a-input v-model:value="form.avatar_url" />
      </a-form-item>
      <a-form-item label="Kata sandi baru (opsional)" name="password">
        <a-input-password v-model:value="form.password" autocomplete="new-password" />
      </a-form-item>
      <a-form-item label="Notifikasi WhatsApp" name="wa_enabled">
        <a-switch v-model:checked="pref.wa_enabled" />
      </a-form-item>
      <a-form-item label="Notifikasi Email" name="email_enabled">
        <a-switch v-model:checked="pref.email_enabled" />
      </a-form-item>
      <a-button html-type="submit" type="primary" block :loading="loading">Simpan profil</a-button>
      <a-button block danger ghost class="logout-btn" @click="logout">Keluar</a-button>
    </a-form>
  </a-card>
</template>

<script setup>
import { reactive, ref, watchEffect } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

const authStore = useAuthStore()
const router = useRouter()
const loading = ref(false)
const form = reactive({ name: '', email: '', phone: '', avatar_url: '', password: '' })
const pref = reactive({ wa_enabled: true, email_enabled: true })

watchEffect(() => {
  form.name = authStore.user?.name || ''
  form.email = authStore.user?.email || ''
  form.phone = authStore.user?.phone || ''
  form.avatar_url = authStore.user?.avatar_url || ''
})

api.get('/notification-preferences').then(({ data }) => Object.assign(pref, { wa_enabled: data.data.wa_enabled, email_enabled: data.data.email_enabled })).catch(() => {})

const save = async () => {
  loading.value = true
  try {
    const payload = { ...form }
    if (!payload.password) delete payload.password
    await api.put('/profile', payload)
    await api.put('/notification-preferences', { wa_enabled: pref.wa_enabled, email_enabled: pref.email_enabled })
    await authStore.refreshMe()
    message.success('Profil diperbarui')
  } catch (error) {
    message.error(getApiErrorMessage(error, 'Profil gagal diperbarui'))
  } finally {
    loading.value = false
  }
}

const logout = async () => {
  await authStore.logout()
  router.replace('/login')
}
</script>

<style scoped>
.portal-card { border-radius: 16px; }
.logout-btn { margin-top: 8px; }
</style>
