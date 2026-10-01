<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Materi</a-typography-title>
      <a-space>
        <a-select v-model:value="classFilter" allow-clear show-search :options="classOptions" :filter-option="filterOption" placeholder="Semua kelas" style="width: 180px;" @change="refetch" />
        <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah Materi</a-button>
      </a-space>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <a-button v-if="column.key === 'file' && record.file_url" size="small" type="link" :href="record.file_url" target="_blank">Buka</a-button>
        <a-space v-else-if="column.key === 'action'">
          <RowActions :actions="[
            { key: 'edit', label: 'Edit', circle: true, show: canUpdate, handler: () => openForm(record) },
            { key: 'hapus', label: 'Hapus', show: canDelete, danger: true, confirm: 'Hapus materi?', handler: () => remove(record.id) },
          ]" />
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Materi' : 'Tambah Materi'" @ok="save" :confirm-loading="saving">
      <a-form layout="vertical">
        <a-form-item label="Kelas" required><a-select v-model:value="form.school_class_id" show-search :options="classOptions" :filter-option="filterOption" /></a-form-item>
        <a-form-item label="Judul" required><a-input v-model:value="form.title" /></a-form-item>
        <a-form-item label="Deskripsi"><a-textarea v-model:value="form.description" :rows="2" /></a-form-item>
        <a-form-item label="Berkas (PDF/gambar)"><a-upload :max-count="1" :before-upload="(f) => { pendingFile = f; return false }"><a-button>Unggah berkas</a-button></a-upload></a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import RowActions from '../../components/shared/RowActions.vue'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

const authStore = useAuthStore()
const page = ref(1), classFilter = ref(null), open = ref(false), editing = ref(null), saving = ref(false)
const pendingFile = ref(null)
const form = reactive({ school_class_id: null, title: '', description: '', file_url: '' })
const columns = [
  { title: 'Judul', dataIndex: 'title' },
  { title: 'Kelas', key: 'class', customRender: ({ record }) => record.school_class?.name || '-' },
  { title: 'Berkas', key: 'file' },
  { title: 'Aksi', key: 'action' },
]
const canCreate = computed(() => authStore.can('materials.create')), canUpdate = computed(() => authStore.can('materials.update')), canDelete = computed(() => authStore.can('materials.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['materials', classFilter.value, page.value]), queryFn: async () => (await api.get('/materials', { params: { school_class_id: classFilter.value, page: page.value } })).data.data })
const { data: classes } = useQuery({ queryKey: ['classes-options'], queryFn: async () => (await api.get('/classes', { params: { per_page: 200 } })).data.data })
const classOptions = computed(() => (classes.value?.data || []).map((c) => ({ label: c.name, value: c.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; pendingFile.value = null; Object.assign(form, { school_class_id: record?.school_class_id || null, title: record?.title || '', description: record?.description || '', file_url: record?.file_url || '' }); open.value = true }
async function save() {
  saving.value = true
  try {
    const payload = { ...form }
    if (pendingFile.value) {
      const formData = new FormData()
      formData.append('file', pendingFile.value)
      const { data } = await api.post('/files/upload', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
      payload.file_url = data.data.url
    }
    if (editing.value) await api.put(`/materials/${editing.value.id}`, payload); else await api.post('/materials', payload)
    open.value = false; refetch(); message.success('Materi tersimpan')
  } catch (e) { message.error(getApiErrorMessage(e, 'Materi gagal disimpan')) } finally { saving.value = false }
}
async function remove(id) { try { await api.delete(`/materials/${id}`); refetch(); message.success('Materi dihapus') } catch { message.error('Materi gagal dihapus') } }
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
