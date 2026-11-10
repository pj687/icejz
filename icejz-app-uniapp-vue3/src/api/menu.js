import * as request from '../utils/request.js'

/**
 * 拉取当前用户菜单导航
 * @param {number} clientType 0PC 1APP 2小程序
 */
export const useMenuNavApi = (clientType = 1) => {
  return request.get('/sys/menu/nav', { clientType })
}

/** 展平菜单树，仅保留带 url 的叶子入口 */
export const flattenMenuLeaves = (nodes = []) => {
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
          icon: item.icon || '/static/icons/user.svg',
          sort: item.sort || 0
        })
      }
    })
  }
  walk(nodes)
  return list.sort((a, b) => a.sort - b.sort)
}
