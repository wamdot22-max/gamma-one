<template>
  <div>
    <a-tabs v-model:active-key="tab">
      <a-tab-pane key="payments" tab="Pembayaran">
        <a-space class="toolbar">
          <a-typography-title :level="3">Pembayaran</a-typography-title>
          <a-button v-if="canCreate" type="primary" @click="openForm()">Catat Pembayaran</a-button>
        </a-space>
        <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
          <template #bodyCell="{ column, record }">
            <span v-if="column.key === 'amount'">Rp {{ rupiah(record.amount) }}</span>
            <a-tag v-else-if="column.key === 'method'">{{ record.method }}</a-tag>
            <a-button v-else-if="column.key === 'proof' && record.proof_url" size="small" type="link" :href="record.proof_url" target="_blank">Lihat</a-button>
            <a-popconfirm v-else-if="column.key === 'action'" title="Hapus pembayaran?" @confirm="remove(record.id)"><a-button size="small" danger>Batalkan</a-button></a-popconfirm>
          </template>
        </a-table>
      </a-tab-pane>
      <a-tab-pane key="reports" tab="Laporan Pemasukan">
        <a-space class="toolbar" wrap>
          <a-date-picker v-model:value="repFrom" value-format="YYYY-MM-DD" placeholder="Dari" />
          <a-date-picker v-model:value="repTo" value-format="YYYY-MM-DD" placeholder="Sampai" />
          <a-select v-model:value="repGroup" :options="[{ label: 'Harian', value: 'harian' }, { label: 'Bulanan', value: 'bulanan' }]" style="width: 120px;" />
          <a-button type="primary" @click="loadReport">Tampilkan</a-button>
          <a-button v-if="report" @click="exportReport">Ekspor Excel</a-button>
        </a-space>
        <a-statistic v-if="report" title="Total pemasukan" :value="`Rp ${rupiah(report.total)}`" class="report-total" />
        <a-table v-if="report" row-key="periode" :data-source="report.rows" :columns="repColumns" :pagination="false" />
      </a-tab-pane>
    </a-tabs>
    <a-modal v-model:open="open" title="Catat Pembayaran Manual" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Invoice" required><a-select v-model:value="form.invoice_id" show-search :options="invoiceOptions" :filter-option="filterOption" placeholder="Pilih invoice" /></a-form-item>
        <a-row :gutter="12">
          <a-col :span="12"><a-form-item label="Nominal (Rp)" required><a-input-number v-model:value="form.amount" :min="1000" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Metode" required><a-select v-model:value="form.method" :options="['tunai', 'transfer'].map((m) => ({ label: m, value: m }))" /></a-form-item></a-col>
        </a-row>
        <a-form-item label="Bukti transfer (opsional)"><a-upload :max-count="1" :before-upload="(f) => { proofFile = f; return false }"><a-button>Unggah bukti</a-button></a-upload></a-form-item>
        <a-form-item label="Catatan"><a-input v-model:value="form.notes" /></a-form-item>
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
const tab = ref('payments'), page = ref(1), open = ref(false)
const proofFile = ref(null)
const form = reactive({ invoice_id: null, amount: null, method: 'tunai', proof_url: '', notes: '' })
const repFrom = ref(null), repTo = ref(null), repGroup = ref('harian'), report = ref(null)
const columns = [
  { title: 'Invoice', key: 'invoice', customRender: ({ record }) => record.invoice?.invoice_no },
  { title: 'Nominal', key: 'amount' },
  { title: 'Metode', key: 'method' },
  { title: 'Tanggal', dataIndex: 'paid_at' },
  { title: 'Bukti', key: 'proof' },
  { title: 'Aksi', key: 'action' },
]
const repColumns = [{ title: 'Periode', dataIndex: 'periode' }, { title: 'Transaksi', dataIndex: 'transaksi' }, { title: 'Total (Rp)', key: 'total', customRender: ({ record }) => rupiah(record.total) }]
const canCreate = computed(() => authStore.can('payments.create'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['payments', page.value]), queryFn: async () => (await api.get('/payments', { params: { page: page.value } })).data.data })
const { data: invoices } = useQuery({ queryKey: ['invoices-options'], queryFn: async () => (await api.get('/invoices', { params: { per_page: 100 } })).data.data })
const invoiceOptions = computed(() => (invoices.value?.data || []).filter((i) => i.total > i.paid_amount).map((i) => ({ label: `${i.invoice_no} — Rp${rupiah(i.total - i.paid_amount)}`, value: i.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
const rupiah = (n) => Number(n || 0).toLocaleString('id-ID')
function openForm() { Object.assign(form, { invoice_id: null, amount: null, method: 'tunai', proof_url: '', notes: '' }); proofFile.value = null; open.value = true }
async function save() {
  try {
    if (proofFile.value) {
      const formData = new FormData()
      formData.append('file', proofFile.value)
      const { data } = await api.post('/files/upload', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
      form.proof_url = data.data.url
    }
    await api.post('/payments', form)
    open.value = false; refetch(); message.success('Pembayaran dicatat')
  } catch (e) { message.error(getApiErrorMessage(e, 'Pembayaran gagal dicatat')) }
}
async function remove(id) { try { await api.delete(`/payments/${id}`); refetch(); message.success('Pembayaran dibatalkan') } catch { message.error('Gagal membatalkan') } }
async function loadReport() {
  try {
    const { data } = await api.get('/reports/income', { params: { from_date: repFrom.value, to_date: repTo.value, group: repGroup.value } })
    report.value = data.data
  } catch (e) { message.error(getApiErrorMessage(e, 'Laporan gagal dimuat')) }
}
async function exportReport() {
  try {
    const res = await api.get('/reports/income-export', { params: { from_date: repFrom.value, to_date: repTo.value, group: repGroup.value }, responseType: 'blob' })
    const url = URL.createObjectURL(new Blob([res.data]))
    const a = document.createElement('a')
    a.href = url
    a.download = `laporan-pemasukan-${repGroup.value}.xlsx`
    a.click()
    URL.revokeObjectURL(url)
  } catch { message.error('Ekspor gagal') }
}
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }.report-total { margin-bottom: 12px; }</style>
