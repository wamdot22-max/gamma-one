<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Rapor</a-typography-title>
      <a-space>
        <a-select v-model:value="studentId" show-search :options="studentOptions" :filter-option="filterOption" placeholder="Pilih siswa" style="width: 220px;" />
        <a-date-picker v-model:value="month" picker="month" value-format="YYYY-MM" />
        <a-button type="primary" @click="refetch">Tampilkan</a-button>
        <a-button v-if="report" @click="download">Unduh PDF</a-button>
      </a-space>
    </a-space>
    <div v-if="report">
      <a-card :title="`${report.student?.name} (${report.student?.nis})`" class="report-card">
        <div v-for="subject in (report.subjects || [])" :key="subject.subject?.id || subject.subject?.name" class="report-subject">
          <b>{{ subject.subject?.name }} — {{ subject.average }}</b>
          <a-table size="small" :data-source="subject.items" :columns="itemColumns" :pagination="false" row-key="title" />
        </div>
        <div class="report-att">Kehadiran — H {{ report.attendance?.hadir }} · I {{ report.attendance?.izin }} · S {{ report.attendance?.sakit }} · A {{ report.attendance?.alfa }}</div>
        <div v-if="report.tutor_notes?.length" class="report-notes">Catatan: {{ report.tutor_notes.join('; ') }}</div>
      </a-card>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'

const studentId = ref(null), month = ref(new Date().toISOString().slice(0, 7))
const itemColumns = [{ title: 'Asesmen', dataIndex: 'title' }, { title: 'Tipe', dataIndex: 'type' }, { title: 'Nilai', dataIndex: 'score' }]
const enabled = computed(() => !!studentId.value)
const { data: report, refetch } = useQuery({
  queryKey: computed(() => ['report-card', studentId.value, month.value]),
  queryFn: async () => (await api.get('/report-cards', { params: { student_id: studentId.value, month: month.value } })).data.data,
  enabled,
})
const { data: students } = useQuery({ queryKey: ['students-options'], queryFn: async () => (await api.get('/students', { params: { per_page: 200 } })).data.data })
const studentOptions = computed(() => (students.value?.data || []).map((s) => ({ label: `${s.name} (${s.nis})`, value: s.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
async function download() {
  try {
    const res = await api.get('/report-cards/download', { params: { student_id: studentId.value, month: month.value }, responseType: 'blob' })
    const url = URL.createObjectURL(new Blob([res.data], { type: 'application/pdf' }))
    const a = document.createElement('a')
    a.href = url
    a.download = `rapor-${month.value}.pdf`
    a.click()
    URL.revokeObjectURL(url)
  } catch { message.error('Rapor gagal diunduh') }
}
</script>

<style scoped>
.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }
.report-card { border-radius: 12px; }
.report-subject { margin-bottom: 12px; }
.report-att { margin-top: 8px; font-weight: 600; }
.report-notes { color: #666; margin-top: 4px; }
</style>
