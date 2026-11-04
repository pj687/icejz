import { useUserPageApi, useOrgListApi, useRolePageApi } from './sys.js'
import { useMessageMyPageApi, useMessageUnreadCountApi } from './message.js'

function flattenOrg(nodes, acc = []) {
  ;(nodes || []).forEach((node) => {
    acc.push(node)
    if (node.children?.length) flattenOrg(node.children, acc)
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

/**
 * 聚合首页 / 工作台统计（复用现有管理端同源接口）
 */
export async function fetchHomeStats() {
  const week = buildWeekBuckets()
  const weekMap = Object.fromEntries(week.map((d) => [d.key, d]))

  const empty = {
    metrics: [
      { key: 'user', value: 0, path: '/pages/sys/user/index' },
      { key: 'org', value: 0, path: '/pages/sys/org/index' },
      { key: 'role', value: 0, path: '/pages/sys/role/index' },
      { key: 'msg', value: 0, path: '/pages/message/inbox' }
    ],
    resourceBars: [
      { key: 'user', value: 0, color: '#00a8e8' },
      { key: 'org', value: 0, color: '#38bdf8' },
      { key: 'role', value: 0, color: '#0ea5e9' },
      { key: 'message', value: 0, color: '#0284c7' }
    ],
    userStatus: [
      { key: 'normal', value: 0, color: '#00a8e8' },
      { key: 'disabled', value: 0, color: '#94a3b8' }
    ],
    messageRing: {
      percent: 0,
      read: 0,
      unread: 0,
      total: 0
    },
    weekBars: week.map((d) => ({ day: d.day, value: 0, color: '#00a8e8' })),
    loading: false
  }

  try {
    const [userRes, orgRes, roleRes, msgRes, unreadRes] = await Promise.all([
      useUserPageApi({ page: 1, limit: 100 }).catch(() => null),
      useOrgListApi().catch(() => null),
      useRolePageApi({ page: 1, limit: 100 }).catch(() => null),
      useMessageMyPageApi({ page: 1, limit: 50 }).catch(() => null),
      useMessageUnreadCountApi().catch(() => null)
    ])

    const users = userRes?.data?.list || []
    const userTotal = userRes?.data?.total ?? users.length
    const active = users.filter((u) => u.status === 1).length
    const disabled = users.filter((u) => u.status !== 1).length

    const orgs = flattenOrg(orgRes?.data || [])
    const orgTotal = orgs.length

    const roles = roleRes?.data?.list || []
    const roleTotal = roleRes?.data?.total ?? roles.length

    const messages = msgRes?.data?.list || []
    const msgTotal = msgRes?.data?.total ?? messages.length
    const unread = unreadRes?.data || 0
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
        { key: 'user', value: userTotal, path: '/pages/sys/user/index' },
        { key: 'org', value: orgTotal, path: '/pages/sys/org/index' },
        { key: 'role', value: roleTotal, path: '/pages/sys/role/index' },
        { key: 'msg', value: unread, path: '/pages/message/inbox' }
      ],
      resourceBars: [
        { key: 'user', value: userTotal, color: '#00a8e8' },
        { key: 'org', value: orgTotal, color: '#38bdf8' },
        { key: 'role', value: roleTotal, color: '#0ea5e9' },
        { key: 'message', value: msgTotal, color: '#0284c7' }
      ],
      userStatus: [
        { key: 'normal', value: active, color: '#00a8e8' },
        { key: 'disabled', value: disabled, color: '#94a3b8' }
      ],
      messageRing: { percent, read, unread, total: msgTotal },
      weekBars: week.map((d) => ({
        day: d.day,
        value: d.value,
        color: d.value > 0 ? '#00a8e8' : '#bae6fd'
      })),
      loading: false
    }
  } catch (e) {
    return { ...empty, loading: false }
  }
}
