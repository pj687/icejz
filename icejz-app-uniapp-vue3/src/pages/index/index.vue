<template>
  <view class="home ice-page with-tab">
    <view class="ambient a1" />
    <view class="ambient a2" />

    <view class="top" :style="{ paddingTop: statusBarPx + 10 + 'px' }">
      <view class="nav">
        <view class="nav-brand">
          <view class="logo-wrap">
            <image class="logo" src="/static/logo.png" mode="aspectFit" />
          </view>
          <view>
            <text class="logo-text">ICEJZ</text>
            <text class="logo-sub">{{ $t('brand.tagline') }}</text>
          </view>
        </view>
        <view class="nav-msg" @click="go('/pages/message/inbox')">
          <image class="nav-msg-ico" src="/static/icons/msg.svg" mode="aspectFit" />
          <view v-if="unreadCount > 0" class="nav-dot">{{ unreadBadge }}</view>
        </view>
      </view>

      <view class="hero">
        <text class="hello">{{ greeting }}，{{ displayName }}</text>
        <view class="wordmark">
          <text class="ice">ICE</text><text class="jz">JZ</text>
        </view>
        <text class="lead">{{ $t('brand.homeLine') }}</text>

        <view class="actions">
          <view class="action main" @click="goTab('/pages/workbench/workbench')">
            <text class="action-t">{{ $t('home.enterWorkbench') }}</text>
            <text class="action-d">{{ $t('home.sysEntry') }}</text>
          </view>
          <view class="action" @click="go('/pages/message/inbox')">
            <text class="action-t">{{ $t('home.message') }}</text>
            <text class="action-d">
              {{ unreadCount > 0 ? $t('home.unreadN', { n: unreadCount }) : $t('home.noUnread') }}
            </text>
          </view>
        </view>
      </view>
    </view>

    <view class="body">
      <view class="kpi-row">
        <view
          v-for="item in localizedMetrics"
          :key="item.key"
          class="kpi-card"
          @click="go(item.path)"
        >
          <text class="kpi-lab">{{ item.label }}</text>
          <text class="kpi-num">{{ statsLoading ? '—' : item.value }}</text>
        </view>
      </view>

      <view class="card">
        <text class="sec-title">{{ $t('home.quickEntry') }}</text>
        <view class="entry-grid">
          <view
            v-for="item in localizedLanes"
            :key="item.key"
            class="entry"
            @click="go(item.path)"
          >
            <view class="entry-orb">
              <image class="entry-img" :src="item.icon" mode="aspectFit" />
            </view>
            <text class="entry-name">{{ item.name }}</text>
            <text class="entry-hint">{{ item.hint }}</text>
          </view>
        </view>
      </view>

      <view v-if="hasChartData" class="card">
        <view class="card-head">
          <text class="sec-title">{{ $t('home.resourceOverview') }}</text>
          <text class="sec-sub">{{ $t('home.sameAsAdmin') }}</text>
        </view>
        <bar-chart type="bar" height="280rpx" :items="localizedResourceBars" />
      </view>

      <view v-if="hasChartData" class="card">
        <view class="card-head">
          <text class="sec-title">{{ $t('home.weekMsg') }}</text>
        </view>
        <bar-chart type="line" height="260rpx" :items="localizedWeekBars" />
      </view>

      <view v-if="hasChartData" class="card">
        <view class="card-head">
          <text class="sec-title">{{ $t('home.readRate') }}</text>
        </view>
        <ring-stat
          height="240rpx"
          :percent="stats.messageRing.percent"
          :label="$t('home.read')"
          :legend="messageLegend"
        />
      </view>

      <view v-if="!hasChartData && !statsLoading" class="card empty-tip">
        <view class="empty-orb" />
        <text class="empty-title">{{ $t('home.boardPending') }}</text>
        <text class="empty-desc">{{ $t('home.boardHint') }}</text>
      </view>

      <view class="card">
        <text class="sec-title">{{ $t('home.capabilities') }}</text>
        <view class="feat-list">
          <view v-for="(item, index) in featureList" :key="item.title" class="feat">
            <view class="feat-i">{{ String(index + 1).padStart(2, '0') }}</view>
            <view class="feat-body">
              <text class="feat-t">{{ item.title }}</text>
              <text class="feat-d">{{ item.desc }}</text>
            </view>
          </view>
        </view>
      </view>

      <text class="foot">{{ $t('brand.footer') }}</text>
    </view>

    <view class="xiaobing-fab" @click="go('/pages/assistant/chat')">
      <view class="fab-stage">
        <view class="fab-halo" />
        <view class="fab-orbit o1" />
        <view class="fab-orbit o2" />
        <view class="fab-spark s1" />
        <view class="fab-spark s2" />
        <view class="fab-orb">
          <view class="fab-sheen" />
          <view class="fab-glow" />
          <image class="fab-img" src="/static/mascot/xiaobing-main.png" mode="aspectFit" />
          <view class="fab-live">
            <view class="fab-live-dot" />
          </view>
        </view>
      </view>
      <view class="fab-tag">
        <view class="fab-tag-dot" />
        <text class="fab-tag-lab">{{ $t('assistant.entry') }}</text>
      </view>
    </view>

    <custom-tab-bar ref="tabBar" />
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import { useUserInfoApi } from '@/api/user.js'
import { fetchHomeStats } from '@/api/stats.js'
import CustomTabBar from '@/custom-tab-bar/index.vue'
import BarChart from '@/components/charts/BarChart.vue'
import RingStat from '@/components/charts/RingStat.vue'

