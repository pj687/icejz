const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { useMessageLatestApi } = require('@/api/message.js')
const {
  useWorkbenchNoteListApi,
  useWorkbenchNoteSaveApi,
  useWorkbenchNoteDeleteApi
} = require('@/api/workbench.js')

const pad2 = (n) => String(n).padStart(2, '0')
const toDateKey = (y, m, d) => `${y}-${pad2(m + 1)}-${pad2(d)}`

function weekFull() {
  return [
    t('stats.daySun'),
    t('stats.dayMon'),
    t('stats.dayTue'),
    t('stats.dayWed'),
    t('stats.dayThu'),
    t('stats.dayFri'),
    t('stats.daySat')
  ]
}

function weekHeaders() {
  return [
    t('stats.dayMon'),
    t('stats.dayTue'),
    t('stats.dayWed'),
    t('stats.dayThu'),
    t('stats.dayFri'),
    t('stats.daySat'),
    t('stats.daySun')
  ]
}

function noteTypes() {
  return [
    { key: 'nudge', label: t('workbench.typeNudge') },
    { key: 'memo', label: t('workbench.typeMemo') },
    { key: 'remind', label: t('workbench.typeRemind') }
  ]
}

function placeholders() {
  return {
    nudge: t('workbench.phNudge'),
    memo: t('workbench.phMemo'),
    remind: t('workbench.phRemind')
  }
}

function buildSparkOption(values, color) {
  return {
    animation: false,
    grid: { left: 0, right: 0, top: 4, bottom: 2 },
    xAxis: { type: 'category', show: false, data: values.map((_, i) => i) },
    yAxis: { type: 'value', show: false, min: 'dataMin', max: 'dataMax' },
    series: [
      {
        type: 'line',
        data: values,
        smooth: true,
        symbol: 'none',
        lineStyle: { width: 2, color },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(0,168,232,0.30)' },
              { offset: 1, color: 'rgba(0,168,232,0.02)' }
            ]
          }
        }
      }
    ]
  }
}

