<template>
  <div>
    <div class="db-head">
      <div>
        <div class="db-greet">Selamat {{ greeting }}, {{ firstName }} 👋</div>
        <div class="db-sub">{{ tagline }}</div>
      </div>
      <div class="db-date">{{ today }}</div>
    </div>

    <div v-if="isStaff">
      <div class="db-section">RINGKASAN — {{ period }}</div>
      <a-row :gutter="16" class="dash-row">
        <a-col :xs="12" :lg="6" v-for="card in statCards" :key="card.title">
          <a-card :loading="isLoading" :bordered="false" :class="['hb-card', `hb-card--${card.theme}`]">
            <div class="hb-top">
              <span class="hb-icon"><component :is="card.icon" /></span>
              <div>
                <div class="hb-label">{{ card.title }}</div>
                <div class="hb-value">{{ card.value }}</div>
              </div>
            </div>
            <div class="hb-desc">{{ card.desc }}</div>
          </a-card>
        </a-col>
      </a-row>

      <a-row :gutter="16" class="dash-row">
        <a-col :xs="24" :lg="16">
          <a-card :loading="isLoading">
            <template #title><span>📊 Pemasukan 6 Bulan Terakhir</span></template>
            <Bar v-if="summary?.grafik_pemasukan" :data="incomeChart" :options="{ responsive: true, plugins: { legend: { display: false } } }" />
            <div class="hb-legend">
              <span><i class="dot dot--blue" /> Total 6 bulan: <b>Rp {{ rupiah(chartTotal) }}</b></span>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :lg="8">
          <a-card :loading="isLoading">
            <template #title><span>⇄ Tagihan (Bulan Ini)</span></template>
            <div class="hb-sub">Kas masuk dan tunggakan bulan ini</div>
            <div class="hb-flow">
              <span>↓ Masuk</span><b class="green">Rp {{ rupiah(summary?.pemasukan_bulan_ini) }}</b>
            </div>
            <a-progress :percent="paidPct" :show-info="false" stroke-color="#22c55e" />
            <div class="hb-flow">
              <span>↑ Tertunggak</span><b class="red">Rp {{ rupiah(summary?.tunggakan_total) }}</b>
            </div>
            <a-progress :percent="100 - paidPct" :show-info="false" stroke-color="#f97316" />
            <a-divider />
            <div class="hb-net">Total: Rp {{ rupiah((summary?.pemasukan_bulan_ini || 0) + (summary?.tunggakan_total || 0)) }}</div>
          </a-card>
        </a-col>
      </a-row>

      <a-row :gutter="16" class="dash-row">
        <a-col :xs="24" :lg="8">
          <a-card :loading="isLoading">
            <template #title><span>🕒 Jadwal Hari Ini</span></template>
            <div v-if="!summary?.jadwal_hari_ini?.length" class="muted">Tidak ada sesi hari ini.</div>
            <div v-for="s in (summary?.jadwal_hari_ini || [])" :key="s.id" class="hb-item">
              <div><b>{{ short(s.start_time) }} · {{ s.school_class?.name }}</b><div class="muted">{{ s.tutor?.name }}</div></div>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :lg="8">
          <a-card :loading="isLoading">
            <template #title><span>⭐ Kelas Teratas</span></template>
            <div v-if="!summary?.kelas_teratas?.length" class="muted">Belum ada data.</div>
            <div v-for="(c, i) in (summary?.kelas_teratas || [])" :key="c.id" class="hb-item">
              <div><span class="hb-rank">{{ i + 1 }}</span> <b>{{ c.name }}</b></div><b>{{ c.active_enrollments_count }}x</b>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :lg="8">
          <a-card :loading="isLoading">
            <template #title><span>🧾 Perlu Ditagih</span></template>
            <div v-if="!summary?.perlu_ditagih?.length" class="muted">Tidak ada tunggakan.</div>
            <div v-for="inv in (summary?.perlu_ditagih || []).slice(0, 5)" :key="inv.id" class="hb-item">
              <div><b>{{ inv.student?.name }}</b><div class="muted">{{ inv.invoice_no }}</div></div>
              <b>Rp {{ rupiah(inv.total - inv.paid_amount) }}</b>
            </div>
          </a-card>
        </a-col>
      </a-row>
    </div>

    <div v-else-if="isTutor">
      <div class="db-section">RINGKASAN SAYA</div>
      <a-row :gutter="16" class="dash-row">
        <a-col :xs="12" :lg="6" v-for="card in tutorStatCards" :key="card.title">
          <a-card :loading="isLoading" :bordered="false" :class="['hb-card', `hb-card--${card.theme}`]">
            <div class="hb-top">
              <span class="hb-icon"><component :is="card.icon" /></span>
              <div>
                <div class="hb-label">{{ card.title }}</div>
                <div class="hb-value">{{ card.value }}</div>
              </div>
            </div>
          </a-card>
        </a-col>
      </a-row>
      <a-row :gutter="16" class="dash-row">
        <a-col :xs="24" :lg="12">
          <a-card title="⚠️ Perlu Perhatian" :loading="isLoading">
            <div v-if="!summary?.perlu_perhatian?.length" class="muted">Semua beres. Tidak ada yang tertunda.</div>
            <div v-for="(item, i) in (summary?.perlu_perhatian || [])" :key="i" class="hb-item">
              <span><a-tag :color="item.jenis === 'absensi' ? 'red' : 'orange'">{{ item.jenis }}</a-tag> {{ item.teks }}</span>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :lg="12">
          <a-card title="🕒 Jadwal Hari Ini" :loading="isLoading">
            <div v-if="!summary?.jadwal_hari_ini?.length" class="muted">Tidak ada sesi hari ini.</div>
            <div v-for="s in (summary?.jadwal_hari_ini || [])" :key="s.id" class="hb-item">
              <div>
                <b>{{ short(s.start_time) }} · {{ s.school_class?.name }}</b>
                <a-tag v-if="s.peran === 'pengganti'" color="purple">Pengganti</a-tag>
                <div class="muted">{{ s.room?.name || '' }} · {{ s.attendances_count ? `${s.attendances_count} terisi` : 'belum absen' }}</div>
              </div>
            </div>
          </a-card>
        </a-col>
      </a-row>
      <a-card title="📅 Sesi 7 Hari ke Depan" :loading="isLoading">
        <div v-if="!summary?.sesi_mendatang?.length" class="muted">Belum ada sesi terjadwal.</div>
        <div v-for="s in (summary?.sesi_mendatang || [])" :key="s.id" class="hb-item">
          <div><b>{{ dateFull(s.session_date) }} · {{ short(s.start_time) }}</b> — {{ s.school_class?.name }}
            <a-tag v-if="s.peran === 'pengganti'" color="purple">Pengganti</a-tag>
          </div>
        </div>
      </a-card>
      <a-row :gutter="16" class="dash-row dash-gap">
        <a-col :xs="24" :lg="8">
          <a-card title="✅ Kehadiran per Kelas" :loading="isLoading">
            <div v-if="!summary?.kehadiran_per_kelas?.length" class="muted">Belum ada data.</div>
            <div v-for="row in (summary?.kehadiran_per_kelas || [])" :key="row.class" class="hb-bar-row">
              <div class="hb-bar-label"><span>{{ row.class }}</span><b>{{ row.persen }}%</b></div>
              <a-progress :percent="row.persen" :show-info="false" stroke-color="#0B4DA2" />
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :lg="8">
          <a-card title="📊 Rata-rata Nilai per Kelas" :loading="isLoading">
            <div v-if="!summary?.rata_nilai_per_kelas?.length" class="muted">Belum ada data.</div>
            <div v-for="row in (summary?.rata_nilai_per_kelas || [])" :key="row.class" class="hb-item">
              <span>{{ row.class }} <span class="muted">({{ row.jumlah }} nilai)</span></span><b>{{ row.rata_rata }}</b>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :lg="8">
          <a-card title="🔄 Usulan Pengganti Saya" :loading="isLoading">
            <div v-if="!summary?.usulan_pengganti?.length" class="muted">Belum ada usulan.</div>
            <div v-for="u in (summary?.usulan_pengganti || [])" :key="u.id" class="hb-item">
              <div><b>{{ u.sesi }}</b> → {{ u.pengganti }}</div>
              <a-tag :color="u.status === 'disetujui' ? 'green' : u.status === 'ditolak' ? 'red' : 'orange'">{{ u.status }}</a-tag>
            </div>
          </a-card>
        </a-col>
      </a-row>
    </div>

    <!-- Siswa/orang tua diarahkan ke /portal; kisi ini hanya pengaman. -->
    <a-alert v-else type="info" message="Gunakan menu bawah untuk membuka Beranda, Jadwal, Nilai, Tagihan, dan Profil." />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Tooltip } from 'chart.js'
