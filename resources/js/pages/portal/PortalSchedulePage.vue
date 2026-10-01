<template>
  <div>
    <a-tabs v-model:active-key="tab">
      <a-tab-pane key="jadwal" tab="Jadwal">
        <div v-for="day in days" :key="day.value" class="p-day">
          <div class="p-day-label">{{ day.label }}</div>
          <div v-if="!(weekly?.[day.value] || []).length" class="p-empty">Tidak ada jadwal</div>
          <div v-for="s in (weekly?.[day.value] || [])" :key="s.id" class="p-slot">
            <div class="p-time">{{ short(s.start_time) }}–{{ short(s.end_time) }}</div>
            <div class="p-class">{{ s.school_class?.name }}</div>
          </div>
        </div>
      </a-tab-pane>
      <a-tab-pane key="mendatang" tab="Sesi Mendatang">
        <div v-if="!upcoming?.data?.length" class="p-empty">Belum ada sesi terjadwal.</div>
        <div v-for="s in (upcoming?.data || [])" :key="s.id" class="p-slot">
          <div class="p-time">{{ dateFull(s.session_date) }} · {{ short(s.start_time) }}</div>
          <div class="p-class">{{ s.school_class?.name }}</div>
          <a-tag :color="s.status === 'dibatalkan' ? 'red' : 'blue'">{{ s.status }}</a-tag>
        </div>
      </a-tab-pane>
      <a-tab-pane key="hadir" tab="Kehadiran">
        <a-select v-model:value="recapClass" :options="classOptions" placeholder="Pilih kelas" style="width: 100%; margin-bottom: 8px;" @change="loadRecap" />
        <div v-if="recap">
          <div v-for="row in recap.rows" :key="row.student.id" class="p-slot">
            <div class="p-class">{{ row.student.name }}</div>
            <div class="p-time">H {{ row.hadir }} · I {{ row.izin }} · S {{ row.sakit }} · A {{ row.alfa }} ({{ row.persen_hadir }}%)</div>
          </div>
        </div>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import api from '../../api/client'

const tab = ref('jadwal')
const days = [{ value: 1, label: 'Senin' }, { value: 2, label: 'Selasa' }, { value: 3, label: 'Rabu' }, { value: 4, label: 'Kamis' }, { value: 5, label: 'Jumat' }, { value: 6, label: 'Sabtu' }, { value: 7, label: 'Minggu' }]
const short = (t) => String(t || '').slice(0, 5)
const dateFull = (d) => { try { return new Date(d).toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric', month: 'short' }) } catch { return d } }

const { data: weekly } = useQuery({ queryKey: ['portal-weekly'], queryFn: async () => (await api.get('/schedules-weekly')).data.data })
const { data: upcoming } = useQuery({ queryKey: ['portal-upcoming'], queryFn: async () => (await api.get('/sessions', { params: { per_page: 20, status: 'terjadwal' } })).data.data })
const { data: classes } = useQuery({ queryKey: ['portal-classes'], queryFn: async () => (await api.get('/classes', { params: { per_page: 50 } })).data.data })
const classOptions = computed(() => (classes.value?.data || []).map((c) => ({ label: c.name, value: c.id })))
const recapClass = ref(null), recap = ref(null)
async function loadRecap() {
  if (!recapClass.value) return
  recap.value = (await api.get('/attendances/recap', { params: { school_class_id: recapClass.value } })).data.data
}
</script>

<style scoped>
.p-day { margin-bottom: 12px; }
.p-day-label { font-weight: 800; color: #0b4da2; margin-bottom: 4px; }
.p-empty { color: #aaa; font-size: 13px; }
.p-slot { background: #fff; border-radius: 12px; padding: 10px 12px; margin-bottom: 8px; }
.p-time { font-weight: 800; color: #0b4da2; font-size: 13px; }
.p-class { font-weight: 600; }
</style>
