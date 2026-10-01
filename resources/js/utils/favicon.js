const iconMimeType = (url) => {
  const extension = url.split('?')[0].split('.').pop()?.toLowerCase()

  return ({
    ico: 'image/x-icon',
    png: 'image/png',
    svg: 'image/svg+xml',
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    webp: 'image/webp',
  })[extension] || 'image/x-icon'
}

export const applyFavicon = (faviconUrl, version = '') => {
  if (!faviconUrl || typeof document === 'undefined') return

  const resolvedUrl = new URL(faviconUrl, window.location.origin)
  if (version) resolvedUrl.searchParams.set('v', version)

  let icon = document.querySelector("link[rel~='icon']")
  if (!icon) {
    icon = document.createElement('link')
    icon.rel = 'icon'
    document.head.appendChild(icon)
  }

  icon.type = iconMimeType(faviconUrl)
  icon.href = resolvedUrl.toString()
}