const emptyStats = () => ({
  metrics: [
    { key: 'user', label: 'user', value: 0, path: '/pages/sys/user/index' },
    { key: 'org', label: 'org', value: 0, path: '/pages/sys/org/index' },
    { key: 'role', label: 'role', value: 0, path: '/pages/sys/role/index' },
    { key: 'msg', label: 'msg', value: 0, path: '/pages/message/inbox' }
  ],
  resourceBars: [
    { key: 'user', label: 'user', value: 0, color: '#00a8e8' },
    { key: 'org', label: 'org', value: 0, color: '#38bdf8' },
    { key: 'role', label: 'role', value: 0, color: '#0ea5e9' },
    { key: 'message', label: 'message', value: 0, color: '#0284c7' }
  ],
  messageRing: { percent: 0, read: 0, unread: 0, total: 0 },
  weekBars: [0, 1, 2, 3, 4, 5, 6].map((day) => ({
    day,
    label: String(day),
    value: 0,
    color: '#00a8e8'
  }))
})

const LANE_BASE = [
  { key: 'user', icon: '/static/icons/user.svg', path: '/pages/sys/user/index' },
  { key: 'org', icon: '/static/icons/org.svg', path: '/pages/sys/org/index' },
  { key: 'role', icon: '/static/icons/role.svg', path: '/pages/sys/role/index' },
  { key: 'msg', icon: '/static/icons/msg.svg', path: '/pages/message/inbox' }
]

const DAY_KEYS = ['daySun', 'dayMon', 'dayTue', 'dayWed', 'dayThu', 'dayFri', 'daySat']

