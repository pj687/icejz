<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('settings.title')" :sub="$t('settings.sub')" />

    <view class="body">
      <view class="panel">
        <text class="group">{{ $t('settings.groupGeneral') }}</text>

        <view class="lang-card">
          <view class="lang-copy">
            <text class="lang-title">{{ $t('mine.language') }}</text>
            <text class="lang-desc">{{ $t('mine.languageHint') }}</text>
          </view>
          <view class="lang-switch">
            <view
              class="lang-opt"
              :class="{ on: locale === 'zh-CN' }"
              @click="switchLocale('zh-CN')"
            >中</view>
            <view
              class="lang-opt"
              :class="{ on: locale === 'en-US' }"
              @click="switchLocale('en-US')"
            >EN</view>
          </view>
        </view>

        <view class="cell" @click="go('/pages/usercenter/about/about')">
          <view class="cell-l">
            <view class="mark">
              <image class="mark-img" src="/static/icons/about.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('mine.about') }}</text>
              <text class="note">{{ $t('settings.aboutHint') }}</text>
            </view>
          </view>
          <text class="arrow">›</text>
        </view>

        <view class="cell" @click="replayGuide">
          <view class="cell-l">
            <view class="mark soft">
              <image class="mark-img" src="/static/icons/about.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('guide.replay') }}</text>
              <text class="note">{{ $t('guide.replayHint') }}</text>
            </view>
          </view>
          <text class="arrow">›</text>
        </view>
      </view>

      <view class="panel">
        <text class="group">{{ $t('settings.groupPermission') }}</text>

        <view class="cell" @click="openSystemSetting">
          <view class="cell-l">
            <view class="mark">
              <image class="mark-img" src="/static/icons/album.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('settings.album') }}</text>
              <text class="note">{{ $t('settings.albumHint') }}</text>
            </view>
          </view>
          <text class="perm" :class="albumClass">{{ albumLabel }}</text>
        </view>

        <view class="cell" @click="openSystemSetting">
          <view class="cell-l">
            <view class="mark">
              <image class="mark-img" src="/static/icons/camera.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('settings.camera') }}</text>
              <text class="note">{{ $t('settings.cameraHint') }}</text>
            </view>
          </view>
          <text class="perm" :class="cameraClass">{{ cameraLabel }}</text>
        </view>

        <view class="cell" @click="openSystemSetting">
          <view class="cell-l">
            <view class="mark soft">
              <image class="mark-img" src="/static/icons/settings.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('settings.openSystemSetting') }}</text>
              <text class="note">{{ $t('settings.openSystemSettingHint') }}</text>
            </view>
          </view>
          <text class="arrow">›</text>
        </view>
      </view>

      <view class="panel">
        <text class="group">{{ $t('settings.groupSecurity') }}</text>

        <view class="cell" @click="go('/pages/usercenter/userinfo/userinfo')">
          <view class="cell-l">
            <view class="mark">
              <image class="mark-img" src="/static/icons/profile.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('mine.profile') }}</text>
              <text class="note">{{ $t('settings.profileHint') }}</text>
            </view>
          </view>
          <text class="arrow">›</text>
        </view>

        <view class="cell" @click="go('/pages/usercenter/password/password')">
          <view class="cell-l">
            <view class="mark">
              <image class="mark-img" src="/static/icons/lock.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('mine.password') }}</text>
              <text class="note">{{ $t('settings.passwordHint') }}</text>
            </view>
          </view>
          <text class="arrow">›</text>
        </view>

        <view class="cell" @click="go('/pages/usercenter/devices/devices')">
          <view class="cell-l">
            <view class="mark">
              <image class="mark-img" src="/static/icons/device.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('mine.devices') }}</text>
              <text class="note">{{ $t('settings.devicesHint') }}</text>
            </view>
          </view>
          <text class="arrow">›</text>
        </view>
      </view>

      <view class="panel">
        <text class="group">{{ $t('settings.groupStorage') }}</text>

        <view class="cell" @click="onClearCache">
          <view class="cell-l">
            <view class="mark soft">
              <image class="mark-img" src="/static/icons/settings.svg" mode="aspectFit" />
            </view>
            <view class="copy">
              <text class="title">{{ $t('settings.clearCache') }}</text>
              <text class="note">{{ $t('settings.clearCacheHint') }}</text>
            </view>
          </view>
          <text class="arrow">›</text>
        </view>
      </view>

      <view class="ver">
        <text class="ver-lab">{{ $t('settings.version') }}</text>
        <text class="ver-val">v1.0.6</text>
      </view>
    </view>
  </view>
