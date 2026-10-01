<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Asesmen & Nilai</a-typography-title>
      <a-space wrap>
        <a-select v-model:value="classFilter" allow-clear show-search :options="classOptions" :filter-option="filterOption" placeholder="Semua kelas" style="width: 180px;" @change="refetch" />
        <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah Asesmen</a-button>
      </a-space>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
        <template #bodyCell="{ column, record }">
          <a-space v-if="column.key === 'action'" wrap>
            <RowActions :actions="[
              { key: 'nilai', label: 'Nilai', keep: true, type: 'primary', show: canGrade, handler: () => openGrades(record) },
              { key: 'edit', label: 'Edit', circle: true, show: canUpdate, handler: () => openForm(record) },
              { key: 'hapus', label: 'Hapus', show: canDelete, danger: true, confirm: 'Hapus asesmen?', handler: () => remove(record.id) },
            ]" />
          </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Asesmen' : 'Tambah Asesmen'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Kelas" required><a-select v-model:value="form.school_class_id" show-search :options="classOptions" :filter-option="filterOption" /></a-form-item>
        <a-form-item label="Judul" required><a-input v-model:value="form.title" /></a-form-item>
        <a-row :gutter="12">
          <a-col :span="8"><a-form-item label="Tipe"><a-select v-model:value="form.type" :options="['ulangan', 'tryout', 'tugas'].map((t) => ({ label: t, value: t }))" /></a-form-item></a-col>
          <a-col :span="8"><a-form-item label="Tanggal"><a-date-picker v-model:value="form.assessment_date" value-format="YYYY-MM-DD" style="width: 100%;" /></a-form-item></a-col>
          <a-col :span="8"><a-form-item label="Bobot"><a-input-number v-model:value="form.weight" :min="0" style="width: 100%;" /></a-form-item></a-col>
        </a-row>
        <a-form-item label="Mapel (opsional)"><a-select v-model:value="form.subject_id" allow-clear show-search :options="subjectOptions" :filter-option="filterOption" /></a-form-item>
      </a-form>
    </a-modal>
    <a-drawer v-model:open="gradeOpen" title="Input Nilai" width="560" placement="right">
      <div v-if="gradeData">
        <div class="att-head">{{ gradeData.assessment?.title }}</div>
        <div class="att-count">{{ gradeData.filled }} dari {{ gradeData.total }} terisi</div>
        <div v-for="item in gradeItems" :key="item.student.id" class="grade-row">
          <div class="att-name">{{ item.student.name }}<div class="att-nis">{{ item.student.nis }}</div></div>
          <a-input-number v-model:value="item.score" :min="0" :max="1000" style="width: 110px;" placeholder="Nilai" />
        </div>
        <a-button type="primary" block size="large" :loading="gradeSaving" class="grade-save" @click="saveGrades">Simpan Nilai</a-button>
      </div>
    </a-drawer>
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
const page = ref(1), classFilter = ref(null), open = ref(false), editing = ref(null)
const gradeOpen = ref(false), gradeTarget = ref(null), gradeData = ref(null), gradeItems = ref([]), gradeSaving = ref(false)
const form = reactive({ school_class_id: null, title: '', type: 'ulangan', assessment_date: null, weight: 1, subject_id: null })
const columns = [
  { title: 'Judul', dataIndex: 'title' },
  { title: 'Kelas', key: 'class', customRender: ({ record }) => record.school_class?.name || '-' },
  { title: 'Tipe', dataIndex: 'type' },
  { title: 'Terisi', key: 'filled', customRender: ({ record }) => record.grades_count || 0 },
  { title: 'Aksi', key: 'action' },
]
const canCreate = computed(() => authStore.can('assessments.create')), canUpdate = computed(() => authStore.can('assessments.update')), canDelete = computed(() => authStore.can('assessments.delete')), canGrade = computed(() => authStore.can('grades.update'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['assessments', classFilter.value, page.value]), queryFn: async () => (await api.get('/assessments', { params: { school_class_id: classFilter.value, page: page.value } })).data.data })
const { data: classes } = useQuery({ queryKey: ['classes-options'], queryFn: async () => (await api.get('/classes', { params: { per_page: 200 } })).data.data })
const { data: subjects } = useQuery({ queryKey: ['subjects-options'], queryFn: async () => (await api.get('/subjects', { params: { per_page: 200 } })).data.data })
const classOptions = computed(() => (classes.value?.data || []).map((c) => ({ label: c.name, value: c.id })))
const subjectOptions = computed(() => (subjects.value?.data || []).map((s) => ({ label: s.name, value: s.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; Object.assign(form, { school_class_id: record?.school_class_id || null, title: record?.title || '', type: record?.type || 'ulangan', assessment_date: record?.assessment_date ? String(record.assessment_date).slice(0, 10) : null, weight: record?.weight ?? 1, subject_id: record?.subject_id || null }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/assessments/${editing.value.id}`, form); else await api.post('/assessments', form); open.value = false; refetch(); message.success('Asesmen tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Asesmen gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/assessments/${id}`); refetch(); message.success('Asesmen dihapus') } catch { message.error('Asesmen gagal dihapus') } }
async function openGrades(record) {
  try {
    gradeTarget.value = record
    const { data } = await api.get(`/assessments/${record.id}/grades`)
    gradeData.value = data.data
    gradeItems.value = (data.data.items || []).map((i) => ({ student: i.student, score: i.score, note: i.note || '' }))
    gradeOpen.value = true
  } catch (e) { message.error(getApiErrorMessage(e, 'Gagal memuat nilai')) }
}
async function saveGrades() {
  gradeSaving.value = true
  try {
    await api.put(`/assessments/${gradeTarget.value.id}/grades`, { items: gradeItems.value.filter((i) => i.score !== null && i.score !== '').map((i) => ({ student_id: i.student.id, score: i.score, note: i.note })) })
    const done = gradeItems.value.filter((i) => i.score !== null && i.score !== '').length
    gradeData.value.filled = done
    refetch(); message.success('Nilai tersimpan')
  } catch (e) { message.error(getApiErrorMessage(e, 'Simpan nilai gagal')) } finally { gradeSaving.value = false }
}
</script>

<style scoped>
.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }
.att-head { font-weight: 800; font-size: 15px; margin-bottom: 4px; }
.att-count { color: #0b4da2; font-weight: 700; margin-bottom: 12px; }
.grade-row { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }
.att-name { font-weight: 600; }
.att-nis { font-size: 12px; color: #888; font-weight: 400; }
.grade-save { margin-top: 12px; }
</style>
