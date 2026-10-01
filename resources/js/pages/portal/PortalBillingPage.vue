<template>
  <div>
    <div v-if="!invoices?.data?.length" class="p-empty">Tidak ada tagihan.</div>
    <div v-for="inv in (invoices?.data || [])" :key="inv.id" class="p-bill">
      <div class="p-bill-top">
        <div><div class="p-no">{{ inv.invoice_no }}</div><div class="p-class">{{ inv.school_class?.name || '' }} · {{ inv.period || '' }}</div></div>
        <a-tag :color="statusColor(inv.status)">{{ inv.status.replace('_', ' ') }}</a-tag>
      </div>
      <div class="p-amount">Rp {{ rupiah(inv.total - inv.paid_amount) }}</div>
      <div class="p-due">Jatuh tempo {{ dateFull(inv.due_date) }}</div>
      <a-button v-if="inv.status !== 'lunas'" class="p-pay" size="large" block :loading="paying === inv.id" @click="payNow(inv)">Bayar sekarang</a-button>
      <a-button block type="link" @click="openDetail(inv)">Riwayat & Kuitansi</a-button>
    </div>
    <a-modal v-model:open="detailOpen" title="Rincian Tagihan" :footer="null">
      <div v-if="detail">
        <div v-for="p in (detail.payments || [])" :key="p.id" class="p-row">
          <span>{{ dateFull(p.paid_at) }} · {{ p.method }}</span><b>Rp {{ rupiah(p.amount) }}</b>
        </div>
        <a-button block class="p-pay" @click="downloadReceipt">Unduh Kuitansi (PDF)</a-button>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import { getApiErrorMessage } from '../../utils/apiError'

const paying = ref(null), detailOpen = ref(false), detail = ref(null), detailId = ref(null)
const { data: invoices, refetch } = useQuery({ queryKey: ['portal-invoices'], queryFn: async () => (await api.get('/invoices', { params: { per_page: 50 } })).data.data })
const rupiah = (n) => Number(n || 0).toLocaleString('id-ID')
const dateFull = (d) => { try { return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' }) } catch { return d } }
const statusColor = (s) => ({ belum_bayar: 'red', sebagian: 'orange', lunas: 'green', terlambat: 'volcano' }[s] || 'default')

let snapLoaded = false
async function ensureSnap(clientKey, snapUrl) {
  if (window.snap) return
  if (!snapLoaded) {
    snapLoaded = true
    await new Promise((resolve, reject) => {
      const s = document.createElement('script')
      s.src = snapUrl
      s.setAttribute('data-client-key', clientKey)
      s.onload = resolve
      s.onerror = reject
      document.head.appendChild(s)
    })
  }
}
async function payNow(inv) {
  paying.value = inv.id
  try {
    const { data } = await api.post(`/invoices/${inv.id}/pay-link`)
    await ensureSnap(data.data.client_key, data.data.snap_url)
    window.snap.pay(data.data.token, { onSuccess: () => { message.success('Pembayaran berhasil'); refetch() }, onPending: () => { message.info('Menunggu pembayaran'); refetch() }, onError: () => message.error('Pembayaran gagal') })
  } catch (e) { message.error(getApiErrorMessage(e, 'Gagal membuat tautan bayar')) } finally { paying.value = null }
}
async function openDetail(inv) {
  detailId.value = inv.id
  detail.value = (await api.get(`/invoices/${inv.id}`)).data.data
  detailOpen.value = true
}
async function downloadReceipt() {
  const res = await api.get(`/invoices/${detailId.value}/receipt`, { responseType: 'blob' })
  const url = URL.createObjectURL(new Blob([res.data], { type: 'application/pdf' }))
  const a = document.createElement('a')
  a.href = url
  a.download = 'kuitansi.pdf'
  a.click()
  URL.revokeObjectURL(url)
}
</script>

<style scoped>
.p-empty { color: #aaa; text-align: center; margin-top: 24px; }
.p-bill { background: #fff; border-radius: 16px; padding: 14px; margin-bottom: 12px; }
.p-bill-top { display: flex; justify-content: space-between; align-items: flex-start; }
.p-no { font-weight: 800; }
.p-class { color: #888; font-size: 12px; }
.p-amount { font-size: 22px; font-weight: 800; color: #0b4da2; margin: 8px 0 2px; }
.p-due { color: #888; font-size: 12px; margin-bottom: 8px; }
.p-pay { background: #f9a825; border-color: #f9a825; color: #3d2c00; font-weight: 800; margin-bottom: 4px; }
.p-row { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #f0f0f0; }
</style>
