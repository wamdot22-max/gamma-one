<template>
  <div>
    <a-space style="margin-bottom: 12px; width: 100%; justify-content: space-between">
      <h3 style="margin: 0">Menu Management</h3>
      <a-space>
        <a-input-search
          placeholder="Search menu..."
          allowClear
          v-model:value="qInput"
          style="width: 260px"
        />
        <a-button v-if="canCreate" type="primary" @click="openCreate">Tambah Menu</a-button>
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
        <template v-if="column.key === 'parent'">
          {{ record.parent?.name || '-' }}
        </template>
        <template v-else-if="column.key === 'active'">
          {{ record.is_active ? 'Yes' : 'No' }}
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a-button v-if="canUpdate" size="small" @click="openEdit(record)">Edit</a-button>
            <a-popconfirm v-if="canDelete" title="Hapus menu?" @confirm="remove(record.id)">
              <a-button size="small" danger>Hapus</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal
      v-model:open="open"
      :title="editing ? 'Edit Menu' : 'Tambah Menu'"
      @cancel="open = false"
    >
      <a-form :model="formState" layout="vertical" ref="formRef">
        <a-form-item name="name" label="Nama" :rules="[{ required: true }]">
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item name="path" label="Path">
          <a-input v-model:value="formState.path" placeholder="/menus" />
        </a-form-item>
        <a-form-item name="icon" label="Icon">
          <a-select
            showSearch
            allowClear
            :options="iconSelectOptions"
            placeholder="Pilih icon"
            optionFilterProp="value"
            v-model:value="formState.icon"
          />
        </a-form-item>
        <a-form-item name="parent_id" label="Parent Menu">
          <a-select allowClear showSearch optionFilterProp="label" :options="parentOptions" v-model:value="formState.parent_id" />
        </a-form-item>
        <a-form-item name="permission_name" label="Permission Name">
          <a-input v-model:value="formState.permission_name" placeholder="menus.view" />
        </a-form-item>
        <a-form-item name="sort_order" label="Sort Order">
          <a-input v-model:value="formState.sort_order" />
        </a-form-item>
        <a-form-item name="is_active" label="Active">
          <a-switch v-model:checked="formState.is_active" />
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
import { ref, reactive, computed, watch, h } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import * as AntIcons from '@ant-design/icons-vue'
import api from '../../api/client'
import useDebouncedValue from '../../hooks/useDebouncedValue'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'
import { iconOptions } from '../../iconOptions'
import ModalActionFooter from '../../components/shared/ModalActionFooter.vue'
import { formatPaginationTotal } from '../../utils/pagination'

const authStore = useAuthStore()
const canCreate = computed(() => authStore.can('menus.create'))
const canUpdate = computed(() => authStore.can('menus.update'))
const canDelete = computed(() => authStore.can('menus.delete'))

const open = ref(false)
const editing = ref(null)
const formRef = ref(null)
const submitting = ref(false)
const formState = reactive({
  name: '',
  path: '',
  icon: undefined,
  parent_id: undefined,
  permission_name: '',
  sort_order: '',
  is_active: true
})
const qInput = ref('')
const q = useDebouncedValue(qInput, 500)
const pagination = reactive({ current: 1, pageSize: 20 })

const columns = [
  { title: 'Nama', dataIndex: 'name' },
  { title: 'Path', dataIndex: 'path' },
  { title: 'Icon', dataIndex: 'icon' },
  { title: 'Parent', key: 'parent' },
  { title: 'Order', dataIndex: 'sort_order' },
  { title: 'Active', key: 'active' },
  { title: 'Aksi', key: 'action' }
]

const iconSelectOptions = computed(() => iconOptions.map(name => {
  const IconComp = AntIcons[name]
  return {
    value: name,
    label: h('div', { style: 'display: flex; align-items: center; gap: 8px;' }, [
      IconComp ? h(IconComp) : null,
      h('span', name)
    ])
  }
}))

watch(qInput, () => {
  pagination.current = 1
})

const { data, refetch, isLoading } = useQuery({
  queryKey: computed(() => ['menus', q.value, pagination.current, pagination.pageSize]),
  queryFn: async () => (await api.get('/menus', { params: { q: q.value, page: pagination.current, per_page: pagination.pageSize } })).data.data,
})

const { data: allMenus } = useQuery({
  queryKey: ['menus-all-for-parent'],
  queryFn: async () => (await api.get('/menus', { params: { per_page: 200 } })).data.data,
})

const rows = computed(() => data.value?.data || [])
const parentOptions = computed(() => (allMenus.value?.data || []).map(m => ({ value: m.id, label: m.name })))

const handleTableChange = (pag) => {
  pagination.current = pag.current
  pagination.pageSize = pag.pageSize
}

const openCreate = () => {
  editing.value = null
  Object.assign(formState, { name: '', path: '', icon: undefined, parent_id: undefined, permission_name: '', sort_order: '', is_active: true })
  if (formRef.value) formRef.value.clearValidate()
  open.value = true
}

const openEdit = (record) => {
  editing.value = record
  Object.assign(formState, {
    name: record.name,
    path: record.path,
    icon: record.icon,
    parent_id: record.parent_id,
    permission_name: record.permission_name,
    sort_order: record.sort_order,
    is_active: record.is_active
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
    values.is_active = values.is_active ?? true
    if (editing.value) await api.put(`/menus/${editing.value.id}`, values)
    else await api.post('/menus', values)
    message.success('Menu tersimpan')
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
    await api.delete(`/menus/${id}`)
    message.success('Menu dihapus')
    refetch()
  } catch (error) {
    message.error(getApiErrorMessage(error))
  }
}
</script>
