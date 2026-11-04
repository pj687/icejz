<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('profile.title')" :sub="$t('profile.sub')" />

    <view class="body">
      <view class="profile-card">
        <view class="avatar-wrap" @tap="uploadAvatar">
          <image :src="displayAvatar" class="avatar" mode="aspectFill" />
          <view class="camera">{{ uploadingAvatar ? '…' : '摄' }}</view>
        </view>
        <view class="meta">
          <text class="name">{{ user.realName || $t('profile.noName') }}</text>
          <text class="sub">{{ user.mobile || $t('profile.fillMobile') }}</text>
          <view class="tags">
            <text class="tag">{{ genderLabel }}</text>
            <text class="tag soft">{{ $t('profile.accountInfo') }}</text>
          </view>
        </view>
      </view>

      <view class="panel">
        <view class="panel-head">
          <text class="panel-title">{{ $t('profile.basic') }}</text>
          <text class="panel-sub">{{ $t('profile.tapEdit') }}</text>
        </view>
        <view class="rows">
          <view class="row" @tap="navigateToInput('realName')">
            <view class="mark dark">
              <image class="mark-img" src="/static/icons/name.svg" mode="aspectFit" />
            </view>
            <view class="row-body">
              <text class="label">{{ $t('profile.name') }}</text>
              <text class="tip">{{ $t('profile.nameTip') }}</text>
            </view>
            <text class="value">{{ user.realName || $t('profile.pleaseFill') }}</text>
            <text class="arrow">›</text>
          </view>
          <view class="row" @tap="navigateToInput('mobile')">
            <view class="mark cyan">
              <image class="mark-img" src="/static/icons/phone.svg" mode="aspectFit" />
            </view>
            <view class="row-body">
              <text class="label">{{ $t('profile.mobile') }}</text>
              <text class="tip">{{ $t('profile.mobileTip') }}</text>
            </view>
            <text class="value">{{ user.mobile || $t('profile.pleaseFill') }}</text>
            <text class="arrow">›</text>
          </view>
          <view class="row" @tap="navigateToInput('email')">
            <view class="mark sky">
              <image class="mark-img" src="/static/icons/email.svg" mode="aspectFit" />
            </view>
            <view class="row-body">
              <text class="label">{{ $t('profile.email') }}</text>
              <text class="tip">{{ $t('profile.emailTip') }}</text>
            </view>
            <text class="value">{{ user.email || $t('profile.pleaseFill') }}</text>
            <text class="arrow">›</text>
          </view>
        </view>
      </view>

      <view class="panel">
        <view class="panel-head">
          <text class="panel-title">{{ $t('profile.gender') }}</text>
          <text class="panel-sub">{{ $t('profile.genderSave') }}</text>
        </view>
        <view class="gender-row">
          <view
            v-for="item in genderList"
            :key="item.value"
            class="gender"
            :class="[item.tone, { active: Number(user.gender) === item.value }]"
            @tap="selectGender(item)"
          >
            <view class="gender-art">
              <image class="gender-img" :src="item.art" mode="aspectFill" />
            </view>
            <text class="gender-name">{{ item.label }}</text>
            <text class="gender-desc">{{ item.desc }}</text>
            <view class="gender-check">
              <view class="gender-check-ico" />
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import * as request from '@/utils/request.js'
import { showIceToast } from '@/utils/iceToast.js'
import { useUserInfoApi, useUserInfoSubmitApi, useUserAvatarApi } from '@/api/user.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'

