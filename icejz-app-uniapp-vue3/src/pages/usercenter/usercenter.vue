<template>
  <view class="page ice-page with-tab">
    <view class="bg">
      <view class="bg-base" />
      <view class="blob b1" />
      <view class="blob b2" />
        </view>

    <view class="shell" :style="{ paddingTop: statusBarPx + 8 + 'px' }">
      <view class="stage">
        <view class="stage-glow g1" />
        <view class="stage-glow g2" />

        <view class="stage-nav">
          <view class="brand">
            <view class="brand-mark">
              <text class="brand-ice">ICE</text><text class="brand-jz">JZ</text>
                    </view>
            <text class="brand-sub">{{ $t('mine.accountCenter') }}</text>
                        </view>
          <view class="stage-actions">
            <view class="act-btn" @click.stop="go('/pages/message/inbox')">
              <image class="act-ico" src="/static/icons/msg.svg" mode="aspectFit" />
              <view v-if="unreadCount > 0" class="act-dot">{{ unreadBadge }}</view>
                        </view>
            <view class="act-btn" @click.stop="go('/pages/usercenter/settings/settings')">
              <image class="act-ico" src="/static/icons/settings.svg" mode="aspectFit" />
                    </view>
                </view>
            </view>

        <view class="identity" @click="go('/pages/usercenter/userinfo/userinfo')">
          <view class="avatar-stage" @click.stop="previewAvatar">
            <view class="avatar-halo" />
            <view class="avatar-orbit" />
            <view class="avatar-box">
              <view class="avatar-sheen" />
              <image class="avatar" :src="displayAvatar" mode="aspectFill" />
              <view class="live" />
                </view>
                    </view>
          <view class="identity-copy">
            <text class="greet">{{ helloText }}</text>
            <view class="name-line">
              <text class="name">{{ displayName }}</text>
              <text class="chip">{{ $t('mine.member') }}</text>
                </view>
            <view class="meta">
              <text v-if="user.username" class="meta-pill">@{{ user.username }}</text>
              <text class="meta-pill soft">{{ orgName || $t('mine.statOrgHintEmpty') }}</text>
            </view>
        </view>
          <view class="edit-btn" @click.stop="go('/pages/usercenter/userinfo/userinfo')">
            <text class="edit-t">{{ $t('mine.editShort') }}</text>
            </view>
            </view>

        <view class="metrics">
          <template v-for="(item, index) in insightCards" :key="item.key">
            <view class="metric" @click.stop="go(item.path)">
              <text class="metric-val">{{ item.value }}</text>
              <text class="metric-lab">{{ item.label }}</text>
            </view>
            <view v-if="index < insightCards.length - 1" class="metric-split" />
          </template>
            </view>
        </view>

      <view class="section">
        <view class="section-head">
          <text class="section-title">{{ $t('mine.frequent') }}</text>
          <text class="section-sub">{{ $t('mine.frequentSub') }}</text>
                </view>
        <view class="service-grid">
                <view
            v-for="item in menuData"
            :key="item.path"
            class="service"
            @click="onClickMenu(item)"
          >
            <view class="service-ico">
              <image class="service-img" :src="item.icon" mode="aspectFit" />
              <view v-if="item.count" class="service-badge">{{ item.count > 99 ? '99+' : item.count }}</view>
                    </view>
            <view class="service-copy">
              <text class="service-name">{{ item.title }}</text>
              <text class="service-hint">{{ item.hint }}</text>
                    </view>
            <text class="service-go">›</text>
                </view>
            </view>
        </view>

      <view class="section account-section">
        <view class="section-head account-head">
          <view class="account-head-mark" />
          <view class="account-head-copy">
            <text class="section-title">{{ $t('mine.accountGroup') }}</text>
            <text class="section-sub">{{ $t('mine.accountGroupSub') }}</text>
            </view>
        </view>

        <view class="panel account-panel">
          <view class="panel-glow" />
          <view class="panel-lines" />
          <view
            v-for="(item, index) in accountMenus"
            :key="item.title"
            class="row"
            :class="{ last: index === accountMenus.length - 1 }"
            hover-class="row-hover"
            :hover-stay-time="80"
            @click="item.action ? item.action() : go(item.path)"
          >
            <view class="row-ico" :class="item.tone">
              <view class="row-ico-ring" />
              <image class="row-img" :src="item.icon" mode="aspectFit" />
                </view>
            <view class="row-copy">
              <text class="row-title">{{ item.title }}</text>
              <text v-if="item.note" class="row-note">{{ item.note }}</text>
            </view>
            <view class="row-trail">
              <text class="row-go">›</text>
                    </view>
                    </view>
            </view>
        </view>

      <view class="logout" @click="onLogout">{{ $t('common.logout') }}</view>
      <text class="foot">{{ $t('brand.footer') }}</text>
        </view>

    <view
      v-if="contactOpen"
      class="contact-mask"
      @touchmove.stop.prevent
      @click="closeContact"
    >
      <view class="contact-sheet" @click.stop>
        <view class="contact-glow g1" />
        <view class="contact-glow g2" />
        <view class="contact-handle" />

        <view class="contact-hero">
          <view class="contact-orb">
            <view class="contact-halo" />
            <view class="contact-ring" />
            <view class="contact-logo-box">
              <image class="contact-logo" src="/static/logo.png" mode="aspectFill" />
              <view class="contact-logo-shine" />
                    </view>
                </view>
          <view class="contact-wordmark">
            <text class="wm-ice">ICE</text><text class="wm-jz">JZ</text>
                </view>
          <text class="contact-title">{{ $t('mine.contactSheetTitle') }}</text>
          <text class="contact-sub">{{ $t('mine.contactSheetSub') }}</text>
          <view class="contact-chip">
            <view class="contact-chip-dot" />
            <text class="contact-chip-t">{{ $t('mine.contactAuthorName') }}</text>
            </view>
        </view>

        <view class="contact-card">
          <view class="contact-row">
            <view class="contact-ico tone-cyan">
              <image class="contact-ico-img" src="/static/icons/contact.svg" mode="aspectFit" />
                    </view>
            <view class="contact-row-main">
              <text class="contact-lab">{{ $t('mine.contactQq') }}</text>
              <text class="contact-val">{{ $t('mine.contactQqValue') }}</text>
                </view>
            <view class="contact-copy-btn" @click.stop="onCopyContact('qq')">{{ $t('mine.contactCopy') }}</view>
                    </view>
          <view class="contact-row">
            <view class="contact-ico tone-deep">
              <image class="contact-ico-img" src="/static/icons/email.svg" mode="aspectFit" />
                    </view>
            <view class="contact-row-main">
              <text class="contact-lab">{{ $t('mine.contactEmail') }}</text>
              <text class="contact-val">{{ $t('mine.contactEmailValue') }}</text>
                        </view>
            <view class="contact-copy-btn" @click.stop="onCopyContact('email')">{{ $t('mine.contactCopy') }}</view>
                    </view>
          <view class="contact-row last">
            <view class="contact-ico tone-slate">
              <image class="contact-ico-img" src="/static/icons/device.svg" mode="aspectFit" />
                    </view>
            <view class="contact-row-main">
              <text class="contact-lab">{{ $t('mine.contactHours') }}</text>
              <text class="contact-val soft">{{ $t('mine.contactHoursValue') }}</text>
                </view>
            </view>
        </view>

        <view class="contact-close" @click="closeContact">{{ $t('mine.contactClose') }}</view>
            </view>
        </view>

    <custom-tab-bar v-show="!avatarPreview && !contactOpen" ref="tabBar" />

    <view
      v-if="avatarPreview"
      class="avatar-preview"
      @touchmove.stop.prevent
    >
      <view class="avatar-preview-close" @click.stop="closeAvatarPreview">
        <view class="avatar-preview-x">
          <view class="x-a" />
          <view class="x-b" />
                    </view>
                </view>
      <text class="avatar-preview-tip">{{ $t('mine.avatarZoomTip') }}</text>
      <view
        class="avatar-preview-stage"
        @click="onPreviewBgClick"
        @touchstart="onPreviewTouchStart"
        @touchmove.stop.prevent="onPreviewTouchMove"
        @touchend="onPreviewTouchEnd"
        @touchcancel="onPreviewTouchEnd"
        @wheel.prevent="onPreviewWheel"
      >
        <image
          class="avatar-preview-img"
          :src="displayAvatar"
          mode="aspectFit"
          :style="avatarPreviewStyle"
          @click.stop="onPreviewImgClick"
        />
                </view>
        </view>
    </view>