Page({
  data: {
    copy: {},
    statusBarPx: 20,
    capsulePadPx: 96,
    avatar: '/images/logo.png',
    displayName: '',
    username: '',
    orgName: '',
    postName: '',
    badgeMeta: '',
    greetText: '',
    helloText: '',
    weekDay: '',
    todayLabel: '',
    todayKey: '',
    viewYear: 0,
    viewMonth: 0,
    monthLabel: '',
    monthTitle: '',
    selectedDateKey: '',
    selectedDateLabel: '',
    selectedDayNum: 1,
    selectedDayShort: '',
    selectedDayTags: [],
    writeForDayText: '',
    weekHeaders: weekHeaders(),
    calendarDays: [],
    notes: [],
    selectedNotes: [],
    draftType: 'nudge',
    draftTypeLabel: '',
    draftText: '',
    draftPlaceholder: '',
    addNoteText: '',
    noteMetaText: '',
    focusCountText: '',
    agendaPulse: false,
    noteSaving: false,
    noteTypes: noteTypes(),
    messages: [],
    kpiList: [],
    quickNav: [],
    projects: [],
    todos: []
  },

  onLoad() {
    try {
      const sys = wx.getSystemInfoSync()
      let capsulePadPx = 96
      try {
        const menu = wx.getMenuButtonBoundingClientRect()
        if (menu && menu.left) {
          capsulePadPx = Math.max(72, Math.ceil(sys.windowWidth - menu.left + 8))
        }
      } catch (e) {
        // ignore
      }
      this.setData({
        statusBarPx: sys.statusBarHeight || 20,
        capsulePadPx
      })
    } catch (e) {
      this.setData({ statusBarPx: 20, capsulePadPx: 96 })
    }
    const now = new Date()
    const todayKey = toDateKey(now.getFullYear(), now.getMonth(), now.getDate())
    this.setData({
      viewYear: now.getFullYear(),
      viewMonth: now.getMonth(),
      selectedDateKey: todayKey,
      todayKey,
      weekDay: weekFull()[now.getDay()],
      todayLabel: `${now.getMonth() + 1}/${now.getDate()}`
    })
    this.refreshI18n()
    this.refreshHeader()
    this.refreshKpi()
    this.rebuildCalendar()
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().init()
    }
    this.refreshI18n()
    this.loadUser()
    this.fetchNotes()
    this.loadLatestMessages()
  },

  refreshI18n() {
    const types = noteTypes()
    const ph = placeholders()
    const draftType = this.data.draftType || 'nudge'
    const draftTypeLabel = (types.find((x) => x.key === draftType) || types[0]).label
    const projects = [
      {
        id: 1,
        title: t('workbench.project1Title'),
        desc: t('workbench.project1Desc'),
        percent: 72,
        daysLeft: 3,
        daysLeftText: t('workbench.daysLeft', { n: 3 }),
        tone: 'blue',
        path: '/pages/sys/role/index'
      },
      {
        id: 2,
        title: t('workbench.project2Title'),
        desc: t('workbench.project2Desc'),
        percent: 58,
        daysLeft: 5,
        daysLeftText: t('workbench.daysLeft', { n: 5 }),
        tone: 'teal',
        path: '/pages/message/inbox'
      },
      {
        id: 3,
        title: t('workbench.project3Title'),
        desc: t('workbench.project3Desc'),
        percent: 36,
        daysLeft: 2,
        daysLeftText: t('workbench.daysLeft', { n: 2 }),
        tone: 'amber',
        path: '/pages/sys/org/index'
      }
    ]
    this.setData({
      copy: {
        statusLine: t('workbench.statusLine'),
        cardBrandSub: t('workbench.cardBrandSub'),
        cardOnDuty: t('workbench.cardOnDuty'),
        cardOrgEmpty: t('workbench.cardOrgEmpty'),
        cardPostEmpty: t('workbench.cardPostEmpty'),
        cardNoAccount: t('workbench.cardNoAccount'),
        trendUp: t('workbench.trendUp'),
        suggestTitle: t('workbench.suggestTitle'),
        suggestBody: t('workbench.suggestBody'),
        suggestAction: t('workbench.suggestAction'),
        quickNav: t('workbench.quickNav'),
        focusTitle: t('workbench.focusTitle'),
        focusSub: t('workbench.focusSub'),
        enter: t('workbench.enter'),
        calendarSub: t('workbench.calendarSub'),
        dayNotes: t('workbench.dayNotes'),
        noteEmpty: t('workbench.noteEmpty'),
        delete: t('workbench.delete'),
        todoTitle: t('workbench.todoTitle'),
        todoSub: t('workbench.todoSub'),
        handle: t('workbench.handle'),
        msgTitle: t('workbench.msgTitle'),
        msgSub: t('workbench.msgSub'),
        msgAll: t('workbench.msgAll'),
        msgEmpty: t('workbench.msgEmpty'),
        saving: t('workbench.saving'),
        today: t('workbench.today'),
        thisMonth: t('workbench.thisMonth'),
        selectedDayHint: t('workbench.selectedDayHint'),
        typeNudge: t('workbench.typeNudge'),
        typeMemo: t('workbench.typeMemo')
      },
      weekHeaders: weekHeaders(),
      noteTypes: types,
      draftTypeLabel,
      draftPlaceholder: ph[draftType],
      addNoteText: this.data.noteSaving
        ? t('workbench.saving')
        : t('workbench.addNote', { type: draftTypeLabel }),
      focusCountText: t('workbench.focusCount', { n: projects.length }),
      noteMetaText: this.data.selectedNotes.length
        ? t('workbench.noteCount', { n: this.data.selectedNotes.length })
        : t('workbench.noteNone'),
      quickNav: [
        { name: t('workbench.userManage'), path: '/pages/sys/user/index', icon: '/images/icons/user.svg' },
        { name: t('workbench.myMsg'), path: '/pages/message/inbox', icon: '/images/icons/msg.svg' },
        { name: t('workbench.assistant'), path: '/pages/assistant/chat', icon: '/images/mascot/xiaobing-head.png' },
        { name: t('workbench.profile'), path: '/pages/usercenter/userinfo/userinfo', icon: '/images/icons/profile.svg' }
      ],
      projects,
      todos: [
        { id: 1, title: t('workbench.todo1'), time: t('workbench.timeToday', { t: '10:20' }), level: 'high', path: '/pages/sys/user/index' },
        { id: 2, title: t('workbench.todo2'), time: t('workbench.timeToday', { t: '11:05' }), level: 'mid', path: '/pages/message/inbox' },
        { id: 3, title: t('workbench.todo3'), time: t('workbench.timeYesterday', { t: '16:40' }), level: 'mid', path: '/pages/sys/org/index' },
        { id: 4, title: t('workbench.todo4'), time: t('workbench.timeYesterday', { t: '09:15' }), level: 'low', path: '/pages/usercenter/userinfo/userinfo' }
      ]
    })
  },

  storageKey() {
    const user = cache.getUserInfo() || {}
    const id = user.username || user.id || 'guest'
    return `icejz-workbench-notes:${id}`
  },

  loadUser() {
    const user = cache.getUserInfo() || {}
    const h = new Date().getHours()
    let greet = t('greet.hi')
    if (h < 6) greet = t('greet.late')
    else if (h < 12) greet = t('greet.morning')
    else if (h < 14) greet = t('greet.noon')
    else if (h < 18) greet = t('greet.afternoon')
    else greet = t('greet.evening')
    const name = user.realName || user.username || t('common.user')
    const posts = user.postNameList
    const postName =
      (Array.isArray(posts) && posts.length && posts[0]) || user.postName || ''
    const orgName = user.orgName || ''
    const username = user.username || ''
    const badgeMeta = [orgName || t('workbench.cardOrgEmpty'), postName || t('workbench.cardPostEmpty')]
      .filter(Boolean)
      .join(' · ')
    this.setData({
      avatar: user.avatar || '/images/logo.png',
      displayName: name,
      username,
      orgName,
      postName,
      badgeMeta,
      greetText: greet,
      helloText: t('workbench.hello', { greet, name })
    })
  },

  refreshHeader() {
    const { viewYear, viewMonth, selectedDateKey, todayKey, selectedNotes } = this.data
    const [y, m, d] = String(selectedDateKey || '')
      .split('-')
      .map(Number)
    const tip =
      selectedDateKey === todayKey
        ? t('workbench.today')
        : weekFull()[new Date(y, m - 1, d).getDay()]
    const selectedDayShort = Number.isFinite(m) && Number.isFinite(d) ? `${m}月${d}日` : ''
    this.setData({
      monthLabel: `${viewYear}-${pad2(viewMonth + 1)}`,
      monthTitle: `${viewMonth + 1} 月`,
      selectedDayNum: Number.isFinite(d) ? d : 1,
      selectedDayShort,
      selectedDateLabel: Number.isFinite(y)
        ? `${y}年${m}月${d}日 · ${tip}`
        : '',
      writeForDayText: t('workbench.writeForDay', { date: selectedDayShort }),
      noteMetaText: (selectedNotes || []).length
        ? t('workbench.noteCount', { n: selectedNotes.length })
        : t('workbench.noteNone')
    })
  },

  pulseAgenda() {
    this.setData({ agendaPulse: false })
    clearTimeout(this._agendaPulseTimer)
    this._agendaPulseTimer = setTimeout(() => {
      this.setData({ agendaPulse: true })
      this._agendaPulseTimer = setTimeout(() => {
        this.setData({ agendaPulse: false })
      }, 420)
    }, 16)
  },

  ensureSelectionInView() {
    const { viewYear, viewMonth, selectedDateKey, todayKey } = this.data
    const [sy, sm] = String(selectedDateKey || '')
      .split('-')
      .map(Number)
    if (sy === viewYear && sm === viewMonth + 1) return selectedDateKey
    const today = new Date()
    if (today.getFullYear() === viewYear && today.getMonth() === viewMonth) {
      return todayKey || toDateKey(today.getFullYear(), today.getMonth(), today.getDate())
    }
    return toDateKey(viewYear, viewMonth, 1)
  },

  refreshKpi() {
    const { projects, todos, notes } = this.data
    this.setData({
      focusCountText: t('workbench.focusCount', { n: projects.length }),
      kpiList: [
        {
          key: 'focus',
          label: t('workbench.metricFocus'),
          value: projects.length,
          canvasId: 'wb-spark-focus',
          sparkOption: buildSparkOption([36, 48, 42, 58, 64, 72, 70], '#00a8e8')
        },
        {
          key: 'todo',
          label: t('workbench.metricTodo'),
          value: todos.length,
          canvasId: 'wb-spark-todo',
          sparkOption: buildSparkOption([28, 40, 52, 44, 60, 55, 68], '#0ea5e9')
        },
        {
          key: 'note',
          label: t('workbench.metricNote'),
          value: notes.length,
          canvasId: 'wb-spark-note',
          sparkOption: buildSparkOption([22, 30, 26, 38, 45, 40, 52], '#38bdf8')
        }
      ]
    })
  },

  notesByDateMap(notes) {
    const map = {}
    ;(notes || []).forEach((note) => {
      if (!map[note.dateKey]) map[note.dateKey] = []
      map[note.dateKey].push(note)
    })
    return map
  },

  rebuildCalendar() {
    const { viewYear: y, viewMonth: m, todayKey, notes, selectedDateKey } = this.data
    const byDate = this.notesByDateMap(notes)
    const first = new Date(y, m, 1)
    const start = (first.getDay() + 6) % 7
    const daysInMonth = new Date(y, m + 1, 0).getDate()
    const prevDays = new Date(y, m, 0).getDate()
    const list = []

    for (let i = start - 1; i >= 0; i--) {
      const n = prevDays - i
      const pm = m === 0 ? 11 : m - 1
      const py = m === 0 ? y - 1 : y
      const dateKey = toDateKey(py, pm, n)
      const tags = this.buildDayTags(dateKey, byDate)
      const noteCount = (byDate[dateKey] || []).length
      list.push({
        key: `p-${i}`,
        n,
        current: false,
        today: false,
        noteCount,
        tags,
        dateKey
      })
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const dateKey = toDateKey(y, m, d)
      const tags = this.buildDayTags(dateKey, byDate)
      const noteCount = (byDate[dateKey] || []).length
      list.push({
        key: `c-${d}`,
        n: d,
        current: true,
        today: dateKey === todayKey,
        noteCount,
        tags,
        dateKey
      })
    }
    let next = 1
    const nm = m === 11 ? 0 : m + 1
    const ny = m === 11 ? y + 1 : y
    while (list.length % 7 !== 0) {
      const n = next++
      const dateKey = toDateKey(ny, nm, n)
      const tags = this.buildDayTags(dateKey, byDate)
      const noteCount = (byDate[dateKey] || []).length
      list.push({
        key: `n-${list.length}`,
        n,
        current: false,
        today: false,
        noteCount,
        tags,
        dateKey
      })
    }

    const selectedNotes = (byDate[selectedDateKey] || []).map((item) => ({
      ...item,
      typeLabel: this.noteTypeLabel(item.type)
    }))
    const selectedDayTags = this.buildDayTags(selectedDateKey, byDate).map((tag) => ({
      key: tag.key,
      label: this.noteTypeLabel(tag.key)
    }))

    this.setData({
      calendarDays: list,
      selectedNotes,
      selectedDayTags,
      noteMetaText: selectedNotes.length
        ? t('workbench.noteCount', { n: selectedNotes.length })
        : t('workbench.noteNone')
    })
    this.refreshHeader()
    this.refreshKpi()
  },

  noteTypeLabel(type) {
    const hit = noteTypes().find((item) => item.key === type)
    return hit ? hit.label : t('workbench.typeMemo')
  },

  noteTagShort(type) {
    if (type === 'nudge') return t('workbench.tagNudge')
    if (type === 'remind') return t('workbench.tagRemind')
    return t('workbench.tagMemo')
  },

  buildDayTags(dateKey, byDate) {
    const notes = (byDate && byDate[dateKey]) || []
    const order = ['nudge', 'remind', 'memo']
    const seen = {}
    notes.forEach((note) => {
      seen[note.type || 'memo'] = true
    })
    return order
      .filter((type) => seen[type])
      .map((type) => ({
        key: type,
        label: this.noteTagShort(type)
      }))
  },

  formatCreatedAt(createTime) {
    if (!createTime) return '--:--'
    const match = String(createTime).match(/(\d{2}):(\d{2})/)
    return match ? `${match[1]}:${match[2]}` : String(createTime).slice(11, 16) || '--:--'
  },

  mapRemoteNote(item) {
    return {
      id: String(item.id),
      dateKey: item.noteDate,
      type: item.noteType || 'memo',
      text: item.content,
      createdAt: this.formatCreatedAt(item.createTime)
    }
  },

  loadLocalNotes() {
    try {
      const raw = wx.getStorageSync(this.storageKey())
      if (!raw) return []
      const parsed = typeof raw === 'string' ? JSON.parse(raw) : raw
      return Array.isArray(parsed) ? parsed : []
    } catch (e) {
      return []
    }
  },

  clearLocalNotes() {
    try {
      wx.removeStorageSync(this.storageKey())
    } catch (e) {
      // ignore
    }
  },

  saveLocalNotes(list) {
    try {
      wx.setStorageSync(this.storageKey(), JSON.stringify(list))
    } catch (e) {
      // ignore
    }
  },

  async fetchNotes() {
    const yearMonth = `${this.data.viewYear}-${pad2(this.data.viewMonth + 1)}`
    try {
      const res = await useWorkbenchNoteListApi(yearMonth)
      const list = Array.isArray(res && res.data) ? res.data : []
      if (list.length) {
        this.setData({ notes: list.map((item) => this.mapRemoteNote(item)) })
        this.clearLocalNotes()
        this.rebuildCalendar()
        return
      }
      const allRes = await useWorkbenchNoteListApi()
      const all = Array.isArray(allRes && allRes.data) ? allRes.data : []
      if (all.length) {
        this.setData({ notes: all.map((item) => this.mapRemoteNote(item)) })
        this.clearLocalNotes()
        this.rebuildCalendar()
        return
      }
      const local = this.loadLocalNotes()
      this.setData({ notes: local })
      this.rebuildCalendar()
    } catch (e) {
      this.setData({ notes: this.loadLocalNotes() })
      this.rebuildCalendar()
      showIceToast({ title: t('workbench.noteSyncFail'), icon: 'none' })
    }
  },

  async loadLatestMessages() {
    try {
      const res = await useMessageLatestApi(5)
      const list = Array.isArray(res && res.data) ? res.data : []
      const system = t('workbench.systemNotice')
      this.setData({
        messages: list.map((item) => ({
          id: item.id,
          name: item.senderName || system,
          short: String(item.senderName || system).slice(0, 1),
          text: item.title || item.content || '',
          time: String(item.sendTime || '').slice(11, 16) || '--:--',
          tone: item.type === 1 ? 'teal' : item.type === 2 ? 'amber' : 'blue'
        }))
      })
    } catch (e) {
      this.setData({ messages: [] })
    }
  },

  onShiftMonth(e) {
    const delta = Number(e.currentTarget.dataset.delta) || 0
    const date = new Date(this.data.viewYear, this.data.viewMonth + delta, 1)
    const viewYear = date.getFullYear()
    const viewMonth = date.getMonth()
    this.setData({ viewYear, viewMonth }, () => {
      const selectedDateKey = this.ensureSelectionInView()
      this.setData({ selectedDateKey })
      this.pulseAgenda()
      this.fetchNotes()
    })
  },

  onGoToday() {
    const now = new Date()
    const todayKey = toDateKey(now.getFullYear(), now.getMonth(), now.getDate())
    this.setData({
      viewYear: now.getFullYear(),
      viewMonth: now.getMonth(),
      selectedDateKey: todayKey,
      todayKey,
      todayLabel: `${now.getMonth() + 1}月${now.getDate()}日`,
      weekDay: weekFull()[now.getDay()]
    })
    this.pulseAgenda()
    this.fetchNotes()
  },

  onSelectDay(e) {
    const { date, current } = e.currentTarget.dataset
    if (!date) return
    const isCurrent = !(current === false || current === 'false' || current === 0 || current === '0')
    if (!isCurrent) {
      const [y, m] = String(date).split('-').map(Number)
      this.setData(
        {
          viewYear: y,
          viewMonth: m - 1,
          selectedDateKey: date
        },
        () => {
          this.pulseAgenda()
          this.fetchNotes()
        }
      )
      return
    }
    if (this.data.selectedDateKey === date) {
      this.pulseAgenda()
      return
    }
    this.setData({ selectedDateKey: date }, () => {
      this.rebuildCalendar()
      this.pulseAgenda()
    })
  },

  onDraftType(e) {
    const type = e.currentTarget.dataset.type
    const ph = placeholders()
    const draftTypeLabel = this.noteTypeLabel(type)
    this.setData({
      draftType: type,
      draftTypeLabel,
      draftPlaceholder: ph[type] || ph.memo,
      addNoteText: t('workbench.addNote', { type: draftTypeLabel })
    })
  },

  onDraftInput(e) {
    this.setData({ draftText: e.detail.value || '' })
  },

  async onAddNote() {
    const text = (this.data.draftText || '').trim()
    if (!text || this.data.noteSaving) return
    this.setData({
      noteSaving: true,
      addNoteText: t('workbench.saving')
    })
    try {
      const res = await useWorkbenchNoteSaveApi({
        noteDate: this.data.selectedDateKey,
        noteType: this.data.draftType,
        content: text
      })
      if (res && res.data) {
        const notes = [this.mapRemoteNote(res.data), ...this.data.notes]
        this.setData({ notes, draftText: '' })
      } else {
        this.setData({ draftText: '' })
        await this.fetchNotes()
      }
      this.rebuildCalendar()
      showIceToast({
        title: t('workbench.noteSaved', { type: this.data.draftTypeLabel }),
        icon: 'success'
      })
    } catch (e) {
      showIceToast({ title: t('workbench.noteSaveFail'), icon: 'none' })
    } finally {
      this.setData({
        noteSaving: false,
        addNoteText: t('workbench.addNote', { type: this.data.draftTypeLabel })
      })
    }
  },

  async onRemoveNote(e) {
    const id = e.currentTarget.dataset.id
    const numericId = Number(id)
    if (!Number.isFinite(numericId)) {
      const notes = this.data.notes.filter((n) => n.id !== id)
      this.setData({ notes })
      this.saveLocalNotes(notes.filter((n) => String(n.id).startsWith('local-')))
      this.rebuildCalendar()
      return
    }
    try {
      await useWorkbenchNoteDeleteApi([numericId])
      this.setData({ notes: this.data.notes.filter((n) => n.id !== id) })
      this.rebuildCalendar()
      showIceToast({ title: t('workbench.noteDeleted'), icon: 'success' })
    } catch (err) {
      showIceToast({ title: t('workbench.noteDeleteFail'), icon: 'none' })
    }
  },

  onNav(e) {
    const { path, tab } = e.currentTarget.dataset
    if (!path) return
    if (tab === true || tab === 'true') {
      wx.switchTab({ url: path })
      return
    }
    wx.navigateTo({ url: path })
  }
})
