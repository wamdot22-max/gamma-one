<template>
  <a-space>
    <template v-for="action in inlineActions" :key="action.key">
      <a-button v-if="useDropdown && action.circle" shape="circle" size="small" :title="action.label" @click="run(action)">
        <template #icon><component :is="action.icon || EditOutlined" /></template>
      </a-button>
      <a-button v-else size="small" :type="action.type || 'default'" @click="run(action)">{{ action.label }}</a-button>
    </template>
    <a-dropdown v-if="menuActions.length" trigger="click">
      <a-button shape="circle" size="small" title="Aksi lainnya">
        <template #icon><MoreOutlined /></template>
      </a-button>
      <template #overlay>
        <a-menu @click="onMenuClick">
          <a-menu-item v-for="action in menuActions" :key="action.key" :danger="!!action.danger">
            {{ action.label }}
          </a-menu-item>
        </a-menu>
      </template>
    </a-dropdown>
  </a-space>
</template>

<script setup>
import { computed } from 'vue'
import { EditOutlined, MoreOutlined } from '@ant-design/icons-vue'
import { Modal } from 'ant-design-vue'

// action: { key, label, icon?, show?, circle?, keep?, danger?, confirm?, href?, type?, handler? }
// - circle: tampil sebagai tombol lingkaran icon-only saat mode dropdown
// - keep: selalu tampil inline walau mode dropdown
// - confirm: tampilkan konfirmasi (teks/judul) sebelum handler dijalankan
const props = defineProps({ actions: { type: Array, default: () => [] } })

const visible = computed(() => props.actions.filter((action) => action.show !== false))
const useDropdown = computed(() => visible.value.length > 2)
const inlineActions = computed(() => {
  if (!useDropdown.value) return visible.value
  return visible.value.filter((action) => action.circle || action.keep)
})
const menuActions = computed(() => {
  if (!useDropdown.value) return []
  return visible.value.filter((action) => !(action.circle || action.keep))
})

function run(action) {
  if (action.href) {
    window.open(action.href, '_blank')
    return
  }
  if (action.confirm) {
    Modal.confirm({ title: typeof action.confirm === 'string' ? action.confirm : `Jalankan ${action.label}?`, okText: 'Ya', cancelText: 'Batal', onOk: () => action.handler?.() })
    return
  }
  action.handler?.()
}

function onMenuClick({ key }) {
  const action = menuActions.value.find((item) => item.key === key)
  if (action) run(action)
}
</script>
