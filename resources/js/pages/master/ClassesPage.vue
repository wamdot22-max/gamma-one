<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Classes</a-typography-title>
      <a-input-search v-model:value="search" placeholder="Cari kelas..." allow-clear @search="refetch" />
      <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah</a-button>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <a-tag v-if="column.key === 'type'" :color="record.type === 'privat' ? 'gold' : 'blue'">{{ record.type }}</a-tag>
        <span v-else-if="column.key === 'filled'">{{ record.active_enrollments_count || 0 }} / {{ record.capacity }}</span>
        <a-space v-else-if="column.key === 'action'">
          <a-button v-if="canUpdate" size="small" @click="openForm(record)">Edit</a-button>
          <a-popconfirm v-if="canDelete" title="Hapus data?" @confirm="remove(record.id)"><a-button size="small" danger>Hapus</a-button></a-popconfirm>
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Kelas' : 'Tambah Kelas'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Nama Kelas" required><a-input v-model:value="form.name" /></a-form-item>
        <a-form-item label="Program" required><a-select v-model:value="form.program_id" show-search :options="programOptions" :filter-option="filterOption" placeholder="Pilih program" /></a-form-item>
        <a-form-item label="Mapel"><a-select v-model:value="form.subject_id" allow-clear show-search :options="subjectOptions" :filter-option="filterOption" placeholder="Pilih mapel" /></a-form-item>
        <a-form-item label="Tutor"><a-select v-model:value="form.tutor_id" allow-clear show-search :options="tutorOptions" :filter-option="filterOption" placeholder="Pilih tutor" /></a-form-item>
        <a-form-item label="Ruangan"><a-select v-model:value="form.room_id" allow-clear show-search :options="roomOptions" :filter-option="filterOption" placeholder="Pilih ruangan" /></a-form-item>
        <a-row :gutter="12">
          <a-col :span="12"><a-form-item label="Kapasitas"><a-input-number v-model:value="form.capacity" :min="0" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Tipe"><a-select v-model:value="form.type" :options="[{ label: 'Reguler', value: 'reguler' }, { label: 'Privat', value: 'privat' }]" /></a-form-item></a-col>
        </a-row>
        <a-form-item label="Deskripsi"><a-textarea v-model:value="form.description" :rows="2" /></a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

const authStore = useAuthStore()
const search = ref(''), page = ref(1), open = ref(false), editing = ref(null)
const form = reactive({ name: '', program_id: null, subject_id: null, tutor_id: null, room_id: null, capacity: 20, type: 'reguler', description: '' })
const columns = [
  { title: 'Nama', dataIndex: 'name', customRender: ({ record }) => record.name },
  { title: 'Program', key: 'program', customRender: ({ record }) => record.program?.name || '-' },
  { title: 'Tutor', key: 'tutor', customRender: ({ record }) => record.tutor?.name || '-' },
  { title: 'Terisi', key: 'filled' },
  { title: 'Tipe', key: 'type' },
  { title: 'Aksi', key: 'action' },
]
const canCreate = computed(() => authStore.can('classes.create')), canUpdate = computed(() => authStore.can('classes.update')), canDelete = computed(() => authStore.can('classes.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['classes', search.value, page.value]), queryFn: async () => (await api.get('/classes', { params: { q: search.value, page: page.value } })).data.data })
const useOptions = (endpoint, label = 'name') => {
  const { data } = useQuery({ queryKey: [endpoint + '-options'], queryFn: async () => (await api.get(`/${endpoint}`, { params: { per_page: 200 } })).data.data })
  return computed(() => (data.value?.data || []).map((i) => ({ label: i[label], value: i.id })))
}
const programOptions = useOptions('programs'), subjectOptions = useOptions('subjects'), tutorOptions = useOptions('tutors'), roomOptions = useOptions('rooms')
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; Object.assign(form, { name: record?.name || '', program_id: record?.program_id || record?.program?.id || null, subject_id: record?.subject_id || record?.subject?.id || null, tutor_id: record?.tutor_id || record?.tutor?.id || null, room_id: record?.room_id || record?.room?.id || null, capacity: record?.capacity ?? 20, type: record?.type || 'reguler', description: record?.description || '' }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/classes/${editing.value.id}`, form); else await api.post('/classes', form); open.value = false; refetch(); message.success('Data tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Data gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/classes/${id}`); refetch(); message.success('Data dihapus') } catch { message.error('Data gagal dihapus') } }
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