</template>

<script>
import cache from '@/utils/cache.js'
import { useLogoutApi } from '@/api/auth.js'
import { useUserInfoApi } from '@/api/user.js'
import { useMessageUnreadCountApi } from '@/api/message.js'
import CustomTabBar from '@/custom-tab-bar/index.vue'

const DEFAULT_AVATAR = '/static/logo.png'

export default {
  components: { CustomTabBar },
    data() {
        return {
      statusBarPx: 20,
      user: {},
      unreadCount: 0,
      contactOpen: false,
      avatarPreview: false,
      avatarScale: 1,
      avatarX: 0,
      avatarY: 0
    }
    },
    computed: {
    avatarPreviewStyle() {
      return {
        transform: `translate3d(${this.avatarX}px, ${this.avatarY}px, 0) scale(${this.avatarScale})`
      }
    },
        displayName() {
      return this.user.realName || this.user.username || this.$t('common.user')
        },
        displayAvatar() {
      return this.user.avatar || DEFAULT_AVATAR
    },
    unreadBadge() {
      return this.unreadCount > 99 ? '99+' : String(this.unreadCount)
    },
    greeting() {
      void this.$i18n.locale
      const h = new Date().getHours()
      if (h < 6) return this.$t('greet.late')
      if (h < 12) return this.$t('greet.morning')
      if (h < 14) return this.$t('greet.noon')
      if (h < 18) return this.$t('greet.afternoon')
      return this.$t('greet.evening')
    },
    helloText() {
      void this.$i18n.locale
      return this.$t('mine.hello', { greet: this.greeting, name: this.displayName })
    },
    accountName() {
      return this.user.username || this.user.realName || '-'
    },
    orgName() {
      return this.user.orgName || ''
    },
    insightCards() {
      void this.$i18n.locale
      const accountShort =
        String(this.accountName).length > 10
          ? String(this.accountName).slice(0, 9) + '…'
          : String(this.accountName)
      const orgShort = this.orgName
        ? String(this.orgName).length > 10
          ? String(this.orgName).slice(0, 9) + '…'
          : String(this.orgName)
        : this.$t('mine.statOrgHintEmpty')
      return [
        {
          key: 'unread',
          tone: 'msg',
          icon: '/static/icons/msg.svg',
          value: String(this.unreadCount),
          label: this.$t('mine.statUnread'),
          path: '/pages/message/inbox'
        },
        {
          key: 'account',
          tone: 'user',
          icon: '/static/icons/user.svg',
          value: accountShort,
          label: this.$t('mine.statAccount'),
          path: '/pages/sys/user/index'
        },
        {
          key: 'org',
          tone: 'org',
          icon: '/static/icons/org.svg',
          value: orgShort,
          label: this.$t('mine.statOrg'),
          path: '/pages/sys/org/index'
        }
      ]
    },
    menuData() {
      void this.$i18n.locale
      return [
        {
          title: this.$t('assistant.entry'),
          hint: this.$t('assistant.entryHint'),
          icon: '/static/mascot/xiaobing-head.png',
          count: 0,
          path: '/pages/assistant/chat'
        },
        {
          title: this.$t('mine.myMsg'),
          hint: this.unreadCount > 0
            ? this.$t('mine.statUnreadHintN', { n: this.unreadCount })
            : this.$t('mine.statUnreadHint0'),
          icon: '/static/icons/msg.svg',
          count: this.unreadCount,
          path: '/pages/message/inbox'
        },
        {
          title: this.$t('mine.userManage'),
          hint: this.$t('mine.statAccountHint'),
          icon: '/static/icons/user.svg',
          count: 0,
          path: '/pages/sys/user/index'
        },
        {
          title: this.$t('mine.orgManage'),
          hint: this.$t('mine.statOrgHint'),
          icon: '/static/icons/org.svg',
          count: 0,
          path: '/pages/sys/org/index'
        }
      ]
    },
    accountMenus() {
      void this.$i18n.locale
                return [
        {
          title: this.$t('mine.settings'),
          icon: '/static/icons/settings.svg',
          note: this.$t('mine.settingsHint'),
          tone: 'tone-cyan',
          path: '/pages/usercenter/settings/settings'
        },
        {
          title: this.$t('mine.profile'),
          icon: '/static/icons/profile.svg',
          note: this.$t('settings.profileHint'),
          tone: 'tone-sky',
          path: '/pages/usercenter/userinfo/userinfo'
        },
        {
          title: this.$t('mine.password'),
          icon: '/static/icons/lock.svg',
          note: this.$t('settings.passwordHint'),
          tone: 'tone-deep',
          path: '/pages/usercenter/password/password'
        },
        {
          title: this.$t('mine.devices'),
          icon: '/static/icons/device.svg',
          note: this.$t('settings.devicesHint'),
          tone: 'tone-mint',
          path: '/pages/usercenter/devices/devices'
        },
        {
          title: this.$t('mine.about'),
          icon: '/static/icons/about.svg',
          note: this.$t('settings.aboutHint'),
          tone: 'tone-slate',
          path: '/pages/usercenter/about/about'
        },
        {
          title: this.$t('mine.contact'),
          icon: '/static/icons/contact.svg',
          note: this.$t('mine.contactHint'),
          tone: 'tone-cyan',
          action: () => this.openContact()
        }
      ]
    }
  },
  onLoad() {
    try {
      this.statusBarPx = uni.getSystemInfoSync().statusBarHeight || 20
    } catch (e) {
      this.statusBarPx = 20
    }
  },
  onShow() {
    try {
      uni.hideTabBar({ animation: false })
    } catch (e) {
      // ignore
    }
    if (!cache.getToken()) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.user = cache.getUserInfo() || {}
    this.loadUser()
    this.loadUnread()
    this.$nextTick(() => this.$refs.tabBar && this.$refs.tabBar.init())
  },
  methods: {
    async loadUser() {
      try {
        const { data } = await useUserInfoApi()
        if (data) {
          this.user = data
          cache.setUserInfo(data)
        }
      } catch (e) {
        // keep
      }
    },
    async loadUnread() {
      try {
        const { data } = await useMessageUnreadCountApi()
        this.unreadCount = data || 0
      } catch (e) {
        this.unreadCount = 0
      }
    },
    onClickMenu(item) {
      if (!item?.path) {
        uni.showToast({ title: this.$t('common.notOpen'), icon: 'none' })
        return
      }
      uni.navigateTo({ url: item.path })
    },
    go(url) {
      uni.navigateTo({ url })
    },
    previewAvatar() {
      if (!this.displayAvatar) return
      this.resetAvatarTransform()
      this.avatarPreview = true
    },
    closeAvatarPreview() {
      this.avatarPreview = false
      this.resetAvatarTransform()
    },
    resetAvatarTransform() {
      this.avatarScale = 1
      this.avatarX = 0
      this.avatarY = 0
      this._pinchStartDist = 0
      this._pinchStartScale = 1
      this._drag = null
      this._moved = false
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
        this._pinchStartScale = this.avatarScale
        this._drag = null
        return
      }
      if (touches.length === 1 && this.avatarScale > 1) {
        this._drag = {
          x: touches[0].clientX,
          y: touches[0].clientY,
          ox: this.avatarX,
          oy: this.avatarY
        }
      }
    },
    onPreviewTouchMove(e) {
      const touches = e.touches || []
      if (touches.length >= 2) {
        this._moved = true
        if (!this._pinchStartDist) {
          this._pinchStartDist = this.touchDistance(touches)
          this._pinchStartScale = this.avatarScale
        }
        const dist = this.touchDistance(touches)
        this.avatarScale = this.clampAvatarScale((dist / this._pinchStartDist) * this._pinchStartScale)
        if (this.avatarScale <= 1) {
          this.avatarX = 0
          this.avatarY = 0
        }
        return
      }
      if (touches.length === 1 && this._drag && this.avatarScale > 1) {
        this._moved = true
        const dx = touches[0].clientX - this._drag.x
        const dy = touches[0].clientY - this._drag.y
        this.avatarX = this._drag.ox + dx
        this.avatarY = this._drag.oy + dy
      }
    },
    onPreviewTouchEnd(e) {
      const touches = e.touches || []
      if (touches.length >= 2) return
      if (touches.length === 1 && this.avatarScale > 1) {
        this._drag = {
          x: touches[0].clientX,
          y: touches[0].clientY,
          ox: this.avatarX,
          oy: this.avatarY
        }
        this._pinchStartDist = 0
        return
      }
      this._pinchStartDist = 0
      this._drag = null
      if (this.avatarScale <= 1.02) {
        this.avatarScale = 1
        this.avatarX = 0
        this.avatarY = 0
      }
    },
    onPreviewWheel(e) {
      const delta = e.deltaY || 0
      const next = this.clampAvatarScale(this.avatarScale + (delta > 0 ? -0.15 : 0.15))
      this.avatarScale = next
      if (next <= 1) {
        this.avatarX = 0
        this.avatarY = 0
      }
    },
    onPreviewImgClick() {
      const now = Date.now()
      if (this._lastTap && now - this._lastTap < 280) {
        this._lastTap = 0
        if (this.avatarScale > 1.05) {
          this.avatarScale = 1
          this.avatarX = 0
          this.avatarY = 0
        } else {
          this.avatarScale = 2.2
        }
        return
      }
      this._lastTap = now
    },
    onPreviewBgClick() {
      if (this._moved) return
      if (this.avatarScale > 1.05) {
        this.avatarScale = 1
        this.avatarX = 0
        this.avatarY = 0
        return
      }
      this.closeAvatarPreview()
    },
    openContact() {
      this.contactOpen = true
    },
    closeContact() {
      this.contactOpen = false
    },
    onCopyContact(type) {
      const isEmail = type === 'email'
      const data = isEmail ? this.$t('mine.contactEmailValue') : this.$t('mine.contactQqValue')
      uni.setClipboardData({
        data,
        success: () => {
          uni.showToast({
            title: isEmail ? this.$t('mine.emailCopied') : this.$t('mine.qqCopied'),
            icon: 'none'
          })
        }
      })
        },
        onLogout() {
                    useLogoutApi()
        .catch(() => null)
                        .finally(() => {
          cache.removeToken()
          cache.removeUserInfo()
          uni.reLaunch({ url: '/pages/login/login' })
        })
    }
  }
}
</script>

