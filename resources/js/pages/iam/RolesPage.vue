<template>
  <div>
    <a-space style="margin-bottom: 12px; width: 100%; justify-content: space-between">
      <h3 style="margin: 0">Roles & Permissions</h3>
      <a-space>
        <a-input-search
          placeholder="Search role..."
          allowClear
          v-model:value="qInput"
          style="width: 230px"
        />
        <a-button v-if="canCreate" type="primary" @click="openCreate">Tambah</a-button>
      </a-space>
    </a-space>

    <a-table
      rowKey="id"
      :loading="isLoading"
      :dataSource="rows"
      :pagination="{
        current: data?.current_page || pagination.current,
        pageSize: data?.per_page || pagination.pageSize,
        total: data?.total || 0,
        showSizeChanger: true,
        showTotal: formatPaginationTotal,
      }"
      @change="handleTableChange"
      :columns="columns"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'permissions'">
          <a-tag v-for="p in (record.permissions || []).slice(0, 6)" :key="p.id">{{ p.name }}</a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a-button v-if="canUpdate" size="small" @click="openEdit(record)">Edit</a-button>
            <a-popconfirm v-if="canDelete" title="Hapus role?" @confirm="remove(record.id)">
              <a-button size="small" danger>Hapus</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal
      width="860px"
      v-model:open="open"
      :title="editing ? 'Edit Role' : 'Tambah Role'"
      @cancel="open = false"
    >
      <a-form :model="formState" layout="vertical" ref="formRef">
        <a-form-item name="name" label="Nama Role" :rules="[{ required: true }]">
          <a-input v-model:value="formState.name" />
        </a-form-item>

        <a-input
          placeholder="Cari permission di form ini..."
          v-model:value="permissionSearchInput"
          allowClear
          style="margin-bottom: 12px"
        />

        <a-form-item name="permissions" label="Permissions (grouped by permission-group)">
          <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 12px; width: 100%">
            <div v-for="group in filteredGroups" :key="group.id" style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 10px">
              <div style="font-weight: 600; margin-bottom: 8px">{{ group.name }}</div>
              <a-space direction="vertical">
                <a-checkbox
                  v-for="perm in group.permissions"
                  :key="perm.id"
                  :checked="formState.permissions.includes(perm.name)"
                  @change="togglePermission(perm.name, $event.target.checked)"
                >
                  {{ perm.name }}
                </a-checkbox>
              </a-space>
            </div>
          </div>
        </a-form-item>
      </a-form>

      <template #footer>
        <ModalActionFooter
          :confirmLoading="submitting"
          :confirmDisabled="submitting"
          :cancelDisabled="submitting"
          @cancel="open = false"
          @confirm="submit"
        />
      </template>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import useDebouncedValue from '../../hooks/useDebouncedValue'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'
import ModalActionFooter from '../../components/shared/ModalActionFooter.vue'
import { formatPaginationTotal } from '../../utils/pagination'

const authStore = useAuthStore()
const canCreate = computed(() => authStore.can('roles.create'))
const canUpdate = computed(() => authStore.can('roles.update'))
const canDelete = computed(() => authStore.can('roles.delete'))

const open = ref(false)
const editing = ref(null)
const formRef = ref(null)
const submitting = ref(false)
const formState = reactive({
  name: '',
  permissions: []
})
const qInput = ref('')
const q = useDebouncedValue(qInput, 500)
const permissionSearchInput = ref('')
const permissionSearch = useDebouncedValue(permissionSearchInput, 300)
const pagination = reactive({ current: 1, pageSize: 10 })

const columns = [
  { title: 'Role', dataIndex: 'name' },
  { title: 'Permissions', key: 'permissions' },
  { title: 'Aksi', key: 'action' }
]

watch(qInput, () => {
  pagination.current = 1
})

const { data, refetch, isLoading } = useQuery({
  queryKey: computed(() => ['roles', q.value, pagination.current, pagination.pageSize]),
  queryFn: async () => (await api.get('/roles', { params: { q: q.value, page: pagination.current, per_page: pagination.pageSize } })).data.data,
})

const { data: groupData } = useQuery({
  queryKey: ['permission-groups-with-permissions'],
  queryFn: async () => (await api.get('/permission-groups?with_permissions=1')).data.data,
})

const rows = computed(() => data.value?.data || [])
const groups = computed(() => groupData.value || [])

const filteredGroups = computed(() => {
  const search = permissionSearch.value.toLowerCase()
  return groups.value.map(group => {
    const filteredPerms = (group.permissions || []).filter(perm => !search || perm.name.toLowerCase().includes(search))
    if (filteredPerms.length === 0) return null
    return { ...group, permissions: filteredPerms }
  }).filter(Boolean)
})

const togglePermission = (permissionName, checked) => {
  if (checked) {
    if (!formState.permissions.includes(permissionName)) {
      formState.permissions = [...formState.permissions, permissionName]
    }
    return
  }

  formState.permissions = formState.permissions.filter(name => name !== permissionName)
}

const handleTableChange = (pag) => {
  pagination.current = pag.current
  pagination.pageSize = pag.pageSize
}

const openCreate = () => {
  editing.value = null
  Object.assign(formState, { name: '', permissions: [] })
  permissionSearchInput.value = ''
  if (formRef.value) formRef.value.clearValidate()
  open.value = true
}

const openEdit = (record) => {
  editing.value = record
  Object.assign(formState, {
    name: record.name,
    permissions: (record.permissions || []).map(p => p.name)
  })
  permissionSearchInput.value = ''
  if (formRef.value) formRef.value.clearValidate()
  open.value = true
}

const submit = async () => {
  try {
    if (submitting.value) return
    submitting.value = true
    await formRef.value.validate()
    const values = { ...formState }
    values.permissions = values.permissions || []
    if (editing.value) await api.put(`/roles/${editing.value.id}`, values)
    else await api.post('/roles', values)
    message.success('Role tersimpan')
    open.value = false
    permissionSearchInput.value = ''
    refetch()
  } catch (error) {
    if (error?.response) {
      message.error(getApiErrorMessage(error))
    }
  } finally {
    submitting.value = false
  }
}

const remove = async (id) => {
  try {
    await api.delete(`/roles/${id}`)
    message.success('Role dihapus')
    refetch()
  } catch (error) {
    message.error(getApiErrorMessage(error))
  }
}
</script>
