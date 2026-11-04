<template>
  <ice-echart :option="chartOption" :height="height" />
</template>

<script>
import * as echarts from 'echarts'
import IceEchart from './IceEchart.vue'

const palette = ['#00a8e8', '#38bdf8', '#0ea5e9', '#0284c7', '#7dd3fc', '#67e8f9']

export default {
  name: 'BarChart',
  components: { IceEchart },
  props: {
    items: {
      type: Array,
      default: () => []
    },
    height: {
      type: String,
      default: '320rpx'
    },
    /** bar | line | auto */
    type: {
      type: String,
      default: 'auto'
    }
  },
  computed: {
    chartType() {
      if (this.type === 'bar' || this.type === 'line') return this.type
      return this.items.length >= 7 ? 'line' : 'bar'
    },
    chartOption() {
      const labels = this.items.map((i) => i.label)
      const values = this.items.map((i) => Number(i.value) || 0)
      const colors = this.items.map((i, idx) => i.color || palette[idx % palette.length])
      const isLine = this.chartType === 'line'

      return {
        color: colors,
        tooltip: {
          trigger: 'axis',
          confine: true,
          backgroundColor: 'rgba(15, 23, 36, 0.88)',
          borderWidth: 0,
          textStyle: { color: '#fff', fontSize: 12 }
        },
        grid: {
          left: 8,
          right: 8,
          top: 28,
          bottom: 8,
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: labels,
          axisTick: { show: false },
          axisLine: { lineStyle: { color: 'rgba(15,23,36,0.08)' } },
          axisLabel: { color: '#7a8899', fontSize: 11 }
        },
        yAxis: {
          type: 'value',
          minInterval: 1,
          splitLine: { lineStyle: { color: 'rgba(15,23,36,0.06)', type: 'dashed' } },
          axisLabel: { color: '#9aa8b6', fontSize: 10 }
        },
        series: [
          isLine
            ? {
                type: 'line',
                data: values,
                smooth: true,
                symbol: 'circle',
                symbolSize: 7,
                lineStyle: { width: 3, color: '#00a8e8' },
                itemStyle: { color: '#00a8e8' },
                areaStyle: {
                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                    { offset: 0, color: 'rgba(0,168,232,0.28)' },
                    { offset: 1, color: 'rgba(0,168,232,0.02)' }
                  ])
                }
              }
            : {
                type: 'bar',
                data: values.map((v, i) => ({
                  value: v,
                  itemStyle: {
                    color: colors[i],
                    borderRadius: [8, 8, 4, 4]
                  }
                })),
                barWidth: '42%',
                label: {
                  show: true,
                  position: 'top',
                  color: '#5b7388',
                  fontSize: 10
                }
              }
        ]
      }
    }
  }
}
</script>