<style scoped>
.page {
    position: relative;
  background: #f3f6fa;
    overflow: hidden;
}

.avatar-preview {
  position: fixed;
    inset: 0;
  z-index: 20000;
  background: rgba(15, 27, 45, 0.9);
  box-sizing: border-box;
}

.avatar-preview-tip {
    position: absolute;
  left: 0;
  right: 0;
  bottom: calc(36rpx + env(safe-area-inset-bottom));
  z-index: 2;
  text-align: center;
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.55);
  pointer-events: none;
}

.avatar-preview-stage {
  position: absolute;
  inset: 0;
    display: flex;
    align-items: center;
  justify-content: center;
  overflow: hidden;
}

.avatar-preview-close {
  position: absolute;
  top: calc(24rpx + env(safe-area-inset-top));
  right: 28rpx;
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.14);
  border: 1rpx solid rgba(255, 255, 255, 0.18);
    display: flex;
    align-items: center;
  justify-content: center;
}

.avatar-preview-x {
    position: relative;
  width: 24rpx;
  height: 24rpx;
}

.x-a,
.x-b {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 24rpx;
  height: 3rpx;
  border-radius: 999rpx;
  background: #fff;
  margin-left: -12rpx;
  margin-top: -1.5rpx;
}

.x-a {
  transform: rotate(45deg);
}

