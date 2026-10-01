<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">{{ title }}</a-typography-title>
      <a-input-search v-model:value="search" placeholder="Cari data..." allow-clear @search="reload" />
      <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah</a-button>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :columns="columnsWithActions" :data-source="data?.data || []" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total, showSizeChanger: true }" @change="changePage">
      <template #bodyCell="{ column, record }">
        <a-space v-if="column.key === 'action'"><a-button v-if="canUpdate" size="small" @click="openForm(record)">Edit</a-button><a-popconfirm v-if="canDelete" title="Hapus data?" @confirm="remove(record.id)"><a-button size="small" danger>Hapus</a-button></a-popconfirm></a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit ' + title : 'Tambah ' + title" :confirm-loading="saving" @ok="submit">
      <a-form layout="vertical">
        <a-form-item v-for="field in fields" :key="field.name" :label="field.label" :required="field.required !== false && isRequired(field)">
          <a-textarea v-if="field.type === 'textarea'" v-model:value="form[field.name]" :rows="3" />
          <a-input-number v-else-if="field.type === 'number'" v-model:value="form[field.name]" style="width: 100%;" :min="field.min || 0" />
          <a-date-picker v-else-if="field.type === 'date'" v-model:value="form[field.name]" value-format="YYYY-MM-DD" style="width: 100%;" />
          <a-time-picker v-else-if="field.type === 'time'" v-model:value="form[field.name]" value-format="HH:mm" style="width: 100%;" />
          <a-switch v-else-if="field.type === 'switch'" v-model:checked="form[field.name]" />
          <a-select
            v-else-if="field.type === 'select'"
            v-model:value="form[field.name]"
            :mode="field.mode"
            :options="selectOptions(field)"
            :loading="selectLoading[field.name]"
            show-search
            allow-clear
            :filter-option="(input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())"
            style="width: 100%;"
            :placeholder="`Pilih ${field.label}`"
          />
          <a-upload
            v-else-if="field.type === 'upload'"
            :max-count="1"
            list-type="picture-card"
            :before-upload="(file) => beforeUpload(field.name, file)"
            @remove="() => removeUpload(field.name)"
          >
            <img v-if="form[field.name] && !pendingFiles[field.name]" :src="form[field.name]" alt="pratinjau" style="max-width: 100%; max-height: 100px; object-fit: contain;" />
            <div v-else><PlusOutlined /><div>Unggah</div></div>
          </a-upload>
          <a-input v-else v-model:value="form[field.name]" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import api from '../../api/client'
import { useAuthStore } from '../../stores/auth'

const props = defineProps({ title: String, endpoint: String, fields: { type: Array, default: () => [] }, columns: { type: Array, default: () => [] }, permissionPrefix: String })
const authStore = useAuthStore()
const search = ref('')
const page = ref(1)
const perPage = ref(10)
const open = ref(false)
const saving = ref(false)
const editing = ref(null)
const form = reactive({})
const pendingFiles = reactive({})
const selectCache = reactive({})
const selectLoading = reactive({})

const canCreate = computed(() => authStore.can(`${props.permissionPrefix}.create`))
const canUpdate = computed(() => authStore.can(`${props.permissionPrefix}.update`))
const canDelete = computed(() => authStore.can(`${props.permissionPrefix}.delete`))
const columnsWithActions = computed(() => props.columns.some((column) => column.key === 'action') ? [...props.columns] : [...props.columns, { title: 'Aksi', key: 'action' }])
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => [props.endpoint, search.value, page.value, perPage.value]), queryFn: async () => (await api.get(`/${props.endpoint}`, { params: { q: search.value, page: page.value, per_page: perPage.value } })).data.data })

watch(search, () => { page.value = 1 })

const isRequired = (field) => field.required === true
const defaultFor = (field) => {
  if (field.type === 'switch') return field.default ?? false
  if (field.type === 'number') return null
  if (field.type === 'select' && field.mode === 'multiple') return []
  return field.default ?? ''
}

function selectOptions(field) {
  if (field.options) return field.options
  if (!field.endpoint) return []
  if (!selectCache[field.name]) {
    selectLoading[field.name] = true
    api.get(`/${field.endpoint}`, { params: { per_page: 200 } })
      .then(({ data }) => {
        selectCache[field.name] = (data.data?.data || []).map((item) => ({ label: item[field.labelKey || 'name'], value: item[field.valueKey || 'id'] }))
      })
      .catch(() => { selectCache[field.name] = [] })
      .finally(() => { selectLoading[field.name] = false })
  }
  return selectCache[field.name] || []
}

function beforeUpload(name, file) {
  pendingFiles[name] = file
  return false
}

function removeUpload(name) {
  delete pendingFiles[name]
  form[name] = ''
}

function reload() { refetch() }
function changePage(pagination) { page.value = pagination.current; perPage.value = pagination.pageSize }
function openForm(record = null) {
  editing.value = record
  Object.keys(pendingFiles).forEach((key) => delete pendingFiles[key])
  props.fields.forEach((field) => {
    const raw = record?.[field.name]
    form[field.name] = raw ?? defaultFor(field)
  })
  open.value = true
}

async function submit() {
  saving.value = true
  try {
    const payload = { ...form }
    for (const field of props.fields) {
      if (field.type === 'upload' && pendingFiles[field.name]) {
        const formData = new FormData()
        formData.append('file', pendingFiles[field.name])
        const { data } = await api.post('/files/upload', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
        payload[field.name] = data.data.url
      }
      if (field.type === 'switch') payload[field.name] = !!payload[field.name]
    }
    if (editing.value) await api.put(`/${props.endpoint}/${editing.value.id}`, payload)
    else await api.post(`/${props.endpoint}`, payload)
    open.value = false
    refetch()
    message.success('Data tersimpan')
  } catch { message.error('Data gagal disimpan') } finally { saving.value = false }
}

async function remove(id) { try { await api.delete(`/${props.endpoint}/${id}`); refetch(); message.success('Data dihapus') } catch { message.error('Data gagal dihapus') } }
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
