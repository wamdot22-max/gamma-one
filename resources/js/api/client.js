import axios from 'axios'
import { clearStoredAuth, getStoredToken } from '../utils/authStorage'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api/v1',
  headers: { 'Content-Type': 'application/json', 'Accept-Language': 'id' },
})

api.interceptors.request.use((config) => {
  const token = getStoredToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    const requestUrl = error.config?.url || ''
    if (error.response?.status === 401 && !requestUrl.includes('/auth/login')) {
      clearStoredAuth()
      if (typeof window !== 'undefined' && window.location.pathname !== '/login') window.location.replace('/login')
    }
    return Promise.reject(error)
  },
)

export default api



