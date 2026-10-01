<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Invoices</a-typography-title>
      <a-space wrap>
        <a-select v-model:value="statusFilter" allow-clear :options="statusOptions" placeholder="Status" style="width: 140px;" @change="refetch" />
        <a-button v-if="canCreate" type="primary" @click="openForm()">Invoice Manual</a-button>
      </a-space>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <span v-if="column.key === 'student'">{{ record.student?.name }}<br /><small>{{ record.student?.nis }}</small></span>
        <span v-else-if="column.key === 'total'">Rp {{ rupiah(record.total) }}</span>
        <span v-else-if="column.key === 'remaining'">Rp {{ rupiah(record.total - record.paid_amount) }}</span>
        <a-tag v-else-if="column.key === 'status'" :color="statusColor(record.status)">{{ record.status.replace('_', ' ') }}</a-tag>
        <a-space v-else-if="column.key === 'action'" wrap>
          <RowActions :actions="[
            { key: 'kuitansi', label: 'Kuitansi', show: true, handler: () => downloadReceipt(record) },
            { key: 'edit', label: 'Edit', circle: true, show: canUpdate, handler: () => openForm(record) },
            { key: 'hapus', label: 'Hapus', show: canDelete, danger: true, confirm: 'Hapus invoice?', handler: () => remove(record.id) },
          ]" />
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Invoice' : 'Invoice Manual'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Siswa" required><a-select v-model:value="form.student_id" show-search :options="studentOptions" :filter-option="filterOption" :disabled="!!editing" /></a-form-item>
        <a-alert v-if="editing && editing.source === 'otomatis'" message="Invoice otomatis: hanya diskon, jatuh tempo, dan catatan yang bisa diubah." type="info" show-icon class="auto-note" />
        <a-row :gutter="12">
          <a-col :span="8"><a-form-item label="Biaya (Rp)" required><a-input-number v-model:value="form.amount" :min="0" style="width: 100%;" :disabled="editing && editing.source === 'otomatis'" /></a-form-item></a-col>
          <a-col :span="8"><a-form-item label="Diskon (Rp)"><a-input-number v-model:value="form.discount" :min="0" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="8"><a-form-item label="Pendaftaran (Rp)"><a-input-number v-model:value="form.registration_fee" :min="0" style="width: 100%;" :disabled="editing && editing.source === 'otomatis'" /></a-form-item></a-col>
        </a-row>
        <a-form-item label="Jatuh tempo" required><a-date-picker v-model:value="form.due_date" value-format="YYYY-MM-DD" style="width: 100%;" /></a-form-item>
        <a-form-item label="Catatan"><a-textarea v-model:value="form.notes" :rows="2" /></a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import RowActions from '../../components/shared/RowActions.vue'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

const authStore = useAuthStore()
const page = ref(1), open = ref(false), editing = ref(null), statusFilter = ref(null)
const form = reactive({ student_id: null, amount: 0, discount: 0, registration_fee: 0, due_date: null, notes: '' })
const statusOptions = ['belum_bayar', 'sebagian', 'lunas', 'terlambat'].map((s) => ({ label: s.replace('_', ' '), value: s }))
const columns = [
  { title: 'No. Invoice', dataIndex: 'invoice_no' },
  { title: 'Siswa', key: 'student' },
  { title: 'Periode', dataIndex: 'period' },
  { title: 'Total', key: 'total' },
  { title: 'Sisa', key: 'remaining' },
  { title: 'Status', key: 'status' },
  { title: 'Aksi', key: 'action' },
]
const canCreate = computed(() => authStore.can('invoices.create')), canUpdate = computed(() => authStore.can('invoices.update')), canDelete = computed(() => authStore.can('invoices.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['invoices', statusFilter.value, page.value]), queryFn: async () => (await api.get('/invoices', { params: { status: statusFilter.value, page: page.value } })).data.data })
const { data: students } = useQuery({ queryKey: ['students-options'], queryFn: async () => (await api.get('/students', { params: { per_page: 200 } })).data.data })
const studentOptions = computed(() => (students.value?.data || []).map((s) => ({ label: `${s.name} (${s.nis})`, value: s.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
const rupiah = (n) => Number(n || 0).toLocaleString('id-ID')
const statusColor = (s) => ({ belum_bayar: 'red', sebagian: 'orange', lunas: 'green', terlambat: 'volcano' }[s] || 'default')
function openForm(record = null) { editing.value = record; Object.assign(form, { student_id: record?.student_id || null, amount: record?.amount || 0, discount: record?.discount || 0, registration_fee: record?.registration_fee || 0, due_date: record?.due_date ? String(record.due_date).slice(0, 10) : null, notes: record?.notes || '' }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/invoices/${editing.value.id}`, form); else await api.post('/invoices', form); open.value = false; refetch(); message.success('Invoice tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Invoice gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/invoices/${id}`); refetch(); message.success('Invoice dihapus') } catch { message.error('Invoice gagal dihapus') } }
async function downloadReceipt(record) {
  try {
    const res = await api.get(`/invoices/${record.id}/receipt`, { responseType: 'blob' })
    const url = URL.createObjectURL(new Blob([res.data], { type: 'application/pdf' }))
    const a = document.createElement('a')
    a.href = url
    a.download = `kuitansi-${record.invoice_no.replaceAll('/', '-')}.pdf`
    a.click()
    URL.revokeObjectURL(url)
  } catch { message.error('Kuitansi gagal diunduh') }
}
</script>

<style scoped>.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }.auto-note { margin-bottom: 12px; }</style>
