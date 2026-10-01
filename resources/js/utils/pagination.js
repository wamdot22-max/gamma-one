export function formatPaginationTotal(total, range) {
  if (!total || !range?.length) {
    return 'Belum ada data'
  }

  return `Menampilkan ${range[0]}-${range[1]} dari ${total} data`
}
