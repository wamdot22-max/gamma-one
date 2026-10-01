<template>
  <div class="auth-wrap">
    <a-card title="Atur ulang kata sandi" class="auth-card">
      <a-form layout="vertical" :model="form" @finish="submit">
        <a-form-item label="Email" name="email" :rules="[{ required: true, type: 'email', message: 'Email tidak valid' }]">
          <a-input v-model:value="form.email" autocomplete="username" />
        </a-form-item>
        <a-form-item label="Token" name="token" :rules="[{ required: true, message: 'Token wajib diisi' }]">
          <a-input v-model:value="form.token" placeholder="Token dari tautan reset" />
        </a-form-item>
        <a-form-item label="Kata sandi baru" name="password" :rules="[{ required: true, min: 8, message: 'Minimal 8 karakter' }]">
          <a-input-password v-model:value="form.password" autocomplete="new-password" />
        </a-form-item>
        <a-form-item label="Konfirmasi kata sandi" name="password_confirmation" :rules="[{ required: true, message: 'Konfirmasi wajib diisi' }]">
          <a-input-password v-model:value="form.password_confirmation" autocomplete="new-password" />
        </a-form-item>
        <a-button html-type="submit" type="primary" block :loading="loading">Simpan kata sandi</a-button>
        <div class="auth-back"><router-link to="/login">Kembali masuk</router-link></div>
      </a-form>
    </a-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'
import { message } from 'ant-design-vue'

const authStore = useAuthStore()
const route = useRoute()
const router = useRouter()
const loading = ref(false)
const form = reactive({
  email: route.query.email || '',
  token: route.query.token || '',
  password: '',
  password_confirmation: '',
})

const submit = async () => {
  loading.value = true
  try {
    await authStore.resetPassword({ ...form })
    message.success('Kata sandi diubah. Silakan masuk kembali.')
    router.replace('/login')
  } catch (error) {
    message.error(getApiErrorMessage(error, 'Reset gagal'))
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-wrap { min-height: 100vh; display: grid; place-items: center; background: linear-gradient(135deg, #0b4da2 0%, #1877c9 60%, #e8f1fb 100%); padding: 16px; }
.auth-card { width: 420px; max-width: 100%; border-radius: 16px; }
.auth-back { text-align: center; margin-top: 12px; }
</style>