.x-b {
  transform: rotate(-45deg);
}

.avatar-preview-img {
  width: 68vw;
  max-width: 640rpx;
  height: 68vw;
  max-height: 640rpx;
  border-radius: 24rpx;
  transform-origin: center center;
  transition: transform 0.08s linear;
  will-change: transform;
}

.bg {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 0;
}

.bg-base {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 90% 50% at 50% -8%, rgba(0, 168, 232, 0.14), transparent 58%),
    linear-gradient(180deg, #eef6fb 0%, #f3f6fa 42%, #f7f9fc 100%);
}

.blob {
    position: absolute;
    border-radius: 50%;
}

.blob.b1 {
  width: 420rpx;
  height: 420rpx;
  top: -120rpx;
  right: -120rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.16), transparent 70%);
}

.blob.b2 {
  width: 320rpx;
  height: 320rpx;
  top: 420rpx;
  left: -140rpx;
  background: radial-gradient(circle, rgba(125, 211, 252, 0.16), transparent 70%);
}

.shell {
  position: relative;
  z-index: 1;
  padding: 0 28rpx 28rpx;
}

.stage {
    position: relative;
  border-radius: 36rpx;
    overflow: hidden;
  background:
    linear-gradient(160deg, rgba(232, 247, 253, 0.95) 0%, rgba(255, 255, 255, 0.98) 42%, #ffffff 100%);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 18rpx 44rpx rgba(15, 35, 55, 0.06);
}

.stage-glow {
    position: absolute;
    border-radius: 50%;
  pointer-events: none;
}

.stage-glow.g1 {
  width: 280rpx;
  height: 280rpx;
  top: -120rpx;
  right: -80rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.18), transparent 70%);
}