</template>

<script>
import IceNavBar from '@/components/layout/IceNavBar.vue'
import cache from '@/utils/cache.js'
import { setAppLocale, getStoredLocale, setStoredLocale } from '@/locale/index.js'
import { isGuideDone, markGuideDone } from '@/utils/guide.js'
import { showIceToast } from '@/utils/iceToast.js'
import { showIceConfirm } from '@/utils/iceConfirm.js'

export default {
  name: 'Settings',
  components: { IceNavBar },
  data() {
    return {
      albumAuth: null,
      cameraAuth: null
    }
  },
  computed: {
    locale() {
      return this.$i18n.locale
    },
    albumLabel() {
      return this.permLabel(this.albumAuth)
    },
    cameraLabel() {
      return this.permLabel(this.cameraAuth)
    },
    albumClass() {
      return this.permClass(this.albumAuth)
    },
    cameraClass() {
      return this.permClass(this.cameraAuth)
    }
  },
  onShow() {
    this.refreshPermissions()
  },
  methods: {
    go(url) {
      uni.navigateTo({ url })
    },
    replayGuide() {
      uni.navigateTo({ url: '/pages/guide/guide' })
    },
    permLabel(auth) {
      if (auth === true) return this.$t('settings.permOn')
      if (auth === false) return this.$t('settings.permOff')
      return this.$t('settings.permUnknown')
    },
    permClass(auth) {
      if (auth === true) return 'on'
      if (auth === false) return 'off'
      return 'unknown'
    },
    readAuth(auth, keys) {
      for (let i = 0; i < keys.length; i += 1) {
        const key = keys[i]
        if (Object.prototype.hasOwnProperty.call(auth, key)) {
          return !!auth[key]
        }
      }
      return null
    },
    refreshPermissions() {
      if (typeof uni.getSetting !== 'function') {
        this.albumAuth = null
        this.cameraAuth = null
        return
      }
      uni.getSetting({
        success: (res) => {
          const auth = (res && res.authSetting) || {}
          this.albumAuth = this.readAuth(auth, ['scope.album', 'scope.writePhotosAlbum'])
          this.cameraAuth = this.readAuth(auth, ['scope.camera'])
        },
        fail: () => {
          this.albumAuth = null
          this.cameraAuth = null
        }
      })
    },
    openSystemSetting() {
      if (typeof uni.openSetting !== 'function') {
        showIceToast({ title: this.$t('settings.openSettingFail'), icon: 'none' })
        return
      }
      uni.openSetting({
        success: () => {
          this.refreshPermissions()
        },
        fail: () => {
          showIceToast({ title: this.$t('settings.openSettingFail'), icon: 'none' })
        }
      })
    },
    switchLocale(code) {
      if (this.locale === code) return
      setAppLocale(code)
      showIceToast({ title: this.$t('lang.switched'), icon: 'success' })
    },
    async onClearCache() {
      const ok = await showIceConfirm({
        title: this.$t('settings.clearTitle'),
        content: this.$t('settings.clearConfirm'),
        confirmText: this.$t('settings.clearAction'),
        cancelText: this.$t('common.cancel'),
        tone: 'danger'
      })
      if (!ok) return
      try {
        const token = cache.getToken()
        const userInfo = cache.getUserInfo()
        const locale = getStoredLocale()
        const guideDone = isGuideDone()
        uni.clearStorageSync()
        if (token) cache.setToken(token)
        if (userInfo) cache.setUserInfo(userInfo)
        setStoredLocale(locale)
        setAppLocale(locale)
        if (guideDone) markGuideDone()
        showIceToast({ title: this.$t('settings.clearOk'), icon: 'success' })
      } catch (e) {
        showIceToast({ title: this.$t('settings.clearFail'), icon: 'error' })
      }
    }
  }
}
</script>

