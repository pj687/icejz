<template>
  <view class="page">
    <view class="hero-card">
      <text class="hero-title">健康监测</text>
      <text class="hero-sub">记录与管理每日健康数据</text>
    </view>

    <!-- 日期选择 -->
    <view class="date-bar">
      <view class="date-arrow" @tap="prevDay">‹</view>
      <picker mode="date" :value="selectedDate" @change="onDateChange">
        <view class="date-display">
          <text class="date-text">{{ dateLabel }}</text>
          <text class="date-sub">{{ isToday ? '今天' : isYesterday ? '昨天' : '' }}</text>
        </view>
      </picker>
      <view class="date-arrow" :class="{ disabled: isToday }" @tap="nextDay">›</view>
    </view>

    <!-- 当日各指标卡片 -->
    <view class="metrics-wrap">
      <view v-for="t in recordTypes" :key="t.type" class="metric-card"
        :class="{ 'has-data': getDayRecord(t.type) }"
        @tap="openInput(t, getDayRecord(t.type))">
        <view class="metric-header">
          <text class="metric-icon">{{ t.icon }}</text>
          <text class="metric-name">{{ t.label }}</text>
          <view v-if="getDayRecord(t.type)" class="edit-tag">修改</view>
          <view v-else class="add-tag">+ 录入</view>
        </view>
        <view v-if="getDayRecord(t.type)" class="metric-body">
          <text class="metric-val">{{ formatValue(getDayRecord(t.type)) }}</text>
          <text class="metric-time">{{ formatTime(getDayRecord(t.type).recordTime) }}</text>
        </view>
        <view v-else class="metric-empty">
          <text class="metric-empty-text">暂无记录</text>
        </view>
      </view>
    </view>

    <!-- 当日全部记录列表 -->
    <view class="section-card" v-if="dayRecords.length">
      <text class="section-title">当日记录（{{ dayRecords.length }} 条）</text>
      <view v-for="item in dayRecords" :key="item.id" class="record-row" @tap="openInput(getTypeConfig(item.recordType), item)">
        <view class="record-left">
          <text class="record-type-icon">{{ getTypeConfig(item.recordType).icon }}</text>
          <view>
            <text class="record-type-name">{{ getTypeConfig(item.recordType).label }}</text>
            <text class="record-time-text">{{ formatTime(item.recordTime) }}</text>
          </view>
        </view>
        <view class="record-right">
          <text class="record-val-text">{{ formatValue(item) }}</text>
          <text class="record-edit-hint">点击修改</text>
        </view>
      </view>
    </view>

    <!-- 预警提醒 -->
    <view class="alert-banner" v-if="alerts.length" @tap="goAlerts">
      <text class="alert-icon">⚠️</text>
      <text class="alert-text">{{ alerts.length }} 条健康预警待处理</text>
      <text class="alert-arrow">›</text>
    </view>

    <!-- 快捷入口 -->
    <view class="quick-row">
      <view class="quick-btn" @tap="goTrend">
        <text class="quick-icon">📈</text>
        <text class="quick-name">趋势分析</text>
      </view>
      <view class="quick-btn" @tap="goAlerts">
        <text class="quick-icon">🔔</text>
        <text class="quick-name">预警记录</text>
      </view>
    </view>

    <!-- 录入/修改弹窗 -->
    <view v-if="showInput" class="popup-overlay" @tap="closeInput">
      <view class="popup-content" @tap.stop>
        <view class="popup-header">
          <text class="popup-title">{{ editingRecord ? '修改' : '录入' }}{{ currentType.label }}</text>
          <uni-icons type="closeempty" size="24" color="#999" @tap="closeInput" />
        </view>

        <!-- 日期时间选择 -->
        <view class="popup-date-row">
          <text class="input-label">记录时间</text>
          <picker mode="date" :value="inputForm.recordDate" @change="e => inputForm.recordDate = e.detail.value">
            <text class="date-picker-val">{{ inputForm.recordDate }}</text>
          </picker>
          <picker mode="time" :value="inputForm.recordTime" @change="e => inputForm.recordTime = e.detail.value">
            <text class="date-picker-val">{{ inputForm.recordTime }}</text>
          </picker>
        </view>

        <view class="input-row">
          <text class="input-label">{{ currentType.label1 || '数值' }}</text>
          <input class="num-input" type="digit" v-model="inputForm.value1" :placeholder="currentType.placeholder1 || '请输入'" />
          <text class="input-unit">{{ currentType.unit }}</text>
        </view>
        <view class="input-row" v-if="currentType.hasValue2">
          <text class="input-label">{{ currentType.label2 }}</text>
          <input class="num-input" type="digit" v-model="inputForm.value2" :placeholder="currentType.placeholder2" />
          <text class="input-unit">{{ currentType.unit }}</text>
        </view>
        <view class="input-row">
          <text class="input-label">备注</text>
          <input class="num-input" type="text" v-model="inputForm.remark" placeholder="可选" />
        </view>

        <view class="popup-footer">
          <button class="cancel-btn" @tap="closeInput">取消</button>
          <button class="submit-btn" :loading="submitting" @tap="submitRecord">
            {{ editingRecord ? '保存修改' : '保存' }}
          </button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { useHealthTrendApi, useHealthRecordAddApi, useHealthAlertListApi } from '../../../api/user.js';