.stage-glow.g2 {
  width: 180rpx;
  height: 180rpx;
  left: -60rpx;
  top: 80rpx;
  background: radial-gradient(circle, rgba(125, 211, 252, 0.16), transparent 70%);
}

.stage-nav {
  position: relative;
  z-index: 1;
  padding: 22rpx 24rpx 8rpx;
    display: flex;
  align-items: flex-start;
  justify-content: space-between;
    gap: 16rpx;
}

.brand-mark {
  line-height: 1;
}

.brand-ice,
.brand-jz {
    font-size: 34rpx;
  font-weight: 800;
  letter-spacing: 0.04em;
}

.brand-ice {
  color: #3d4b5c;
}

.brand-jz {
  color: #2bb8ef;
}

.brand-sub {
    display: block;
  margin-top: 6rpx;
    font-size: 20rpx;
  color: #9aa8b6;
}

.stage-actions {
  display: flex;
  gap: 10rpx;
}

.act-btn {
  position: relative;
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.88);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 8rpx 18rpx rgba(15, 35, 55, 0.05);
    display: flex;
  align-items: center;
  justify-content: center;
}

.act-ico {
  width: 30rpx;
  height: 30rpx;
}

.act-dot {
  position: absolute;
  top: 2rpx;
  right: 2rpx;
  min-width: 26rpx;
  height: 26rpx;
  padding: 0 6rpx;
  border-radius: 999rpx;
  background: #fb7185;
  color: #fff;
  font-size: 15rpx;
    font-weight: 700;
  line-height: 26rpx;
  text-align: center;
}

.identity {
  position: relative;
  z-index: 1;
  margin: 8rpx 20rpx 0;
  padding: 14rpx 8rpx 20rpx;
    display: flex;
    align-items: center;
  gap: 20rpx;
}

.avatar-stage {
  position: relative;
  width: 132rpx;
  height: 132rpx;
  flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
}

.avatar-halo {
  position: absolute;
  width: 128rpx;
  height: 128rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.2), transparent 68%);
}

.avatar-orbit {
  position: absolute;
  width: 124rpx;
  height: 124rpx;
  border-radius: 50%;
  border: 2rpx dashed rgba(0, 168, 232, 0.22);
  box-sizing: border-box;
}

.avatar-box {
  position: relative;
  z-index: 1;
  width: 104rpx;
  height: 104rpx;
  border-radius: 50%;
  padding: 5rpx;
  background: linear-gradient(145deg, #ffffff, #d9f1fb 55%, #b8e4f7);
  box-shadow:
    0 14rpx 28rpx rgba(0, 140, 200, 0.16),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95);
  box-sizing: border-box;
}

.avatar-sheen {
  position: absolute;
  inset: 5rpx;
  border-radius: 50%;
  z-index: 2;
  pointer-events: none;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.45), transparent 42%);
}

.avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: #e8f4fb;
    display: block;
}

.live {
  position: absolute;
  right: 4rpx;
  bottom: 6rpx;
  z-index: 3;
  width: 20rpx;
  height: 20rpx;
  border-radius: 50%;
  background: #22c55e;
  border: 3rpx solid #fff;
  box-shadow: 0 0 0 4rpx rgba(34, 197, 94, 0.12);
}

.identity-copy {
  min-width: 0;
  flex: 1;
}

.greet {
    display: block;
    font-size: 22rpx;
  color: #9aa8b6;
  font-weight: 600;
}

.name-line {
  margin-top: 6rpx;
    display: flex;
  align-items: center;
    flex-wrap: wrap;
  gap: 10rpx;
}

.name {
    font-size: 34rpx;
  font-weight: 780;
  color: #3d4b5c;
}

