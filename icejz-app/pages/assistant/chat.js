const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const {
  useAiRobotInfoApi,
  useAiChatApi,
  useAiChatSessionListApi,
  useAiChatSessionMessagesApi,
  useAiChatSessionDeleteApi
} = require('@/api/ai.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { showIceConfirm } = require('@/utils/iceConfirm.js')

Page({
  data: {
    robotName: '小冰',
    statusText: '',
    welcome: '',
    hello: '',
    messages: [],
    input: '',
    loading: false,
    currentSessionId: null,
    scrollInto: '',
    historyOpen: false,
    sessions: [],
    sessionsLoading: false,
    quickasks: [],
    sendLabel: '',
    placeholder: '',
    tHistory: '',
    tNew: '',
    tHistoryTitle: '',
    tHistoryLoading: '',
    tHistoryEmpty: '',
    tDelete: ''
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.refreshCopy()
    this.loadProfile()
    if (!this._initialized) {
      this._initialized = true
      this.loadLatestSession()
    }
  },

  refreshCopy() {
    const name = cache.getUserInfo()?.realName || t('common.user')
    const h = new Date().getHours()
    let greet = t('greet.hi')
    if (h < 6) greet = t('greet.late')
    else if (h < 12) greet = t('greet.morning')
    else if (h < 14) greet = t('greet.noon')
    else if (h < 18) greet = t('greet.afternoon')
    else greet = t('greet.evening')

    this.setData({
      hello: `${greet}，${name}`,
      statusText: this.data.loading ? t('assistant.thinking') : t('assistant.online'),
      quickasks: [
        t('assistant.chip1'),
        t('assistant.chip2'),
        t('assistant.chip3'),
        t('assistant.chip4')
      ],
      sendLabel: this.data.loading ? t('assistant.sending') : t('assistant.send'),
      placeholder: t('assistant.placeholder'),
      robotName: this.data.robotName || t('assistant.defaultName'),
      tHistory: t('assistant.history'),
      tNew: t('assistant.newChat'),
      tHistoryTitle: t('assistant.historyTitle'),
      tHistoryLoading: t('assistant.historyLoading'),
      tHistoryEmpty: t('assistant.historyEmpty'),
      tDelete: t('assistant.delete')
    })
    wx.setNavigationBarTitle({ title: this.data.robotName || t('assistant.title') })
  },

  formatSessionTime(raw) {
    if (!raw) return ''
    const m = String(raw).match(/(\d{2}-\d{2})\s+(\d{2}:\d{2})/)
    if (m) return `${m[1]} ${m[2]}`
    return String(raw).slice(5, 16)
  },

  formatAssistantError(raw) {
    const text = (raw || '').trim()
    if (!text) return t('assistant.errGeneric')
    const lower = text.toLowerCase()
    if (
      lower.includes('authentication fails') ||
      lower.includes('governor') ||
      text.includes('鉴权失败') ||
      text.includes('(401)')
    ) {
      return t('assistant.errAuth')
    }
    if (text.includes('额度不足') || lower.includes('402')) {
      return t('assistant.errQuota')
    }
    if (text.includes('过于频繁') || lower.includes('429')) {
      return t('assistant.errRate')
    }
    return text
  },

  async loadProfile() {
    try {
      const { data } = await useAiRobotInfoApi()
      const robotName = data?.name || t('assistant.defaultName')
      this.setData({
        robotName,
        welcome: data?.welcome || t('assistant.defaultWelcome')
      })
      wx.setNavigationBarTitle({ title: robotName })
    } catch (e) {
      this.setData({
        robotName: t('assistant.defaultName'),
        welcome: t('assistant.defaultWelcome')
      })
    }
  },

  mapSessions(list) {
    return (Array.isArray(list) ? list : []).map((item) => ({
      ...item,
      titleText: item.title || t('assistant.untitled'),
      timeText: this.formatSessionTime(item.lastMsgTime || item.createTime)
    }))
  },

  async loadSessions(preferId) {
    this.setData({ sessionsLoading: true })
    try {
      const { data } = await useAiChatSessionListApi()
      const sessions = this.mapSessions(data)
      this.setData({ sessions })
      const target =
        preferId && sessions.some((s) => s.id === preferId)
          ? preferId
          : this.data.currentSessionId && sessions.some((s) => s.id === this.data.currentSessionId)
            ? this.data.currentSessionId
            : sessions[0]?.id || null
      if (target && target !== this.data.currentSessionId) {
        await this.openSession(target)
      } else if (!target) {
        this.setData({ currentSessionId: null })
      }
    } catch (e) {
      this.setData({ sessions: [] })
    } finally {
      this.setData({ sessionsLoading: false })
    }
  },

  async loadLatestSession() {
    try {
      const { data } = await useAiChatSessionListApi()
      const sessions = this.mapSessions(data)
      this.setData({ sessions })
      if (!sessions.length) return
      const first = sessions[0]
      if (!first?.id) return
      await this.openSession(first.id)
    } catch (e) {
      // keep empty
    }
  },

  async openSession(id) {
    if (this.data.loading) return
    try {
      const { data } = await useAiChatSessionMessagesApi(id)
      const messages = (Array.isArray(data) ? data : [])
        .filter((m) => m?.role === 'user' || m?.role === 'assistant')
        .map((m) => ({ role: m.role, content: m.content }))
      this.setData({ currentSessionId: id, messages })
      this.scrollBottom()
    } catch (e) {
      showIceToast({ title: t('assistant.loadFail'), icon: 'none' })
    }
  },

  openHistory() {
    this.setData({ historyOpen: true })
    this.loadSessions(this.data.currentSessionId)
  },

  closeHistory() {
    this.setData({ historyOpen: false })
  },

  async onSelectSession(e) {
    const id = e.currentTarget.dataset.id
    if (!id || id === this.data.currentSessionId) {
      this.closeHistory()
      return
    }
    await this.openSession(id)
    this.closeHistory()
  },

  onHistoryNew() {
    this.startNewChat()
    this.closeHistory()
  },

  startNewChat() {
    if (this.data.loading) return
    this.setData({
      currentSessionId: null,
      messages: [],
      input: ''
    })
  },

  async onDeleteSession(e) {
    const id = e.currentTarget.dataset.id
    const ok = await showIceConfirm({
      title: t('assistant.historyTitle'),
      content: t('assistant.deleteConfirm'),
      confirmText: '删除',
      cancelText: '取消',
      tone: 'danger'
    })
    if (!ok) return
    try {
      await useAiChatSessionDeleteApi([id])
      if (this.data.currentSessionId === id) {
        this.setData({ currentSessionId: null, messages: [] })
      }
      await this.loadSessions()
      showIceToast({ title: t('assistant.deleted'), icon: 'success' })
    } catch (err) {
      // request toast
    }
  },

  onInput(e) {
    this.setData({ input: e.detail.value })
  },

  askChip(e) {
    const text = e.currentTarget.dataset.text
    this.setData({ input: text })
    this.send()
  },

  scrollBottom() {
    this.setData({ scrollInto: '' })
    setTimeout(() => {
      this.setData({
        scrollInto: this.data.loading ? 'typing' : 'bottom-anchor'
      })
    }, 30)
  },

  async send() {
    const text = (this.data.input || '').trim()
    if (!text || this.data.loading) return
    const messages = this.data.messages.concat([{ role: 'user', content: text }])
    this.setData({
      messages,
      input: '',
      loading: true,
      statusText: t('assistant.thinking'),
      sendLabel: t('assistant.sending')
    })
    this.scrollBottom()
    try {
      const history = messages
        .slice(0, -1)
        .slice(-8)
        .map((m) => ({ role: m.role, content: m.content }))
      const { data } = await useAiChatApi({
        message: text,
        sessionId: this.data.currentSessionId,
        history
      })
      const patch = {
        messages: messages.concat([
          {
            role: 'assistant',
            content: data?.content || t('assistant.emptyReply')
          }
        ])
      }
      if (data?.sessionId) patch.currentSessionId = data.sessionId
      this.setData(patch)
      useAiChatSessionListApi()
        .then((res) => {
          this.setData({ sessions: this.mapSessions(res.data) })
        })
        .catch(() => null)
    } catch (e) {
      const tip = this.formatAssistantError(e?.msg || e?.message || '')
      this.setData({
        messages: messages.concat([{ role: 'assistant', content: tip }])
      })
    } finally {
      this.setData({
        loading: false,
        statusText: t('assistant.online'),
        sendLabel: t('assistant.send')
      })
      this.scrollBottom()
    }
  }
})
