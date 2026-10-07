<template>
  <div>
    <a-tabs v-model:active-key="tab">
      <a-tab-pane key="sessions" tab="Sesi">
        <a-space class="toolbar">
          <a-typography-title :level="3">Sesi & Absensi</a-typography-title>
          <a-space wrap>
            <a-select v-model:value="classFilter" allow-clear show-search :options="classOptions" :filter-option="filterOption" placeholder="Semua kelas" style="width: 180px;" @change="refetch" />
            <a-select v-model:value="statusFilter" allow-clear :options="['terjadwal', 'selesai', 'dibatalkan'].map((s) => ({ label: s, value: s }))" placeholder="Status" style="width: 130px;" @change="refetch" />
            <a-select v-model:value="roleFilter" :options="[{ label: 'Semua sesi', value: 'all' }, { label: 'Yang saya gantikan', value: 'sub' }]" style="width: 170px;" @change="refetch" />
            <a-button v-if="canCreate" type="primary" @click="genOpen = true">Generate Sesi</a-button>
          </a-space>
        </a-space>
        <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
          <template #bodyCell="{ column, record }">
            <span v-if="column.key === 'when'">{{ dateShort(record.session_date) }}<br />{{ short(record.start_time) }}–{{ short(record.end_time) }}</span>
            <span v-else-if="column.key === 'class'">{{ record.school_class?.name || '-' }}<br v-if="record.substitute" /><a-tag v-if="record.substitute" color="purple">pengganti: {{ record.substitute.name }}</a-tag></span>
            <a-tag v-if="column.key === 'status'" :color="statusColor(record.status)">{{ record.status }}</a-tag>
            <span v-else-if="column.key === 'filled'">{{ record.attendances_count || 0 }}</span>            <a-space v-else-if="column.key === 'action'" wrap>
              <RowActions :actions="[
                { key: 'absensi', label: 'Kelola Sesi', keep: true, type: 'primary', show: canUpdate && record.status === 'terjadwal', handler: () => openAttendance(record) },
                { key: 'riwayat', label: 'Riwayat', show: true, handler: () => openHistory(record) },
                { key: 'reschedule', label: 'Reschedule', show: canUpdate && record.status === 'terjadwal', handler: () => openReschedule(record) },
                { key: 'pengganti', label: 'Pengganti', show: canUpdate && record.status === 'terjadwal', handler: () => openSubstitute(record) },
                { key: 'buka', label: 'Buka Ulang', show: isStaffLike && record.status === 'selesai', handler: () => openReopen(record) },
                { key: 'batal', label: 'Batal', show: canUpdate && record.status === 'terjadwal', danger: true, handler: () => openCancel(record) },
              ]" />
            </a-space>
          </template>
        </a-table>
      </a-tab-pane>
      <a-tab-pane key="recap" tab="Rekap Kehadiran">
        <a-space class="toolbar" wrap>
          <a-select v-model:value="recapClass" show-search :options="classOptions" :filter-option="filterOption" placeholder="Pilih kelas" style="width: 200px;" />
          <a-date-picker v-model:value="recapFrom" value-format="YYYY-MM-DD" placeholder="Dari" />
          <a-date-picker v-model:value="recapTo" value-format="YYYY-MM-DD" placeholder="Sampai" />
          <a-button type="primary" @click="loadRecap">Tampilkan</a-button>
          <a-button v-if="recap" @click="exportRecap">Ekspor Excel</a-button>
        </a-space>
        <a-table v-if="recap" row-key="student.id" :data-source="recap.rows" :columns="recapColumns" :pagination="false" />
      </a-tab-pane>
      <a-tab-pane key="substitutes" tab="Usulan Pengganti">
        <a-space class="toolbar" wrap>
          <a-select v-model:value="subStatus" :options="[{ label: 'Menunggu', value: 'diusulkan' }, { label: 'Disetujui', value: 'disetujui' }, { label: 'Ditolak', value: 'ditolak' }]" style="width: 150px;" @change="refetchSubs" />
        </a-space>
        <a-table row-key="id" :loading="subsLoading" :data-source="subs?.data || []" :columns="subColumns" :pagination="{ current: subs?.current_page, pageSize: subs?.per_page, total: subs?.total }" @change="({ current }) => subPage = current">
          <template #bodyCell="{ column, record }">
            <a-tag v-if="column.key === 'status'" :color="subColor(record.status)">{{ record.status }}</a-tag>
            <a-space v-else-if="column.key === 'action'">
              <a-button v-if="isStaffLike && record.status === 'diusulkan'" size="small" type="primary" @click="reviewSub(record, true)">Setujui</a-button>
              <a-button v-if="isStaffLike && record.status === 'diusulkan'" size="small" danger @click="reviewSub(record, false)">Tolak</a-button>
            </a-space>
          </template>
        </a-table>
      </a-tab-pane>
    </a-tabs>

    <a-modal v-model:open="genOpen" title="Generate Sesi" @ok="doGenerate" :confirm-loading="generating">
      <a-form layout="vertical">
        <a-form-item label="Kelas" required><a-select v-model:value="genForm.school_class_id" show-search :options="classOptions" :filter-option="filterOption" /></a-form-item>
        <a-row :gutter="12">
          <a-col :span="12"><a-form-item label="Dari" required><a-date-picker v-model:value="genForm.from_date" value-format="YYYY-MM-DD" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Sampai" required><a-date-picker v-model:value="genForm.to_date" value-format="YYYY-MM-DD" style="width: 100%;" /></a-form-item></a-col>
        </a-row>
      </a-form>
    </a-modal>

    <a-modal v-model:open="resOpen" title="Reschedule Sesi" @ok="doReschedule">
      <a-form layout="vertical">
        <a-form-item label="Tanggal" required><a-date-picker v-model:value="resForm.session_date" value-format="YYYY-MM-DD" style="width: 100%;" /></a-form-item>
        <a-row :gutter="12">
          <a-col :span="12"><a-form-item label="Mulai" required><a-time-picker v-model:value="resForm.start_time" value-format="HH:mm" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Selesai" required><a-time-picker v-model:value="resForm.end_time" value-format="HH:mm" style="width: 100%;" /></a-form-item></a-col>
        </a-row>
        <a-form-item label="Alasan" required><a-textarea v-model:value="resForm.reason" :rows="2" /></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="cancelOpen" title="Batalkan Sesi" @ok="doCancel">
      <a-form layout="vertical"><a-form-item label="Alasan pembatalan" required><a-textarea v-model:value="cancelReason" :rows="2" /></a-form-item></a-form>
    </a-modal>

    <a-modal v-model:open="reopenOpen" title="Buka Ulang Sesi" @ok="doReopen">
      <a-form layout="vertical"><a-form-item label="Alasan dibuka kembali" required><a-textarea v-model:value="reopenReason" :rows="2" /></a-form-item></a-form>
    </a-modal>

    <a-modal v-model:open="subOpen" title="Usulkan Tutor Pengganti" @ok="doPropose">
      <div class="muted">Honor sesi ikut tarif tutor asli. Pengganti harus mengampu mapel yang sama.</div>
      <a-form layout="vertical">
        <a-form-item label="Tutor Pengganti" required><a-select v-model:value="subForm.proposed_tutor_id" show-search :options="subTutorOptions" :filter-option="filterOption" placeholder="Pilih tutor" /></a-form-item>
        <a-form-item label="Alasan" required><a-textarea v-model:value="subForm.reason" :rows="2" /></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="historyOpen" title="Riwayat Perubahan Sesi" :footer="null" width="640px">
      <div v-if="!history?.length" class="muted">Belum ada perubahan tercatat.</div>
      <a-timeline v-else>
        <a-timeline-item v-for="log in history" :key="log.id" :color="log.action === 'created' ? 'green' : 'blue'">
          <b>{{ actionLabel(log.action) }}</b> oleh {{ log.user?.name || 'sistem' }} · {{ dateTime(log.created_at) }}
          <div v-if="log.action === 'updated'" class="muted">{{ describeChange(log) }}</div>
          <div v-if="log.new_values?.reason" class="muted">Alasan: {{ log.new_values.reason }}</div>
        </a-timeline-item>
      </a-timeline>
      <div class="muted">Orang tua otomatis menerima notifikasi setiap reschedule/pembatalan.</div>
    </a-modal>

    <a-drawer v-model:open="attOpen" title="Kelola Sesi" :width="drawerWidth" placement="right">
      <div v-if="att">
        <a-alert v-if="att.session?.status === 'selesai'" type="warning" show-icon message="Sesi sudah selesai dan terkunci." class="att-lock" />
        <a-card size="small" class="att-info">
          <div class="att-head">{{ att.session?.school_class?.name }}</div>
          <div class="muted">{{ dateFull(att.session?.session_date) }} · {{ short(att.session?.start_time) }}–{{ short(att.session?.end_time) }} · {{ att.session?.room?.name || 'tanpa ruangan' }}</div>
          <div class="att-tutor">Tutor: {{ att.session?.substitute?.name || att.session?.tutor?.name || '-' }}<a-tag v-if="att.session?.substitute" color="purple">pengganti</a-tag></div>
          <div class="att-count">{{ filledCount }} dari {{ att.total }} terisi</div>
          <a-progress :percent="att.total ? Math.round((filledCount / att.total) * 100) : 0" />
        </a-card>
        <a-tabs v-model:active-key="attTab">
          <a-tab-pane key="manual" tab="Manual">
            <a-input v-model:value="studentSearch" placeholder="Cari nama siswa..." allow-clear class="att-search" />
            <a-button block class="att-all" @click="markAllPresent">Tandai semua hadir</a-button>
            <div v-for="item in filteredAttItems" :key="item.student.id" class="att-card">
              <div class="att-row">
                <div class="att-name">{{ item.student.name }}<div class="att-nis">{{ item.student.nis }}</div></div>
                <a-radio-group v-model:value="item.status" button-style="solid" size="large">
                  <a-radio-button v-for="s in statuses" :key="s.value" :value="s.value" :class="'st-' + s.value">{{ s.label }}</a-radio-button>
                </a-radio-group>
              </div>
              <div class="att-sub">
                <a-rate v-model:value="item.understanding" :count="5" class="att-stars" />
                <a-button size="small" type="link" @click="item.showNote = !item.showNote">{{ item.note ? 'Ubah catatan' : 'Catatan' }}</a-button>
              </div>
              <a-textarea v-if="item.showNote" v-model:value="item.note" :rows="1" placeholder="Catatan untuk ortu..." class="att-note" />
            </div>
          </a-tab-pane>
          <a-tab-pane key="scan" tab="Pindai QR">
            <div class="scan-hint">Arahkan kamera ke QR kartu siswa, atau ketik NIS manual.</div>
            <a-space-compact style="width: 100%;">
              <a-input v-model:value="scanCode" placeholder="NIS siswa" @press-enter="doScan" />
              <a-button type="primary" @click="doScan">Tandai Hadir</a-button>
            </a-space-compact>
            <div v-if="!qrSupported" class="scan-hint">Kamera tidak didukung di peramban ini — gunakan ketik NIS.</div>
            <video v-show="qrSupported && scanning" ref="videoEl" class="scan-video" playsinline muted></video>
            <a-button v-if="qrSupported" block class="scan-btn" @click="toggleScan">{{ scanning ? 'Hentikan Kamera' : 'Nyalakan Kamera' }}</a-button>
          </a-tab-pane>
        </a-tabs>
        <a-divider class="att-divider">Catatan sesi</a-divider>
        <a-form layout="vertical">
          <a-form-item label="Catatan materi sesi" required><a-textarea v-model:value="materialNotes" :rows="2" placeholder="Wajib diisi sebelum menyelesaikan sesi" /></a-form-item>
          <a-form-item v-if="showTutorStatus" label="Kehadiran tutor"><a-select v-model:value="tutorStatus" allow-clear :options="statuses.map((s) => ({ label: s.label, value: s.value }))" /></a-form-item>
          <div v-else class="muted">Kehadiran Anda tercatat otomatis sebagai hadir.</div>
        </a-form>
      </div>
      <template #footer>
        <div class="att-foot">
          <a-button type="primary" ghost :loading="attSaving" :disabled="att?.session?.status === 'selesai' || !canComplete" @click="confirmComplete">Selesaikan Sesi</a-button>
          <a-button type="primary" size="large" :loading="attSaving" :disabled="att?.session?.status === 'selesai'" @click="saveAttendance" class="att-save">
            Simpan ({{ filledCount }}/{{ att?.total || 0 }})
          </a-button>
        </div>
      </template>
    </a-drawer>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message, Modal } from 'ant-design-vue'