.chip {
  padding: 4rpx 12rpx;
    border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.1);
  color: #2bb8ef;
  font-size: 18rpx;
  font-weight: 720;
}

.meta {
  margin-top: 12rpx;
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.meta-pill {
  max-width: 100%;
    padding: 6rpx 14rpx;
    border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.82);
  border: 1rpx solid rgba(232, 238, 245, 0.95);
    font-size: 20rpx;
  color: #6b7a8c;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.meta-pill.soft {
  color: #9aa8b6;
}

.edit-btn {
  flex-shrink: 0;
  height: 56rpx;
  padding: 0 18rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.88);
  border: 1rpx solid rgba(186, 230, 253, 0.9);
    display: flex;
    align-items: center;
  justify-content: center;
}

.edit-t {
    font-size: 22rpx;
  font-weight: 720;
  color: #5b9fbf;
}

.metrics {
  position: relative;
  z-index: 1;
  margin: 0 16rpx 16rpx;
  padding: 6rpx 4rpx;
  border-radius: 24rpx;
  background: rgba(255, 255, 255, 0.72);
  border: 1rpx solid rgba(255, 255, 255, 0.95);
    display: flex;
  align-items: stretch;
}

.metric {
  flex: 1;
  min-width: 0;
  padding: 18rpx 10rpx;
    display: flex;
  flex-direction: column;
    align-items: center;
  gap: 6rpx;
}

.metric-split {
  width: 1rpx;
  align-self: stretch;
  margin: 18rpx 0;
  background: linear-gradient(180deg, transparent, #e4ebf2, transparent);
}

.metric-val {
    display: block;
  max-width: 100%;
  font-size: 28rpx;
  font-weight: 780;
  color: #3d4b5c;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.metric-lab {
    display: block;
    font-size: 20rpx;
  color: #9aa8b6;
    font-weight: 600;
}

.section {
  margin-top: 28rpx;
}

.section-head {
  padding: 0 6rpx 14rpx;
}

.section-title {
    display: block;
  font-size: 30rpx;
  font-weight: 800;
  color: #0f1b2d;
}

.section-sub {
    display: block;
  margin-top: 6rpx;
    font-size: 22rpx;
  color: #8492a6;
}

.service-grid {
    display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14rpx;
}

.service {
  padding: 22rpx 20rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.96);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 12rpx 28rpx rgba(15, 35, 55, 0.04);
    display: flex;
    align-items: center;
  gap: 14rpx;
}

.service-ico {
  position: relative;
  width: 68rpx;
  height: 68rpx;
    border-radius: 22rpx;
  background: linear-gradient(160deg, #eaf7fd, #dff2fb);
    display: flex;
    align-items: center;
    justify-content: center;
  flex-shrink: 0;
}

.service-img {
  width: 36rpx;
  height: 36rpx;
}

.service-badge {
  position: absolute;
  top: -8rpx;
  right: -8rpx;
  min-width: 30rpx;
  height: 30rpx;
  padding: 0 8rpx;
  border-radius: 999rpx;
  background: #fb7185;
  color: #fff;
  font-size: 16rpx;
  font-weight: 700;
    display: flex;
    align-items: center;
  justify-content: center;
}

.service-copy {
    min-width: 0;
  flex: 1;
}

.service-name {
    display: block;
  font-size: 26rpx;
  font-weight: 740;
  color: #0f1b2d;
}

.service-hint {
    display: block;
  margin-top: 4rpx;
    font-size: 20rpx;
  color: #8492a6;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.service-go {
  font-size: 30rpx;
    color: #94a3b8;
    flex-shrink: 0;
}

.account-section {
  margin-top: 32rpx;
}

.account-head {
  display: flex;
  align-items: flex-start;
  gap: 14rpx;
  padding: 0 4rpx 18rpx;
}

.account-head-mark {
  width: 8rpx;
  height: 36rpx;
  margin-top: 6rpx;
  border-radius: 999rpx;
  background: linear-gradient(180deg, #3ec6ff 0%, #00a8e8 55%, #0879a8 100%);
  box-shadow: 0 8rpx 16rpx rgba(0, 168, 232, 0.28);
  flex-shrink: 0;
}

.account-head-copy {
  min-width: 0;
  flex: 1;
}

.panel,
.account-panel {
    position: relative;
  border-radius: 32rpx;
  background:
    linear-gradient(165deg, rgba(255, 255, 255, 0.98) 0%, rgba(246, 251, 254, 0.96) 48%, #ffffff 100%);
  border: 1rpx solid rgba(220, 234, 244, 0.95);
  box-shadow:
    0 18rpx 40rpx rgba(15, 35, 55, 0.06),
    0 2rpx 0 rgba(255, 255, 255, 0.95) inset;
  overflow: hidden;
  padding: 10rpx 10rpx 8rpx;
}

.panel-glow {
  position: absolute;
  top: -80rpx;
  right: -40rpx;
  width: 220rpx;
  height: 220rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.12), transparent 68%);
  pointer-events: none;
  z-index: 0;
}

.panel-lines {
    position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 0;
  opacity: 0.45;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.55), transparent 36%),
    linear-gradient(180deg, transparent, rgba(232, 244, 250, 0.35));
}

