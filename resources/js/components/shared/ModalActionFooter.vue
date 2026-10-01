<template>
  <div class="modal-action-footer">
    <a-button :disabled="cancelDisabled" @click="$emit('cancel')">
      <template #icon><CloseOutlined /></template>
      {{ cancelText }}
    </a-button>
    <a-button type="primary" :loading="confirmLoading" :disabled="confirmDisabled" @click="$emit('confirm')">
      <template #icon><SaveOutlined /></template>
      {{ confirmText }}
    </a-button>
  </div>
</template>

<script setup>
import { CloseOutlined, SaveOutlined } from '@ant-design/icons-vue'

defineProps({
  cancelText: {
    type: String,
    default: 'Batal'
  },
  confirmText: {
    type: String,
    default: 'Simpan'
  },
  confirmLoading: {
    type: Boolean,
    default: false
  },
  confirmDisabled: {
    type: Boolean,
    default: false
  },
  cancelDisabled: {
    type: Boolean,
    default: false
  }
})

defineEmits(['cancel', 'confirm'])
</script>

<style scoped>
.modal-action-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  width: 100%;
}
</style>
