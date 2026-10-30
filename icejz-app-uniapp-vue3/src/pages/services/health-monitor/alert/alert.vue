<template>
  <view class="page">
    <view class="hero-card">
      <text class="hero-title">健康预警</text>
      <text class="hero-sub">{{ unhandledCount }} 条待处理预警</text>
    </view>

    <view class="filter-row">
      <view v-for="f in filters" :key="f.value"
        class="filter-btn" :class="{ active: activeFilter === f.value }"
        @tap="activeFilter = f.value; loadAlerts()">
        {{ f.label }}
      </view>
    </view>

    <view v-if="alerts.length === 0" class="empty-card">
      <text class="empty-text">{{ activeFilter === 0 ? '暂无待处理预警 🎉' : '暂无记录' }}</text>
    </view>

    <view v-for="item in alerts" :key="item.id" class="alert-card" :class="'level-' + item.level">
      <view class="alert-top">
        <view class="alert-badge" :class="'badge-' + item.level">
          {{ levelLabel(item.level) }}
        </view>
        <text class="alert-type">{{ typeLabel(item.recordType) }}</text>
        <text class="alert-time">{{ formatTime(item.createTime) }}</text>
      </view>
      <text class="alert-msg">{{ item.alertMessage }}</text>
      <text class="alert-val">检测值：{{ item.alertValue }}</text>
      <view class="alert-actions" v-if="item.status === 0">
        <button class="action-btn ignore" @tap="handleAlert(item, 2)">忽略</button>
        <button class="action-btn handle" @tap="handleAlert(item, 1)">已处理</button>
      </view>
      <text v-else class="handled-tag">{{ item.status === 1 ? '✓ 已处理' : '已忽略' }}</text>
    </view>
  </view>
</template>

<script>
import { useHealthAlertListApi } from '../../../../api/user.js';
import * as request from '../../../../utils/request.js';

const TYPE_MAP = { blood_pressure:'血压', blood_sugar:'血糖', heart_rate:'心率', weight:'体重', temperature:'体温', oxygen:'血氧' };

export default {
  name: 'HealthAlert',
  data() {
    return {
      activeFilter: null,
      alerts: [],
      unhandledCount: 0,
      filters: [
        { label: '全部', value: null },
        { label: '待处理', value: 0 },
        { label: '已处理', value: 1 }
      ]
    };
  },
  async onShow() { await this.loadAlerts(); },
  methods: {
    async loadAlerts() {
      try {
        const params = { limit: 50 };
        if (this.activeFilter !== null) params.status = this.activeFilter;
        const res = await useHealthAlertListApi(params);
        this.alerts = res?.data?.list || [];
        this.unhandledCount = this.alerts.filter(a => a.status === 0).length;
      } catch (e) { console.error(e); }
    },
    async handleAlert(item, status) {
      try {
        await request.put(`/member/health-alert/${item.id}/handle`, { status });
        item.status = status;
        this.unhandledCount = this.alerts.filter(a => a.status === 0).length;
        uni.showToast({ title: status === 1 ? '已标记处理' : '已忽略', icon: 'success' });
      } catch (e) {
        uni.showToast({ title: '操作失败', icon: 'none' });
      }
    },
    levelLabel(l) { return { 1:'提示', 2:'警告', 3:'危险' }[l] || '-'; },
    typeLabel(t) { return TYPE_MAP[t] || t; },
    formatTime(t) { return t ? String(t).slice(0, 16) : ''; }
  }
};
</script>

<style scoped>
.page { min-height:100vh; background:#f6f6f6; padding:24rpx; }
.hero-card { background:#111; border-radius:20rpx; padding:30rpx; margin-bottom:16rpx; }
.hero-title { display:block; color:#fff; font-size:36rpx; font-weight:700; }
.hero-sub { display:block; color:#ccc; font-size:22rpx; margin-top:6rpx; }
.filter-row { display:flex; gap:12rpx; margin-bottom:16rpx; }
.filter-btn { padding:12rpx 24rpx; border-radius:999rpx; background:#fff; color:#666; font-size:24rpx; }
.filter-btn.active { background:#111; color:#fff; }
.empty-card { background:#fff; border-radius:18rpx; padding:60rpx; text-align:center; }
.empty-text { color:#aaa; font-size:28rpx; }
.alert-card { background:#fff; border-radius:18rpx; padding:24rpx; margin-bottom:16rpx; border-left:6rpx solid #e5e7eb; }
.level-1 { border-left-color:#f59e0b; }
.level-2 { border-left-color:#ef4444; }
.level-3 { border-left-color:#dc2626; background:#fff5f5; }
.alert-top { display:flex; align-items:center; gap:12rpx; margin-bottom:12rpx; }
.alert-badge { padding:4rpx 14rpx; border-radius:999rpx; font-size:20rpx; font-weight:600; }
.badge-1 { background:#fef3c7; color:#d97706; }
.badge-2 { background:#fee2e2; color:#ef4444; }
.badge-3 { background:#ef4444; color:#fff; }
.alert-type { color:#666; font-size:22rpx; flex:1; }
.alert-time { color:#aaa; font-size:20rpx; }
.alert-msg { display:block; color:#111; font-size:26rpx; font-weight:600; margin-bottom:8rpx; }
.alert-val { display:block; color:#666; font-size:22rpx; margin-bottom:16rpx; }
.alert-actions { display:flex; gap:16rpx; }
.action-btn { flex:1; height:72rpx; line-height:72rpx; border-radius:12rpx; font-size:26rpx; border:none; }
.action-btn::after { border:none; }
.ignore { background:#f3f4f6; color:#666; }
.handle { background:#111; color:#fff; }
.handled-tag { color:#aaa; font-size:22rpx; }
</style>