.row {
  position: relative;
  z-index: 1;
    display: flex;
    align-items: center;
  gap: 18rpx;
  padding: 20rpx 16rpx;
  margin-bottom: 4rpx;
  border-radius: 24rpx;
  background: transparent;
}

.row.last {
  margin-bottom: 0;
}

.row::after {
  content: '';
  position: absolute;
  left: 98rpx;
  right: 18rpx;
  bottom: 0;
  height: 1rpx;
  background: linear-gradient(90deg, rgba(15, 35, 55, 0.06), rgba(15, 35, 55, 0.02), transparent);
}

.row.last::after {
  display: none;
}

.row-hover {
  background: rgba(0, 168, 232, 0.05);
}

.row-ico {
  position: relative;
  width: 68rpx;
  height: 68rpx;
  border-radius: 22rpx;
  background: linear-gradient(160deg, #eaf7fd, #e4f3fb);
    display: flex;
    align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow:
    0 10rpx 20rpx rgba(0, 140, 200, 0.08),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.9);
  overflow: hidden;
}

.row-ico-ring {
  position: absolute;
  inset: 0;
  border-radius: 22rpx;
  border: 1rpx solid rgba(255, 255, 255, 0.75);
  pointer-events: none;
}

.row-ico.tone-cyan {
  background: linear-gradient(145deg, #e8f8fe, #d5f0fb 55%, #c5e9f7);
}

.row-ico.tone-sky {
  background: linear-gradient(145deg, #eef8ff, #dceffc 55%, #cfe7f8);
}

.row-ico.tone-deep {
  background: linear-gradient(145deg, #e6f4fb, #cfe6f4 55%, #b9dceb);
}

.row-ico.tone-mint {
  background: linear-gradient(145deg, #eafaf7, #d8f3ee 55%, #c7ebe4);
}

.row-ico.tone-slate {
  background: linear-gradient(145deg, #f2f6fa, #e6edf4 55%, #dbe5ef);
}

.row-ico.tone-coral {
  background: linear-gradient(145deg, #e8f8fe, #d5f0fb 55%, #c5e9f7);
}

.row-img {
  position: relative;
  z-index: 1;
  width: 30rpx;
  height: 30rpx;
}

.row-copy {
  min-width: 0;
  flex: 1;
}

.row-title {
    display: block;
  font-size: 28rpx;
  font-weight: 720;
  color: #122033;
  letter-spacing: 0.01em;
}

.row-note {
    display: block;
  margin-top: 6rpx;
  font-size: 20rpx;
  color: #8492a6;
  line-height: 1.35;
}

.row-trail {
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.88);
  border: 1rpx solid rgba(220, 232, 242, 0.95);
  box-shadow: 0 6rpx 14rpx rgba(15, 35, 55, 0.04);
    display: flex;
    align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.row-go {
  font-size: 28rpx;
  color: #7f94a8;
  line-height: 1;
  transform: translateX(1rpx);
}

.logout {
  margin-top: 28rpx;
    height: 92rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.96);
  border: 1rpx solid rgba(196, 91, 106, 0.14);
  color: #c45b6a;
    font-size: 30rpx;
  font-weight: 750;
    display: flex;
    align-items: center;
    justify-content: center;
  box-shadow: 0 12rpx 28rpx rgba(168, 72, 88, 0.04);
}

.foot {
    display: block;
  margin-top: 20rpx;
  text-align: center;
    font-size: 20rpx;
  color: #9aa8b6;
  letter-spacing: 0.04em;
}

.contact-mask {
  position: fixed;
  inset: 0;
  z-index: 12000;
  background: rgba(8, 28, 44, 0.45);
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.contact-sheet {
    position: relative;
  width: 100%;
  overflow: hidden;
  padding: 14rpx 28rpx calc(28rpx + env(safe-area-inset-bottom));
  border-radius: 40rpx 40rpx 0 0;
  background:
    linear-gradient(180deg, rgba(236, 248, 253, 0.98) 0%, rgba(255, 255, 255, 0.99) 34%, #ffffff 100%);
  border-top: 1rpx solid rgba(186, 230, 253, 0.7);
  box-shadow: 0 -20rpx 56rpx rgba(0, 120, 180, 0.14);
  box-sizing: border-box;
}

.contact-glow {
    position: absolute;
    border-radius: 50%;
  pointer-events: none;
}

.contact-glow.g1 {
  top: -110rpx;
  left: 50%;
  width: 320rpx;
  height: 320rpx;
  margin-left: -160rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.18), transparent 68%);
}

.contact-glow.g2 {
  top: 180rpx;
  right: -80rpx;
  width: 200rpx;
  height: 200rpx;
  background: radial-gradient(circle, rgba(62, 198, 255, 0.12), transparent 70%);
}

.contact-handle {
  position: relative;
  z-index: 1;
  width: 68rpx;
  height: 8rpx;
  margin: 2rpx auto 18rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.22);
}

.contact-hero {
  position: relative;
  z-index: 1;
    display: flex;
  flex-direction: column;
    align-items: center;
  padding: 4rpx 12rpx 26rpx;
}

.contact-orb {
  position: relative;
  width: 168rpx;
  height: 168rpx;
    display: flex;
    align-items: center;
    justify-content: center;
}

.contact-halo {
  position: absolute;
  inset: 10rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.2), transparent 68%);
}

.contact-ring {
  position: absolute;
  inset: 18rpx;
  border-radius: 50%;
  border: 2rpx dashed rgba(0, 168, 232, 0.22);
  box-sizing: border-box;
}

.contact-logo-box {
  position: relative;
  z-index: 1;
  width: 112rpx;
  height: 112rpx;
  border-radius: 34rpx;
  padding: 8rpx;
  background: linear-gradient(145deg, #ffffff, #e8f7fd 55%, #d5eef9);
  box-shadow:
    0 16rpx 32rpx rgba(0, 140, 200, 0.18),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95);
  box-sizing: border-box;
    overflow: hidden;
}

.contact-logo {
    width: 100%;
  height: 100%;
  border-radius: 26rpx;
  display: block;
  background: #eaf7fd;
}

.contact-logo-shine {
  position: absolute;
  inset: 8rpx;
  border-radius: 26rpx;
  pointer-events: none;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.42), transparent 46%);
}

