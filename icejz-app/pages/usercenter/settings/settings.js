const cache = require('@/utils/cache.js')
const {
  getLocale,
  setAppLocale,
  getStoredLocale,
  setStoredLocale,
  t
} = require('@/locale/index.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { showIceConfirm } = require('@/utils/iceConfirm.js')
const { isGuideDone, markGuideDone } = require('@/utils/guide.js')

function permMeta(auth) {
  if (auth === true) return { labelKey: 'settings.permOn', className: 'on' }
  if (auth === false) return { labelKey: 'settings.permOff', className: 'off' }
  return { labelKey: 'settings.permUnknown', className: 'unknown' }
}

function readAuth(auth, keys) {
  for (let i = 0; i < keys.length; i += 1) {
    const key = keys[i]
    if (Object.prototype.hasOwnProperty.call(auth, key)) {
      return !!auth[key]
    }
  }
  return null
}

Page({
  data: {
    locale: 'zh-CN',
    copy: {},
    albumAuth: null,
    cameraAuth: null,
    albumLabel: '',
    cameraLabel: '',
    albumClass: 'unknown',
    cameraClass: 'unknown'
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.refreshCopy()
    this.refreshPermissions()
  },

  refreshCopy() {
    const album = permMeta(this.data.albumAuth)
    const camera = permMeta(this.data.cameraAuth)
    this.setData({
      locale: getLocale(),
      albumLabel: t(album.labelKey),
      cameraLabel: t(camera.labelKey),
      albumClass: album.className,
      cameraClass: camera.className,
      copy: {
        title: t('settings.title'),
        sub: t('settings.sub') || t('mine.settingsHint') || '偏好与安全',
        groupGeneral: t('settings.groupGeneral'),
        language: t('mine.language'),
        languageHint: t('mine.languageHint'),
        about: t('mine.about'),
        aboutHint: t('settings.aboutHint'),
        replay: t('guide.replay'),
        replayHint: t('guide.replayHint'),
        groupPermission: t('settings.groupPermission'),
        album: t('settings.album'),
        albumHint: t('settings.albumHint'),
        camera: t('settings.camera'),
        cameraHint: t('settings.cameraHint'),
        openSystemSetting: t('settings.openSystemSetting'),
        openSystemSettingHint: t('settings.openSystemSettingHint'),
        groupSecurity: t('settings.groupSecurity'),
        profile: t('mine.profile'),
        profileHint: t('settings.profileHint'),
        password: t('mine.password'),
        passwordHint: t('settings.passwordHint'),
        devices: t('mine.devices'),
        devicesHint: t('settings.devicesHint'),
        groupStorage: t('settings.groupStorage'),
        clearCache: t('settings.clearCache'),
        clearCacheHint: t('settings.clearCacheHint'),
        version: t('settings.version')
      }
    })
  },

  refreshPermissions() {
    wx.getSetting({
      success: (res) => {
        const auth = (res && res.authSetting) || {}
        const albumAuth = readAuth(auth, ['scope.album', 'scope.writePhotosAlbum'])
        const cameraAuth = readAuth(auth, ['scope.camera'])
        const album = permMeta(albumAuth)
        const camera = permMeta(cameraAuth)
        this.setData({
          albumAuth,
          cameraAuth,
          albumLabel: t(album.labelKey),
          cameraLabel: t(camera.labelKey),
          albumClass: album.className,
          cameraClass: camera.className
        })
      },
      fail: () => {
        const album = permMeta(null)
        const camera = permMeta(null)
        this.setData({
          albumAuth: null,
          cameraAuth: null,
          albumLabel: t(album.labelKey),
          cameraLabel: t(camera.labelKey),
          albumClass: album.className,
          cameraClass: camera.className
        })
      }
    })
  },

  openSystemSetting() {
    wx.openSetting({
      success: () => {
        this.refreshPermissions()
      },
      fail: () => {
        showIceToast({ title: t('settings.openSettingFail'), icon: 'none' })
      }
    })
  },

  go(e) {
    const path = e.currentTarget.dataset.path
    if (!path) return
    wx.navigateTo({ url: path })
  },

  replayGuide() {
    wx.navigateTo({ url: '/pages/guide/guide' })
  },

  switchLocale(e) {
    const code = e.currentTarget.dataset.code
    if (!code || code === this.data.locale) return
    setAppLocale(code)
    this.refreshCopy()
    showIceToast({ title: t('lang.switched'), icon: 'success' })
  },

  async onClearCache() {
    const ok = await showIceConfirm({
      title: t('settings.clearTitle'),
      content: t('settings.clearConfirm'),
      confirmText: t('settings.clearAction'),
      cancelText: t('common.cancel'),
      tone: 'danger'
    })
    if (!ok) return
    try {
      const token = cache.getToken()
      const userInfo = cache.getUserInfo()
      const locale = getStoredLocale()
      const guideDone = isGuideDone()
      wx.clearStorageSync()
      if (token) cache.setToken(token)
      if (userInfo) cache.setUserInfo(userInfo)
      setStoredLocale(locale)
      setAppLocale(locale)
      if (guideDone) markGuideDone()
      showIceToast({ title: t('settings.clearOk'), icon: 'success' })
      this.refreshCopy()
    } catch (e) {
      showIceToast({ title: t('settings.clearFail'), icon: 'error' })
    }
  }
})