import {
  TeamOutlined,
  WalletOutlined,
  WarningOutlined,
  CheckCircleOutlined,
  CalendarOutlined,
  SolutionOutlined,
} from '@ant-design/icons-vue'
import api from '../../api/client'
import { useAuthStore } from '../../stores/auth'

ChartJS.register(CategoryScale, LinearScale, BarElement, Tooltip)

const authStore = useAuthStore()
const isStaff = computed(() => authStore.hasRole('super-admin') || authStore.hasRole('admin') || authStore.hasRole('staf'))
const isTutor = computed(() => authStore.hasRole('tutor'))

const hour = new Date().getHours()
const greeting = hour < 11 ? 'pagi' : hour < 15 ? 'siang' : hour < 19 ? 'sore' : 'malam'
const firstName = computed(() => (authStore.user?.name || 'Kak').split(' ')[0])
const today = new Date().toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
const period = new Date().toLocaleDateString('id-ID', { month: 'long', year: 'numeric' }).toUpperCase()

const tagline = computed(() => {
  if (isTutor.value) return 'Kelola kelas dan absensi Anda di sini.'
  if (isStaff.value) return 'Ringkasan bimbel hari ini.'
  return 'One Step, One Growth.'
})

const { data: summary, isLoading } = useQuery({
  queryKey: ['dashboard-summary'],
  queryFn: async () => (await api.get('/dashboard/summary')).data.data,
})

