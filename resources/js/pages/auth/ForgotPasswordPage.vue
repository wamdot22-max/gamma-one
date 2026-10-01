<template>
  <div class="auth-wrap">
    <a-card title="Lupa kata sandi" class="auth-card">
      <div class="auth-desc">Masukkan email atau nomor HP akun Anda. Kami akan mengirimkan tautan reset bila data terdaftar.</div>
      <a-form layout="vertical" :model="form" @finish="submit">
        <a-form-item label="Email / No. HP" name="identity" :rules="[{ required: true, message: 'Email atau nomor HP wajib diisi' }]">
          <a-input v-model:value="form.identity" placeholder="nama@email.com atau 08xxxxxxxxxx" />
        </a-form-item>
        <a-button html-type="submit" type="primary" block :loading="loading">Kirim tautan reset</a-button>
        <div class="auth-back"><router-link to="/login">Kembali masuk</router-link></div>
      </a-form>
    </a-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'
import { message } from 'ant-design-vue'

const authStore = useAuthStore()
const loading = ref(false)
const form = reactive({ identity: '' })

const submit = async () => {
  loading.value = true
  try {
    await authStore.forgotPassword(form.identity)
    message.success('Jika data terdaftar, tautan reset akan dikirim.')
  } catch (error) {
    message.error(getApiErrorMessage(error, 'Gagal memproses permintaan'))
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-wrap { min-height: 100vh; display: grid; place-items: center; background: linear-gradient(135deg, #0b4da2 0%, #1877c9 60%, #e8f1fb 100%); padding: 16px; }
.auth-card { width: 420px; max-width: 100%; border-radius: 16px; }
.auth-desc { color: #666; margin-bottom: 16px; }
.auth-back { text-align: center; margin-top: 12px; }
</style>
