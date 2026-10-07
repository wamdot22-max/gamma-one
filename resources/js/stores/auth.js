import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import api from '../api/client'
import { clearStoredAuth, getStoredToken, storeToken } from '../utils/authStorage'

const PORTAL_ROLES = ['siswa', 'orang_tua']

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const permissions = ref([])
  const roles = ref([])
  const tutorId = ref(null)
  const loading = ref(true)

  const setAuthData = (payload = {}) => {
    user.value = payload.user || null
    permissions.value = payload.permissions || []
    roles.value = payload.roles || []
    tutorId.value = payload.tutor_id || null
  }

  const clearState = () => {
    user.value = null
    permissions.value = []
    roles.value = []
    tutorId.value = null
  }

  const login = async (identity, password, remember = false) => {
    const { data } = await api.post('/auth/login', { identity, password, remember })
    clearStoredAuth()
    storeToken(data.data.token, remember, data.data.token_expires_at)
    setAuthData(data.data)
  }

  const logout = async () => {
    try { await api.post('/auth/logout') } catch {}
    clearStoredAuth()
    clearState()
  }

  const refreshMe = async () => {
    if (!getStoredToken()) return
    try {
      const { data } = await api.get('/auth/me')
      setAuthData(data.data)
    } catch {
      clearStoredAuth()
      clearState()
    }
  }

  const forgotPassword = (identity) => api.post('/auth/forgot-password', { identity })
  const resetPassword = (payload) => api.post('/auth/reset-password', payload)

  const can = (permission) => permissions.value.includes(permission)
  const hasRole = (role) => roles.value.includes(role)
  const isPortalUser = computed(() => roles.value.some((role) => PORTAL_ROLES.includes(role)))
  const homePath = computed(() => (isPortalUser.value ? '/portal' : '/dashboard'))

  return { user, permissions, roles, tutorId, loading, login, logout, refreshMe, forgotPassword, resetPassword, can, hasRole, isPortalUser, homePath }
})