.contact-wordmark {
  margin-top: 16rpx;
  line-height: 1;
}

.wm-ice,
.wm-jz {
  font-size: 34rpx;
  font-weight: 800;
  letter-spacing: 0.04em;
}

.wm-ice {
  color: #3d4b5c;
}

.wm-jz {
  color: #2bb8ef;
}

.contact-title {
    display: block;
  margin-top: 12rpx;
    font-size: 34rpx;
  font-weight: 800;
  color: #122033;
}

.contact-sub {
    display: block;
  margin-top: 8rpx;
  max-width: 520rpx;
  text-align: center;
  font-size: 22rpx;
  color: #8492a6;
  line-height: 1.45;
}

.contact-chip {
  margin-top: 16rpx;
  height: 48rpx;
  padding: 0 18rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.08);
  border: 1rpx solid rgba(0, 168, 232, 0.14);
    display: flex;
    align-items: center;
  gap: 10rpx;
}

.contact-chip-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 0 4rpx rgba(34, 197, 94, 0.14);
}

.contact-chip-t {
  font-size: 22rpx;
  font-weight: 720;
  color: #0879a8;
}

.contact-card {
  position: relative;
  z-index: 1;
  border-radius: 30rpx;
  background:
    linear-gradient(165deg, rgba(255, 255, 255, 0.98) 0%, rgba(246, 251, 254, 0.96) 100%);
  border: 1rpx solid rgba(220, 234, 244, 0.95);
  box-shadow:
    0 14rpx 32rpx rgba(15, 35, 55, 0.05),
    0 2rpx 0 rgba(255, 255, 255, 0.95) inset;
  overflow: hidden;
  padding: 10rpx;
}

.contact-row {
    display: flex;
    align-items: center;
  gap: 16rpx;
  padding: 18rpx 14rpx;
  border-radius: 22rpx;
  margin-bottom: 4rpx;
  background: rgba(255, 255, 255, 0.55);
}

.contact-row.last {
  margin-bottom: 0;
}

.contact-ico {
  width: 64rpx;
  height: 64rpx;
  border-radius: 20rpx;
    display: flex;
    align-items: center;
    justify-content: center;
  flex-shrink: 0;
  box-shadow:
    0 8rpx 16rpx rgba(0, 140, 200, 0.08),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.9);
}

.contact-ico.tone-cyan {
  background: linear-gradient(145deg, #e8f8fe, #d5f0fb 55%, #c5e9f7);
}

.contact-ico.tone-deep {
  background: linear-gradient(145deg, #e6f4fb, #cfe6f4 55%, #b9dceb);
}

.contact-ico.tone-slate {
  background: linear-gradient(145deg, #f2f6fa, #e6edf4 55%, #dbe5ef);
}

.contact-ico-img {
  width: 28rpx;
  height: 28rpx;
}

.contact-row-main {
  min-width: 0;
  flex: 1;
}

.contact-lab {
  display: block;
  font-size: 20rpx;
  color: #9aa8b6;
  font-weight: 600;
}

.contact-val {
  display: block;
  margin-top: 6rpx;
    font-size: 28rpx;
  font-weight: 720;
  color: #122033;
  word-break: break-all;
}

.contact-val.soft {
    font-size: 24rpx;
  font-weight: 600;
  color: #5b6b7c;
  line-height: 1.45;
}

.contact-copy-btn {
  flex-shrink: 0;
  height: 56rpx;
  padding: 0 22rpx;
  border-radius: 999rpx;
  background: linear-gradient(135deg, #00a8e8, #2bb8ef);
  color: #fff;
  font-size: 22rpx;
  font-weight: 720;
    display: flex;
    align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 18rpx rgba(0, 140, 200, 0.22);
}

.contact-close {
    position: relative;
  z-index: 1;
  margin-top: 22rpx;
  height: 88rpx;
  border-radius: 999rpx;
  background: rgba(232, 247, 253, 0.92);
  border: 1rpx solid rgba(186, 230, 253, 0.75);
  color: #0879a8;
  font-size: 28rpx;
  font-weight: 720;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
