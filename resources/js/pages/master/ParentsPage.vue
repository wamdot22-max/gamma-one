<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Parents</a-typography-title>
      <a-input-search v-model:value="search" placeholder="Cari orang tua..." allow-clear @search="refetch" />
      <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah</a-button>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <a-space v-if="column.key === 'students'" wrap><a-tag v-for="s in record.students" :key="s.id">{{ s.name }}</a-tag></a-space>
        <a-space v-else-if="column.key === 'action'">
          <a-button v-if="canUpdate" size="small" @click="openForm(record)">Edit</a-button>
          <a-popconfirm v-if="canDelete" title="Hapus data?" @confirm="remove(record.id)"><a-button size="small" danger>Hapus</a-button></a-popconfirm>
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Orang Tua' : 'Tambah Orang Tua'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Nama" required><a-input v-model:value="form.name" /></a-form-item>
        <a-form-item label="No. HP"><a-input v-model:value="form.phone" placeholder="08xxxxxxxxxx" /></a-form-item>
        <a-form-item label="Alamat"><a-textarea v-model:value="form.address" :rows="2" /></a-form-item>
        <a-form-item label="Akun Login (opsional)"><a-select v-model:value="form.user_id" allow-clear show-search :options="userOptions" :filter-option="filterOption" placeholder="Pilih user" /></a-form-item>
        <a-form-item label="Anak"><a-select v-model:value="form.student_ids" mode="multiple" show-search :options="studentOptions" :filter-option="filterOption" placeholder="Pilih anak" /></a-form-item>
        <a-form-item label="Hubungan (berlaku untuk semua anak terpilih)"><a-select v-model:value="form.relationship" :options="['ayah', 'ibu', 'wali', 'lainnya'].map((r) => ({ label: r, value: r }))" /></a-form-item>
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
const form = reactive({ name: '', phone: '', address: '', user_id: null, student_ids: [], relationship: 'wali' })
const columns = [{ title: 'Nama', dataIndex: 'name' }, { title: 'No. HP', dataIndex: 'phone' }, { title: 'Anak', key: 'students' }, { title: 'Aksi', key: 'action' }]
const canCreate = computed(() => authStore.can('parents.create')), canUpdate = computed(() => authStore.can('parents.update')), canDelete = computed(() => authStore.can('parents.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['parents', search.value, page.value]), queryFn: async () => (await api.get('/parents', { params: { q: search.value, page: page.value } })).data.data })
const { data: users } = useQuery({ queryKey: ['users-options'], queryFn: async () => (await api.get('/users', { params: { per_page: 200 } })).data.data })
const { data: students } = useQuery({ queryKey: ['students-options'], queryFn: async () => (await api.get('/students', { params: { per_page: 200 } })).data.data })
const userOptions = computed(() => (users.value?.data || []).map((u) => ({ label: `${u.name} (${u.email})`, value: u.id })))
const studentOptions = computed(() => (students.value?.data || []).map((s) => ({ label: `${s.name} (${s.nis})`, value: s.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; Object.assign(form, { name: record?.name || '', phone: record?.phone || '', address: record?.address || '', user_id: record?.user_id || null, student_ids: record?.students?.map((s) => s.id) || [], relationship: record?.students?.[0]?.pivot?.relationship || 'wali' }); open.value = true }
async function save() {
  try {
    const payload = { name: form.name, phone: form.phone, address: form.address, user_id: form.user_id, students: form.student_ids.map((id) => ({ id, relationship: form.relationship })) }
    if (editing.value) await api.put(`/parents/${editing.value.id}`, payload); else await api.post('/parents', payload)
    open.value = false; refetch(); message.success('Data tersimpan')
  } catch (e) { message.error(getApiErrorMessage(e, 'Data gagal disimpan')) }
}
async function remove(id) { try { await api.delete(`/parents/${id}`); refetch(); message.success('Data dihapus') } catch { message.error('Data gagal dihapus') } }
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
