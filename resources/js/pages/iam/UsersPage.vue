<template>
  <div>
    <a-space class="toolbar"><a-typography-title :level="3">Users</a-typography-title><a-input-search v-model:value="search" placeholder="Cari user..." @search="refetch" /><a-button v-if="canCreate" type="primary" @click="openForm()">Tambah User</a-button></a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current"><template #bodyCell="{ column, record }"><a-space v-if="column.key === 'roles'"><a-tag v-for="role in record.roles" :key="role.id">{{ role.name }}</a-tag></a-space><a-space v-else-if="column.key === 'action'"><a-button v-if="canUpdate" size="small" @click="openForm(record)">Edit</a-button><a-popconfirm v-if="canDelete" title="Hapus user?" @confirm="remove(record.id)"><a-button size="small" danger>Hapus</a-button></a-popconfirm></a-space></template></a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit User' : 'Tambah User'" @ok="save"><a-form layout="vertical"><a-form-item label="Nama"><a-input v-model:value="form.name" /></a-form-item><a-form-item label="Email"><a-input v-model:value="form.email" /></a-form-item><a-form-item label="No. HP"><a-input v-model:value="form.phone" placeholder="08xxxxxxxxxx" /></a-form-item><a-form-item label="URL Avatar"><a-input v-model:value="form.avatar_url" /></a-form-item><a-form-item :label="editing ? 'Password baru (opsional)' : 'Password'"><a-input-password v-model:value="form.password" /></a-form-item><a-form-item label="Roles"><a-select v-model:value="form.roles" mode="multiple" :options="roleOptions" /></a-form-item></a-form></a-modal>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import { useAuthStore } from '../../stores/auth'

const authStore = useAuthStore()
const search = ref(''), page = ref(1), open = ref(false), editing = ref(null)
const form = reactive({ name: '', email: '', phone: '', avatar_url: '', password: '', roles: [] })
const columns = [{ title: 'Nama', dataIndex: 'name' }, { title: 'Email', dataIndex: 'email' }, { title: 'No. HP', dataIndex: 'phone' }, { title: 'Roles', key: 'roles' }, { title: 'Aksi', key: 'action' }]
const canCreate = computed(() => authStore.can('users.create')), canUpdate = computed(() => authStore.can('users.update')), canDelete = computed(() => authStore.can('users.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['users', search.value, page.value]), queryFn: async () => (await api.get('/users', { params: { q: search.value, page: page.value } })).data.data })
const { data: roles } = useQuery({ queryKey: ['roles-options'], queryFn: async () => (await api.get('/roles', { params: { per_page: 100 } })).data.data })
const roleOptions = computed(() => (roles.value?.data || []).map((role) => ({ label: role.name, value: role.name })))
function openForm(record = null) { editing.value = record; Object.assign(form, { name: record?.name || '', email: record?.email || '', phone: record?.phone || '', avatar_url: record?.avatar_url || '', password: '', roles: record?.roles?.map((role) => role.name) || [] }); open.value = true }
async function save() { try { const payload = { ...form }; if (editing.value && !payload.password) delete payload.password; if (editing.value) await api.put(`/users/${editing.value.id}`, payload); else await api.post('/users', payload); open.value = false; refetch(); message.success('User tersimpan') } catch { message.error('User gagal disimpan') } }
async function remove(id) { try { await api.delete(`/users/${id}`); refetch(); message.success('User dihapus') } catch { message.error('User gagal dihapus') } }
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>



