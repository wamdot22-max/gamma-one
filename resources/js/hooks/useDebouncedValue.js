import { ref, watch } from 'vue'

export default function useDebouncedValue(valueRef, delay = 500) {
  const debouncedValue = ref(valueRef.value)
  let timeout
  watch(valueRef, (newValue) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => {
      debouncedValue.value = newValue
    }, delay)
  })
  return debouncedValue
}