export default {
  components: { CustomTabBar, BarChart, RingStat },
  data() {
    return {
      greeting: '',
      displayName: '',
      unreadCount: 0,
      statusBarPx: 20,
      statsLoading: true,
      stats: emptyStats()
    }
  },
  computed: {
    unreadBadge() {
      return this.unreadCount > 99 ? '99+' : String(this.unreadCount)
    },
    localizedMetrics() {
      void this.$i18n.locale
      return (this.stats.metrics || []).map((item) => ({
        ...item,
        label: this.$t(`stats.${item.key === 'msg' ? 'msg' : item.key}`)
      }))
    },
    localizedResourceBars() {
      void this.$i18n.locale
      const keys = ['user', 'org', 'role', 'message']
      return (this.stats.resourceBars || []).map((item, index) => ({
        ...item,
        label: this.$t(`stats.${item.key || keys[index] || 'user'}`)
      }))
    },
    localizedWeekBars() {
      void this.$i18n.locale
      return (this.stats.weekBars || []).map((item, index) => {
        const day = typeof item.day === 'number' ? item.day : index
        return {
          ...item,
          label: this.$t(`stats.${DAY_KEYS[day] || 'daySun'}`)
        }
      })
    },
    localizedLanes() {
      void this.$i18n.locale
      const nameMap = {
        user: this.$t('stats.user'),
        org: this.$t('stats.org'),
        role: this.$t('stats.role'),
        msg: this.$t('home.message')
      }
      const hintMap = {
        user: this.$t('home.userHint'),
        org: this.$t('home.orgHint'),
        role: this.$t('home.roleHint'),
        msg:
          this.unreadCount > 0
            ? this.$t('home.unreadN', { n: this.unreadCount })
            : this.$t('home.noUnread')
      }
      return LANE_BASE.map((item) => ({
        ...item,
        name: nameMap[item.key],
        hint: hintMap[item.key]
      }))
    },
    featureList() {
      void this.$i18n.locale
      return [1, 2, 3, 4].map((n) => ({
        title: this.$t(`brand.feature${n}Title`),
        desc: this.$t(`brand.feature${n}Desc`)
      }))
    },
    messageLegend() {
      return [
        { label: this.$t('home.read'), value: this.stats.messageRing.read, color: '#00a8e8' },
        { label: this.$t('home.unread'), value: this.stats.messageRing.unread, color: '#cfeaf7' }
      ]
    },
    hasChartData() {
      const bars = this.stats.resourceBars || []
      const week = this.stats.weekBars || []
      const sumBars = bars.reduce((s, i) => s + (Number(i.value) || 0), 0)
      const sumWeek = week.reduce((s, i) => s + (Number(i.value) || 0), 0)
      return sumBars > 0 || sumWeek > 0 || (this.stats.messageRing?.total || 0) > 0
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
    this.refreshGreeting()
    this.loadUser()
    this.loadStats()
    this.$nextTick(() => this.$refs.tabBar && this.$refs.tabBar.init())
  },
  methods: {
    refreshGreeting() {
      const h = new Date().getHours()
      if (h < 6) this.greeting = this.$t('greet.late')
      else if (h < 12) this.greeting = this.$t('greet.morning')
      else if (h < 14) this.greeting = this.$t('greet.noon')
      else if (h < 18) this.greeting = this.$t('greet.afternoon')
      else this.greeting = this.$t('greet.evening')
    },
    async loadUser() {
      try {
        const { data } = await useUserInfoApi()
        this.displayName = data?.realName || data?.username || this.$t('common.user')
        if (data) cache.setUserInfo(data)
      } catch (e) {
        const cached = cache.getUserInfo()
        this.displayName = cached?.realName || cached?.username || this.$t('common.user')
      }
    },
    async loadStats() {
      this.statsLoading = true
      try {
        const data = await fetchHomeStats()
        this.stats = data
        this.unreadCount = data.metrics.find((m) => m.key === 'msg')?.value || 0
      } catch (e) {
        this.stats = emptyStats()
      } finally {
        this.statsLoading = false
      }
    },
    go(url) {
      uni.navigateTo({ url })
    },
    goTab(url) {
      uni.switchTab({ url })
    }
  }
}
</script>

<style scoped>
.home {
  position: relative;
  background: #f3f6fa;
  overflow: hidden;
}

.ambient {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

.ambient.a1 {
  width: 460rpx;
  height: 460rpx;
  top: -160rpx;
  right: -120rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.18), transparent 70%);
}

.ambient.a2 {
  width: 360rpx;
  height: 360rpx;
  top: 280rpx;
  left: -140rpx;
  background: radial-gradient(circle, rgba(56, 189, 248, 0.14), transparent 70%);
}

.top,
.body {
  position: relative;
  z-index: 1;
}

.top {
  padding: 0 28rpx 8rpx;
}

.nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-brand {
  display: flex;
  align-items: center;
  gap: 14rpx;
  min-width: 0;
}

