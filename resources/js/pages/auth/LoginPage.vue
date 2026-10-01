<template>
  <div class="login-wrap">
    <a-card class="login-card" :bordered="false">
      <a-row :gutter="0">
        <a-col :xs="0" :sm="10" class="login-side">
          <img v-if="appSettings?.login_logo_url" :src="appSettings.login_logo_url" alt="Gamma One" class="login-logo" />
          <div class="login-brand">Gamma One</div>
          <div class="login-tagline">One Step, One Growth.</div>
          <div class="login-desc">Sistem informasi bimbel: jadwal, kehadiran, nilai, dan tagihan dalam satu genggaman.</div>
        </a-col>
        <a-col :xs="24" :sm="14" class="login-form-col">
          <a-typography-title :level="3" class="login-title">{{ appSettings?.app_name || 'Gamma One' }}</a-typography-title>
          <div class="login-subtitle">Masuk untuk melanjutkan</div>
          <a-form layout="vertical" :model="formState" @finish="submit" autocomplete="on" name="login_form">
            <a-form-item label="Email / No. HP" name="identity" :rules="[{ required: true, message: 'Email atau nomor HP wajib diisi' }]">
              <a-input v-model:value="formState.identity" placeholder="nama@email.com atau 08xxxxxxxxxx" autocomplete="username" />
            </a-form-item>
            <a-form-item label="Kata Sandi" name="password" :rules="[{ required: true, message: 'Kata sandi wajib diisi' }]">
              <a-input-password v-model:value="formState.password" autocomplete="current-password" />
            </a-form-item>
            <a-form-item>
              <div class="login-row">
                <a-checkbox v-model:checked="formState.remember">Tetap masuk</a-checkbox>
                <router-link to="/forgot-password">Lupa kata sandi?</router-link>
              </div>
            </a-form-item>
            <a-button html-type="submit" type="primary" block :loading="loading">Masuk</a-button>
          </a-form>
        </a-col>
      </a-row>
    </a-card>
  </div>
</template>

<script setup>
import { reactive, ref, watchEffect } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import { useQuery } from '@tanstack/vue-query'
import api from '../../api/client'
import { getApiErrorMessage } from '../../utils/apiError'
import { applyFavicon } from '../../utils/favicon'
import { message } from 'ant-design-vue'

const authStore = useAuthStore()
const router = useRouter()
const loading = ref(false)

const { data: appSettings } = useQuery({
  queryKey: ['app-settings-login'],
  queryFn: async () => (await api.get('/app-settings')).data.data,
})

watchEffect(() => {
  const appName = appSettings.value?.app_name || 'Gamma One'
  document.title = `${appName} Masuk`
  applyFavicon(appSettings.value?.favicon_url, appSettings.value?.updated_at)
})

const formState = reactive({
  identity: '',
  password: '',
  remember: false,
})

const submit = async () => {
  loading.value = true
  try {
    await authStore.login(formState.identity, formState.password, formState.remember)
    router.replace(authStore.homePath)
  } catch (error) {
    message.error(getApiErrorMessage(error, 'Login gagal'))
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-wrap {
  min-height: 100vh;
  display: grid;
  place-items: center;
  background: linear-gradient(135deg, #0b4da2 0%, #1877c9 60%, #e8f1fb 100%);
  padding: 16px;
}
.login-card {
  width: 720px;
  max-width: 100%;
  border-radius: 16px;
  overflow: hidden;
}
.login-side {
  background: #0b4da2;
  color: #fff;
  padding: 40px 32px !important;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.login-logo {
  max-width: 120px;
  max-height: 80px;
  object-fit: contain;
  margin-bottom: 16px;
}
.login-brand {
  font-size: 28px;
  font-weight: 800;
}
.login-tagline {
  font-size: 16px;
  font-weight: 700;
  color: #f9a825;
  margin: 4px 0 12px;
}
.login-desc {
  font-size: 14px;
  opacity: 0.85;
}
.login-form-col {
  padding: 32px !important;
}
.login-title {
  margin-bottom: 0 !important;
}
.login-subtitle {
  color: #666;
  margin-bottom: 16px;
}
.login-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
