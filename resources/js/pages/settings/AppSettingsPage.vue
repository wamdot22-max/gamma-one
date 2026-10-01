<template>
  <div>
  <a-card title="Pengaturan Aplikasi">
    <a-form layout="vertical" :model="formState" ref="formRef">
      <a-form-item name="app_name" label="Nama Aplikasi" :rules="[{ required: true, message: 'Nama aplikasi wajib diisi' }]">
        <a-input v-model:value="formState.app_name" />
      </a-form-item>
      <a-form-item name="company_name" label="Nama Perusahaan">
        <a-input v-model:value="formState.company_name" />
      </a-form-item>

      <a-row :gutter="16">
        <a-col :xs="24" :lg="8">
          <a-form-item name="sidebar_logo_url" label="URL Logo Sidebar">
            <a-input v-model:value="formState.sidebar_logo_url" />
          </a-form-item>
          <a-form-item label="Upload Logo Sidebar">
            <a-upload :beforeUpload="handleSidebarUpload" :showUploadList="false">
              <a-button>
                <UploadOutlined /> Upload
              </a-button>
            </a-upload>
          </a-form-item>
          <img
            v-if="sidebarLogoPreview || formState.sidebar_logo_url"
            :src="sidebarLogoPreview || formState.sidebar_logo_url"
            alt="sidebar logo preview"
            class="app-settings-page__logo app-settings-page__logo--large"
          />
        </a-col>
        <a-col :xs="24" :lg="8">
          <a-form-item name="login_logo_url" label="URL Logo Login">
            <a-input v-model:value="formState.login_logo_url" />
          </a-form-item>
          <a-form-item label="Upload Logo Login">
            <a-upload :beforeUpload="handleLoginUpload" :showUploadList="false">
              <a-button>
                <UploadOutlined /> Upload
              </a-button>
            </a-upload>
          </a-form-item>
          <img
            v-if="loginLogoPreview || formState.login_logo_url"
            :src="loginLogoPreview || formState.login_logo_url"
            alt="login logo preview"
            class="app-settings-page__logo app-settings-page__logo--large"
          />
        </a-col>
        <a-col :xs="24" :lg="8">
          <a-form-item name="favicon_url" label="URL Favicon">
            <a-input v-model:value="formState.favicon_url" />
          </a-form-item>
          <a-form-item label="Upload Favicon">
            <a-upload :beforeUpload="handleFaviconUpload" :showUploadList="false">
              <a-button>
                <UploadOutlined /> Upload
              </a-button>
            </a-upload>
          </a-form-item>
          <img
            v-if="faviconPreview || formState.favicon_url"
            :src="faviconPreview || formState.favicon_url"
            alt="favicon preview"
            class="app-settings-page__logo app-settings-page__logo--small"
          />
        </a-col>
      </a-row>

      <a-space class="app-settings-page__actions">
        <a-button type="primary" :loading="saving" @click="submit">Simpan Pengaturan</a-button>
      </a-space>
    </a-form>
  </a-card>
  <a-card title="Profil Bimbel" class="profile-card">
    <a-form layout="vertical" :model="courseForm">
      <a-row :gutter="16">
        <a-col :xs="24" :lg="12"><a-form-item label="Nama Sekolah/Lembaga"><a-input v-model:value="courseForm.school_name" /></a-form-item></a-col>
        <a-col :xs="24" :lg="6"><a-form-item label="Tahun Ajaran"><a-input v-model:value="courseForm.academic_year" placeholder="2026/2027" /></a-form-item></a-col>
        <a-col :xs="24" :lg="6"><a-form-item label="Semester"><a-input v-model:value="courseForm.semester" placeholder="Ganjil" /></a-form-item></a-col>
        <a-col :xs="24" :lg="12"><a-form-item label="Telepon"><a-input v-model:value="courseForm.phone" /></a-form-item></a-col>
        <a-col :xs="24" :lg="12"><a-form-item label="Email"><a-input v-model:value="courseForm.email" /></a-form-item></a-col>
        <a-col :span="24"><a-form-item label="Alamat"><a-textarea v-model:value="courseForm.address" :rows="2" /></a-form-item></a-col>
        <a-col :xs="24" :lg="12"><a-form-item label="Jatuh tempo invoice (hari)"><a-input-number v-model:value="courseForm.invoice_due_days" :min="1" :max="60" style="width: 100%;" /></a-form-item></a-col>
      </a-row>
      <a-space class="app-settings-page__actions">
        <a-button type="primary" :loading="courseSaving" @click="saveCourse">Simpan Profil Bimbel</a-button>
      </a-space>
    </a-form>
  </a-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import { UploadOutlined } from '@ant-design/icons-vue'
import api from '../../api/client'
import { getApiErrorMessage } from '../../utils/apiError'
import { applyFavicon } from '../../utils/favicon'
import { useQueryClient } from '@tanstack/vue-query'

const formRef = ref(null)
const saving = ref(false)
const queryClient = useQueryClient()

// Pending file objects — uploaded only on submit
const pendingSidebarLogo = ref(null)
const pendingLoginLogo = ref(null)
const pendingFavicon = ref(null)

// Local object URL previews
const sidebarLogoPreview = ref(null)
const loginLogoPreview = ref(null)
const faviconPreview = ref(null)

