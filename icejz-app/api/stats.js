const { useUserPageApi, useOrgListApi, useRolePageApi } = require('@/api/sys.js')
const { useMessageMyPageApi, useMessageUnreadCountApi } = require('@/api/message.js')

function flattenOrg(nodes, acc = []) {
  ;(nodes || []).forEach((node) => {
    acc.push(node)
    if (node.children && node.children.length) flattenOrg(node.children, acc)
  })
  return acc
}

function dayKey(date) {
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`
}

function buildWeekBuckets() {
  const now = new Date()
  const buckets = []
  for (let i = 6; i >= 0; i--) {
    const d = new Date(now)
    d.setHours(0, 0, 0, 0)
    d.setDate(now.getDate() - i)
    buckets.push({
      key: dayKey(d),
      day: d.getDay(),
      value: 0
    })
  }
  return buckets
}

function parseTime(raw) {
  if (!raw) return null
  if (raw instanceof Date) return raw
  const text = String(raw).replace(/-/g, '/')
  const d = new Date(text)
  return Number.isNaN(d.getTime()) ? null : d
}

function emptyStats() {
  const week = buildWeekBuckets()
  return {
    metrics: [
      { key: 'user', label: '用户', value: 0, path: '/pages/sys/user/index' },
      { key: 'org', label: '机构', value: 0, path: '/pages/sys/org/index' },
      { key: 'role', label: '角色', value: 0, path: '/pages/sys/role/index' },
      { key: 'msg', label: '未读', value: 0, path: '/pages/message/inbox' }
    ],
    resourceBars: [
      { key: 'user', label: '用户', value: 0, color: '#00a8e8' },
      { key: 'org', label: '机构', value: 0, color: '#38bdf8' },
      { key: 'role', label: '角色', value: 0, color: '#0ea5e9' },
      { key: 'message', label: '消息', value: 0, color: '#0284c7' }
    ],
    messageRing: { percent: 0, read: 0, unread: 0, total: 0 },
    weekBars: week.map((d) => ({
      day: d.day,
      label: ['日', '一', '二', '三', '四', '五', '六'][d.day],
      value: 0,
      color: '#00a8e8'
    }))
  }
}

/**
 * 聚合首页统计（与 uniapp / 管理端同源接口）
 */
async function fetchHomeStats() {
  const week = buildWeekBuckets()
  const weekMap = Object.fromEntries(week.map((d) => [d.key, d]))
  const dayLabels = ['日', '一', '二', '三', '四', '五', '六']

  try {
    const [userRes, orgRes, roleRes, msgRes, unreadRes] = await Promise.all([
      useUserPageApi({ page: 1, limit: 100 }).catch(() => null),
      useOrgListApi().catch(() => null),
      useRolePageApi({ page: 1, limit: 100 }).catch(() => null),
      useMessageMyPageApi({ page: 1, limit: 50 }).catch(() => null),
      useMessageUnreadCountApi().catch(() => null)
    ])

    const users = (userRes && userRes.data && userRes.data.list) || []
    const userTotal = (userRes && userRes.data && userRes.data.total) != null ? userRes.data.total : users.length

    const orgs = flattenOrg((orgRes && orgRes.data) || [])
    const orgTotal = orgs.length

    const roles = (roleRes && roleRes.data && roleRes.data.list) || []
    const roleTotal = (roleRes && roleRes.data && roleRes.data.total) != null ? roleRes.data.total : roles.length

    const messages = (msgRes && msgRes.data && msgRes.data.list) || []
    const msgTotal = (msgRes && msgRes.data && msgRes.data.total) != null ? msgRes.data.total : messages.length
    const unread = (unreadRes && unreadRes.data) || 0
    const read = Math.max(0, msgTotal - unread)
    const percent = msgTotal > 0 ? Math.round((read / msgTotal) * 100) : 0

    messages.forEach((msg) => {
      const t = parseTime(msg.sendTime || msg.createTime)
      if (!t) return
      const key = dayKey(t)
      if (weekMap[key]) weekMap[key].value += 1
    })

    return {
      metrics: [
        { key: 'user', label: '用户', value: userTotal, path: '/pages/sys/user/index' },
        { key: 'org', label: '机构', value: orgTotal, path: '/pages/sys/org/index' },
        { key: 'role', label: '角色', value: roleTotal, path: '/pages/sys/role/index' },
        { key: 'msg', label: '未读', value: unread, path: '/pages/message/inbox' }
      ],
      resourceBars: [
        { key: 'user', label: '用户', value: userTotal, color: '#00a8e8' },
        { key: 'org', label: '机构', value: orgTotal, color: '#38bdf8' },
        { key: 'role', label: '角色', value: roleTotal, color: '#0ea5e9' },
        { key: 'message', label: '消息', value: msgTotal, color: '#0284c7' }
      ],
      messageRing: { percent, read, unread, total: msgTotal },
      weekBars: week.map((d) => ({
        day: d.day,
        label: dayLabels[d.day],
        value: d.value,
        color: d.value > 0 ? '#00a8e8' : '#bae6fd'
      }))
    }
  } catch (e) {
    return emptyStats()
  }
}

module.exports = {
  emptyStats,
  fetchHomeStats
}
