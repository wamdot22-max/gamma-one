<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Students</a-typography-title>
      <a-input-search v-model:value="search" placeholder="Cari NIS/nama..." allow-clear @search="refetch" />
      <a-space>
        <a-button v-if="canCreate" @click="importOpen = true">Impor Excel</a-button>
        <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah Siswa</a-button>
      </a-space>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <a-tag v-if="column.key === 'status'" :color="record.status === 'aktif' ? 'green' : 'orange'">{{ record.status }}</a-tag>
        <a-space v-else-if="column.key === 'action'">
          <a-button v-if="canUpdate" size="small" @click="openForm(record)">Edit</a-button>
          <a-popconfirm v-if="canDelete" title="Hapus siswa?" @confirm="remove(record.id)"><a-button size="small" danger>Hapus</a-button></a-popconfirm>
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Siswa' : 'Tambah Siswa'" width="640px" @ok="save">
      <a-form layout="vertical">
        <a-row :gutter="12">
          <a-col :span="12"><a-form-item label="NIS" required><a-input v-model:value="form.nis" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Nama" required><a-input v-model:value="form.name" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Jenis Kelamin"><a-select v-model:value="form.gender" allow-clear :options="[{ label: 'Laki-laki', value: 'L' }, { label: 'Perempuan', value: 'P' }]" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Tanggal Lahir"><a-date-picker v-model:value="form.birth_date" value-format="YYYY-MM-DD" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="No. HP"><a-input v-model:value="form.phone" placeholder="08xxxxxxxxxx" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Sekolah"><a-input v-model:value="form.school" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Status"><a-select v-model:value="form.status" :options="['aktif', 'cuti', 'lulus'].map((s) => ({ label: s, value: s }))" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Akun Login (opsional)"><a-select v-model:value="form.user_id" allow-clear show-search :options="userOptions" :filter-option="filterOption" placeholder="Pilih user" /></a-form-item></a-col>
        </a-row>
        <a-form-item label="Alamat"><a-textarea v-model:value="form.address" :rows="2" /></a-form-item>
      </a-form>
    </a-modal>
    <a-modal v-model:open="importOpen" title="Impor Siswa dari Excel/CSV" :footer="null">
      <div class="import-hint">Kolom: nis, name, gender, birth_date, phone, address, school.</div>
      <a-upload :before-upload="() => false" :max-count="1" v-model:file-list="fileList">
        <a-button>Pilih berkas (.xlsx/.csv)</a-button>
      </a-upload>
      <a-button type="primary" block class="import-btn" :loading="importing" @click="doImport">Unggah & Impor</a-button>
      <a-alert v-if="report" :message="`Berhasil ${report.imported} dari ${report.total} baris`" :type="report.failed.length ? 'warning' : 'success'" show-icon class="import-report" />
      <a-table v-if="report?.failed?.length" row-key="row" size="small" :data-source="report.failed" :columns="failColumns" :pagination="false" />
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
const importOpen = ref(false), importing = ref(false), fileList = ref([]), report = ref(null)
const form = reactive({ nis: '', name: '', gender: null, birth_date: null, phone: '', school: '', status: 'aktif', user_id: null, address: '' })
const columns = [{ title: 'NIS', dataIndex: 'nis' }, { title: 'Nama', dataIndex: 'name' }, { title: 'Sekolah', dataIndex: 'school' }, { title: 'No. HP', dataIndex: 'phone' }, { title: 'Status', key: 'status' }, { title: 'Aksi', key: 'action' }]
const failColumns = [{ title: 'Baris', dataIndex: 'row' }, { title: 'NIS', dataIndex: 'nis' }, { title: 'Galat', dataIndex: 'errors', customRender: ({ text }) => (text || []).join('; ') }]
const canCreate = computed(() => authStore.can('students.create')), canUpdate = computed(() => authStore.can('students.update')), canDelete = computed(() => authStore.can('students.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['students', search.value, page.value]), queryFn: async () => (await api.get('/students', { params: { q: search.value, page: page.value } })).data.data })
const { data: users } = useQuery({ queryKey: ['users-options'], queryFn: async () => (await api.get('/users', { params: { per_page: 200 } })).data.data })
const userOptions = computed(() => (users.value?.data || []).map((u) => ({ label: `${u.name} (${u.email})`, value: u.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; Object.assign(form, { nis: record?.nis || '', name: record?.name || '', gender: record?.gender || null, birth_date: record?.birth_date ? String(record.birth_date).slice(0, 10) : null, phone: record?.phone || '', school: record?.school || '', status: record?.status || 'aktif', user_id: record?.user_id || null, address: record?.address || '' }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/students/${editing.value.id}`, form); else await api.post('/students', form); open.value = false; refetch(); message.success('Siswa tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Siswa gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/students/${id}`); refetch(); message.success('Siswa dihapus') } catch { message.error('Siswa gagal dihapus') } }
async function doImport() {
  if (!fileList.value.length) { message.warning('Pilih berkas dulu'); return }
  importing.value = true
  try {
    const formData = new FormData()
    formData.append('file', fileList.value[0].originFileObj)
    const { data } = await api.post('/students/import', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
    report.value = data.data
    refetch()
    message.success(data.message)
  } catch (e) { message.error(getApiErrorMessage(e, 'Impor gagal')) } finally { importing.value = false }
}
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }.import-hint { color: #888; margin-bottom: 8px; }.import-btn { margin: 12px 0; }.import-report { margin-bottom: 8px; }</style>