const rupiah = (n) => Number(n || 0).toLocaleString('id-ID')
const short = (t) => String(t || '').slice(0, 5)

const statCards = computed(() => [
  { title: 'PEMASUKAN', value: `Rp ${rupiah(summary.value?.pemasukan_bulan_ini)}`, desc: 'Kas yang masuk bulan ini', theme: 'green', icon: WalletOutlined },
  { title: 'TUNGGAKAN', value: `Rp ${rupiah(summary.value?.tunggakan_total)}`, desc: `${summary.value?.tunggakan_jumlah || 0} invoice belum dibayar`, theme: 'orange', icon: WarningOutlined },
  { title: 'KEHADIRAN', value: `${summary.value?.tingkat_kehadiran || 0}%`, desc: 'Rata-rata kehadiran bulan ini', theme: 'blue', icon: CheckCircleOutlined },
  { title: 'SISWA AKTIF', value: summary.value?.siswa_aktif || 0, desc: 'Siswa berstatus aktif', theme: 'purple', icon: TeamOutlined },
])

const chartTotal = computed(() => (summary.value?.grafik_pemasukan || []).reduce((sum, r) => sum + (r.total || 0), 0))
const paidPct = computed(() => {
  const masuk = summary.value?.pemasukan_bulan_ini || 0
  const total = masuk + (summary.value?.tunggakan_total || 0)
  return total > 0 ? Math.round((masuk / total) * 100) : 0
})

const incomeChart = computed(() => ({
  labels: (summary.value?.grafik_pemasukan || []).map((r) => r.month),
  datasets: [{ data: (summary.value?.grafik_pemasukan || []).map((r) => r.total), backgroundColor: '#bfdbfe', hoverBackgroundColor: '#0B4DA2', borderRadius: 6 }],
}))

