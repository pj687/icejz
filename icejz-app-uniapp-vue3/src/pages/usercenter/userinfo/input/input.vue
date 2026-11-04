<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="activeField.title" :sub="activeField.desc" />

    <view class="body">
      <view class="panel">
        <view class="field-head">
          <view class="mark" :class="activeField.theme">
            <image class="mark-img" :src="activeField.icon" mode="aspectFit" />
          </view>
          <view class="field-meta">
            <text class="label">{{ activeField.label }}</text>
            <text class="tip">{{ activeField.tip }}</text>
          </view>
        </view>

        <view class="input-shell">
          <input
            v-model.trim="formValue"
            :type="activeField.inputType"
            :maxlength="activeField.maxlength"
            :placeholder="activeField.placeholder"
            :cursor-spacing="20"
            class="field-input"
            :focus="true"
            confirm-type="done"
            @confirm="onSubmit"
          />
        </view>

        <view class="compare">
          <view class="compare-item">
            <text class="compare-label">{{ $t('profile.original') }}</text>
            <text class="compare-value">{{ originalValue || activeField.emptyText }}</text>
          </view>
          <text class="compare-arrow">→</text>
          <view class="compare-item">
            <text class="compare-label">{{ $t('profile.next') }}</text>
            <text class="compare-value accent">{{ formValue || activeField.emptyText }}</text>
          </view>
        </view>
      </view>

      <button class="save-btn" :loading="saving" @click="onSubmit">{{ $t('profile.saveEdit') }}</button>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import { useUserInfoApi, useUserInfoSubmitApi } from '@/api/user.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'

const FIELD_META = {
  realName: {
    key: 'realName',
    inputType: 'text',
    maxlength: 20,
    icon: '/static/icons/name.svg',
    theme: 'dark',
    titleKey: 'profile.editName',
    labelKey: 'profile.name',
    descKey: 'profile.nameDesc',
    tipKey: 'profile.nameLabelTip',
    phKey: 'profile.namePh',
    emptyKey: 'profile.emptyName'
  },
  mobile: {
    key: 'mobile',
    inputType: 'number',
    maxlength: 11,
    icon: '/static/icons/phone.svg',
    theme: 'cyan',
    titleKey: 'profile.editMobile',
    labelKey: 'profile.mobile',
    descKey: 'profile.mobileDesc',
    tipKey: 'profile.mobileLabelTip',
    phKey: 'profile.mobilePh',
    emptyKey: 'profile.emptyMobile'
  },
  email: {
    key: 'email',
    inputType: 'text',
    maxlength: 50,
    icon: '/static/icons/email.svg',
    theme: 'sky',
    titleKey: 'profile.editEmail',
    labelKey: 'profile.email',
    descKey: 'profile.emailDesc',
    tipKey: 'profile.emailLabelTip',
    phKey: 'profile.emailPh',
    emptyKey: 'profile.emptyEmail'
  }
}

