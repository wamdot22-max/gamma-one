const TOKEN_KEY = 'auth_token'
const TOKEN_EXPIRY_KEY = 'auth_token_expires_at'

export function getStoredToken() {
  const token = localStorage.getItem(TOKEN_KEY) || sessionStorage.getItem(TOKEN_KEY)
  if (!token) return null

  // Bersihkan token kedaluwarsa di sisi klien agar tidak dikirim sia-sia.
  const expiry = localStorage.getItem(TOKEN_EXPIRY_KEY) || sessionStorage.getItem(TOKEN_EXPIRY_KEY)
  if (expiry && new Date(expiry).getTime() < Date.now()) {
    clearStoredAuth()
    return null
  }

  return token
}

export function storeToken(token, remember = false, expiresAt = null) {
  const target = remember ? localStorage : sessionStorage
  localStorage.removeItem(TOKEN_KEY)
  sessionStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(TOKEN_EXPIRY_KEY)
  sessionStorage.removeItem(TOKEN_EXPIRY_KEY)
  target.setItem(TOKEN_KEY, token)
  if (expiresAt) target.setItem(TOKEN_EXPIRY_KEY, expiresAt)
}

export function clearStoredAuth() {
  localStorage.removeItem(TOKEN_KEY)
  sessionStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(TOKEN_EXPIRY_KEY)
  sessionStorage.removeItem(TOKEN_EXPIRY_KEY)
}
