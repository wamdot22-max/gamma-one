<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Enrollments</a-typography-title>
      <a-space>
        <a-select v-model:value="classFilter" allow-clear show-search :options="classOptions" :filter-option="filterOption" placeholder="Filter kelas" style="width: 200px;" @change="refetch" />
        <a-button v-if="canCreate" type="primary" @click="openForm()">Daftarkan Siswa</a-button>
      </a-space>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <a-tag v-if="column.key === 'status'" :color="record.status === 'aktif' ? 'green' : 'default'">{{ record.status }}</a-tag>
        <a-space v-else-if="column.key === 'action'">
          <a-button v-if="canUpdate" size="small" @click="openForm(record)">Edit</a-button>
          <a-popconfirm v-if="canDelete" title="Hapus pendaftaran?" @confirm="remove(record.id)"><a-button size="small" danger>Hapus</a-button></a-popconfirm>
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Pendaftaran' : 'Daftarkan Siswa'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Siswa" required><a-select v-model:value="form.student_id" show-search :options="studentOptions" :filter-option="filterOption" placeholder="Pilih siswa" /></a-form-item>
        <a-form-item label="Kelas" required><a-select v-model:value="form.school_class_id" show-search :options="classOptions" :filter-option="filterOption" placeholder="Pilih kelas" /></a-form-item>
        <a-form-item label="Tanggal Daftar"><a-date-picker v-model:value="form.enrollment_date" value-format="YYYY-MM-DD" style="width: 100%;" /></a-form-item>
        <a-form-item label="Status"><a-select v-model:value="form.status" :options="['aktif', 'selesai', 'berhenti'].map((s) => ({ label: s, value: s }))" /></a-form-item>
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
const page = ref(1), open = ref(false), editing = ref(null), classFilter = ref(null)
const form = reactive({ student_id: null, school_class_id: null, enrollment_date: null, status: 'aktif' })
const columns = [
  { title: 'Siswa', key: 'student', customRender: ({ record }) => `${record.student?.name || '-'} (${record.student?.nis || '-'})` },
  { title: 'Kelas', key: 'class', customRender: ({ record }) => record.school_class?.name || record.schoolClass?.name || '-' },
  { title: 'Status', key: 'status' },
  { title: 'Aksi', key: 'action' },
]
const canCreate = computed(() => authStore.can('enrollments.create')), canUpdate = computed(() => authStore.can('enrollments.update')), canDelete = computed(() => authStore.can('enrollments.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['enrollments', classFilter.value, page.value]), queryFn: async () => (await api.get('/enrollments', { params: { school_class_id: classFilter.value, page: page.value } })).data.data })
const { data: students } = useQuery({ queryKey: ['students-options'], queryFn: async () => (await api.get('/students', { params: { per_page: 200 } })).data.data })
const { data: classes } = useQuery({ queryKey: ['classes-options'], queryFn: async () => (await api.get('/classes', { params: { per_page: 200 } })).data.data })
const studentOptions = computed(() => (students.value?.data || []).map((s) => ({ label: `${s.name} (${s.nis})`, value: s.id })))
const classOptions = computed(() => (classes.value?.data || []).map((c) => ({ label: c.name, value: c.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; Object.assign(form, { student_id: record?.student_id || null, school_class_id: record?.school_class_id || null, enrollment_date: record?.enrollment_date ? String(record.enrollment_date).slice(0, 10) : null, status: record?.status || 'aktif' }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/enrollments/${editing.value.id}`, form); else await api.post('/enrollments', form); open.value = false; refetch(); message.success('Pendaftaran tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Pendaftaran gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/enrollments/${id}`); refetch(); message.success('Pendaftaran dihapus') } catch { message.error('Pendaftaran gagal dihapus') } }
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