.logo-wrap {
  width: 68rpx;
  height: 68rpx;
  border-radius: 22rpx;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 10rpx 22rpx rgba(15, 35, 55, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo {
  width: 42rpx;
  height: 42rpx;
}

.logo-text {
  display: block;
  font-size: 28rpx;
  font-weight: 800;
  letter-spacing: 0.08em;
  color: #0f1b2d;
}

.logo-sub {
  display: block;
  margin-top: 2rpx;
  font-size: 18rpx;
  color: #8492a6;
  max-width: 360rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.nav-msg {
  position: relative;
  width: 68rpx;
  height: 68rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 10rpx 22rpx rgba(15, 35, 55, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-msg-ico {
  width: 32rpx;
  height: 32rpx;
}

.nav-dot {
  position: absolute;
  top: 4rpx;
  right: 4rpx;
  min-width: 28rpx;
  height: 28rpx;
  padding: 0 6rpx;
  border-radius: 999rpx;
  background: #fb7185;
  color: #fff;
  font-size: 16rpx;
  line-height: 28rpx;
  text-align: center;
  font-weight: 700;
}

.hero {
  margin-top: 24rpx;
  padding: 28rpx 24rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.06);
}

.hello {
  display: block;
  font-size: 24rpx;
  color: #8492a6;
  font-weight: 600;
}

.wordmark {
  margin-top: 10rpx;
  line-height: 1;
}

.ice,
.jz {
  font-size: 64rpx;
  font-weight: 800;
  letter-spacing: 0.04em;
}

.ice {
  color: #0f1b2d;
}

.jz {
  color: #00a8e8;
}

.lead {
  display: block;
  margin-top: 12rpx;
  font-size: 24rpx;
  color: #8492a6;
  line-height: 1.5;
}

.actions {
  margin-top: 24rpx;
  display: flex;
  gap: 12rpx;
}

.action {
  flex: 1;
  padding: 22rpx 18rpx;
  border-radius: 22rpx;
  background: #f3f6fa;
}

.action.main {
  flex: 1.35;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  box-shadow: 0 12rpx 24rpx rgba(0, 168, 232, 0.24);
}

.action-t {
  display: block;
  font-size: 28rpx;
  font-weight: 750;
  color: #0f1b2d;
}

.action.main .action-t {
  color: #fff;
}

.action-d {
  display: block;
  margin-top: 6rpx;
  font-size: 20rpx;
  color: #8492a6;
}

.action.main .action-d {
  color: rgba(255, 255, 255, 0.82);
}

.body {
  padding: 12rpx 24rpx 28rpx;
}

.kpi-row {
  display: flex;
  gap: 12rpx;
}

.kpi-card {
  flex: 1;
  padding: 22rpx 10rpx;
  border-radius: 24rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 12rpx 28rpx rgba(15, 35, 55, 0.05);
  text-align: center;
}

.kpi-lab {
  display: block;
  font-size: 20rpx;
  color: #8492a6;
  font-weight: 600;
}

.kpi-num {
  display: block;
  margin-top: 10rpx;
  font-size: 36rpx;
  font-weight: 800;
  color: #0f1b2d;
  line-height: 1;
}

.card {
  margin-top: 16rpx;
  padding: 26rpx 22rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.card-head {
  margin-bottom: 16rpx;
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12rpx;
}

.sec-title {
  display: block;
  font-size: 30rpx;
  font-weight: 800;
  color: #0f1b2d;
}

.sec-sub {
  font-size: 22rpx;
  color: #8492a6;
}

.entry-grid {
  margin-top: 18rpx;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8rpx;
}

.entry {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.entry-orb {
  width: 92rpx;
  height: 92rpx;
  border-radius: 50%;
  background: linear-gradient(160deg, #eaf7fd, #dff2fb);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow:
    0 10rpx 22rpx rgba(0, 140, 200, 0.1),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.85);
}

.entry-img {
  width: 40rpx;
  height: 40rpx;
}

.entry-name {
  margin-top: 12rpx;
  font-size: 24rpx;
  font-weight: 650;
  color: #0f1b2d;
}

.entry-hint {
  margin-top: 4rpx;
  font-size: 18rpx;
  color: #8492a6;
}

.empty-tip {
  text-align: center;
  padding: 48rpx 28rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.empty-orb {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  margin-bottom: 16rpx;
  background: radial-gradient(circle at 35% 30%, #e8f7fd, #bae6fd 60%, #7dd3fc);
  box-shadow: 0 12rpx 24rpx rgba(0, 168, 232, 0.16);
}

.empty-title {
  display: block;
  font-size: 28rpx;
  font-weight: 750;
  color: #0f1b2d;
}

.empty-desc {
  display: block;
  margin-top: 10rpx;
  font-size: 22rpx;
  color: #8492a6;
  line-height: 1.5;
}

.feat-list {
  margin-top: 12rpx;
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.feat {
  display: flex;
  gap: 16rpx;
  padding: 18rpx 16rpx;
  border-radius: 20rpx;
  background: #f7fafc;
}

.feat-i {
  width: 52rpx;
  height: 52rpx;
  border-radius: 16rpx;
  background: rgba(0, 168, 232, 0.12);
  color: #00a8e8;
  font-size: 22rpx;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.feat-body {
  min-width: 0;
}

.feat-t {
  display: block;
  font-size: 28rpx;
  font-weight: 700;
  color: #0f1b2d;
}

.feat-d {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #8492a6;
  line-height: 1.5;
}

.foot {
  display: block;
  margin: 32rpx 0 8rpx;
  text-align: center;
  font-size: 20rpx;
  color: #9aa8b6;
  letter-spacing: 0.06em;
}

.xiaobing-fab {
  position: fixed;
  right: 20rpx;
  bottom: calc(150rpx + env(safe-area-inset-bottom));
  z-index: 900;
  width: 128rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  animation: fab-float 3.4s ease-in-out infinite;
}

.fab-stage {
  position: relative;
  width: 116rpx;
  height: 116rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.fab-halo {
  position: absolute;
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.22), transparent 68%);
  animation: fab-halo 2.6s ease-in-out infinite;
}

.fab-orbit {
  position: absolute;
  border-radius: 50%;
  box-sizing: border-box;
  pointer-events: none;
}

.fab-orbit.o1 {
  width: 112rpx;
  height: 112rpx;
  border: 2rpx solid rgba(0, 168, 232, 0.12);
  border-top-color: rgba(0, 168, 232, 0.55);
  border-right-color: rgba(43, 184, 239, 0.2);
  animation: fab-spin 8s linear infinite;
}

.fab-orbit.o2 {
  width: 98rpx;
  height: 98rpx;
  border: 1rpx dashed rgba(0, 168, 232, 0.22);
  animation: fab-spin-rev 14s linear infinite;
}

.fab-spark {
  position: absolute;
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  background: #2bb8ef;
  box-shadow: 0 0 10rpx rgba(0, 168, 232, 0.45);
  animation: fab-pulse 1.8s ease-in-out infinite;
}

.fab-spark.s1 {
  top: 8rpx;
  right: 18rpx;
}

.fab-spark.s2 {
  bottom: 14rpx;
  left: 14rpx;
  width: 6rpx;
  height: 6rpx;
  background: #7dd3fc;
  animation-delay: 0.45s;
}

.fab-orb {
  position: relative;
  z-index: 1;
  width: 86rpx;
  height: 86rpx;
  border-radius: 50%;
  background: linear-gradient(155deg, rgba(255, 255, 255, 0.98), rgba(232, 247, 253, 0.94) 48%, rgba(214, 240, 251, 0.92));
  border: 2rpx solid rgba(255, 255, 255, 0.98);
  box-shadow:
    0 16rpx 32rpx rgba(0, 168, 232, 0.22),
    0 6rpx 14rpx rgba(15, 35, 55, 0.08),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  backdrop-filter: blur(10px);
}

.fab-sheen {
  position: absolute;
  inset: 0;
  background: linear-gradient(125deg, rgba(255, 255, 255, 0.75), transparent 42%);
  pointer-events: none;
}

.fab-glow {
  position: absolute;
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  top: -10rpx;
  left: 12rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.16), transparent 70%);
  pointer-events: none;
}

.fab-img {
  position: relative;
  z-index: 1;
  width: 78rpx;
  height: 78rpx;
  animation: fab-bob 2.8s ease-in-out infinite;
}

.fab-live {
  position: absolute;
  right: 4rpx;
  bottom: 6rpx;
  z-index: 2;
  width: 18rpx;
  height: 18rpx;
  border-radius: 50%;
  background: #fff;
  border: 2rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 3rpx 8rpx rgba(15, 35, 55, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.fab-live-dot {
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 0 3rpx rgba(34, 197, 94, 0.18);
  animation: fab-live 1.6s ease-in-out infinite;
}

.fab-tag {
  margin-top: -2rpx;
  z-index: 2;
  min-height: 30rpx;
  padding: 0 12rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow:
    0 8rpx 16rpx rgba(15, 35, 55, 0.08),
    0 0 0 1rpx rgba(0, 168, 232, 0.08);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  backdrop-filter: blur(8px);
}

.fab-tag-dot {
  width: 6rpx;
  height: 6rpx;
  border-radius: 50%;
  background: #00a8e8;
  box-shadow: 0 0 0 3rpx rgba(0, 168, 232, 0.14);
}

.fab-tag-lab {
  font-size: 16rpx;
  font-weight: 750;
  color: #0284c7;
  line-height: 1;
  letter-spacing: 0.04em;
}

@keyframes fab-float {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-12rpx);
  }
}

@keyframes fab-halo {
  0%,
  100% {
    transform: scale(0.92);
    opacity: 0.55;
  }
  50% {
    transform: scale(1.08);
    opacity: 1;
  }
}

@keyframes fab-spin {
  to {
    transform: rotate(360deg);
  }
}

@keyframes fab-spin-rev {
  to {
    transform: rotate(-360deg);
  }
}

@keyframes fab-pulse {
  0%,
  100% {
    opacity: 0.35;
    transform: scale(0.85);
  }
  50% {
    opacity: 1;
    transform: scale(1.15);
  }
}

@keyframes fab-bob {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-4rpx);
  }
}

@keyframes fab-live {
  0%,
  100% {
    transform: scale(0.92);
    opacity: 0.75;
  }
  50% {
    transform: scale(1.08);
    opacity: 1;
  }
}
</style>