const tutorStatCards = computed(() => [
  { title: 'KELAS AKTIF', value: summary.value?.kelas_aktif || 0, theme: 'blue', icon: CalendarOutlined },
  { title: 'TOTAL SISWA', value: summary.value?.total_siswa || 0, theme: 'purple', icon: TeamOutlined },
  { title: 'SESI MINGGU INI', value: summary.value?.sesi_minggu_ini || 0, theme: 'green', icon: SolutionOutlined },
  { title: 'HONOR BULAN INI', value: `Rp ${rupiah(summary.value?.honor_bulan_ini)}`, theme: 'orange', icon: WalletOutlined },
])

const dateFull = (d) => { try { return new Date(d).toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric', month: 'short' }) } catch { return d } }
</script>

<style scoped>
.db-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 4px; }
.db-greet { font-size: 20px; font-weight: 800; }
.db-sub { color: #888; font-size: 13px; }
.db-date { color: #888; font-size: 12px; white-space: nowrap; }
.db-section { font-size: 12px; font-weight: 700; letter-spacing: 1px; color: #888; margin: 12px 0; }
.dash-row { margin-bottom: 16px; row-gap: 16px; }
.muted { color: #888; }
.green { color: #16a34a; }
.red { color: #dc2626; }

/* Kartu pastel ala referensi */
.hb-card { border-radius: 16px; }
.hb-card--green { background: #f0fdf4; border: 1px solid #bbf7d0; }
.hb-card--orange { background: #fff7ed; border: 1px solid #fed7aa; }
.hb-card--blue { background: #eff6ff; border: 1px solid #bfdbfe; }
.hb-card--purple { background: #f5f3ff; border: 1px solid #ddd6fe; }
.hb-top { display: flex; align-items: center; gap: 12px; }
.hb-icon { display: inline-flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 12px; font-size: 22px; flex-shrink: 0; }
.hb-card--green .hb-icon { background: #dcfce7; color: #16a34a; }
.hb-card--orange .hb-icon { background: #ffedd5; color: #ea580c; }
.hb-card--blue .hb-icon { background: #dbeafe; color: #0b4da2; }
.hb-card--purple .hb-icon { background: #ede9fe; color: #7c3aed; }
.hb-label { font-size: 11px; font-weight: 700; letter-spacing: 0.5px; }
.hb-card--green .hb-label { color: #16a34a; }
.hb-card--orange .hb-label { color: #ea580c; }
.hb-card--blue .hb-label { color: #0b4da2; }
.hb-card--purple .hb-label { color: #7c3aed; }
.hb-value { font-size: 20px; font-weight: 800; }
.hb-card--green .hb-value { color: #15803d; }
.hb-card--orange .hb-value { color: #c2410c; }
.hb-card--blue .hb-value { color: #0b4da2; }
.hb-card--purple .hb-value { color: #6d28d9; }
.hb-desc { font-size: 12px; color: #888; margin-top: 6px; }

.hb-sub { color: #888; font-size: 12px; margin-bottom: 12px; }
.hb-flow { display: flex; justify-content: space-between; margin: 8px 0 4px; }
.hb-net { text-align: right; font-weight: 800; color: #16a34a; margin-top: 8px; }
.hb-legend { margin-top: 8px; font-size: 13px; }
.dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 4px; }
.dot--blue { background: #0b4da2; }
.hb-item { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #f5f5f5; }
.hb-item:last-child { border-bottom: none; }
.hb-bar-row { margin-bottom: 10px; }
.hb-bar-label { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 2px; }
.dash-gap { margin-top: 16px; }
.hb-rank { display: inline-flex; align-items: center; justify-content: center; width: 22px; height: 22px; border-radius: 50%; background: #fef3c7; color: #b45309; font-size: 12px; font-weight: 800; margin-right: 6px; }
</style>