import cache from '../../../utils/cache.js';
import * as request from '../../../utils/request.js';

const RECORD_TYPES = [
  { type: 'blood_pressure', label: '血压',  icon: '❤️',  unit: 'mmHg',    label1: '收缩压', label2: '舒张压', placeholder1: '如：120', placeholder2: '如：80', hasValue2: true },
  { type: 'blood_sugar',    label: '血糖',  icon: '🩸',  unit: 'mmol/L',  label1: '血糖值', placeholder1: '如：5.6', hasValue2: false },
  { type: 'heart_rate',     label: '心率',  icon: '💓',  unit: '次/分',   label1: '心率',   placeholder1: '如：75', hasValue2: false },
  { type: 'weight',         label: '体重',  icon: '⚖️',  unit: 'kg',      label1: '体重',   placeholder1: '如：65.5', hasValue2: false },
  { type: 'temperature',    label: '体温',  icon: '🌡️', unit: '℃',       label1: '体温',   placeholder1: '如：36.5', hasValue2: false },
  { type: 'oxygen',         label: '血氧',  icon: '🫁',  unit: '%',       label1: '血氧饱和度', placeholder1: '如：98', hasValue2: false }
];

export default {
  name: 'HealthMonitor',
  data() {
    const today = new Date();
    const pad = n => String(n).padStart(2, '0');
    const todayStr = `${today.getFullYear()}-${pad(today.getMonth()+1)}-${pad(today.getDate())}`;
    return {
      recordTypes: RECORD_TYPES,
      selectedDate: todayStr,
      dayRecords: [],
      alerts: [],
      showInput: false,
      submitting: false,
      editingRecord: null,
      currentType: RECORD_TYPES[0],
      inputForm: { value1: '', value2: '', remark: '', recordDate: todayStr, recordTime: '08:00' }
    };
  },
  computed: {
    dateLabel() {
      return this.selectedDate;
    },
    isToday() {
      const today = new Date();
      const pad = n => String(n).padStart(2, '0');
      return this.selectedDate === `${today.getFullYear()}-${pad(today.getMonth()+1)}-${pad(today.getDate())}`;
    },
    isYesterday() {
      const d = new Date(); d.setDate(d.getDate() - 1);
      const pad = n => String(n).padStart(2, '0');
      return this.selectedDate === `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
    }
  },
  async onShow() {
    await this.loadDayData();
    await this.loadAlerts();
  },
  methods: {
    async loadDayData() {
      try {
        const user = cache.getUserInfo() || {};
        // 查当天所有类型的记录（取最近100条再按日期过滤）
        const res = await useHealthTrendApi('', 100, user.id);
        const all = res?.data || [];
        this.dayRecords = all.filter(r => r.recordTime && r.recordTime.startsWith(this.selectedDate));
      } catch (e) { console.error(e); }
    },
    async loadAlerts() {
      try {
        const res = await useHealthAlertListApi({ status: 0, limit: 20 });
        this.alerts = res?.data?.list || [];
      } catch (e) {}
    },
    getDayRecord(type) {
      return this.dayRecords.find(r => r.recordType === type) || null;
    },
    getTypeConfig(type) {
      return RECORD_TYPES.find(t => t.type === type) || { label: type, icon: '📊', unit: '', hasValue2: false };
    },
    prevDay() {
      const d = new Date(this.selectedDate);
      d.setDate(d.getDate() - 1);
      const pad = n => String(n).padStart(2, '0');
      this.selectedDate = `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
      this.loadDayData();
    },
    nextDay() {
      if (this.isToday) return;
      const d = new Date(this.selectedDate);
      d.setDate(d.getDate() + 1);
      const pad = n => String(n).padStart(2, '0');
      this.selectedDate = `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
      this.loadDayData();
    },
    onDateChange(e) {
      this.selectedDate = e.detail.value;
      this.loadDayData();
    },
    openInput(typeConfig, existingRecord) {
      this.currentType = typeConfig;
      this.editingRecord = existingRecord || null;
      if (existingRecord) {
        // 修改模式：填入已有数据
        const t = existingRecord.recordTime || '';
        this.inputForm = {
          value1: String(existingRecord.value1 || ''),
          value2: String(existingRecord.value2 || ''),
          remark: existingRecord.remark || '',
          recordDate: t.slice(0, 10) || this.selectedDate,
          recordTime: t.slice(11, 16) || '08:00'
        };
      } else {
        // 新增模式
        const now = new Date();
        const pad = n => String(n).padStart(2, '0');
        this.inputForm = {
          value1: '', value2: '', remark: '',
          recordDate: this.selectedDate,
          recordTime: `${pad(now.getHours())}:${pad(now.getMinutes())}`
        };
      }
      this.showInput = true;
    },
    closeInput() { this.showInput = false; this.editingRecord = null; },
    async submitRecord() {
      if (!this.inputForm.value1) {
        uni.showToast({ title: '请输入数值', icon: 'none' }); return;
      }
      this.submitting = true;
      try {
        const user = cache.getUserInfo() || {};
        const recordTime = `${this.inputForm.recordDate} ${this.inputForm.recordTime}:00`;
        const payload = {
          elderUserId: user.id,
          elderName: user.realName,
          recordType: this.currentType.type,
          value1: parseFloat(this.inputForm.value1),
          value2: this.inputForm.value2 ? parseFloat(this.inputForm.value2) : null,
          unit: this.currentType.unit,
          recordTime,
          remark: this.inputForm.remark
        };
        if (this.editingRecord) {
          // 修改：PUT 接口
          await request.put(`/member/health-record/${this.editingRecord.id}`, payload);
          uni.showToast({ title: '修改成功', icon: 'success' });
        } else {
          // 新增
          await useHealthRecordAddApi(payload);
          uni.showToast({ title: '录入成功', icon: 'success' });
        }
        this.closeInput();
        await this.loadDayData();
      } catch (e) {
        uni.showToast({ title: '操作失败', icon: 'none' });
      } finally {
        this.submitting = false;
      }
    },
    goTrend() {
      uni.navigateTo({ url: '/pages/services/health-monitor/trend/trend' });
    },
    goAlerts() {
      uni.navigateTo({ url: '/pages/services/health-monitor/alert/alert' });
    },
    formatValue(item) {
      if (!item) return '--';
      if (item.value2) return `${item.value1}/${item.value2} ${item.unit}`;
      return `${item.value1} ${item.unit}`;
    },
    formatTime(t) { return t ? String(t).slice(11, 16) : ''; }
  }
};
</script>

<style scoped>
.page { min-height:100vh; background:#f6f6f6; padding:24rpx 24rpx 48rpx; }
.hero-card { background:#111; border-radius:20rpx; padding:28rpx 30rpx; margin-bottom:16rpx; }
.hero-title { display:block; color:#fff; font-size:36rpx; font-weight:700; }
.hero-sub { display:block; color:#ccc; font-size:22rpx; margin-top:6rpx; }

/* 日期栏 */
.date-bar { display:flex; align-items:center; justify-content:space-between; background:#fff; border-radius:18rpx; padding:20rpx 24rpx; margin-bottom:16rpx; }
.date-arrow { font-size:48rpx; color:#111; padding:0 16rpx; font-weight:300; }
.date-arrow.disabled { color:#ccc; }
.date-display { text-align:center; }
.date-text { display:block; color:#111; font-size:30rpx; font-weight:700; }
.date-sub { display:block; color:#00a8e8; font-size:20rpx; margin-top:4rpx; }

/* 指标卡片网格 */
.metrics-wrap { display:grid; grid-template-columns:repeat(2,1fr); gap:14rpx; margin-bottom:16rpx; }
.metric-card { background:#fff; border-radius:18rpx; padding:20rpx; border:2rpx solid transparent; }
.metric-card.has-data { border-color:#e8f7fd; background:#f0f7ff; }
.metric-header { display:flex; align-items:center; gap:10rpx; margin-bottom:12rpx; }
.metric-icon { font-size:32rpx; }
.metric-name { flex:1; color:#111; font-size:26rpx; font-weight:600; }
.edit-tag { background:#00a8e8; color:#fff; font-size:18rpx; padding:4rpx 12rpx; border-radius:999rpx; }
.add-tag { background:#f3f4f6; color:#888; font-size:18rpx; padding:4rpx 12rpx; border-radius:999rpx; }
.metric-val { display:block; color:#111; font-size:30rpx; font-weight:700; }
.metric-time { display:block; color:#aaa; font-size:20rpx; margin-top:4rpx; }
.metric-empty { padding:8rpx 0; }
.metric-empty-text { color:#ccc; font-size:22rpx; }

/* 记录列表 */
.section-card { background:#fff; border-radius:18rpx; padding:24rpx; margin-bottom:16rpx; }
.section-title { display:block; color:#111; font-size:28rpx; font-weight:600; margin-bottom:16rpx; }
.record-row { display:flex; justify-content:space-between; align-items:center; padding:16rpx 0; border-bottom:1rpx solid #f1f5f9; }
.record-row:last-child { border-bottom:none; }
.record-left { display:flex; align-items:center; gap:14rpx; }
.record-type-icon { font-size:32rpx; }
.record-type-name { display:block; color:#111; font-size:26rpx; font-weight:600; }
.record-time-text { display:block; color:#aaa; font-size:20rpx; margin-top:4rpx; }
.record-right { text-align:right; }
.record-val-text { display:block; color:#00a8e8; font-size:26rpx; font-weight:700; }
.record-edit-hint { display:block; color:#aaa; font-size:18rpx; margin-top:4rpx; }

/* 预警横幅 */
.alert-banner { display:flex; align-items:center; gap:12rpx; background:#fff5f5; border:1rpx solid #fecaca; border-radius:14rpx; padding:18rpx 20rpx; margin-bottom:16rpx; }
.alert-icon { font-size:28rpx; }
.alert-text { flex:1; color:#ef4444; font-size:24rpx; font-weight:600; }
.alert-arrow { color:#ef4444; font-size:32rpx; }

/* 快捷入口 */
.quick-row { display:grid; grid-template-columns:repeat(2,1fr); gap:14rpx; margin-bottom:16rpx; }
.quick-btn { background:#fff; border-radius:18rpx; padding:24rpx; display:flex; flex-direction:column; align-items:center; gap:10rpx; }
.quick-icon { font-size:36rpx; }
.quick-name { color:#111; font-size:24rpx; font-weight:600; }

/* 弹窗 */
.popup-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:1000; display:flex; align-items:flex-end; }
.popup-content { background:#fff; border-radius:20rpx 20rpx 0 0; width:100%; padding:30rpx 30rpx 48rpx; }
.popup-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24rpx; }
.popup-title { color:#111; font-size:32rpx; font-weight:700; }
.popup-date-row { display:flex; align-items:center; gap:16rpx; padding:16rpx 0; border-bottom:1rpx solid #f1f5f9; margin-bottom:4rpx; }
.date-picker-val { color:#00a8e8; font-size:26rpx; padding:6rpx 16rpx; background:#eff6ff; border-radius:8rpx; }
.input-row { display:flex; align-items:center; gap:16rpx; padding:16rpx 0; border-bottom:1rpx solid #f1f5f9; }
.input-label { color:#666; font-size:26rpx; width:140rpx; flex-shrink:0; }
.num-input { flex:1; font-size:28rpx; color:#111; }
.input-unit { color:#aaa; font-size:22rpx; width:80rpx; text-align:right; }
.popup-footer { display:flex; gap:16rpx; margin-top:28rpx; }
.cancel-btn { flex:1; height:88rpx; line-height:88rpx; border-radius:14rpx; background:#f3f4f6; color:#111; font-size:28rpx; border:none; }
.cancel-btn::after { border:none; }
.submit-btn { flex:1; height:88rpx; line-height:88rpx; border-radius:14rpx; background:#111; color:#fff; font-size:28rpx; border:none; }
.submit-btn::after { border:none; }
</style>
