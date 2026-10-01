<template>
  <div>
    <a-space style="margin-bottom: 12px; width: 100%; justify-content: space-between">
      <h3 style="margin: 0">Blamable Logs</h3>
      <a-space>
        <a-input-search
          allowClear
          v-model:value="qInput"
          placeholder="Cari model/user..."
          style="width: 240px"
        />
        <a-select
          allowClear
          placeholder="Action"
          :options="[
            { label: 'Created', value: 'created' },
            { label: 'Updated', value: 'updated' },
            { label: 'Deleted', value: 'deleted' },
          ]"
          style="width: 140px"
          v-model:value="action"
        />
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
        <template v-if="column.key === 'created_at'">
          {{ record.created_at ? new Date(record.created_at).toLocaleString('id-ID') : '-' }}
        </template>
        <template v-else-if="column.key === 'user'">
          {{ record.user?.name || record.user?.email || '-' }}
        </template>
        <template v-else-if="column.key === 'model_type'">
          {{ (record.model_type || '').split('\\').pop() || '-' }}
        </template>
        <template v-else-if="column.key === 'action_col'">
          <a-tag :color="record.action === 'created' ? 'green' : record.action === 'updated' ? 'blue' : 'red'">
            {{ record.action }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'detail'">
          <a-button size="small" @click="detail = record">Lihat</a-button>
        </template>
      </template>
    </a-table>

    <a-modal
      :open="!!detail"
      @cancel="detail = null"
      :footer="null"
      title="Detail Log"
      :width="900"
    >
      <div v-if="detail" style="display: grid; gap: 10px;">
        <div><strong>Action:</strong> {{ detail.action }}</div>
        <div><strong>Model:</strong> {{ detail.model_type }} #{{ detail.model_id }}</div>
        <div><strong>User:</strong> {{ detail.user?.name || detail.user?.email || '-' }}</div>
        <div>
          <strong>Old Values</strong>
          <pre style="background: #f5f5f5; padding: 12px; border-radius: 8px; max-height: 220px; overflow: auto;">
{{ JSON.stringify(detail.old_values || {}, null, 2) }}
          </pre>
        </div>
        <div>
          <strong>New Values</strong>
          <pre style="background: #f5f5f5; padding: 12px; border-radius: 8px; max-height: 220px; overflow: auto;">
{{ JSON.stringify(detail.new_values || {}, null, 2) }}
          </pre>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import api from '../../api/client'
import useDebouncedValue from '../../hooks/useDebouncedValue'
import { formatPaginationTotal } from '../../utils/pagination'

const qInput = ref('')
const q = useDebouncedValue(qInput, 500)
const action = ref(undefined)
const pagination = reactive({ current: 1, pageSize: 20 })
const detail = ref(null)

const columns = [
  { title: 'Waktu', key: 'created_at' },
  { title: 'User', key: 'user' },
  { title: 'Model', key: 'model_type' },
  { title: 'Model ID', dataIndex: 'model_id' },
  { title: 'Action', key: 'action_col' },
  { title: 'Detail', key: 'detail' }
]

watch([qInput, action], () => {
  pagination.current = 1
})

const { data, isLoading } = useQuery({
  queryKey: computed(() => ['blamable-logs', q.value, action.value, pagination.current, pagination.pageSize]),
  queryFn: async () => (
    await api.get('/blamable-logs', { params: { q: q.value, action: action.value, page: pagination.current, per_page: pagination.pageSize } })
  ).data.data,
})

const rows = computed(() => data.value?.data || [])

const handleTableChange = (pag) => {
  pagination.current = pag.current
  pagination.pageSize = pag.pageSize
}
</script>
