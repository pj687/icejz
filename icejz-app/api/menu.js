const request = require('@/utils/request.js')

/** clientType: 0PC 1APP 2小程序 — 本工程为微信小程序，默认 2 */
const useMenuNavApi = (clientType = 2) => {
  return request.get('/sys/menu/nav', { clientType })
}

const flattenMenuLeaves = (nodes = []) => {
  const list = []
  const walk = (arr) => {
    ;(arr || []).forEach((item) => {
      const children = item.children || item.childList || []
      if (children.length) {
        walk(children)
      } else if (item.url) {
        list.push({
          id: item.id,
          name: item.name,
          path: item.url,
          icon: item.icon || '/images/icons/user.svg',
          sort: item.sort || 0
        })
      }
    })
  }
  walk(nodes)
  return list.sort((a, b) => a.sort - b.sort)
}

module.exports = {
  useMenuNavApi,
  flattenMenuLeaves
}