import api from '../../api/client'
import RowActions from '../../components/shared/RowActions.vue'
import { useDrawerWidth } from '../../hooks/useDrawerWidth'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

const authStore = useAuthStore()
const drawerWidth = useDrawerWidth(520)
const tab = ref('sessions'), page = ref(1)
const classFilter = ref(null), statusFilter = ref(null), roleFilter = ref('all')
const genOpen = ref(false), generating = ref(false)
const genForm = reactive({ school_class_id: null, from_date: null, to_date: null })
const resOpen = ref(false), resTarget = ref(null)
const resForm = reactive({ session_date: null, start_time: null, end_time: null, reason: '' })
const cancelOpen = ref(false), cancelTarget = ref(null), cancelReason = ref('')
const reopenOpen = ref(false), reopenTarget = ref(null), reopenReason = ref('')
const subOpen = ref(false), subTarget = ref(null), subPage = ref(1), subStatus = ref('diusulkan')
const subForm = reactive({ proposed_tutor_id: null, reason: '' })
const subColumns = [
  { title: 'Sesi', key: 'session', customRender: ({ record }) => `${record.session?.school_class?.name || '-'} · ${record.session_id}` },
  { title: 'Pengusul', key: 'requester', customRender: ({ record }) => record.requester?.name || '-' },
  { title: 'Asli → Usulan', key: 'tutors', customRender: ({ record }) => `${record.original_tutor?.name || '-'} → ${record.proposed_tutor?.name || '-'}` },
  { title: 'Alasan', dataIndex: 'reason' },
  { title: 'Status', key: 'status' },
  { title: 'Aksi', key: 'action' },
]
const subColor = (s) => ({ diusulkan: 'orange', disetujui: 'green', ditolak: 'red' }[s] || 'default')
const { data: subs, isLoading: subsLoading, refetch: refetchSubs } = useQuery({ queryKey: computed(() => ['substitute-requests', subStatus.value, subPage.value]), queryFn: async () => (await api.get('/substitute-requests', { params: { status: subStatus.value, page: subPage.value } })).data.data })
const { data: tutors } = useQuery({ queryKey: computed(() => ['tutors-substitute-options', subTarget.value?.school_class_id]), queryFn: async () => (await api.get('/tutors/substitute-options', { params: { school_class_id: subTarget.value.school_class_id } })).data.data, enabled: computed(() => subOpen.value && !!subTarget.value?.school_class_id) })
const subTutorOptions = computed(() => (tutors.value || []).map((t) => ({ label: t.name, value: t.id })))
function openSubstitute(record) { subTarget.value = record; Object.assign(subForm, { proposed_tutor_id: null, reason: '' }); subOpen.value = true }
async function doPropose() {
  try {
    await api.post(`/sessions/${subTarget.value.id}/substitute-requests`, subForm)
    subOpen.value = false; refetchSubs(); message.success('Usulan dikirim, menunggu persetujuan staf')
  } catch (e) { message.error(getApiErrorMessage(e, 'Usulan gagal dikirim')) }
}
async function reviewSub(record, approve) {
  try {
    await api.put(`/substitute-requests/${record.id}/${approve ? 'approve' : 'reject'}`, {})
    refetchSubs(); refetch(); message.success(approve ? 'Pengganti disetujui' : 'Usulan ditolak')
  } catch (e) { message.error(getApiErrorMessage(e, 'Gagal memproses usulan')) }
}
const historyOpen = ref(false), history = ref([])
const attOpen = ref(false), att = ref(null), attTab = ref('manual')
const attItems = ref([]), materialNotes = ref(''), tutorStatus = ref(null), attSaving = ref(false)
const studentSearch = ref('')
const filteredAttItems = computed(() => {
  const query = studentSearch.value.trim().toLowerCase()
  if (!query) return attItems.value
  return attItems.value.filter((i) => i.student.name.toLowerCase().includes(query) || String(i.student.nis || '').toLowerCase().includes(query))
})
const filledCount = computed(() => attItems.value.filter((i) => i.status).length)
const showTutorStatus = computed(() => {
  const mine = authStore.tutorId
  if (!mine) return true
  return mine !== att.value?.session?.tutor_id && mine !== att.value?.session?.substitute?.id
})
function markAllPresent() { attItems.value.forEach((i) => { i.status = 'hadir' }) }
const scanCode = ref(''), scanning = ref(false), videoEl = ref(null)
const qrSupported = typeof window !== 'undefined' && 'BarcodeDetector' in window
const recapClass = ref(null), recapFrom = ref(null), recapTo = ref(null), recap = ref(null)
const statuses = [{ label: 'H', value: 'hadir' }, { label: 'I', value: 'izin' }, { label: 'S', value: 'sakit' }, { label: 'A', value: 'alfa' }]
const columns = [
  { title: 'Jadwal', key: 'when' },
  { title: 'Kelas', key: 'class', customRender: ({ record }) => record.school_class?.name || '-' },  { title: 'Status', key: 'status' },
  { title: 'Terisi', key: 'filled' },
  { title: 'Aksi', key: 'action' },
]
const recapColumns = [
  { title: 'NIS', key: 'nis', customRender: ({ record }) => record.student?.nis },
  { title: 'Nama', key: 'name', customRender: ({ record }) => record.student?.name },
  { title: 'H', dataIndex: 'hadir' }, { title: 'I', dataIndex: 'izin' }, { title: 'S', dataIndex: 'sakit' }, { title: 'A', dataIndex: 'alfa' },
  { title: '% Hadir', dataIndex: 'persen_hadir' },
]
const canCreate = computed(() => authStore.can('sessions.create')), canUpdate = computed(() => authStore.can('sessions.update'))
const isStaffLike = computed(() => authStore.hasRole('super-admin') || authStore.hasRole('admin') || authStore.hasRole('staf'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['sessions', classFilter.value, statusFilter.value, roleFilter.value, page.value]), queryFn: async () => (await api.get('/sessions', { params: { school_class_id: classFilter.value, status: statusFilter.value, digantikan: roleFilter.value === 'sub' || undefined, page: page.value } })).data.data })
const { data: classes } = useQuery({ queryKey: ['classes-options'], queryFn: async () => (await api.get('/classes', { params: { per_page: 200 } })).data.data })
const classOptions = computed(() => (classes.value?.data || []).map((c) => ({ label: c.name, value: c.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
const short = (t) => String(t || '').slice(0, 5)
const dateShort = (d) => { try { return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' }) } catch { return d } }
const dateFull = (d) => { try { return new Date(d).toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric', month: 'short' }) } catch { return d } }
const statusColor = (s) => ({ terjadwal: 'blue', selesai: 'green', dibatalkan: 'red' }[s] || 'default')
const actionLabel = (a) => ({ created: 'Dibuat', updated: 'Diubah', deleted: 'Dihapus' }[a] || a)
const dateTime = (d) => { try { return new Date(d).toLocaleString('id-ID', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' }) } catch { return d } }
const describeChange = (log) => {
  const old = log.old_values || {}, cur = log.new_values || {}
  const parts = []
  if (old.session_date !== cur.session_date && cur.session_date) parts.push(`tanggal ${old.session_date} → ${cur.session_date}`)
  if ((old.start_time || '').slice(0, 5) !== (cur.start_time || '').slice(0, 5) && cur.start_time) parts.push(`jam ${String(old.start_time || '').slice(0, 5)} → ${String(cur.start_time).slice(0, 5)}`)
  if (old.status !== cur.status && cur.status) parts.push(`status ${old.status} → ${cur.status}`)
  if (old.substitute_tutor_id !== cur.substitute_tutor_id && cur.substitute_tutor_id) parts.push('tutor digantikan')
  return parts.join('; ') || 'data diperbarui'
}
async function openHistory(record) {
  try {
    const { data } = await api.get(`/sessions/${record.id}/history`)
    history.value = data.data
    historyOpen.value = true
  } catch (e) { message.error(getApiErrorMessage(e, 'Riwayat gagal dimuat')) }
}

async function doGenerate() {
  generating.value = true
  try {
    const { data } = await api.post('/sessions/generate', genForm)
    genOpen.value = false; refetch(); message.success(data.message)
  } catch (e) { message.error(getApiErrorMessage(e, 'Generate gagal')) } finally { generating.value = false }
}
function openReschedule(record) { resTarget.value = record; Object.assign(resForm, { session_date: String(record.session_date).slice(0, 10), start_time: short(record.start_time), end_time: short(record.end_time), reason: '' }); resOpen.value = true }
async function doReschedule() { try { await api.put(`/sessions/${resTarget.value.id}/reschedule`, resForm); resOpen.value = false; refetch(); message.success('Sesi dijadwal ulang') } catch (e) { message.error(getApiErrorMessage(e, 'Reschedule gagal')) } }
function openCancel(record) { cancelTarget.value = record; cancelReason.value = ''; cancelOpen.value = true }
async function doCancel() { try { await api.put(`/sessions/${cancelTarget.value.id}/cancel`, { reason: cancelReason.value }); cancelOpen.value = false; refetch(); message.success('Sesi dibatalkan') } catch (e) { message.error(getApiErrorMessage(e, 'Pembatalan gagal')) } }
function openReopen(record) { reopenTarget.value = record; reopenReason.value = ''; reopenOpen.value = true }
async function doReopen() { try { await api.put(`/sessions/${reopenTarget.value.id}/reopen`, { reason: reopenReason.value }); reopenOpen.value = false; refetch(); message.success('Sesi dibuka kembali') } catch (e) { message.error(getApiErrorMessage(e, 'Gagal membuka sesi')) } }
const canComplete = computed(() => att.value && att.value.session?.status === 'terjadwal' && (att.value.total || 0) > 0 && filledCount.value >= (att.value.total || 0))
function confirmComplete() {
  Modal.confirm({
    title: 'Selesaikan sesi ini?',
    content: 'Absensi, reschedule, dan pembatalan akan terkunci.',
    okText: 'Ya, selesaikan',
    cancelText: 'Batal',
    onOk: async () => {
      try {
        await api.put(`/sessions/${att.value.session.id}/complete`, {})
        attOpen.value = false; refetch(); message.success('Sesi selesai, absensi terkunci')
      } catch (e) { message.error(getApiErrorMessage(e, 'Sesi belum bisa diselesaikan')) }
    },
  })
}

async function openAttendance(record) {
  try {
    const { data } = await api.get(`/sessions/${record.id}/attendances`)
    att.value = data.data
    attItems.value = (data.data.items || []).map((i) => ({ student: i.student, status: i.status || null, understanding: i.understanding || 0, note: i.note || '', showNote: !!i.note }))
    studentSearch.value = ''
    materialNotes.value = ''
    tutorStatus.value = null
    attTab.value = 'manual'
    attOpen.value = true
  } catch (e) { message.error(getApiErrorMessage(e, 'Gagal memuat absensi')) }
}
async function saveAttendance() {
  const empty = attItems.value.filter((i) => !i.status).length
  if (empty > 0) {
    message.warning(`${empty} siswa belum bertanda. Tandai semua dulu.`)
    return
  }
  attSaving.value = true
  try {
    await api.put(`/sessions/${att.value.session.id}/attendances`, { items: attItems.value.map((i) => ({ student_id: i.student.id, status: i.status, understanding: i.understanding || null, note: i.note })), material_notes: materialNotes.value || undefined, tutor_status: tutorStatus.value || undefined })
    const done = attItems.value.filter((i) => i.status).length
    att.value.filled = done
    refetch(); message.success('Absensi tersimpan')
  } catch (e) { message.error(getApiErrorMessage(e, 'Simpan absensi gagal')) } finally { attSaving.value = false }
}
async function doScan() {
  if (!scanCode.value) return
  try {
    const { data } = await api.post(`/sessions/${att.value.session.id}/attendances/scan`, { code: scanCode.value })
    const found = attItems.value.find((i) => i.student.id === data.data.student_id)
    if (found) found.status = 'hadir'
    att.value.filled += 1
    scanCode.value = ''
    message.success(data.message)
    openAttendance_keepTab()
  } catch (e) { message.error(getApiErrorMessage(e, 'Pindaian gagal')) }
}
async function openAttendance_keepTab() {
  const { data } = await api.get(`/sessions/${att.value.session.id}/attendances`)
  att.value = data.data
  const prev = Object.fromEntries(attItems.value.map((i) => [i.student.id, i.status]))
  attItems.value = (data.data.items || []).map((i) => ({ student: i.student, status: prev[i.student.id] || i.status || null, understanding: i.understanding || 0, note: i.note || '', showNote: !!i.note }))
}
let scanStream = null, scanRaf = 0
async function toggleScan() {
  if (scanning.value) { stopScan(); return }
  try {
    scanStream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
    videoEl.value.srcObject = scanStream
    await videoEl.value.play()
    scanning.value = true
    tickScan()
  } catch { message.error('Kamera tidak dapat diakses') }
}
function stopScan() { scanning.value = false; cancelAnimationFrame(scanRaf); scanStream?.getTracks().forEach((t) => t.stop()); scanStream = null }
async function tickScan() {
  if (!scanning.value) return
  try {
    const detector = new window.BarcodeDetector({ formats: ['qr_code'] })
    const codes = await detector.detect(videoEl.value)
    if (codes.length) { scanCode.value = codes[0].rawValue; stopScan(); doScan(); return }
  } catch {}
  scanRaf = requestAnimationFrame(tickScan)
}

async function loadRecap() {
  if (!recapClass.value) { message.warning('Pilih kelas dulu'); return }
  try {
    const { data } = await api.get('/attendances/recap', { params: { school_class_id: recapClass.value, from_date: recapFrom.value, to_date: recapTo.value } })
    recap.value = data.data
  } catch (e) { message.error(getApiErrorMessage(e, 'Rekap gagal dimuat')) }
}
async function exportRecap() {
  try {
    const res = await api.get('/attendances/export', { params: { school_class_id: recapClass.value, from_date: recapFrom.value, to_date: recapTo.value }, responseType: 'blob' })
    const url = URL.createObjectURL(new Blob([res.data]))
    const a = document.createElement('a')
    a.href = url
    a.download = `rekap-kehadiran-${recapClass.value}.xlsx`
    a.click()
    URL.revokeObjectURL(url)
  } catch { message.error('Ekspor gagal') }
}
</script>

<style scoped>
.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }
.att-info { border-radius: 12px; margin-bottom: 12px; background: #f6f9ff; }
.att-head { font-weight: 800; font-size: 15px; }
.att-count { color: #0b4da2; font-weight: 700; margin: 4px 0 8px; }
.att-tutor { font-size: 13px; margin-top: 4px; display: flex; align-items: center; gap: 6px; }
.att-search { margin-bottom: 8px; }
.att-all { margin-bottom: 8px; }
.att-divider { margin: 12px 0; }
.att-card { padding: 8px 0; border-bottom: 1px solid #f0f0f0; }
.att-row { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.att-sub { display: flex; align-items: center; justify-content: space-between; margin-top: 4px; }
.att-stars { font-size: 16px; }
.att-note { margin-top: 4px; }
.att-name { font-weight: 600; }
.att-nis { font-size: 12px; color: #888; font-weight: 400; }
.st-hadir :deep(.ant-radio-button-checked) { background: #16a34a; border-color: #16a34a; }
.st-izin :deep(.ant-radio-button-checked) { background: #1877c9; border-color: #1877c9; }
.st-sakit :deep(.ant-radio-button-checked) { background: #f9a825; border-color: #f9a825; }
.st-alfa :deep(.ant-radio-button-checked) { background: #dc2626; border-color: #dc2626; }
.scan-hint { color: #888; margin-bottom: 8px; }
.scan-video { width: 100%; border-radius: 12px; margin-top: 8px; }
.scan-btn { margin-top: 8px; }
.att-extra { margin-top: 12px; }
.att-lock { margin-bottom: 8px; }
.att-foot { display: flex; gap: 8px; }
.att-foot .att-save { flex: 1; }
</style>
