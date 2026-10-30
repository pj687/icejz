<template>
  <view class="page">
    <view class="hero-card">
      <text class="hero-title">{{ typeConfig.label }}趋势</text>
      <text class="hero-sub">近{{ records.length }}条记录分析</text>
    </view>

    <!-- 指标切换 -->
    <scroll-view scroll-x class="type-scroll">
      <view class="type-tabs">
        <view v-for="t in recordTypes" :key="t.type"
          class="type-tab" :class="{ active: activeType === t.type }"
          @tap="switchType(t.type)">
          {{ t.label }}
        </view>
      </view>
    </scroll-view>

    <!-- 统计卡片 -->
    <view class="stats-row" v-if="stats.count > 0">
      <view class="stat-card">
        <text class="stat-val">{{ stats.latest }}</text>
        <text class="stat-label">最新值</text>
      </view>
      <view class="stat-card">
        <text class="stat-val">{{ stats.avg }}</text>
        <text class="stat-label">平均值</text>
      </view>
      <view class="stat-card">
        <text class="stat-val">{{ stats.max }}</text>
        <text class="stat-label">最高值</text>
      </view>
      <view class="stat-card">
        <text class="stat-val">{{ stats.min }}</text>
        <text class="stat-label">最低值</text>
      </view>
    </view>

    <!-- 趋势图 -->
    <view class="section-card" v-if="records.length">
      <text class="section-title">趋势图（近{{ records.length }}条）</text>

      <view class="chart-block">
        <view class="chart-block-head">
          <text class="chart-name">柱状图</text>
          <text class="chart-meta">适合看单次波动</text>
        </view>
        <view class="chart-wrap">
          <view class="chart-bars">
            <view v-for="(item, idx) in chartData" :key="idx" class="bar-col">
              <text class="bar-value" :class="item.textClass">{{ item.displayValue }}</text>
              <view class="bar-fill" :style="{ height: item.height + 'rpx' }" :class="item.alertClass"></view>
              <text class="bar-label">{{ item.label }}</text>
            </view>
          </view>
          <view class="chart-y-labels">
            <text class="y-label">{{ stats.max }}</text>
            <text class="y-label">{{ stats.avg }}</text>
            <text class="y-label">{{ stats.min }}</text>
          </view>
        </view>
      </view>

      <view class="chart-block line-block">
        <view class="chart-block-head">
          <text class="chart-name">折线图</text>
          <text class="chart-meta">{{ typeConfig.type === 'blood_pressure' ? '收缩压 / 舒张压双趋势' : '适合看整体趋势' }}</text>
        </view>
        <view class="line-legend" v-if="typeConfig.type === 'blood_pressure'">
          <view class="legend-item">
            <text class="legend-dot systolic"></text>
            <text class="legend-text">收缩压</text>
          </view>
          <view class="legend-item">
            <text class="legend-dot diastolic"></text>
            <text class="legend-text">舒张压</text>
          </view>
        </view>
        <view class="status-legend">
          <view class="legend-item">
            <text class="legend-dot normal"></text>
            <text class="legend-text">正常</text>
          </view>
          <view class="legend-item">
            <text class="legend-dot warning"></text>
            <text class="legend-text">预警</text>
          </view>
          <view class="legend-item">
            <text class="legend-dot danger"></text>
            <text class="legend-text">异常</text>
          </view>
        </view>
        <view class="range-tip">{{ rangeTip }}</view>
        <view class="line-chart-wrap">
          <view class="line-chart">
            <view class="line-grid">
              <view class="grid-line"></view>
              <view class="grid-line"></view>
              <view class="grid-line"></view>
            </view>
            <svg class="line-svg" viewBox="0 0 320 180" preserveAspectRatio="none">
              <template v-if="typeConfig.type === 'blood_pressure'">
                <polyline
                  :points="bloodPressureLinePoints1"
                  fill="none"
                  stroke="#00a8e8"
                  stroke-width="3"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
                <polyline
                  :points="bloodPressureLinePoints2"
                  fill="none"
                  stroke="#f59e0b"
                  stroke-width="3"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
                <template v-for="(point, idx) in bloodPressurePointList1" :key="`sys-wrap-${idx}`">
                  <circle
                    :cx="point.x"
                    :cy="point.y"
                    r="4"
                    fill="#ffffff"
                    :stroke="point.color"
                    stroke-width="2"
                  />
                  <text :x="point.x" :y="point.y - 10" text-anchor="middle" :fill="point.color" font-size="10">{{ point.value }}</text>
                </template>
                <template v-for="(point, idx) in bloodPressurePointList2" :key="`dia-wrap-${idx}`">
                  <circle
                    :cx="point.x"
                    :cy="point.y"
                    r="4"
                    fill="#ffffff"
                    :stroke="point.color"
                    stroke-width="2"
                  />
                  <text :x="point.x" :y="point.y + 16" text-anchor="middle" :fill="point.color" font-size="10">{{ point.value }}</text>
                </template>
              </template>
              <template v-else>
                <polyline
                  :points="linePoints"
                  fill="none"
                  stroke="#00a8e8"
                  stroke-width="3"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
                <template v-for="(point, idx) in linePointList" :key="`single-${idx}`">
                  <circle
                    :cx="point.x"
                    :cy="point.y"
                    r="4"
                    fill="#ffffff"
                    :stroke="point.color"
                    stroke-width="2"
                  />
                  <text :x="point.x" :y="point.y - 10" text-anchor="middle" :fill="point.color" font-size="10">{{ point.value }}</text>
                </template>
              </template>
            </svg>
          </view>
          <view class="line-label-row">
            <text v-for="(item, idx) in chartData" :key="idx" class="line-label">{{ item.label }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 记录列表 -->
    <view class="section-card">
      <text class="section-title">详细记录</text>
      <view v-if="records.length === 0" class="empty-tip">暂无{{ typeConfig.label }}记录</view>
      <view v-for="item in records" :key="item.id" class="record-row">
        <view>
          <text class="record-val">{{ formatValue(item) }}</text>
          <text class="record-time">{{ formatTime(item.recordTime) }}</text>
        </view>
        <text class="record-remark">{{ item.remark || '' }}</text>
      </view>
    </view>
  </view>
</template>

<script>
import { useHealthTrendApi } from '../../../../api/user.js';

const RECORD_TYPES = [
  { type: 'blood_pressure', label: '血压', unit: 'mmHg', hasValue2: true },
  { type: 'blood_sugar',    label: '血糖', unit: 'mmol/L', hasValue2: false },
  { type: 'heart_rate',     label: '心率', unit: '次/分', hasValue2: false },
  { type: 'weight',         label: '体重', unit: 'kg', hasValue2: false },
  { type: 'temperature',    label: '体温', unit: '℃', hasValue2: false },
  { type: 'oxygen',         label: '血氧', unit: '%', hasValue2: false }
];

export default {
  name: 'HealthTrend',
  data() {
    return { activeType: 'blood_pressure', records: [], recordTypes: RECORD_TYPES };
  },
  computed: {
    typeConfig() {
      return RECORD_TYPES.find(t => t.type === this.activeType) || RECORD_TYPES[0];
    },
    stats() {
      if (!this.records.length) return { count: 0, latest: '--', avg: '--', max: '--', min: '--' };
      const vals = this.records.map(r => parseFloat(r.value1)).filter(v => !isNaN(v));
      const avg = (vals.reduce((a, b) => a + b, 0) / vals.length).toFixed(1);
      return {
        count: vals.length,
        latest: vals[0]?.toFixed(1) || '--',
        avg,
        max: Math.max(...vals).toFixed(1),
        min: Math.min(...vals).toFixed(1)
      };
    },
    chartData() {
      if (!this.records.length) return [];
      const source = this.records.slice(0, 12).map(r => ({
        value: parseFloat(r.value1),
        value2: parseFloat(r.value2),
        label: r?.recordTime?.slice(5, 10) || ''
      })).filter(v => !isNaN(v.value));
      if (!source.length) return [];
      const vals = source.map(item => item.value);
      const max = Math.max(...vals);
      const min = Math.min(...vals);
      const range = max - min || 1;
      return source.reverse().map((item) => {
        const level = this.getValueLevel(item.value, item.value2);
        return {
          value: item.value,
          value2: item.value2,
          height: Math.max(20, ((item.value - min) / range) * 160 + 20),
          label: item.label,
          alertClass: `bar-${level}`,
          textClass: `text-${level}`,
          displayValue: this.typeConfig.type === 'blood_pressure' && !isNaN(item.value2)
            ? `${item.value}/${item.value2}`
            : `${item.value}`
        };
      });
    },
    linePointList() {
      if (!this.chartData.length || this.typeConfig.type === 'blood_pressure') return [];
      return this.buildLinePoints(this.chartData.map(item => item.value));
    },
    linePoints() {
      return this.linePointList.map(point => `${point.x},${point.y}`).join(' ');
    },
    bloodPressurePointList1() {
      if (this.typeConfig.type !== 'blood_pressure') return [];
      return this.buildDualLinePoints('value');
    },
    bloodPressurePointList2() {
      if (this.typeConfig.type !== 'blood_pressure') return [];
      return this.buildDualLinePoints('value2');
    },
    bloodPressureLinePoints1() {
      return this.bloodPressurePointList1.map(point => `${point.x},${point.y}`).join(' ');
    },
    bloodPressureLinePoints2() {
      return this.bloodPressurePointList2.map(point => `${point.x},${point.y}`).join(' ');
    },
    rangeTip() {
      if (this.typeConfig.type === 'blood_pressure') {
        return '参考范围：正常 < 120/80，预警 120-139 或 80-89，异常 ≥ 140/90';
      }
      if (this.typeConfig.type === 'blood_sugar') {
        return '参考范围：正常 < 7.8，预警 7.8-11.0，异常 ≥ 11.1 mmol/L';
      }
      if (this.typeConfig.type === 'heart_rate') {
        return '参考范围：正常 60-100 次/分，超出区间为预警';
      }
      if (this.typeConfig.type === 'temperature') {
        return '参考范围：正常 < 37.3℃，高于等于 37.3℃ 为预警';
      }
      if (this.typeConfig.type === 'oxygen') {
        return '参考范围：正常 ≥ 95%，低于 95% 为预警';
      }
      if (this.typeConfig.type === 'weight') {
        return '体重趋势仅作历史记录参考，请结合个人健康计划判断变化。';
      }
      return '趋势数据仅供参考，请结合医生或护理人员建议进行判断。';
    }
  },
  onLoad(query) {
    if (query?.type) this.activeType = query.type;
    this.loadTrend();
  },
  methods: {
    async loadTrend() {
      try {
        const res = await useHealthTrendApi(this.activeType, 30);
        this.records = res?.data || [];
      } catch (e) { console.error(e); }
    },
    switchType(type) {
      this.activeType = type;
      this.loadTrend();
    },
    buildLinePoints(values) {
      const validValues = values.filter(v => !isNaN(v));
      if (!validValues.length) return [];
      const max = Math.max(...validValues);
      const min = Math.min(...validValues);
      const range = max - min || 1;
      const width = 320;
      const height = 180;
      const xStep = values.length === 1 ? 0 : width / (values.length - 1);
      return values.map((value, idx) => ({
        x: Number((idx * xStep).toFixed(2)),
        y: Number((height - ((value - min) / range) * 140 - 20).toFixed(2)),
        value,
        color: this.getLineColorByLevel(this.getValueLevel(value))
      }));
    },
    buildDualLinePoints(field) {
      const list = this.chartData.filter(item => !isNaN(item[field]));
      if (!list.length) return [];
      const allValues = this.chartData.flatMap(item => [item.value, item.value2]).filter(v => !isNaN(v));
      const max = Math.max(...allValues);
      const min = Math.min(...allValues);
      const range = max - min || 1;
      const width = 320;
      const height = 180;
      const xStep = this.chartData.length === 1 ? 0 : width / (this.chartData.length - 1);
      return this.chartData.map((item, idx) => {
        const value = item[field];
        const isSystolic = field === 'value';
        const level = isSystolic ? this.getBloodPressureLevel(value, null) : this.getBloodPressureLevel(null, value);
        return {
          x: Number((idx * xStep).toFixed(2)),
          y: Number((height - (((value || min) - min) / range) * 140 - 20).toFixed(2)),
          value,
          color: this.getLineColorByLevel(level, isSystolic)
        };
      });
    },
    getValueLevel(value, value2) {
      const v = Number(value);
      const v2 = Number(value2);
      if (this.typeConfig.type === 'blood_pressure') {
        return this.getBloodPressureLevel(v, v2);
      }
      if (this.typeConfig.type === 'blood_sugar') {
        if (v >= 11.1) return 'danger';
        if (v >= 7.8) return 'warning';
        return 'normal';
      }
      if (this.typeConfig.type === 'heart_rate') {
        if (v < 60 || v > 100) return 'warning';
        return 'normal';
      }
      if (this.typeConfig.type === 'temperature') {
        if (v >= 37.3) return 'warning';
        return 'normal';
      }
      if (this.typeConfig.type === 'oxygen') {
        if (v < 95) return 'warning';
        return 'normal';
      }
      return 'normal';
    },
    getBloodPressureLevel(systolic, diastolic) {
      const sys = Number(systolic);
      const dia = Number(diastolic);
      if ((!isNaN(sys) && sys >= 140) || (!isNaN(dia) && dia >= 90)) return 'danger';
      if ((!isNaN(sys) && sys >= 120) || (!isNaN(dia) && dia >= 80)) return 'warning';
      return 'normal';
    },
    getLineColorByLevel(level, isSystolic = true) {
      if (level === 'danger') return '#ef4444';
      if (level === 'warning') return isSystolic ? '#00a8e8' : '#f59e0b';
      return isSystolic ? '#00a8e8' : '#10b981';
    },
    formatValue(item) {
      if (item.value2) return `${item.value1}/${item.value2} ${item.unit}`;
      return `${item.value1} ${item.unit}`;
    },
    formatTime(t) { return t ? String(t).slice(0, 16) : ''; }
  }
};
</script>

<style scoped>
.page { min-height:100vh; background:#f6f6f6; padding:24rpx; }
.hero-card { background:#111; border-radius:20rpx; padding:30rpx; margin-bottom:16rpx; }
.hero-title { display:block; color:#fff; font-size:36rpx; font-weight:700; }
.hero-sub { display:block; color:#ccc; font-size:22rpx; margin-top:6rpx; }
.type-scroll { margin-bottom:16rpx; }
.type-tabs { display:flex; gap:12rpx; padding:4rpx 0; }
.type-tab { padding:12rpx 24rpx; border-radius:999rpx; background:#fff; color:#666; font-size:24rpx; white-space:nowrap; }
.type-tab.active { background:#111; color:#fff; }
.stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:12rpx; margin-bottom:16rpx; }
.stat-card { background:#fff; border-radius:14rpx; padding:18rpx 10rpx; text-align:center; }
.stat-val { display:block; color:#111; font-size:28rpx; font-weight:700; }
.stat-label { display:block; color:#aaa; font-size:20rpx; margin-top:6rpx; }
.section-card { background:#fff; border-radius:18rpx; padding:24rpx; margin-bottom:16rpx; }
.section-title { display:block; color:#111; font-size:28rpx; font-weight:600; margin-bottom:16rpx; }
.chart-block { margin-bottom:24rpx; }
.chart-block:last-child { margin-bottom:0; }
.chart-block-head { display:flex; align-items:center; justify-content:space-between; margin-bottom:14rpx; }
.chart-name { color:#111; font-size:24rpx; font-weight:600; }
.chart-meta { color:#94a3b8; font-size:20rpx; }
.chart-wrap { display:flex; gap:12rpx; }
.chart-bars { flex:1; display:flex; align-items:flex-end; gap:6rpx; height:200rpx; }
.bar-col { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:flex-end; }
.bar-value { font-size:16rpx; margin-bottom:6rpx; font-weight:600; }
.bar-fill { width:100%; background:#00a8e8; border-radius:4rpx 4rpx 0 0; min-height:20rpx; }
.bar-fill.bar-normal { background:#00a8e8; }
.bar-fill.bar-warning { background:#f59e0b; }
.bar-fill.bar-danger { background:#ef4444; }
.bar-label { font-size:16rpx; color:#aaa; margin-top:4rpx; }
.text-normal { color:#00a8e8; }
.text-warning { color:#f59e0b; }
.text-danger { color:#ef4444; }
.chart-y-labels { display:flex; flex-direction:column; justify-content:space-between; padding:0 0 20rpx; }
.y-label { color:#aaa; font-size:18rpx; }
.line-block { padding-top:8rpx; border-top:1rpx solid #f1f5f9; }
.line-legend, .status-legend { display:flex; flex-wrap:wrap; gap:24rpx; margin-bottom:12rpx; }
.legend-item { display:flex; align-items:center; gap:10rpx; }
.legend-dot { width:18rpx; height:18rpx; border-radius:50%; display:inline-block; }
.legend-dot.systolic { background:#00a8e8; }
.legend-dot.diastolic { background:#f59e0b; }
.legend-dot.normal { background:#00a8e8; }
.legend-dot.warning { background:#f59e0b; }
.legend-dot.danger { background:#ef4444; }
.legend-text { color:#64748b; font-size:20rpx; }
.range-tip { margin-bottom:14rpx; padding:14rpx 18rpx; border-radius:12rpx; background:#f8fafc; color:#64748b; font-size:20rpx; line-height:1.6; }
.line-chart-wrap { margin-top:4rpx; }
.line-chart { position:relative; height:200rpx; border-radius:14rpx; background:linear-gradient(180deg, #f8fbff 0%, #eef4ff 100%); overflow:hidden; }
.line-grid { position:absolute; inset:0; display:flex; flex-direction:column; justify-content:space-between; padding:18rpx 0; }
.grid-line { border-top:1rpx dashed #cbd5e1; }
.line-svg { position:absolute; inset:0; width:100%; height:100%; }
.line-label-row { display:flex; justify-content:space-between; gap:6rpx; margin-top:10rpx; }
.line-label { flex:1; text-align:center; color:#94a3b8; font-size:16rpx; }
.record-row { display:flex; justify-content:space-between; align-items:center; padding:16rpx 0; border-bottom:1rpx solid #f1f5f9; }
.record-row:last-child { border-bottom:none; }
.record-val { display:block; color:#111; font-size:28rpx; font-weight:700; }
.record-time { display:block; color:#aaa; font-size:20rpx; margin-top:4rpx; }
.record-remark { color:#888; font-size:22rpx; }
.empty-tip { color:#aaa; font-size:24rpx; text-align:center; padding:20rpx 0; }
</style>