export default {
  name: 'UserInfo',
  components: { IceNavBar },
  data() {
    return {
      uploadingAvatar: false,
      savingGender: false,
      user: {
        id: '',
        avatar: '',
        realName: '',
        mobile: '',
        email: '',
        gender: 2
      },
    }
  },
  computed: {
    displayAvatar() {
      return this.user.avatar || '/static/logo.png'
    },
    genderList() {
      void this.$i18n.locale
      return [
        {
          label: this.$t('profile.male'),
          value: 0,
          tone: 'male',
          desc: this.$t('profile.maleDesc'),
          art: '/static/profile/gender-male.jpg'
        },
        {
          label: this.$t('profile.unknown'),
          value: 2,
          tone: 'unknown',
          desc: this.$t('profile.unknownDesc'),
          art: '/static/profile/gender-unknown.jpg'
        },
        {
          label: this.$t('profile.female'),
          value: 1,
          tone: 'female',
          desc: this.$t('profile.femaleDesc'),
          art: '/static/profile/gender-female.jpg'
        }
      ]
    },
    genderLabel() {
      const current = this.genderList.find((item) => item.value === Number(this.user.gender))
      return current ? current.label : this.$t('profile.unknown')
    }
  },
  async onShow() {
    try {
      const response = await useUserInfoApi()
      const userInfo = response?.data || {}
      this.user = {
        id: userInfo.id || '',
        avatar: userInfo.avatar || '',
        realName: userInfo.realName || '',
        mobile: userInfo.mobile || '',
        email: userInfo.email || '',
        gender:
          userInfo.gender === undefined || userInfo.gender === null || userInfo.gender === ''
            ? 2
            : Number(userInfo.gender)
      }
      cache.setUserInfo(this.user)
    } catch (error) {
      uni.showToast({ title: this.$t('profile.loadFail'), icon: 'none' })
    }
  },
  methods: {
    async uploadAvatar() {
      if (this.uploadingAvatar) return
      this.uploadingAvatar = true
      let loadingShown = false
      try {
        const tempFilePath = await new Promise((resolve, reject) => {
          uni.chooseImage({
            count: 1,
            sizeType: ['compressed'],
            sourceType: ['album', 'camera'],
            success: (res) => resolve((res.tempFilePaths && res.tempFilePaths[0]) || ''),
            fail: (err) => reject(err)
          })
        })
        if (!tempFilePath) throw new Error('未获取到图片')
        uni.showLoading({ title: '上传中...' })
        loadingShown = true
        const { data } = await request.upload('/sys/file/upload', tempFilePath)
        await useUserAvatarApi({ avatar: data.url })
        this.user.avatar = data.url
        cache.setUserInfo(this.user)
        uni.showToast({ title: this.$t('profile.avatarOk'), icon: 'success' })
        const pages = getCurrentPages()
        pages.forEach((page) => {
          const vm = page.$vm
          if (vm && typeof vm.loadUser === 'function') vm.loadUser()
          if (vm && typeof vm.loadUserInfo === 'function') vm.loadUserInfo()
        })
      } catch (error) {
        if (error && error.errMsg && error.errMsg.includes('cancel')) return
        uni.showToast({ title: this.$t('profile.avatarFail'), icon: 'none' })
      } finally {
        if (loadingShown) uni.hideLoading()
        this.uploadingAvatar = false
      }
    },
    navigateToInput(key) {
      uni.navigateTo({ url: `input/input?key=${key}` })
    },
    async selectGender(item) {
      const nextGender = Number(item.value)
      if (this.savingGender || Number(this.user.gender) === nextGender) return
      this.savingGender = true
      const prevGender = this.user.gender
      this.user.gender = nextGender
      try {
        await useUserInfoSubmitApi(this.user)
        cache.setUserInfo(this.user)
        showIceToast({
          title: this.$t('profile.genderSwitched', { name: item.label }),
          sub: this.$t('profile.genderSwitchedSub'),
          art: item.art,
          tone: item.tone || 'ok'
        })
      } catch (error) {
        this.user.gender = prevGender
        showIceToast({
          title: this.$t('profile.genderFail'),
          sub: this.$t('profile.genderFailSub'),
          tone: 'fail'
        })
      } finally {
        this.savingGender = false
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

.profile-card {
  padding: 28rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  color: #0f1b2d;
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
  display: flex;
  align-items: center;
  gap: 22rpx;
}

.avatar-wrap {
  position: relative;
  width: 132rpx;
  height: 132rpx;
  flex-shrink: 0;
}

.avatar {
  width: 132rpx;
  height: 132rpx;
  border-radius: 50%;
  background: linear-gradient(160deg, #eaf7fd, #dff2fb);
  border: 3rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 12rpx 28rpx rgba(0, 140, 200, 0.14);
}

.camera {
  position: absolute;
  right: -2rpx;
  bottom: -2rpx;
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: #00a8e8;
  color: #fff;
  font-size: 22rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 18rpx rgba(0, 168, 232, 0.28);
}

.meta {
  flex: 1;
  min-width: 0;
}

.name {
  display: block;
  font-size: 34rpx;
  font-weight: 800;
  color: #0f1b2d;
}

.sub {
  display: block;
  margin-top: 8rpx;
  font-size: 24rpx;
  color: #8492a6;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10rpx;
  margin-top: 16rpx;
}

.tag {
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.1);
  color: #0284c7;
  font-size: 20rpx;
  font-weight: 600;
}

.tag.soft {
  background: #f3f6fa;
  color: #8492a6;
}

.panel {
  margin-top: 22rpx;
  padding: 28rpx 24rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.panel-head {
  margin-bottom: 8rpx;
}

.panel-title {
  display: block;
  font-size: 30rpx;
  font-weight: 700;
  color: #0f1724;
}

.panel-sub {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #7a8899;
}

.rows {
  margin-top: 12rpx;
}

.row {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 20rpx 16rpx;
  margin-top: 10rpx;
  border-radius: 20rpx;
  background: #f7fafc;
}

.row:first-child {
  margin-top: 4rpx;
}

.mark {
  width: 64rpx;
  height: 64rpx;
  border-radius: 18rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.mark-img {
  width: 34rpx;
  height: 34rpx;
}

.mark.dark {
  background: rgba(2, 132, 199, 0.12);
}

.mark.cyan {
  background: rgba(0, 168, 232, 0.12);
}

.mark.sky {
  background: rgba(14, 165, 233, 0.12);
}

.row-body {
  flex: 1;
  min-width: 0;
}

.label {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: #0f1724;
}

.tip {
  display: block;
  margin-top: 4rpx;
  font-size: 22rpx;
  color: #7a8899;
}

.value {
  max-width: 220rpx;
  font-size: 24rpx;
  color: #5b7388;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.arrow {
  color: #b0bac6;
  font-size: 36rpx;
  line-height: 1;
}

.gender-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14rpx;
  margin-top: 16rpx;
}

.gender {
  position: relative;
  padding: 22rpx 12rpx 18rpx;
  border-radius: 22rpx;
  background: linear-gradient(180deg, #fff 0%, #f5f8fb 100%);
  border: 2rpx solid rgba(12, 21, 32, 0.06);
  text-align: center;
  transition: all 0.2s ease;
}

.gender-art {
  width: 112rpx;
  height: 112rpx;
  margin: 0 auto;
  border-radius: 50%;
  overflow: hidden;
  background: #eef6fb;
  box-shadow: 0 10rpx 18rpx rgba(15, 23, 36, 0.08);
}

.gender-img {
  width: 112rpx;
  height: 112rpx;
}

.gender-name {
  display: block;
  margin-top: 12rpx;
  font-size: 26rpx;
  font-weight: 700;
  color: #0f1724;
}

.gender-desc {
  display: block;
  margin-top: 4rpx;
  font-size: 20rpx;
  color: #7a8899;
}

.gender-check {
  position: absolute;
  top: 10rpx;
  right: 10rpx;
  width: 28rpx;
  height: 28rpx;
  border-radius: 50%;
  background: rgba(15, 23, 36, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
}

.gender-check-ico {
  width: 10rpx;
  height: 6rpx;
  border-left: 3rpx solid transparent;
  border-bottom: 3rpx solid transparent;
  transform: rotate(-45deg) translateY(-1rpx);
  box-sizing: border-box;
}

.gender.active .gender-check-ico {
  border-left-color: #fff;
  border-bottom-color: #fff;
}

.gender.male.active {
  background: linear-gradient(180deg, rgba(0, 168, 232, 0.12), #fff);
  border-color: rgba(0, 168, 232, 0.45);
  box-shadow: 0 12rpx 24rpx rgba(0, 168, 232, 0.14);
}

.gender.male.active .gender-check {
  background: #00a8e8;
}

.gender.female.active {
  background: linear-gradient(180deg, rgba(226, 138, 173, 0.14), #fff);
  border-color: rgba(226, 138, 173, 0.45);
  box-shadow: 0 12rpx 24rpx rgba(226, 138, 173, 0.14);
}

.gender.female.active .gender-check {
  background: #e28aad;
}

.gender.unknown.active {
  background: linear-gradient(180deg, rgba(138, 160, 180, 0.16), #fff);
  border-color: rgba(138, 160, 180, 0.55);
  box-shadow: 0 12rpx 24rpx rgba(96, 119, 137, 0.12);
}

.gender.unknown.active .gender-check {
  background: #8aa0b4;
}
</style>