<style scoped>
.page {
  min-height: 100vh;
  box-sizing: border-box;
}

.body {
  padding: 8rpx 28rpx 48rpx;
}

.panel {
  margin-top: 18rpx;
  padding: 18rpx 18rpx 8rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.group {
  display: block;
  margin: 4rpx 8rpx 14rpx;
  font-size: 22rpx;
  font-weight: 750;
  letter-spacing: 0.08em;
  color: #7aa8c4;
}

.lang-card {
  margin-bottom: 8rpx;
  padding: 18rpx 16rpx;
  border-radius: 22rpx;
  background: #f5f9fc;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
}

.lang-copy {
  min-width: 0;
}

.lang-title {
  display: block;
  font-size: 28rpx;
  font-weight: 740;
  color: #0f1b2d;
}

.lang-desc {
  display: block;
  margin-top: 4rpx;
  font-size: 20rpx;
  color: #8492a6;
}

.lang-switch {
  display: flex;
  padding: 4rpx;
  border-radius: 999rpx;
  background: #fff;
  border: 1rpx solid #e8eef5;
  flex-shrink: 0;
}

.lang-opt {
  min-width: 56rpx;
  height: 52rpx;
  padding: 0 14rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22rpx;
  font-weight: 750;
  color: #8492a6;
}

.lang-opt.on {
  background: linear-gradient(145deg, #2bb8ef, #00a8e8);
  color: #fff;
  box-shadow: 0 6rpx 14rpx rgba(0, 168, 232, 0.22);
}

.cell {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
  padding: 18rpx 8rpx;
  border-top: 1rpx solid #eef2f6;
}

.cell:first-of-type {
  border-top: none;
}

.lang-card + .cell {
  border-top: 1rpx solid #eef2f6;
  margin-top: 4rpx;
}

.cell-l {
  display: flex;
  align-items: center;
  gap: 16rpx;
  min-width: 0;
}

.mark {
  width: 64rpx;
  height: 64rpx;
  border-radius: 20rpx;
  background: linear-gradient(160deg, #eaf7fd, #e4f3fb);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.mark.soft {
  background: #f3f6fa;
}

.mark-img {
  width: 30rpx;
  height: 30rpx;
}

.copy {
  min-width: 0;
}

.title {
  display: block;
  font-size: 28rpx;
  font-weight: 680;
  color: #0f1b2d;
}

.note {
  display: block;
  margin-top: 4rpx;
  font-size: 20rpx;
  color: #8492a6;
}

.arrow {
  font-size: 30rpx;
  color: #94a3b8;
  flex-shrink: 0;
}

.perm {
  flex-shrink: 0;
  padding: 6rpx 14rpx;
  border-radius: 999rpx;
  font-size: 20rpx;
  font-weight: 720;
  line-height: 1.2;
}

.perm.on {
  color: #0a7ea4;
  background: rgba(0, 168, 232, 0.12);
}

.perm.off {
  color: #c2410c;
  background: rgba(234, 88, 12, 0.1);
}

.perm.unknown {
  color: #8492a6;
  background: #f1f5f9;
}

.ver {
  margin-top: 28rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
}

.ver-lab,
.ver-val {
  font-size: 22rpx;
  color: #9aa8b6;
}

.ver-val {
  font-weight: 700;
  color: #8492a6;
}
</style>
