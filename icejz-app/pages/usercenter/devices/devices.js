const {
  useMyLoginSecurityApi,
  useMyLoginSecuritySaveApi,
  useUserDeviceKickApi,
  useUserDeviceListApi
} = require('@/api/user.js')
const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { showIceConfirm } = require('@/utils/iceConfirm.js')

Page({
  data: {
    loading: false,
    kicking: '',
    list: [],
    prefLoading: false,
    prefSaving: false,
    prefMode: 'sys',
    prefMax: 5,
    systemOn: false,
    systemMax: 5,
    effectiveOn: false,
    effectiveMax: 5,
    effectiveLabel: '',
    prefDescText: '',
    limitDescText: '',
    modeOptions: [],
    copy: {}
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.refreshCopy()
    this.loadAll()
  },

  refreshCopy() {
    this.setData({
      copy: {
        title: t('devices.title'),
        sub: t('devices.sub'),
        prefKicker: t('devices.prefKicker'),
        prefTitle: t('devices.prefTitle'),
        systemLockedTip: t('devices.systemLockedTip'),
        limitTitle: t('devices.limitTitle'),
        save: t('devices.save'),
        reload: t('devices.reload'),
        sessionTitle: t('devices.sessionTitle'),
        sessionDesc: t('devices.sessionDesc'),
        refresh: t('devices.refresh'),
        loading: `${t('common.loading')}…`,
        empty: t('devices.empty'),
        current: t('devices.current'),
        thisDevice: t('devices.thisDevice'),
        kick: t('devices.kick'),
        kicking: t('devices.kicking')
      }
    })
    this.refreshDerived()
  },

  buildModeOptions(systemOn, systemMax) {
    return [
      {
        value: 'sys',
        badge: t('devices.modeSysBadge'),
        title: t('devices.modeSysTitle'),
        desc: t('devices.modeSysDesc'),
        note: systemOn
          ? t('devices.modeSysNoteOn', { n: systemMax })
          : t('devices.modeSysNoteOff')
      },
      {
        value: 'on',
        badge: t('devices.modeOnBadge'),
        title: t('devices.modeOnTitle'),
        desc: t('devices.modeOnDesc'),
        note: systemOn
          ? t('devices.modeOnNote', { n: systemMax })
          : t('devices.modeOnLocked'),
        locked: !systemOn
      },
      {
        value: 'off',
        badge: t('devices.modeOffBadge'),
        title: t('devices.modeOffTitle'),
        desc: t('devices.modeOffDesc'),
        note: systemOn ? t('devices.modeOffNote') : t('devices.modeOffNoteLocked')
      }
    ]
  },

  refreshDerived() {
    const { systemOn, systemMax, effectiveOn, effectiveMax } = this.data
    this.setData({
      prefDescText: systemOn ? t('devices.prefDescOn') : t('devices.prefDescOff'),
      effectiveLabel: effectiveOn
        ? t('devices.effectiveMulti', { n: effectiveMax })
        : t('devices.effectiveSingle'),
      limitDescText: t('devices.limitDesc', { n: systemMax }),
      modeOptions: this.buildModeOptions(systemOn, systemMax)
    })
  },

  selectMode(e) {
    const value = e.currentTarget.dataset.value
    if (value === 'on' && !this.data.systemOn) {
      showIceToast({ title: t('devices.systemLockedToast'), icon: 'none' })
      return
    }
    this.setData({ prefMode: value })
  },

  clientLabel(type) {
    const map = {
      pc: t('devices.clientPc'),
      app: t('devices.clientApp'),
      mp: t('devices.clientMp')
    }
    return map[type || ''] || type || t('devices.clientUnknown')
  },

  clientShort(type) {
    const map = { pc: 'PC', app: 'App', mp: 'MP' }
    return map[type || ''] || '?'
  },

  shortUa(ua) {
    if (!ua) return '—'
    return ua.length <= 72 ? ua : ua.slice(0, 72) + '…'
  },

  formatTime(tVal) {
    if (!tVal) return '—'
    return String(tVal).replace('T', ' ').replace(/\.\d+$/, '').slice(0, 19)
  },

  clampMax(n) {
    return Math.max(1, Math.min(n ?? this.data.systemMax, this.data.systemMax))
  },

  decMax() {
    if (this.data.prefMode !== 'on' || this.data.prefMax <= 1) return
    this.setData({ prefMax: this.data.prefMax - 1 })
  },

  incMax() {
    if (this.data.prefMode !== 'on' || this.data.prefMax >= this.data.systemMax) return
    this.setData({ prefMax: this.data.prefMax + 1 })
  },

  async loadAll() {
    await Promise.all([this.loadPref(), this.loadList()])
  },

  async loadList() {
    this.setData({ loading: true })
    try {
      const res = await useUserDeviceListApi()
      const raw = Array.isArray(res.data) ? res.data : []
      const list = raw.map((item) => ({
        ...item,
        clientLabel: this.clientLabel(item.clientType),
        clientShort: this.clientShort(item.clientType),
        loginTimeText: this.formatTime(item.loginTime),
        uaShort: this.shortUa(item.userAgent)
      }))
      this.setData({ list })
    } catch (e) {
      showIceToast({ title: t('devices.loadFail'), icon: 'error' })
    } finally {
      this.setData({ loading: false })
    }
  },

  async loadPref() {
    this.setData({ prefLoading: true })
    try {
      const { data } = await useMyLoginSecurityApi()
      const systemOn = !!data?.systemMultiDeviceLogin
      const systemMax = Math.max(1, data?.systemMultiDeviceMax ?? 5)
      const effectiveOn = !!data?.effectiveMultiDeviceLogin
      const effectiveMax = Math.min(data?.effectiveMultiDeviceMax ?? systemMax, systemMax)
      let prefMode = 'sys'
      let prefMax = systemMax
      if (data?.multiDeviceLogin === 1) {
        prefMode = systemOn ? 'on' : 'sys'
        prefMax = Math.max(1, Math.min(data?.multiDeviceMax ?? systemMax, systemMax))
      } else if (data?.multiDeviceLogin === 0) {
        prefMode = 'off'
      }
      this.setData({
        systemOn,
        systemMax,
        effectiveOn,
        effectiveMax,
        prefMode,
        prefMax
      })
      this.refreshDerived()
    } catch (e) {
      showIceToast({ title: t('devices.prefLoadFail'), icon: 'error' })
    } finally {
      this.setData({ prefLoading: false })
    }
  },

  async savePref() {
    if (this.data.prefSaving) return
    if (this.data.prefMode === 'on' && !this.data.systemOn) {
      showIceToast({ title: t('devices.systemLockedToast'), icon: 'none' })
      return
    }
    this.setData({ prefSaving: true })
    try {
      const multiDeviceLogin =
        this.data.prefMode === 'sys' ? null : this.data.prefMode === 'on' ? 1 : 0
      const multiDeviceMax =
        this.data.prefMode === 'on' ? this.clampMax(this.data.prefMax) : null
      await useMyLoginSecuritySaveApi({ multiDeviceLogin, multiDeviceMax })
      showIceToast({ title: t('devices.saveOk'), icon: 'success' })
      await this.loadPref()
    } catch (e) {
      showIceToast({ title: t('devices.saveFail'), icon: 'error' })
    } finally {
      this.setData({ prefSaving: false })
    }
  },

  async kick(e) {
    const index = e.currentTarget.dataset.index
    const item = this.data.list[index]
    if (!item?.accessToken || item.current || this.data.kicking) return
    const ok = await showIceConfirm({
      title: t('devices.kickTitle'),
      content: t('devices.kickConfirm'),
      confirmText: t('devices.kick'),
      cancelText: t('common.cancel'),
      tone: 'danger'
    })
    if (!ok) return
    this.setData({ kicking: item.accessToken })
    try {
      await useUserDeviceKickApi(item.accessToken)
      showIceToast({ title: t('devices.kickOk'), icon: 'success' })
      await this.loadList()
    } catch (err) {
      showIceToast({ title: t('devices.kickFail'), icon: 'error' })
    } finally {
      this.setData({ kicking: '' })
    }
  }
})
