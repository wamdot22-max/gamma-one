<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Jadwal Mingguan</a-typography-title>
      <a-space>
        <a-select v-model:value="classFilter" allow-clear show-search :options="classOptions" :filter-option="filterOption" placeholder="Semua kelas" style="width: 200px;" @change="refetch" />
        <a-select v-if="showPeran" v-model:value="peranFilter" :options="[{ label: 'Semua', value: '' }, { label: 'Utama', value: 'utama' }, { label: 'Pengganti', value: 'pengganti' }]" style="width: 140px;" @change="refetch" />
        <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah Jadwal</a-button>
      </a-space>
    </a-space>
    <a-alert v-if="loadError" type="error" :message="loadError" show-icon class="alert" />
    <a-row :gutter="8" class="week-grid">
      <a-col v-for="day in days" :key="day.value" :xs="24" :sm="12" :md="8" :lg="6" :xl="3">
        <a-card :title="day.label" size="small" class="day-card">
          <div v-if="!(weekly?.[day.value] || []).length" class="empty">—</div>
          <div v-for="s in (weekly?.[day.value] || [])" :key="s.id" class="slot">
            <div class="slot-time">{{ short(s.start_time) }}–{{ short(s.end_time) }}</div>
            <div class="slot-class">{{ s.school_class?.name }}</div>
            <div class="slot-room">{{ s.room?.name || '' }}</div>
            <div><a-tag v-if="s.peran === 'pengganti'" color="purple">Pengganti</a-tag><a-tag v-else-if="showPeran" color="blue">Utama</a-tag></div>
            <a-space v-if="canUpdate || canDelete" size="small">
              <a-button v-if="canUpdate" size="small" type="link" @click="openForm(s)">Edit</a-button>
              <a-popconfirm v-if="canDelete" title="Hapus jadwal?" @confirm="remove(s.id)"><a-button size="small" type="link" danger>Hapus</a-button></a-popconfirm>
            </a-space>
          </div>
        </a-card>
      </a-col>
    </a-row>
    <a-modal v-model:open="open" :title="editing ? 'Edit Jadwal' : 'Tambah Jadwal'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Kelas" required><a-select v-model:value="form.school_class_id" show-search :options="classOptions" :filter-option="filterOption" placeholder="Pilih kelas" /></a-form-item>
        <a-row :gutter="12">
          <a-col :span="8"><a-form-item label="Hari" required><a-select v-model:value="form.day_of_week" :options="days.map((d) => ({ label: d.label, value: d.value }))" /></a-form-item></a-col>
          <a-col :span="8"><a-form-item label="Mulai" required><a-time-picker v-model:value="form.start_time" value-format="HH:mm" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="8"><a-form-item label="Selesai" required><a-time-picker v-model:value="form.end_time" value-format="HH:mm" style="width: 100%;" /></a-form-item></a-col>
        </a-row>
        <a-form-item label="Ruangan (opsional, default ruangan kelas)"><a-select v-model:value="form.room_id" allow-clear show-search :options="roomOptions" :filter-option="filterOption" placeholder="Pilih ruangan" /></a-form-item>
        <a-form-item label="Aktif"><a-switch v-model:checked="form.is_active" /></a-form-item>
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
const classFilter = ref(null), peranFilter = ref(''), open = ref(false), editing = ref(null), loadError = ref('')
const showPeran = computed(() => authStore.hasRole('tutor') && !authStore.hasRole('super-admin') && !authStore.hasRole('admin') && !authStore.hasRole('staf'))
const days = [{ value: 1, label: 'Senin' }, { value: 2, label: 'Selasa' }, { value: 3, label: 'Rabu' }, { value: 4, label: 'Kamis' }, { value: 5, label: 'Jumat' }, { value: 6, label: 'Sabtu' }, { value: 7, label: 'Minggu' }]
const form = reactive({ school_class_id: null, day_of_week: 1, start_time: null, end_time: null, room_id: null, is_active: true })
const canCreate = computed(() => authStore.can('schedules.create')), canUpdate = computed(() => authStore.can('schedules.update')), canDelete = computed(() => authStore.can('schedules.delete'))
const { data: weekly, refetch } = useQuery({
  queryKey: computed(() => ['schedules-weekly', classFilter.value, peranFilter.value]),
  queryFn: async () => {
    try {
      loadError.value = ''
      return (await api.get('/schedules-weekly', { params: { school_class_id: classFilter.value, peran: peranFilter.value || undefined } })).data.data
    } catch (e) { loadError.value = getApiErrorMessage(e, 'Gagal memuat jadwal'); throw e }
  },
})
const { data: classes } = useQuery({ queryKey: ['classes-options'], queryFn: async () => (await api.get('/classes', { params: { per_page: 200 } })).data.data })
const { data: rooms } = useQuery({ queryKey: ['rooms-options'], queryFn: async () => (await api.get('/rooms', { params: { per_page: 200 } })).data.data })
const classOptions = computed(() => (classes.value?.data || []).map((c) => ({ label: c.name, value: c.id })))
const roomOptions = computed(() => (rooms.value?.data || []).map((r) => ({ label: r.name, value: r.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
const short = (t) => String(t || '').slice(0, 5)
function openForm(record = null) { editing.value = record; Object.assign(form, { school_class_id: record?.school_class_id || null, day_of_week: record?.day_of_week || 1, start_time: short(record?.start_time), end_time: short(record?.end_time), room_id: record?.room_id || null, is_active: record ? !!record.is_active : true }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/schedules/${editing.value.id}`, form); else await api.post('/schedules', form); open.value = false; refetch(); message.success('Jadwal tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Jadwal gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/schedules/${id}`); refetch(); message.success('Jadwal dihapus') } catch { message.error('Jadwal gagal dihapus') } }
</script>

<style scoped>
.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }
.alert { margin-bottom: 12px; }
.week-grid { row-gap: 8px; }
.day-card { min-height: 140px; }
.empty { color: #ccc; text-align: center; }
.slot { border-left: 3px solid #0b4da2; padding: 4px 8px; margin-bottom: 8px; background: #f6f9ff; border-radius: 0 8px 8px 0; }
.slot-time { font-weight: 800; color: #0b4da2; }
.slot-class { font-weight: 600; }
.slot-room { color: #888; font-size: 12px; }
</style>
