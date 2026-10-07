<template>
  <div>
    <a-select v-if="childOptions.length > 1" v-model:value="selectedStudent" :options="childOptions" style="width: 100%; margin-bottom: 8px;" @change="onChildChange" />
    <a-tabs v-model:active-key="tab">
      <a-tab-pane key="nilai" tab="Nilai">
        <a-select v-model:value="subjectId" allow-clear :options="subjectOptions" placeholder="Semua mapel" style="width: 100%; margin-bottom: 8px;" @change="refetch" />
        <div v-if="averages">
          <div v-for="subject in (averages.subjects || [])" :key="subject.subject?.id || subject.subject?.name" class="p-card">
            <div class="p-title">{{ subject.subject?.name }} — {{ subject.average }}</div>
            <Line v-if="subject.trend?.length" :data="chartData(subject)" :options="chartOptions" class="p-chart" />
            <div v-for="point in (subject.trend || [])" :key="point.title" class="p-row">
              <span>{{ point.title }}</span><b>{{ point.score }}</b>
            </div>
          </div>
        </div>
      </a-tab-pane>
      <a-tab-pane key="rapor" tab="Rapor">        <a-date-picker v-model:value="month" picker="month" value-format="YYYY-MM" style="width: 100%; margin-bottom: 8px;" @change="loadReport" />
        <div v-if="report" class="p-card">
          <div class="p-title">Rapor {{ report.month }}</div>
          <div v-for="subject in (report.subjects || [])" :key="subject.subject?.name" class="p-row">
            <span>{{ subject.subject?.name }}</span><b>{{ subject.average }}</b>
          </div>
          <div class="p-row"><span>Kehadiran</span><b>H {{ report.attendance?.hadir }} · I {{ report.attendance?.izin }} · S {{ report.attendance?.sakit }} · A {{ report.attendance?.alfa }}</b></div>
          <a-button block class="p-btn" @click="downloadReport">Unduh PDF</a-button>
        </div>
      </a-tab-pane>
      <a-tab-pane key="jurnal" tab="Jurnal">
        <div v-if="!journal?.data?.length" class="p-empty">Belum ada jurnal belajar.</div>
        <div v-for="entry in (journal?.data || [])" :key="entry.id" class="p-card">
          <div class="p-title">{{ entry.kelas }} · {{ entry.tanggal }}</div>
          <div class="p-sub">{{ entry.mapel }} · {{ entry.status }}</div>
          <a-rate v-if="entry.pemahaman" :value="entry.pemahaman" disabled class="p-stars" />
          <div v-if="entry.catatan" class="p-note">"{{ entry.catatan }}"</div>
          <div v-if="entry.materi" class="p-sub">Materi: {{ entry.materi }}</div>
        </div>
      </a-tab-pane>
      <a-tab-pane key="materi" tab="Materi">
        <div v-if="!materials?.data?.length" class="p-empty">Belum ada materi.</div>
        <div v-for="m in (materials?.data || [])" :key="m.id" class="p-card">
          <div class="p-title">{{ m.title }}</div>
          <div class="p-sub">{{ m.school_class?.name }}</div>
          <a-button v-if="m.file_url" block type="link" :href="m.file_url" target="_blank">Buka berkas</a-button>
        </div>
      </a-tab-pane>
      <a-tab-pane key="tugas" tab="Tugas">
        <div v-if="!assignments?.data?.length" class="p-empty">Belum ada tugas.</div>
        <div v-for="t in (assignments?.data || [])" :key="t.id" class="p-card">
          <div class="p-title">{{ t.title }}</div>
          <div class="p-sub">{{ t.school_class?.name }} · Deadline {{ t.deadline || '-' }}</div>
          <div :class="['p-status', submittedIds.has(t.id) ? 'done' : '']">{{ submittedIds.has(t.id) ? 'Sudah dikumpulkan' : 'Belum dikumpulkan' }}</div>
          <a-upload :before-upload="(f) => submitTask(t, f)" :max-count="1" :show-upload-list="false">
            <a-button block class="p-btn">Kumpulkan Berkas</a-button>
          </a-upload>
        </div>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Tooltip } from 'chart.js'
import api from '../../api/client'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Tooltip)

