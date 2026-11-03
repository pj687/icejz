<template>
	<ShowcaseShell title="ECharts 图表" desc="堆叠面积图示例，可另存为图片；窗口变化时自动自适应">
		<div class="chart-panel">
			<div ref="main" class="chart-canvas"></div>
		</div>
	</ShowcaseShell>
</template>

<script setup lang="ts">
import * as echarts from 'echarts'
import { onBeforeUnmount, onMounted, ref } from 'vue'
import ShowcaseShell from '../ShowcaseShell.vue'

const main = ref()
let chart: echarts.ECharts | null = null

const init = () => {
	chart = echarts.init(main.value)
	chart.setOption({
		color: ['#00a8e8', '#2fbfa4', '#f0a202', '#7c6cf0', '#ef5b5b'],
		title: {
			text: '一周访问趋势',
			left: 8,
			top: 8,
			textStyle: { color: '#0f1724', fontSize: 16, fontWeight: 700 }
		},
		tooltip: {
			trigger: 'axis',
			axisPointer: { type: 'cross', label: { backgroundColor: '#0f4f6e' } }
		},
		legend: {
			top: 12,
			right: 12,
			data: ['邮件', '广告', '视频', '直达', '搜索']
		},
		toolbox: {
			feature: { saveAsImage: {} },
			right: 12,
			top: 40
		},
		grid: { left: '3%', right: '4%', bottom: '4%', top: 84, containLabel: true },
		xAxis: [
			{
				type: 'category',
				boundaryGap: false,
				data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
				axisLine: { lineStyle: { color: '#cbd5e1' } },
				axisLabel: { color: '#64748b' }
			}
		],
		yAxis: [
			{
				type: 'value',
				splitLine: { lineStyle: { color: '#eef2f7' } },
				axisLabel: { color: '#64748b' }
			}
		],
		series: [
			{ name: '邮件', type: 'line', stack: 'Total', areaStyle: { opacity: 0.35 }, smooth: true, emphasis: { focus: 'series' }, data: [120, 132, 101, 134, 90, 230, 210] },
			{ name: '广告', type: 'line', stack: 'Total', areaStyle: { opacity: 0.35 }, smooth: true, emphasis: { focus: 'series' }, data: [220, 182, 191, 234, 290, 330, 310] },
			{ name: '视频', type: 'line', stack: 'Total', areaStyle: { opacity: 0.35 }, smooth: true, emphasis: { focus: 'series' }, data: [150, 232, 201, 154, 190, 330, 410] },
			{ name: '直达', type: 'line', stack: 'Total', areaStyle: { opacity: 0.35 }, smooth: true, emphasis: { focus: 'series' }, data: [320, 332, 301, 334, 390, 330, 320] },
			{ name: '搜索', type: 'line', stack: 'Total', areaStyle: { opacity: 0.4 }, smooth: true, label: { show: true, position: 'top' }, emphasis: { focus: 'series' }, data: [820, 932, 901, 934, 1290, 1330, 1320] }
		]
	})
}

const onResize = () => chart?.resize()

onMounted(() => {
	init()
	window.addEventListener('resize', onResize)
})

onBeforeUnmount(() => {
	window.removeEventListener('resize', onResize)
	chart?.dispose()
	chart = null
})
</script>

<style scoped lang="scss">
.chart-panel {
	padding: 10px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.12);
	background: color-mix(in srgb, var(--sc-panel, #fff) 94%, transparent);
	box-shadow: 0 10px 24px rgba(15, 40, 64, 0.04);
}

.chart-canvas {
	width: 100%;
	height: calc(100vh - 220px - var(--theme-header-height, 60px));
	min-height: 420px;
}
</style>