export default {
  name: 'UserInfoInput',
  components: { IceNavBar },
  data() {
    return {
      fieldKey: 'realName',
      formValue: '',
      originalValue: '',
      saving: false,
      user: {
        realName: '',
        mobile: '',
        email: '',
        gender: 2
      }
    }
  },
  computed: {
    activeField() {
      void this.$i18n.locale
      const meta = FIELD_META[this.fieldKey] || FIELD_META.realName
      return {
        ...meta,
        title: this.$t(meta.titleKey),
        label: this.$t(meta.labelKey),
        desc: this.$t(meta.descKey),
        tip: this.$t(meta.tipKey),
        placeholder: this.$t(meta.phKey),
        emptyText: this.$t(meta.emptyKey)
      }
    }
  },
  onLoad(options) {
    const nextKey = options?.key
    this.fieldKey = FIELD_META[nextKey] ? nextKey : 'realName'
    const userInfo = cache.getUserInfo() || {}
    this.user = {
      realName: userInfo.realName || '',
      mobile: userInfo.mobile || '',
      email: userInfo.email || '',
      gender: userInfo.gender ?? 2
    }
    this.formValue = this.user[this.fieldKey] || ''
    this.originalValue = this.formValue
  },
  methods: {
    validateValue() {
      const value = (this.formValue || '').trim()
      if (this.fieldKey === 'realName' && !value) {
        uni.showToast({ title: this.$t('profile.nameRequired'), icon: 'none' })
        return false
      }
      if (this.fieldKey === 'mobile') {
        if (!value) {
          uni.showToast({ title: this.$t('profile.mobileRequired'), icon: 'none' })
          return false
        }
        if (!/^1[3-9]\d{9}$/.test(value)) {
          uni.showToast({ title: this.$t('profile.mobileInvalid'), icon: 'none' })
          return false
        }
      }
      if (this.fieldKey === 'email') {
        if (!value) {
          uni.showToast({ title: this.$t('profile.emailRequired'), icon: 'none' })
          return false
        }
        if (!/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/.test(value)) {
          uni.showToast({ title: this.$t('profile.emailInvalid'), icon: 'none' })
          return false
        }
      }
      return true
    },
    async onSubmit() {
      if (this.saving) return
      if (!this.validateValue()) return
      const value = (this.formValue || '').trim()
      if (value === (this.originalValue || '').trim()) {
        uni.showToast({ title: this.$t('profile.noChange'), icon: 'none' })
        return
      }
      this.saving = true
      try {
        const payload = { ...this.user, [this.fieldKey]: value }
        await useUserInfoSubmitApi(payload)
        const userResponse = await useUserInfoApi()
        const latestUser = userResponse?.data || payload
        this.user = { ...this.user, ...latestUser }
        this.formValue = latestUser[this.fieldKey] || value
        this.originalValue = latestUser[this.fieldKey] || value
        cache.setUserInfo({ ...cache.getUserInfo(), ...latestUser })
        uni.showToast({ title: this.$t('profile.saveOk'), icon: 'success' })
        const pages = getCurrentPages()
        pages.forEach((page) => {
          const vm = page.$vm
          if (!vm) return
          if (typeof vm.loadUser === 'function') vm.loadUser()
          if (typeof vm.loadUserInfo === 'function') vm.loadUserInfo()
        })
        setTimeout(() => uni.navigateBack(), 600)
      } catch (error) {
        uni.showToast({ title: error?.msg || this.$t('common.fail'), icon: 'none' })
      } finally {
        this.saving = false
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
  margin-top: 0;
  padding: 28rpx 24rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.field-head {
  display: flex;
  align-items: center;
  gap: 18rpx;
}

.mark {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.mark-img {
  width: 36rpx;
  height: 36rpx;
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

.field-meta {
  flex: 1;
  min-width: 0;
}

.label {
  display: block;
  font-size: 30rpx;
  font-weight: 700;
  color: #0f1724;
}

.tip {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #7a8899;
}

.input-shell {
  margin-top: 28rpx;
  height: 96rpx;
  padding: 0 28rpx;
  border-radius: 24rpx;
  background: #f7fafc;
  border: 1rpx solid rgba(232, 238, 245, 0.9);
  display: flex;
  align-items: center;
}

.field-input {
  width: 100%;
  font-size: 30rpx;
  color: #0f1724;
}

.compare {
  margin-top: 22rpx;
  padding: 22rpx;
  border-radius: 20rpx;
  background: rgba(0, 168, 232, 0.06);
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.compare-item {
  flex: 1;
  min-width: 0;
}

.compare-label {
  display: block;
  font-size: 20rpx;
  color: #7a8899;
}

.compare-value {
  display: block;
  margin-top: 8rpx;
  font-size: 26rpx;
  font-weight: 600;
  color: #0f1724;
  word-break: break-all;
  line-height: 1.5;
}

.compare-value.accent {
  color: #00a8e8;
}

.compare-arrow {
  color: #94a3b8;
  font-size: 28rpx;
  flex-shrink: 0;
}

.save-btn {
  margin-top: 28rpx;
  width: 100%;
  height: 92rpx;
  line-height: 92rpx;
  border-radius: 999rpx;
  border: none;
  font-size: 30rpx;
  font-weight: 700;
  color: #fff;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  box-shadow: 0 14rpx 28rpx rgba(0, 168, 232, 0.26);
}

.save-btn::after {
  border: none;
}
</style>