const authStore = useAuthStore()
const tab = ref('nilai'), subjectId = ref(null), month = ref(new Date().toISOString().slice(0, 7)), report = ref(null)
const chartOptions = { responsive: true, plugins: { legend: { display: false } }, scales: { y: { min: 0, max: 100 } } }
const chartData = (subject) => ({ labels: (subject.trend || []).map((p) => p.title), datasets: [{ data: (subject.trend || []).map((p) => p.score), borderColor: '#0B4DA2', backgroundColor: '#1877C9', tension: 0.3 }] })

const { data: me } = useQuery({ queryKey: ['portal-me-student'], queryFn: async () => (await api.get('/students', { params: { per_page: 50 } })).data.data })
const childOptions = computed(() => (me.value?.data || []).map((s) => ({ label: s.name, value: s.id })))
const selectedStudent = ref(null)
const myStudentId = computed(() => selectedStudent.value || me.value?.data?.[0]?.id || null)
function onChildChange() { refetch(); loadReport(); refetchJournal() }
const { data: averages, refetch } = useQuery({
  queryKey: computed(() => ['portal-averages', myStudentId.value, subjectId.value]),
  queryFn: async () => (await api.get('/grades/averages', { params: { student_id: myStudentId.value, subject_id: subjectId.value } })).data.data,
  enabled: computed(() => !!myStudentId.value),
})
const { data: materials } = useQuery({ queryKey: ['portal-materials'], queryFn: async () => (await api.get('/materials', { params: { per_page: 50 } })).data.data })
const { data: journal, refetch: refetchJournal } = useQuery({
  queryKey: computed(() => ['portal-journal', myStudentId.value]),
  queryFn: async () => (await api.get('/journals', { params: { student_id: myStudentId.value, per_page: 20 } })).data.data,
  enabled: computed(() => !!myStudentId.value),
})
const { data: assignments, refetch: refetchTasks } = useQuery({ queryKey: ['portal-assignments'], queryFn: async () => (await api.get('/assignments', { params: { per_page: 50 } })).data.data })
const { data: submissions } = useQuery({ queryKey: ['portal-submissions'], queryFn: async () => (await api.get('/submissions', { params: { per_page: 100 } })).data.data })
const submittedIds = computed(() => new Set((submissions.value?.data || []).map((s) => s.assignment_id)))
const subjectOptions = computed(() => (averages.value?.subjects || []).map((s) => ({ label: s.subject?.name, value: s.subject?.id })).filter((o) => o.value))

async function loadReport() {
  if (!myStudentId.value) return
  report.value = (await api.get('/report-cards', { params: { student_id: myStudentId.value, month: month.value } })).data.data
}
async function downloadReport() {
  const res = await api.get('/report-cards/download', { params: { student_id: myStudentId.value, month: month.value }, responseType: 'blob' })
  const url = URL.createObjectURL(new Blob([res.data], { type: 'application/pdf' }))
  const a = document.createElement('a')
  a.href = url
  a.download = `rapor-${month.value}.pdf`
  a.click()
  URL.revokeObjectURL(url)
}
async function submitTask(task, file) {
  if (!myStudentId.value) { message.warning('Data siswa tidak ditemukan'); return false }
  try {
    const formData = new FormData()
    formData.append('file', file)
    const { data } = await api.post('/files/upload', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
    await api.post('/submissions', { assignment_id: task.id, student_id: myStudentId.value, file_url: data.data.url })
    message.success('Tugas terkumpul')
    refetchTasks()
  } catch (e) { message.error(getApiErrorMessage(e, 'Pengumpulan gagal')) }
  return false
}
</script>

<style scoped>
.p-card { background: #fff; border-radius: 12px; padding: 12px; margin-bottom: 10px; }
.p-title { font-weight: 800; color: #0b4da2; margin-bottom: 4px; }
.p-sub { color: #888; font-size: 12px; margin-bottom: 4px; }
.p-empty { color: #aaa; text-align: center; }
.p-row { display: flex; justify-content: space-between; padding: 4px 0; border-bottom: 1px solid #f5f5f5; }
.p-chart { max-height: 220px; margin: 8px 0; }
.p-status { font-size: 12px; color: #c00; margin-bottom: 6px; }
.p-status.done { color: #16a34a; }
.p-stars { font-size: 16px; }
.p-note { font-style: italic; color: #555; margin-top: 4px; }
.p-btn { margin-top: 6px; }
</style>
