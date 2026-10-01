export function getApiErrorMessage(error, fallback = 'Permintaan gagal diproses') {
  const data = error?.response?.data
  const validationMessage = Object.values(data?.errors || {}).flat().find(Boolean)
  const raw = (validationMessage || data?.message || error?.message || fallback || '').toString()
  const lower = raw.toLowerCase()
  const status = error?.response?.status

  if (status === 401 || lower.includes('unauthenticated')) {
    if (error?.config?.url?.includes('/auth/login')) {
      return 'Email atau password yang Anda masukkan salah'
    }
    return 'Sesi login berakhir, silakan login ulang'
  }
  if (status === 403 || lower.includes('forbidden') || lower.includes('this action is unauthorized')) return 'Anda tidak memiliki akses untuk aksi ini'
  if (status === 404 || lower.includes('not found')) return 'Data yang diminta tidak ditemukan'
  if (status === 419) return 'Sesi Anda telah berakhir, silakan muat ulang halaman'
  if (status === 429 || lower.includes('too many requests')) return 'Terlalu banyak permintaan, coba lagi sebentar'
  if (status >= 500) return 'Terjadi gangguan pada server, silakan coba lagi'
  if (lower.includes('network error')) return 'Gagal terhubung ke server'
  if (lower.includes('duplicate') || lower.includes('already been taken') || lower.includes('unique')) return 'Data duplikat, gunakan nilai lain'
  if (lower.includes('the given data was invalid') || lower.includes('validation')) return 'Data tidak valid, periksa kembali form'
  if (status === 422) return toIndonesianValidationMessage(raw) || 'Data tidak valid, periksa kembali form'

  return toIndonesianValidationMessage(raw) || fallback
}

export function toIndonesianValidationMessage(message) {
  const lower = message.toLowerCase()
  if (lower.includes('has already been taken') || lower.includes('already exists')) return 'Nilai ini sudah digunakan'
  if (lower.includes('is required') || lower.includes('required field')) return 'Kolom ini wajib diisi'
  if (lower.includes('must be a valid email')) return 'Format email tidak valid'
  if (lower.includes('must be at least')) return 'Nilai belum memenuhi batas minimum'
  if (lower.includes('must not be greater than')) return 'Nilai melebihi batas maksimum'
  if (lower.includes('must be a number')) return 'Nilai harus berupa angka'
  if (lower.includes('must be an integer')) return 'Nilai harus berupa bilangan bulat'
  if (lower.includes('must be a valid date')) return 'Format tanggal tidak valid'
  if (lower.includes('must be') || lower.includes('is invalid') || lower.includes('invalid')) return 'Format data tidak sesuai'
  if (/\b(the|this|there|has|have|was|were|with|from|not|no|could|should|please|unable|failed|error|exception)\b/i.test(message)) return 'Permintaan gagal diproses'
  return message
}
