<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Gaji Tutor</a-typography-title>
      <a-date-picker v-model:value="month" picker="month" value-format="YYYY-MM" @change="refetch" />
    </a-space>
    <a-table row-key="tutor.id" :loading="isLoading" :data-source="data?.rows || []" :columns="columns" :pagination="false">
      <template #bodyCell="{ column, record }">
        <span v-if="column.key === 'fee' || column.key === 'total'">Rp {{ rupiah(record[column.key === 'fee' ? 'fee_per_session' : 'total']) }}</span>
        <a-button v-else-if="column.key === 'action'" size="small" @click="downloadSlip(record)">Slip PDF</a-button>
      </template>
    </a-table>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'

const month = ref(new Date().toISOString().slice(0, 7))
const columns = [
  { title: 'Tutor', key: 'name', customRender: ({ record }) => record.tutor?.name },
  { title: 'Sesi', dataIndex: 'sessions_count' },
  { title: 'Honor/Sesi', key: 'fee' },
  { title: 'Total', key: 'total' },
  { title: 'Aksi', key: 'action' },
]
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['payrolls', month.value]), queryFn: async () => (await api.get('/payrolls', { params: { month: month.value } })).data.data })
const rupiah = (n) => Number(n || 0).toLocaleString('id-ID')
async function downloadSlip(record) {
  try {
    const res = await api.get(`/payrolls/${record.tutor.id}/slip`, { params: { month: month.value }, responseType: 'blob' })
    const url = URL.createObjectURL(new Blob([res.data], { type: 'application/pdf' }))
    const a = document.createElement('a')
    a.href = url
    a.download = `slip-honor-${record.tutor.id}-${month.value}.pdf`
    a.click()
    URL.revokeObjectURL(url)
  } catch { message.error('Slip gagal diunduh') }
}
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
