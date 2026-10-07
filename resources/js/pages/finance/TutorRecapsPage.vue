<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Rekap Tutor</a-typography-title>
      <a-space>
        <a-date-picker v-model:value="month" picker="month" value-format="YYYY-MM" @change="refetch" />
        <a-button @click="exportExcel">Ekspor Excel</a-button>
      </a-space>
    </a-space>
    <a-table row-key="tutor.id" :loading="isLoading" :data-source="data?.rows || []" :columns="columns" :pagination="false">
      <template #bodyCell="{ column, record }">
        <a-progress v-if="column.key === 'absensi'" :percent="record.absensi_persen" size="small" />
        <a-progress v-else-if="column.key === 'nilai'" :percent="record.nilai_persen" size="small" />
        <span v-else-if="column.key === 'honor'">Rp {{ rupiah(record.honor) }}</span>
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
  { title: 'Dijadwalkan', dataIndex: 'dijadwalkan' },
  { title: 'Selesai', dataIndex: 'selesai' },
  { title: 'Dibatalkan', dataIndex: 'dibatalkan' },
  { title: 'Menggantikan', dataIndex: 'menggantikan' },
  { title: '% Absensi', key: 'absensi' },
  { title: '% Nilai', key: 'nilai' },
  { title: 'Honor', key: 'honor' },
]
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['tutor-recaps', month.value]), queryFn: async () => (await api.get('/tutor-recaps', { params: { month: month.value } })).data.data })
const rupiah = (n) => Number(n || 0).toLocaleString('id-ID')
async function exportExcel() {
  try {
    const res = await api.get('/tutor-recaps/export', { params: { month: month.value }, responseType: 'blob' })
    const url = URL.createObjectURL(new Blob([res.data]))
    const a = document.createElement('a')
    a.href = url
    a.download = `rekap-tutor-${month.value}.xlsx`
    a.click()
    URL.revokeObjectURL(url)
  } catch { message.error('Ekspor gagal') }
}
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }</style>
