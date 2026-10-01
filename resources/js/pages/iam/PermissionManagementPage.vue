<template>
  <div>
    <a-space style="margin-bottom: 12px; width: 100%; justify-content: space-between">
      <h3 style="margin: 0">Permission Management</h3>
      <a-space>
        <a-input-search
          placeholder="Search permission..."
          allowClear
          v-model:value="qInput"
          style="width: 220px"
        />
        <a-select
          allowClear
          showSearch
          placeholder="Filter by role"
          :options="roleOptions"
          style="width: 220px"
          v-model:value="roleFilter"
        />
        <a-button type="primary" @click="openCreate">Tambah</a-button>
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
        <template v-if="column.key === 'roles'">
          <a-tag v-for="r in (record.roles || [])" :key="r.id">{{ r.name }}</a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a-button size="small" @click="openEdit(record)">Edit</a-button>
            <a-popconfirm title="Hapus permission?" @confirm="remove(record.id)">
              <a-button size="small" danger>Hapus</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal
      v-model:open="open"
      :title="editing ? 'Edit Permission' : 'Tambah Permission'"
      @cancel="open = false"
    >
      <a-form :model="formState" layout="vertical" ref="formRef">
        <a-form-item name="name" label="Permission Name" :rules="[{ required: true }]">
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item name="permission_group_id" label="Permission Group">
          <a-select allowClear showSearch :options="groupOptions" v-model:value="formState.permission_group_id" />
        </a-form-item>
        <a-form-item name="roles" label="Roles (by name)">
          <a-select mode="multiple" allowClear showSearch :options="roleOptions" v-model:value="formState.roles" />
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
import { getApiErrorMessage } from '../../utils/apiError'
import ModalActionFooter from '../../components/shared/ModalActionFooter.vue'
import { formatPaginationTotal } from '../../utils/pagination'

const open = ref(false)
const editing = ref(null)
const formRef = ref(null)
const submitting = ref(false)
const formState = reactive({
  name: '',
  permission_group_id: undefined,
  roles: []
})
const qInput = ref('')
const q = useDebouncedValue(qInput, 500)
const roleFilter = ref(undefined)
const pagination = reactive({ current: 1, pageSize: 20 })

const columns = [
  { title: 'Permission', dataIndex: 'name' },
  { title: 'Roles', key: 'roles' },
  { title: 'Aksi', key: 'action' }
]

watch([qInput, roleFilter], () => {
  pagination.current = 1
})

const { data, refetch, isLoading } = useQuery({
  queryKey: computed(() => ['permissions', q.value, roleFilter.value, pagination.current, pagination.pageSize]),
  queryFn: async () => (await api.get('/permissions', { params: { q: q.value, role: roleFilter.value, page: pagination.current, per_page: pagination.pageSize } })).data.data,
})

const { data: roleOptionsData } = useQuery({
  queryKey: ['permission-role-options'],
  queryFn: async () => (await api.get('/permissions-role-options')).data.data,
})

const { data: groupData } = useQuery({
  queryKey: ['permission-groups-for-perm'],
  queryFn: async () => (await api.get('/permission-groups', { params: { per_page: 200 } })).data.data,
})

const rows = computed(() => data.value?.data || [])
const roleOptions = computed(() => (roleOptionsData.value || []).map(r => ({ label: r.name, value: r.name })))
const groupOptions = computed(() => (groupData.value?.data || []).map(g => ({ label: g.name, value: g.id })))

const handleTableChange = (pag) => {
  pagination.current = pag.current
  pagination.pageSize = pag.pageSize
}

const openCreate = () => {
  editing.value = null
  Object.assign(formState, { name: '', permission_group_id: undefined, roles: [] })
  if (formRef.value) formRef.value.clearValidate()
  open.value = true
}

const openEdit = (record) => {
  editing.value = record
  Object.assign(formState, {
    name: record.name,
    permission_group_id: record.permission_group_id,
    roles: (record.roles || []).map(r => r.name)
  })
  if (formRef.value) formRef.value.clearValidate()
  open.value = true
}

const submit = async () => {
  try {
    if (submitting.value) return
    submitting.value = true
    await formRef.value.validate()
    const values = { ...formState }
    if (editing.value) await api.put(`/permissions/${editing.value.id}`, values)
    else await api.post('/permissions', values)
    message.success('Permission tersimpan')
    open.value = false
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
    await api.delete(`/permissions/${id}`)
    message.success('Permission dihapus')
    refetch()
  } catch (error) {
    message.error(getApiErrorMessage(error))
  }
}
</script>
