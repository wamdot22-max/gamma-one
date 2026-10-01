<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Tugas</a-typography-title>
      <a-button v-if="canCreate" type="primary" @click="openForm()">Tambah Tugas</a-button>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
        <template #bodyCell="{ column, record }">
          <a-space v-if="column.key === 'action'" wrap>
          <RowActions :actions="[
            { key: 'pengumpulan', label: `Pengumpulan (${record.submissions_count || 0})`, show: true, handler: () => openDetail(record) },
            { key: 'edit', label: 'Edit', circle: true, show: canUpdate, handler: () => openForm(record) },
            { key: 'hapus', label: 'Hapus', show: canDelete, danger: true, confirm: 'Hapus tugas?', handler: () => remove(record.id) },
          ]" />
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="open" :title="editing ? 'Edit Tugas' : 'Tambah Tugas'" @ok="save">
      <a-form layout="vertical">
        <a-form-item label="Kelas" required><a-select v-model:value="form.school_class_id" show-search :options="classOptions" :filter-option="filterOption" /></a-form-item>
        <a-form-item label="Judul" required><a-input v-model:value="form.title" /></a-form-item>
        <a-form-item label="Deskripsi"><a-textarea v-model:value="form.description" :rows="2" /></a-form-item>
        <a-form-item label="Deadline"><a-date-picker v-model:value="form.deadline" show-time value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%;" /></a-form-item>
      </a-form>
    </a-modal>
    <a-drawer v-model:open="detailOpen" title="Pengumpulan" :width="drawerWidth" placement="right">
      <div v-if="!submissions?.length" class="empty">Belum ada pengumpulan.</div>
      <div v-for="s in (submissions || [])" :key="s.id" class="sub-row">
        <div><b>{{ s.student?.name }}</b> ({{ s.student?.nis }})<div class="sub-time">{{ s.submitted_at }}</div></div>
        <a-button size="small" type="link" :href="s.file_url" target="_blank">Berkas</a-button>
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
import { useDrawerWidth } from '../../hooks/useDrawerWidth'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

const authStore = useAuthStore()
const drawerWidth = useDrawerWidth(520)
const page = ref(1), open = ref(false), editing = ref(null), detailOpen = ref(false), submissions = ref([])
const form = reactive({ school_class_id: null, title: '', description: '', deadline: null })
const columns = [
  { title: 'Judul', dataIndex: 'title' },
  { title: 'Kelas', key: 'class', customRender: ({ record }) => record.school_class?.name || '-' },
  { title: 'Deadline', dataIndex: 'deadline' },
  { title: 'Aksi', key: 'action' },
]
const canCreate = computed(() => authStore.can('assignments.create')), canUpdate = computed(() => authStore.can('assignments.update')), canDelete = computed(() => authStore.can('assignments.delete'))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['assignments', page.value]), queryFn: async () => (await api.get('/assignments', { params: { page: page.value } })).data.data })
const { data: classes } = useQuery({ queryKey: ['classes-options'], queryFn: async () => (await api.get('/classes', { params: { per_page: 200 } })).data.data })
const classOptions = computed(() => (classes.value?.data || []).map((c) => ({ label: c.name, value: c.id })))
const filterOption = (input, option) => String(option?.label || '').toLowerCase().includes(input.toLowerCase())
function openForm(record = null) { editing.value = record; Object.assign(form, { school_class_id: record?.school_class_id || null, title: record?.title || '', description: record?.description || '', deadline: record?.deadline || null }); open.value = true }
async function save() { try { if (editing.value) await api.put(`/assignments/${editing.value.id}`, form); else await api.post('/assignments', form); open.value = false; refetch(); message.success('Tugas tersimpan') } catch (e) { message.error(getApiErrorMessage(e, 'Tugas gagal disimpan')) } }
async function remove(id) { try { await api.delete(`/assignments/${id}`); refetch(); message.success('Tugas dihapus') } catch { message.error('Tugas gagal dihapus') } }
async function openDetail(record) {
  try {
    const { data } = await api.get(`/assignments/${record.id}`)
    submissions.value = data.data.submissions || []
    detailOpen.value = true
  } catch { message.error('Gagal memuat pengumpulan') }
}
</script>

<style scoped>
.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }
.empty { color: #aaa; text-align: center; }
.sub-row { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }
.sub-time { font-size: 12px; color: #888; }
</style>
