<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('password.title')" :sub="$t('password.sub')" />

    <view class="body">
      <view class="tips">
        <text class="tip-chip">{{ $t('password.tipMix') }}</text>
        <text class="tip-chip">{{ $t('password.tipDiff') }}</text>
      </view>

      <view class="panel">
        <view class="field">
          <text class="label">{{ $t('password.old') }}</text>
          <view class="input-shell">
            <input
              v-model="passwordForm.password"
              password
              :placeholder="$t('password.oldPh')"
              class="input"
            />
          </view>
        </view>
        <view class="field">
          <text class="label">{{ $t('password.newPwd') }}</text>
          <view class="input-shell">
            <input
              v-model="passwordForm.newPassword"
              password
              :placeholder="$t('password.newPh')"
              class="input"
            />
          </view>
        </view>
        <view class="field last">
          <text class="label">{{ $t('password.confirm') }}</text>
          <view class="input-shell">
            <input
              v-model="passwordForm.confirmPassword"
              password
              :placeholder="$t('password.confirmPh')"
              class="input"
            />
          </view>
        </view>
      </view>

      <button class="save-btn" :loading="saving" @click="onPassword">{{ $t('password.save') }}</button>
    </view>
  </view>
</template>

<script>
import { validateForm } from '@/utils/validator.js'
import { updatePasswordApi } from '@/api/user.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'

export default {
  name: 'Password',
  components: { IceNavBar },
  data() {
    return {
      saving: false,
      passwordForm: {
        password: '',
        newPassword: '',
        confirmPassword: ''
      }
    }
  },
  methods: {
    async onPassword() {
      if (this.saving) return
      const dataForm = this.passwordForm
      const rules = {
        password: [{ required: true, message: this.$t('password.oldRequired') }],
        newPassword: [
          { required: true, message: this.$t('password.newRequired') },
          { pattern: /^.{4,20}$/, message: this.$t('password.newPattern') }
        ],
        confirmPassword: [{ required: true, message: this.$t('password.confirmRequired') }]
      }
      if (!validateForm(dataForm, rules)) return
      if (dataForm.newPassword != dataForm.confirmPassword) {
        uni.showToast({ title: '新密码与确认密码不一致', icon: 'none', duration: 2000 })
        return
      }
      this.saving = true
      try {
        await updatePasswordApi(dataForm)
        uni.showToast({ title: '密码修改成功', icon: 'success' })
        uni.navigateBack()
      } catch (error) {
        console.error('修改密码失败:', error)
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

.tips {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.tip-chip {
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.1);
  color: #0284c7;
  font-size: 20rpx;
  font-weight: 650;
}

.panel {
  margin-top: 18rpx;
  padding: 12rpx 24rpx 28rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.field {
  padding: 24rpx 0;
  border-bottom: 1rpx solid #eef2f6;
}

.field.last {
  border-bottom: none;
}

.label {
  display: block;
  font-size: 26rpx;
  font-weight: 600;
  color: #0f1724;
  margin-bottom: 14rpx;
}

.input-shell {
  height: 88rpx;
  padding: 0 24rpx;
  border-radius: 999rpx;
  background: #f3f6fa;
  border: 1rpx solid transparent;
  display: flex;
  align-items: center;
}

.input {
  width: 100%;
  font-size: 28rpx;
  color: #0f1b2d;
}

.save-btn {
  margin-top: 28rpx;
  width: 100%;
  height: 92rpx;
  line-height: 92rpx;
  border-radius: 999rpx;
  border: none;
  font-size: 30rpx;
  font-weight: 750;
  color: #fff;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  box-shadow: 0 14rpx 28rpx rgba(0, 168, 232, 0.26);
}

.save-btn::after {
  border: none;
}
</style>
