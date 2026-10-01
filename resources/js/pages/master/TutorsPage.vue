<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Tutors</a-typography-title>
      <a-input-search v-model:value="search" placeholder="Cari tutor..." allow-clear @search="refetch" />
      <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah</a-button>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <span v-if="column.key === 'name'">{{ record.name }}<br v-if="!record.user_id || !record.school_classes_count" /><a-tag v-if="!record.user_id" color="orange">tanpa akun login</a-tag><a-tag v-if="!record.school_classes_count" color="blue">Cadangan</a-tag></span>
        <span v-if="column.key === 'fee'">Rp {{ Number(record.fee_per_session || 0).toLocaleString('id-ID') }}</span>
        <a-space v-else-if="column.key === 'subjects'" wrap><a-tag v-for="s in record.subjects" :key="s.id">{{ s.name }}</a-tag></a-space>
        <a-space v-else-if="column.key === 'action'">
          <a-button v-if="canUpdate" size="small" @click="openForm(record)">Edit</a-button>
          <a-popconfirm v-if="canDelete" title="Hapus data?" @confirm="remove(record.id)"><a-button size="small" danger>Hapus</a-button></a-popconfirm>
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Tutor' : 'Tambah Tutor'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Nama" required><a-input v-model:value="form.name" /></a-form-item>
        <a-form-item label="No. HP"><a-input v-model:value="form.phone" placeholder="08xxxxxxxxxx" /></a-form-item>
        <a-form-item label="Honor per Sesi (Rp)"><a-input-number v-model:value="form.fee_per_session" :min="0" style="width: 100%;" /></a-form-item>
        <a-form-item label="Mapel"><a-select v-model:value="form.subject_ids" mode="multiple" show-search :options="subjectOptions" :filter-option="filterOption" placeholder="Pilih mapel" /></a-form-item>
        <a-form-item label="Akun Login (opsional)"><a-select v-model:value="form.user_id" allow-clear show-search :options="userOptions" :filter-option="filterOption" placeholder="Pilih user" /></a-form-item>
        <a-form-item label="Bio"><a-textarea v-model:value="form.bio" :rows="2" /></a-form-item>
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
const form = reactive({ name: '', phone: '', fee_per_session: 0, subject_ids: [], user_id: null, bio: '' })
const columns = [{ title: 'Nama', dataIndex: 'name' }, { title: 'No. HP', dataIndex: 'phone' }, { title: 'Honor/Sesi', key: 'fee' }, { title: 'Mapel', key: 'subjects' }, { title: 'Aksi', key: 'action' }]
const canCreate = computed(() => authStore.can('tutors.create')), canUpdate = computed(() => authStore.can('tutors.update')), canDelete = computed(() => authStore.can('tutors.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['tutors', search.value, page.value]), queryFn: async () => (await api.get('/tutors', { params: { q: search.value, page: page.value } })).data.data })
const { data: users } = useQuery({ queryKey: ['users-options'], queryFn: async () => (await api.get('/users', { params: { per_page: 200 } })).data.data })
const { data: subjects } = useQuery({ queryKey: ['subjects-options'], queryFn: async () => (await api.get('/subjects', { params: { per_page: 200 } })).data.data })
const userOptions = computed(() => (users.value?.data || []).map((u) => ({ label: `${u.name} (${u.email})`, value: u.id })))
const subjectOptions = computed(() => (subjects.value?.data || []).map((s) => ({ label: s.name, value: s.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; Object.assign(form, { name: record?.name || '', phone: record?.phone || '', fee_per_session: record?.fee_per_session || 0, subject_ids: record?.subjects?.map((s) => s.id) || [], user_id: record?.user_id || null, bio: record?.bio || '' }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/tutors/${editing.value.id}`, form); else await api.post('/tutors', form); open.value = false; refetch(); message.success('Data tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Data gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/tutors/${id}`); refetch(); message.success('Data dihapus') } catch { message.error('Data gagal dihapus') } }
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
