<template>
  <div>
    <a-space class="toolbar">
      <a-typography-title :level="3">Log Notifikasi</a-typography-title>
      <a-space wrap>
        <a-select v-model:value="statusFilter" allow-clear :options="['pending', 'terkirim', 'gagal'].map((s) => ({ label: s, value: s }))" placeholder="Status" style="width: 130px;" @change="refetch" />
        <a-select v-model:value="channelFilter" allow-clear :options="[{ label: 'WA', value: 'wa' }, { label: 'Email', value: 'email' }]" placeholder="Kanal" style="width: 110px;" @change="refetch" />
        <a-checkbox v-model:checked="followUpOnly" @change="refetch">Perlu tindak lanjut</a-checkbox>
      </a-space>
    </a-space>
    <a-table row-key="id" :loading="isLoading" :data-source="data?.data || []" :columns="columns" :pagination="{ current: data?.current_page, pageSize: data?.per_page, total: data?.total }" @change="({ current }) => page = current">
      <template #bodyCell="{ column, record }">
        <span v-if="column.key === 'to'">{{ record.user?.name || record.phone || record.email }}</span>
        <a-tag v-else-if="column.key === 'channel'" :color="record.channel === 'wa' ? 'green' : 'blue'">{{ record.channel }}</a-tag>
        <a-tag v-else-if="column.key === 'status'" :color="statusColor(record.status)">{{ record.status }}</a-tag>
        <a-tag v-else-if="column.key === 'follow'" color="volcano">Ya</a-tag>
        <a-space v-else-if="column.key === 'action'">
          <a-button v-if="canRetry && record.status !== 'terkirim'" size="small" @click="retry(record.id)">Kirim ulang</a-button>
          <a-button size="small" type="link" @click="openDetail(record)">Detail</a-button>
        </a-space>
      </template>
    </a-table>
    <a-modal v-model:open="detailOpen" title="Isi Pesan" :footer="null">
      <div v-if="detail">
        <div class="detail-body">{{ detail.body }}</div>
        <div v-if="detail.error" class="detail-error">Galat: {{ detail.error }}</div>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { message } from 'ant-design-vue'
import api from '../../api/client'
import { useAuthStore } from '../../stores/auth'
import { getApiErrorMessage } from '../../utils/apiError'

const authStore = useAuthStore()
const page = ref(1), statusFilter = ref(null), channelFilter = ref(null), followUpOnly = ref(false)
const detailOpen = ref(false), detail = ref(null)
const columns = [
  { title: 'Waktu', dataIndex: 'created_at' },
  { title: 'Tujuan', key: 'to' },
  { title: 'Kanal', key: 'channel' },
  { title: 'Template', dataIndex: 'template_key' },
  { title: 'Status', key: 'status' },
  { title: 'Tindak Lanjut', key: 'follow', customRender: ({ record }) => (record.needs_follow_up ? 'Ya' : '') },
  { title: 'Aksi', key: 'action' },
]
const canRetry = computed(() => authStore.can('notifications.update'))
const params = computed(() => ({ page: page.value, status: statusFilter.value, channel: channelFilter.value, needs_follow_up: followUpOnly.value || undefined }))
const { data, isLoading, refetch } = useQuery({ queryKey: computed(() => ['notifications', statusFilter.value, channelFilter.value, followUpOnly.value, page.value]), queryFn: async () => (await api.get('/notifications', { params: params.value })).data.data })
const statusColor = (s) => ({ pending: 'orange', terkirim: 'green', gagal: 'red' }[s] || 'default')
function openDetail(record) { detail.value = record; detailOpen.value = true }
async function retry(id) { try { await api.post(`/notifications/${id}/retry`); refetch(); message.success('Dimasukkan antrean ulang') } catch (e) { message.error(getApiErrorMessage(e, 'Gagal kirim ulang')) } }
</script>

<style scoped>
.toolbar { width: 100%; justify-content: space-between; margin-bottom: 16px; }
.detail-body { white-space: pre-wrap; background: #f6f6f6; padding: 12px; border-radius: 8px; }
.detail-error { color: #c00; margin-top: 8px; }
</style>