function setPreview(fileRef, previewRef, file) {
  if (previewRef.value) URL.revokeObjectURL(previewRef.value)
  fileRef.value = file
  previewRef.value = URL.createObjectURL(file)
}

const formState = reactive({
  app_name: '',
  company_name: '',
  sidebar_logo_url: '',
  login_logo_url: '',
  favicon_url: '',
})

const courseSaving = ref(false)
const courseForm = reactive({
  school_name: '',
  address: '',
  phone: '',
  email: '',
  academic_year: '',
  semester: '',
  invoice_due_days: 7,
  description: '',
})

const applyPayloadToForm = (payload) => {
  if (!payload) return

  formState.app_name = payload.app_name || ''
  formState.company_name = payload.company_name || ''
  formState.sidebar_logo_url = payload.sidebar_logo_url || ''
  formState.login_logo_url = payload.login_logo_url || ''
  formState.favicon_url = payload.favicon_url || ''

  document.title = payload.app_name || 'Admin Template'
  applyFavicon(payload.favicon_url, payload.updated_at)
}

const { refetch } = useQuery({
  queryKey: ['app-settings'],
  queryFn: async () => {
    const payload = (await api.get('/app-settings')).data.data
    applyPayloadToForm(payload)
    return payload
  },
})

useQuery({
  queryKey: ['course-settings'],
  queryFn: async () => {
    const payload = (await api.get('/course-settings')).data.data
    Object.assign(courseForm, {
      school_name: payload.school_name || '',
      address: payload.address || '',
      phone: payload.phone || '',
      email: payload.email || '',
      academic_year: payload.academic_year || '',
      semester: payload.semester || '',
      invoice_due_days: payload.invoice_due_days || 7,
      description: payload.description || '',
    })
    return payload
  },
})

const saveCourse = async () => {
  courseSaving.value = true
  try {
    await api.put('/course-settings', { ...courseForm })
    message.success('Profil bimbel tersimpan')
  } catch (error) {
    message.error(getApiErrorMessage(error, 'Profil bimbel gagal disimpan'))
  } finally {
    courseSaving.value = false
  }
}

const uploadFile = async (file) => {
  const formData = new FormData()
  formData.append('file', file)
  const response = await api.post('/files/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })

  return response.data.data.url
}

const handleSidebarUpload = (file) => {
  setPreview(pendingSidebarLogo, sidebarLogoPreview, file)
  return false
}

const handleLoginUpload = (file) => {
  setPreview(pendingLoginLogo, loginLogoPreview, file)
  return false
}

const handleFaviconUpload = (file) => {
  setPreview(pendingFavicon, faviconPreview, file)
  return false
}

const submit = async () => {
  try {
    await formRef.value.validate()
    saving.value = true

    // Upload any pending files first
    if (pendingSidebarLogo.value) {
      try {
        formState.sidebar_logo_url = await uploadFile(pendingSidebarLogo.value)
        URL.revokeObjectURL(sidebarLogoPreview.value)
        sidebarLogoPreview.value = null
        pendingSidebarLogo.value = null
      } catch {
        message.error('Upload logo sidebar gagal')
        saving.value = false
        return
      }
    }

    if (pendingLoginLogo.value) {
      try {
        formState.login_logo_url = await uploadFile(pendingLoginLogo.value)
        URL.revokeObjectURL(loginLogoPreview.value)
        loginLogoPreview.value = null
        pendingLoginLogo.value = null
      } catch {
        message.error('Upload logo login gagal')
        saving.value = false
        return
      }
    }

    if (pendingFavicon.value) {
      try {
        formState.favicon_url = await uploadFile(pendingFavicon.value)
        URL.revokeObjectURL(faviconPreview.value)
        faviconPreview.value = null
        pendingFavicon.value = null
        applyFavicon(formState.favicon_url)
      } catch {
        message.error('Upload favicon gagal')
        saving.value = false
        return
      }
    }

    const payload = {
      app_name: formState.app_name,
      company_name: formState.company_name,
      sidebar_logo_url: formState.sidebar_logo_url || '',
      login_logo_url: formState.login_logo_url || '',
      favicon_url: formState.favicon_url || '',
    }

    const response = (await api.put('/app-settings', payload)).data.data
    applyPayloadToForm(response)
    await queryClient.invalidateQueries({ queryKey: ['app-settings-layout'] })
    await queryClient.invalidateQueries({ queryKey: ['app-settings-login'] })
    await queryClient.invalidateQueries({ queryKey: ['app-settings-portal'] })
    await queryClient.invalidateQueries({ queryKey: ['app-settings'] })
    message.success('Pengaturan aplikasi tersimpan')
    refetch()
  } catch (error) {
    if (error?.response) {
      message.error(getApiErrorMessage(error))
    }
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.app-settings-page__logo {
  display: block;
  object-fit: cover;
  border-radius: 10px;
  margin-bottom: 10px;
  border: 1px solid #e2e8f0;
}

.app-settings-page__logo--large {
  width: 80px;
  height: 80px;
}

.app-settings-page__logo--small {
  width: 32px;
  height: 32px;
  border-radius: 6px;
}

.app-settings-page__actions {
  justify-content: flex-end;
  width: 100%;
}

.profile-card {
  margin-top: 16px;
}
</style>
