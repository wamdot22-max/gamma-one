import { onMounted, onUnmounted, ref } from 'vue'

// Lebar drawer responsif: maksimal `max`, tapi tak lebih lebar dari layar.
// Pengganti aturan CSS global untuk class internal Ant Design.
export function useDrawerWidth(max = 520) {
  const width = ref(typeof window === 'undefined' ? max : Math.min(max, window.innerWidth))
  const onResize = () => {
    width.value = Math.min(max, window.innerWidth)
  }
  onMounted(() => window.addEventListener('resize', onResize))
  onUnmounted(() => window.removeEventListener('resize', onResize))
  return width
}
