const cache = require('@/utils/cache.js')
const brand = require('@/config/brand.js')
const { t } = require('@/locale/index.js')
const { useLogoutApi } = require('@/api/auth.js')
const { useMessageUnreadCountApi } = require('@/api/message.js')
const { useUserInfoApi } = require('@/api/user.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { showIceConfirm } = require('@/utils/iceConfirm.js')

const DEFAULT_AVATAR = '/images/logo.png'

function greetingByHour() {
  const h = new Date().getHours()
  if (h < 6) return t('greet.late')
  if (h < 12) return t('greet.morning')
  if (h < 14) return t('greet.noon')
  if (h < 18) return t('greet.afternoon')
  return t('greet.evening')
}

function shortText(value, empty = '-') {
  const text = String(value || empty)
  return text.length > 10 ? text.slice(0, 9) + '…' : text
}

function buildCopy() {
  return {
    accountCenter: t('mine.accountCenter'),
    member: t('mine.member'),
    orgEmpty: t('mine.statOrgHintEmpty'),
    editShort: t('mine.editShort'),
    statUnread: t('mine.statUnread'),
    statAccount: t('mine.statAccount'),
    statOrg: t('mine.statOrg'),
    frequent: t('mine.frequent'),
    frequentSub: t('mine.frequentSub'),
    accountGroup: t('mine.accountGroup'),
    accountGroupSub: t('mine.accountGroupSub'),
    logout: t('common.logout'),
    contactSheetTitle: t('mine.contactSheetTitle'),
    contactSheetSub: t('mine.contactSheetSub'),
    contactAuthor: t('mine.contactAuthor'),
    contactAuthorName: t('mine.contactAuthorName'),
    contactQq: t('mine.contactQq'),
    contactQqValue: t('mine.contactQqValue'),
    contactEmail: t('mine.contactEmail'),
    contactEmailValue: t('mine.contactEmailValue'),
    contactHours: t('mine.contactHours'),
    contactHoursValue: t('mine.contactHoursValue'),
    contactCopy: t('mine.contactCopy'),
    contactClose: t('mine.contactClose'),
    avatarZoomTip: t('mine.avatarZoomTip')
  }
}

Page({
  data: {
    brand,
    copy: buildCopy(),
    statusBarPx: 20,
    stagePadRightPx: 12,
    contactOpen: false,
    avatarPreview: false,
    avatarScale: 1,
    avatarX: 0,
    avatarY: 0,
    user: {},
    unreadCount: 0,
    unreadBadge: '0',
    displayName: '用户',
    displayAvatar: DEFAULT_AVATAR,
    helloText: '',
    orgName: '',
    accountShort: '-',
    orgShort: '未绑定',
    menuData: [],
    accountMenus: []
  },

  _pinchStartDist: 0,
  _pinchStartScale: 1,
  _drag: null,
  _moved: false,
  _lastTap: 0,

  onLoad() {
    try {
      const info = wx.getSystemInfoSync()
      let stagePadRightPx = 12
      try {
        const menu = wx.getMenuButtonBoundingClientRect()
        // 顶部右侧操作避开微信胶囊（布局同 uniapp：左品牌 / 右操作）
        if (menu && menu.left) {
          const shellPadPx = 14
          stagePadRightPx = Math.max(
            24,
            Math.ceil(info.windowWidth - menu.left - shellPadPx + 8)
          )
        }
      } catch (e) {
        // ignore
      }
      this.setData({
        statusBarPx: info.statusBarHeight || 20,
        stagePadRightPx
      })
    } catch (e) {
      this.setData({ statusBarPx: 20, stagePadRightPx: 12 })
    }
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.setData({ copy: buildCopy() })
    this.refreshMenus()
    this.refreshUserView(cache.getUserInfo() || {})
    const tabBar = this.getTabBar && this.getTabBar()
    if (tabBar && tabBar.init) tabBar.init()
    this.loadUser()
    this.loadUnread()
  },

  refreshMenus(unreadCount = this.data.unreadCount) {
    this.setData({
      menuData: [
        {
          title: t('assistant.entry'),
          hint: t('assistant.entryHint'),
          icon: '/images/icons/msg.svg',
          count: 0,
          path: '/pages/assistant/chat',
          useMascot: true
        },
        {
          title: t('mine.myMsg'),
          hint:
            unreadCount > 0
              ? t('mine.statUnreadHintN', { n: unreadCount })
              : t('mine.statUnreadHint0'),
          icon: '/images/icons/msg.svg',
          count: unreadCount,
          path: '/pages/message/inbox'
        },
        {
          title: t('mine.userManage'),
          hint: t('mine.statAccountHint'),
          icon: '/images/icons/user.svg',
          count: 0,
          path: '/pages/sys/user/index'
        },
        {
          title: t('mine.orgManage'),
          hint: t('mine.statOrgHint'),
          icon: '/images/icons/org.svg',
          count: 0,
          path: '/pages/sys/org/index'
        }
      ],
      accountMenus: [
        {
          title: t('mine.settings'),
          note: t('mine.settingsHint'),
          icon: '/images/icons/settings.svg',
          tone: 'tone-cyan',
          path: '/pages/usercenter/settings/settings'
        },
        {
          title: t('mine.profile'),
          note: t('settings.profileHint'),
          icon: '/images/icons/profile.svg',
          tone: 'tone-sky',
          path: '/pages/usercenter/userinfo/userinfo'
        },
        {
          title: t('mine.password'),
          note: t('settings.passwordHint'),
          icon: '/images/icons/lock.svg',
          tone: 'tone-deep',
          path: '/pages/usercenter/password/password'
        },
        {
          title: t('mine.devices'),
          note: t('settings.devicesHint'),
          icon: '/images/icons/device.svg',
          tone: 'tone-mint',
          path: '/pages/usercenter/devices/devices'
        },
        {
          title: t('mine.about'),
          note: t('settings.aboutHint'),
          icon: '/images/icons/about.svg',
          tone: 'tone-slate',
          path: '/pages/usercenter/about/about'
        },
        {
          title: t('mine.contact'),
          note: t('mine.contactHint'),
          icon: '/images/icons/contact.svg',
          tone: 'tone-cyan',
          action: 'contact'
        }
      ]
    })
  },

  refreshUserView(user) {
    const displayName = user.realName || user.username || t('common.user')
    const orgName = user.orgName || ''
    const accountName = user.username || user.realName || '-'
    const greet = greetingByHour()
    this.setData({
      user,
      displayName,
      displayAvatar: user.avatar || DEFAULT_AVATAR,
      orgName,
      helloText: t('mine.hello', { greet, name: displayName }),
      accountShort: shortText(accountName),
      orgShort: shortText(orgName, t('mine.statOrgHintEmpty'))
    })
  },

  async loadUser() {
    try {
      const { data } = await useUserInfoApi()
      if (data) {
        cache.setUserInfo(data)
        this.refreshUserView(data)
      }
    } catch (e) {
      // keep cache
    }
  },

  async loadUnread() {
    try {
      const { data } = await useMessageUnreadCountApi()
      const count = data || 0
      this.setData({
        unreadCount: count,
        unreadBadge: count > 99 ? '99+' : String(count)
      })
      this.refreshMenus(count)
    } catch (e) {
      // ignore
    }
  },

  onNavigate(e) {
    const path = e.currentTarget.dataset.path
    if (!path) return
    wx.navigateTo({ url: path })
  },

  onClickMenu(e) {
    const index = e.currentTarget.dataset.index
    const item = this.data.menuData[index]
    if (!item?.path) {
      showIceToast({ title: t('common.notOpen'), icon: 'none' })
      return
    }
    wx.navigateTo({ url: item.path })
  },

  onAccountTap(e) {
    const { path, action } = e.currentTarget.dataset
    if (action === 'contact') {
      this.openContact()
      return
    }
    if (path) {
      wx.navigateTo({ url: path })
    }
  },

  setTabBarVisible(show) {
    try {
      if (typeof this.getTabBar === 'function' && this.getTabBar()) {
        this.getTabBar().setData({ hidden: !show })
      }
    } catch (e) {
      // ignore
    }
  },

  previewAvatar() {
    if (!this.data.displayAvatar) return
    this.resetAvatarTransform()
    this.setData({ avatarPreview: true })
    this.setTabBarVisible(false)
  },

  closeAvatarPreview() {
    this.setData({ avatarPreview: false })
    this.resetAvatarTransform()
    this.setTabBarVisible(true)
  },

  resetAvatarTransform() {
    this._pinchStartDist = 0
    this._pinchStartScale = 1
    this._drag = null
    this._moved = false
    this.setData({
      avatarScale: 1,
      avatarX: 0,
      avatarY: 0
    })
  },

  clampAvatarScale(scale) {
    return Math.min(4, Math.max(1, scale))
  },

  touchDistance(touches) {
    const a = touches[0]
    const b = touches[1]
    const dx = a.clientX - b.clientX
    const dy = a.clientY - b.clientY
    return Math.sqrt(dx * dx + dy * dy)
  },

  onPreviewTouchStart(e) {
    const touches = e.touches || []
    this._moved = false
    if (touches.length >= 2) {
      this._pinchStartDist = this.touchDistance(touches)
      this._pinchStartScale = this.data.avatarScale
      this._drag = null
      return
    }
    if (touches.length === 1 && this.data.avatarScale > 1) {
      this._drag = {
        x: touches[0].clientX,
        y: touches[0].clientY,
        ox: this.data.avatarX,
        oy: this.data.avatarY
      }
    }
  },

  onPreviewTouchMove(e) {
    const touches = e.touches || []
    if (touches.length >= 2) {
      this._moved = true
      if (!this._pinchStartDist) {
        this._pinchStartDist = this.touchDistance(touches)
        this._pinchStartScale = this.data.avatarScale
      }
      const dist = this.touchDistance(touches)
      const avatarScale = this.clampAvatarScale((dist / this._pinchStartDist) * this._pinchStartScale)
      const patch = { avatarScale }
      if (avatarScale <= 1) {
        patch.avatarX = 0
        patch.avatarY = 0
      }
      this.setData(patch)
      return
    }
    if (touches.length === 1 && this._drag && this.data.avatarScale > 1) {
      this._moved = true
      const dx = touches[0].clientX - this._drag.x
      const dy = touches[0].clientY - this._drag.y
      this.setData({
        avatarX: this._drag.ox + dx,
        avatarY: this._drag.oy + dy
      })
    }
  },

  onPreviewTouchEnd(e) {
    const touches = e.touches || []
    if (touches.length >= 2) return
    if (touches.length === 1 && this.data.avatarScale > 1) {
      this._drag = {
        x: touches[0].clientX,
        y: touches[0].clientY,
        ox: this.data.avatarX,
        oy: this.data.avatarY
      }
      this._pinchStartDist = 0
      return
    }
    this._pinchStartDist = 0
    this._drag = null
    if (this.data.avatarScale <= 1.02) {
      this.setData({
        avatarScale: 1,
        avatarX: 0,
        avatarY: 0
      })
    }
  },

  onPreviewImgClick() {
    const now = Date.now()
    if (this._lastTap && now - this._lastTap < 280) {
      this._lastTap = 0
      if (this.data.avatarScale > 1.05) {
        this.setData({ avatarScale: 1, avatarX: 0, avatarY: 0 })
      } else {
        this.setData({ avatarScale: 2.2 })
      }
      return
    }
    this._lastTap = now
  },

  onPreviewBgClick() {
    if (this._moved) return
    if (this.data.avatarScale > 1.05) {
      this.setData({ avatarScale: 1, avatarX: 0, avatarY: 0 })
      return
    }
    this.closeAvatarPreview()
  },

  openContact() {
    this.setData({ contactOpen: true })
    this.setTabBarVisible(false)
  },

  closeContact() {
    this.setData({ contactOpen: false })
    this.setTabBarVisible(true)
  },

  noop() {},

  onCopyContact(e) {
    const type = e.currentTarget.dataset.type
    const isEmail = type === 'email'
    const data = isEmail ? t('mine.contactEmailValue') : t('mine.contactQqValue')
    wx.setClipboardData({
      data,
      success: () => {
        showIceToast({
          title: isEmail ? t('mine.emailCopied') : t('mine.qqCopied'),
          icon: 'none'
        })
      }
    })
  },

  async onLogout() {
    const ok = await showIceConfirm({
      title: t('common.logout'),
      content: '确认退出当前账号？',
      confirmText: t('common.logout'),
      cancelText: t('common.cancel') || '取消',
      tone: 'danger'
    })
    if (!ok) return
    useLogoutApi()
      .catch(() => null)
      .finally(() => {
        cache.removeToken()
        cache.removeUserInfo()
        wx.reLaunch({ url: '/pages/login/login' })
      })
  }
})
