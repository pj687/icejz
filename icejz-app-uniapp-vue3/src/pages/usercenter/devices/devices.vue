<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('devices.title')" :sub="$t('devices.sub')" />

    <view class="body">
      <view class="panel pref">
        <view class="panel-head">
          <view>
            <text class="kicker">{{ $t('devices.prefKicker') }}</text>
            <text class="panel-title">{{ $t('devices.prefTitle') }}</text>
            <text class="panel-desc">{{ prefDescText }}</text>
          </view>
          <view class="eff-chip" :class="{ on: effectiveOn }">
            {{ effectiveLabel }}
          </view>
        </view>

        <view v-if="!systemOn" class="lock-tip">{{ $t('devices.systemLockedTip') }}</view>

        <view class="mode-list">
          <view
            v-for="opt in modeOptions"
            :key="opt.value"
            class="mode-card"
            :class="[opt.value, { active: prefMode === opt.value, locked: opt.value === 'on' && !systemOn }]"
            @click="selectMode(opt.value)"
          >
            <view class="mode-top">
              <text class="mode-badge">{{ opt.badge }}</text>
              <view v-if="prefMode === opt.value" class="mode-check" />
            </view>
            <text class="mode-title">{{ opt.title }}</text>
            <text class="mode-desc">{{ opt.desc }}</text>
            <text class="mode-note">{{ opt.note }}</text>
          </view>
        </view>

        <view class="limit-panel" :class="{ dimmed: prefMode !== 'on' }">
          <view class="limit-copy">
            <text class="limit-title">{{ $t('devices.limitTitle') }}</text>
            <text class="limit-desc">{{ $t('devices.limitDesc', { n: systemMax }) }}</text>
          </view>
          <view class="stepper">
            <view class="step-btn" :class="{ disabled: prefMode !== 'on' || prefMax <= 1 }" @click="decMax">−</view>
            <text class="step-val">{{ prefMax }}</text>
            <view
              class="step-btn"
              :class="{ disabled: prefMode !== 'on' || prefMax >= systemMax }"
              @click="incMax"
            >+</view>
          </view>
        </view>

        <view class="pref-actions">
          <button class="save-btn" :loading="prefSaving" @click="savePref">{{ $t('devices.save') }}</button>
          <view class="reload-btn" @click="loadAll">{{ $t('devices.reload') }}</view>
        </view>
      </view>

      <view class="panel session">
        <view class="panel-head row">
          <view>
            <text class="panel-title">{{ $t('devices.sessionTitle') }}</text>
            <text class="panel-desc">{{ $t('devices.sessionDesc') }}</text>
          </view>
          <view class="refresh" @click="loadList">{{ $t('devices.refresh') }}</view>
        </view>

        <view v-if="loading" class="empty soft">{{ $t('common.loading') }}…</view>
        <view v-else-if="!list.length" class="empty">{{ $t('devices.empty') }}</view>

        <view v-else class="device-list">
          <view
            v-for="item in list"
            :key="item.accessToken"
            class="device-item"
            :class="{ current: item.current }"
          >
            <view class="device-icon">{{ clientShort(item.clientType) }}</view>
            <view class="device-main">
              <view class="device-title">
                <text class="device-name">{{ clientLabel(item.clientType) }}</text>
                <text v-if="item.current" class="badge">{{ $t('devices.current') }}</text>
              </view>
              <view class="device-meta">
                <text>IP {{ item.loginIp || '—' }}</text>
                <text>{{ formatTime(item.loginTime) }}</text>
              </view>
              <text class="device-ua">{{ shortUa(item.userAgent) }}</text>
            </view>
            <view class="device-actions">
              <view
                v-if="!item.current"
                class="kick-btn"
                :class="{ busy: kicking === item.accessToken }"
                @click="kick(item)"
              >
                {{ kicking === item.accessToken ? $t('devices.kicking') : $t('devices.kick') }}
              </view>
              <text v-else class="current-tip">{{ $t('devices.thisDevice') }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import IceNavBar from '@/components/layout/IceNavBar.vue'
import { showIceToast } from '@/utils/iceToast.js'
import { showIceConfirm } from '@/utils/iceConfirm.js'
import {
  useMyLoginSecurityApi,
  useMyLoginSecuritySaveApi,
  useUserDeviceKickApi,
  useUserDeviceListApi
} from '@/api/user.js'

export default {
  name: 'Devices',
  components: { IceNavBar },
  data() {
    return {
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
      effectiveMax: 5
    }
  },
  computed: {
    effectiveLabel() {
      void this.$i18n.locale
      if (this.effectiveOn) {
        return this.$t('devices.effectiveMulti', { n: this.effectiveMax })
      }
      return this.$t('devices.effectiveSingle')
    },
    prefDescText() {
      void this.$i18n.locale
      return this.systemOn ? this.$t('devices.prefDescOn') : this.$t('devices.prefDescOff')
    },
    modeOptions() {
      void this.$i18n.locale
      return [
        {
          value: 'sys',
          badge: this.$t('devices.modeSysBadge'),
          title: this.$t('devices.modeSysTitle'),
          desc: this.$t('devices.modeSysDesc'),
          note: this.systemOn
            ? this.$t('devices.modeSysNoteOn', { n: this.systemMax })
            : this.$t('devices.modeSysNoteOff')
        },
        {
          value: 'on',
          badge: this.$t('devices.modeOnBadge'),
          title: this.$t('devices.modeOnTitle'),
          desc: this.$t('devices.modeOnDesc'),
          note: this.systemOn
            ? this.$t('devices.modeOnNote', { n: this.systemMax })
            : this.$t('devices.modeOnLocked')
        },
        {
          value: 'off',
          badge: this.$t('devices.modeOffBadge'),
          title: this.$t('devices.modeOffTitle'),
          desc: this.$t('devices.modeOffDesc'),
          note: this.systemOn ? this.$t('devices.modeOffNote') : this.$t('devices.modeOffNoteLocked')
        }
      ]
    }
  },
  onShow() {
    this.loadAll()
  },
  methods: {
    selectMode(value) {
      if (value === 'on' && !this.systemOn) {
        showIceToast({ title: this.$t('devices.systemLockedToast'), icon: 'none' })
        return
      }
      this.prefMode = value
    },
    clientLabel(type) {
      const map = {
        pc: this.$t('devices.clientPc'),
        app: this.$t('devices.clientApp'),
        mp: this.$t('devices.clientMp')
      }
      return map[type || ''] || type || this.$t('devices.clientUnknown')
    },
    clientShort(type) {
      const map = { pc: 'PC', app: 'App', mp: 'MP' }
      return map[type || ''] || '?'
    },
    shortUa(ua) {
      if (!ua) return '—'
      return ua.length <= 72 ? ua : ua.slice(0, 72) + '…'
    },
    formatTime(t) {
      if (!t) return '—'
      return String(t).replace('T', ' ').replace(/\.\d+$/, '').slice(0, 19)
    },
    clampMax(n) {
      return Math.max(1, Math.min(n ?? this.systemMax, this.systemMax))
    },
    decMax() {
      if (this.prefMode !== 'on' || this.prefMax <= 1) return
      this.prefMax -= 1
    },
    incMax() {
      if (this.prefMode !== 'on' || this.prefMax >= this.systemMax) return
      this.prefMax += 1
    },
    async loadAll() {
      await Promise.all([this.loadPref(), this.loadList()])
    },
    async loadList() {
      this.loading = true
      try {
        const res = await useUserDeviceListApi()
        this.list = Array.isArray(res.data) ? res.data : []
      } catch (e) {
        showIceToast({ title: this.$t('devices.loadFail'), icon: 'error' })
      } finally {
        this.loading = false
      }
    },
    async loadPref() {
      this.prefLoading = true
      try {
        const { data } = await useMyLoginSecurityApi()
        this.systemOn = !!data?.systemMultiDeviceLogin
        this.systemMax = Math.max(1, data?.systemMultiDeviceMax ?? 5)
        this.effectiveOn = !!data?.effectiveMultiDeviceLogin
        this.effectiveMax = Math.min(data?.effectiveMultiDeviceMax ?? this.systemMax, this.systemMax)
        if (data?.multiDeviceLogin === 1) {
          this.prefMode = this.systemOn ? 'on' : 'sys'
          this.prefMax = this.clampMax(data?.multiDeviceMax)
        } else if (data?.multiDeviceLogin === 0) {
          this.prefMode = 'off'
          this.prefMax = this.systemMax
        } else {
          this.prefMode = 'sys'
          this.prefMax = this.systemMax
        }
      } catch (e) {
        showIceToast({ title: this.$t('devices.prefLoadFail'), icon: 'error' })
      } finally {
        this.prefLoading = false
      }
    },
    async savePref() {
      if (this.prefSaving) return
      if (this.prefMode === 'on' && !this.systemOn) {
        showIceToast({ title: this.$t('devices.systemLockedToast'), icon: 'none' })
        return
      }
      this.prefSaving = true
      try {
        const multiDeviceLogin = this.prefMode === 'sys' ? null : this.prefMode === 'on' ? 1 : 0
        const multiDeviceMax =
          this.prefMode === 'on' ? this.clampMax(this.prefMax) : null
        await useMyLoginSecuritySaveApi({ multiDeviceLogin, multiDeviceMax })
        showIceToast({ title: this.$t('devices.saveOk'), icon: 'success' })
        await this.loadPref()
      } catch (e) {
        showIceToast({ title: this.$t('devices.saveFail'), icon: 'error' })
      } finally {
        this.prefSaving = false
      }
    },
    async kick(item) {
      if (!item?.accessToken || item.current || this.kicking) return
      const ok = await showIceConfirm({
        title: this.$t('devices.kickTitle'),
        content: this.$t('devices.kickConfirm'),
        confirmText: this.$t('devices.kick'),
        cancelText: this.$t('common.cancel'),
        tone: 'danger'
      })
      if (!ok) return
      this.kicking = item.accessToken
      try {
        await useUserDeviceKickApi(item.accessToken)
        showIceToast({ title: this.$t('devices.kickOk'), icon: 'success' })
        await this.loadList()
      } catch (e) {
        showIceToast({ title: this.$t('devices.kickFail'), icon: 'error' })
      } finally {
        this.kicking = ''
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
  padding: 26rpx 24rpx 28rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.panel.pref {
  background:
    radial-gradient(120% 140% at 0% 0%, rgba(0, 168, 232, 0.08), transparent 55%),
    rgba(255, 255, 255, 0.96);
}

.panel-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16rpx;
  margin-bottom: 22rpx;
}

.panel-head.row {
  padding-bottom: 18rpx;
  border-bottom: 1rpx dashed #e8eef5;
}

.kicker {
  display: inline-flex;
  margin-bottom: 8rpx;
  padding: 4rpx 14rpx;
  border-radius: 999rpx;
  font-size: 18rpx;
  font-weight: 700;
  color: #0284c7;
  background: rgba(0, 168, 232, 0.1);
}

.panel-title {
  display: block;
  font-size: 30rpx;
  font-weight: 780;
  color: #0f1b2d;
}

.panel-desc {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  line-height: 1.5;
  color: #8492a6;
}

.eff-chip {
  flex-shrink: 0;
  max-width: 240rpx;
  padding: 10rpx 16rpx;
  border-radius: 999rpx;
  font-size: 20rpx;
  font-weight: 700;
  color: #64748b;
  background: #f1f5f9;
  border: 1rpx solid #e2e8f0;
  text-align: center;
  line-height: 1.35;
}

.eff-chip.on {
  color: #0f766e;
  background: rgba(47, 191, 164, 0.12);
  border-color: rgba(47, 191, 164, 0.22);
}

.mode-list {
  display: flex;
  flex-direction: column;
  gap: 14rpx;
}

.lock-tip {
  margin-bottom: 16rpx;
  padding: 16rpx 18rpx;
  border-radius: 18rpx;
  font-size: 22rpx;
  line-height: 1.5;
  color: #9a3412;
  background: rgba(251, 146, 60, 0.12);
  border: 1rpx solid rgba(251, 146, 60, 0.28);
}

.mode-card {
  position: relative;
  padding: 22rpx 22rpx 18rpx;
  border-radius: 22rpx;
  border: 1rpx solid #e8eef5;
  background: #fff;
  transition: border-color 0.18s ease, background 0.18s ease, box-shadow 0.18s ease;
}

.mode-card.locked {
  opacity: 0.45;
}

.mode-card.sys.active {
  border-color: rgba(0, 126, 184, 0.35);
  background: linear-gradient(160deg, rgba(0, 168, 232, 0.08), #fff);
  box-shadow: 0 10rpx 22rpx rgba(0, 168, 232, 0.08);
}

.mode-card.on.active {
  border-color: rgba(15, 118, 110, 0.35);
  background: linear-gradient(160deg, rgba(47, 191, 164, 0.1), #fff);
  box-shadow: 0 10rpx 22rpx rgba(15, 118, 110, 0.08);
}

.mode-card.off.active {
  border-color: rgba(180, 83, 9, 0.3);
  background: linear-gradient(160deg, rgba(251, 191, 36, 0.12), #fff);
  box-shadow: 0 10rpx 22rpx rgba(180, 83, 9, 0.06);
}

.mode-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10rpx;
}

.mode-badge {
  display: inline-flex;
  align-items: center;
  height: 36rpx;
  padding: 0 14rpx;
  border-radius: 999rpx;
  font-size: 18rpx;
  font-weight: 700;
  color: #0284c7;
  background: rgba(0, 168, 232, 0.1);
}

.mode-card.on .mode-badge {
  color: #0f766e;
  background: rgba(47, 191, 164, 0.12);
}

.mode-card.off .mode-badge {
  color: #b45309;
  background: rgba(251, 191, 36, 0.16);
}

.mode-card.active .mode-badge {
  color: #fff;
  background: #00a8e8;
}

.mode-card.on.active .mode-badge {
  background: #0f766e;
}

.mode-card.off.active .mode-badge {
  background: #b45309;
}

.mode-check {
  width: 28rpx;
  height: 28rpx;
  border-radius: 50%;
  background: radial-gradient(circle at center, #fff 0 35%, transparent 36%), #00a8e8;
}

.mode-card.on .mode-check {
  background: radial-gradient(circle at center, #fff 0 35%, transparent 36%), #0f766e;
}

.mode-card.off .mode-check {
  background: radial-gradient(circle at center, #fff 0 35%, transparent 36%), #b45309;
}

.mode-title {
  display: block;
  font-size: 28rpx;
  font-weight: 740;
  color: #122033;
}

.mode-desc {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  line-height: 1.45;
  color: #64748b;
}

.mode-note {
  display: block;
  margin-top: 10rpx;
  font-size: 20rpx;
  font-weight: 650;
  color: #7aa8c4;
}

.limit-panel {
  margin-top: 18rpx;
  padding: 20rpx 22rpx;
  border-radius: 22rpx;
  border: 1rpx solid #e8eef5;
  background: #f7fbfe;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
  transition: opacity 0.18s ease;
}

.limit-panel.dimmed {
  opacity: 0.55;
}

.limit-copy {
  min-width: 0;
  flex: 1;
}

.limit-title {
  display: block;
  font-size: 26rpx;
  font-weight: 700;
  color: #122033;
}

.limit-desc {
  display: block;
  margin-top: 4rpx;
  font-size: 20rpx;
  line-height: 1.4;
  color: #8492a6;
}

.stepper {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}

.step-btn {
  width: 56rpx;
  height: 56rpx;
  border-radius: 16rpx;
  background: #fff;
  border: 1rpx solid #e2e8f0;
  color: #0f1b2d;
  font-size: 32rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.step-btn.disabled {
  opacity: 0.4;
}

.step-val {
  min-width: 40rpx;
  text-align: center;
  font-size: 30rpx;
  font-weight: 780;
  color: #0f1b2d;
}

.pref-actions {
  margin-top: 22rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.save-btn {
  flex: 1;
  height: 88rpx;
  line-height: 88rpx;
  border-radius: 999rpx;
  border: none;
  font-size: 28rpx;
  font-weight: 750;
  color: #fff;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  box-shadow: 0 14rpx 28rpx rgba(0, 168, 232, 0.22);
}

.save-btn::after {
  border: none;
}

.reload-btn {
  padding: 0 28rpx;
  height: 88rpx;
  line-height: 88rpx;
  border-radius: 999rpx;
  background: #f3f6fa;
  color: #3d4b5c;
  font-size: 26rpx;
  font-weight: 650;
}

.refresh {
  flex-shrink: 0;
  padding: 10rpx 20rpx;
  border-radius: 999rpx;
  background: #f3f6fa;
  color: #0284c7;
  font-size: 22rpx;
  font-weight: 700;
}

.empty {
  padding: 48rpx 20rpx;
  text-align: center;
  color: #94a3b8;
  font-size: 24rpx;
  border-radius: 20rpx;
  background: #f7fbfe;
  border: 1rpx dashed #e8eef5;
}

.empty.soft {
  border-style: solid;
}

.device-list {
  display: flex;
  flex-direction: column;
  gap: 14rpx;
}

.device-item {
  display: flex;
  align-items: flex-start;
  gap: 16rpx;
  padding: 22rpx 20rpx;
  border-radius: 22rpx;
  border: 1rpx solid #e8eef5;
  background: #fff;
}

.device-item.current {
  border-color: rgba(0, 168, 232, 0.28);
  background: linear-gradient(135deg, rgba(0, 168, 232, 0.06), #fff);
}

.device-icon {
  width: 72rpx;
  height: 72rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22rpx;
  font-weight: 780;
  color: #0284c7;
  background: rgba(0, 168, 232, 0.1);
  flex-shrink: 0;
}

.device-main {
  min-width: 0;
  flex: 1;
}

.device-title {
  display: flex;
  align-items: center;
  gap: 10rpx;
  flex-wrap: wrap;
}

.device-name {
  font-size: 28rpx;
  font-weight: 740;
  color: #122033;
}

.badge {
  padding: 2rpx 12rpx;
  border-radius: 999rpx;
  font-size: 18rpx;
  font-weight: 700;
  color: #0284c7;
  background: rgba(0, 168, 232, 0.12);
}

.device-meta {
  margin-top: 8rpx;
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  font-size: 22rpx;
  color: #64748b;
}

.device-ua {
  display: block;
  margin-top: 6rpx;
  font-size: 20rpx;
  color: #94a3b8;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.device-actions {
  flex-shrink: 0;
  padding-top: 8rpx;
}

.kick-btn {
  padding: 10rpx 20rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
  font-weight: 700;
  color: #c45b6a;
  background: rgba(196, 91, 106, 0.08);
  border: 1rpx solid rgba(196, 91, 106, 0.16);
}

.kick-btn.busy {
  opacity: 0.55;
}

.current-tip {
  font-size: 22rpx;
  font-weight: 650;
  color: #0284c7;
}
</style>
