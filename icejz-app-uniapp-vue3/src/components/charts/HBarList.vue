<template>
  <ice-echart :option="chartOption" :height="height" />
</template>

<script>
import * as echarts from 'echarts'
import IceEchart from './IceEchart.vue'

const palette = ['#00a8e8', '#38bdf8', '#0ea5e9', '#67e8f9']

export default {
  name: 'HBarList',
  components: { IceEchart },
  props: {
    items: {
      type: Array,
      default: () => []
    },
    height: {
      type: String,
      default: '220rpx'
    }
  },
  computed: {
    chartOption() {
      const labels = this.items.map((i) => i.label).reverse()
      const values = this.items.map((i) => Number(i.value) || 0).reverse()
      const colors = this.items
        .map((i, idx) => i.color || palette[idx % palette.length])
        .reverse()

      return {
        tooltip: {
          trigger: 'axis',
          confine: true,
          axisPointer: { type: 'shadow' },
          backgroundColor: 'rgba(15, 23, 36, 0.88)',
          borderWidth: 0,
          textStyle: { color: '#fff', fontSize: 12 }
        },
        grid: {
          left: 8,
          right: 24,
          top: 8,
          bottom: 8,
          containLabel: true
        },
        xAxis: {
          type: 'value',
          minInterval: 1,
          splitLine: { lineStyle: { color: 'rgba(15,23,36,0.06)', type: 'dashed' } },
          axisLabel: { color: '#9aa8b6', fontSize: 10 }
        },
        yAxis: {
          type: 'category',
          data: labels,
          axisTick: { show: false },
          axisLine: { show: false },
          axisLabel: { color: '#5b7388', fontSize: 12 }
        },
        series: [
          {
            type: 'bar',
            data: values.map((v, i) => ({
              value: v,
              itemStyle: {
                color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
                  { offset: 0, color: colors[i] },
                  { offset: 1, color: '#7dd3fc' }
                ]),
                borderRadius: [0, 8, 8, 0]
              }
            })),
            barWidth: 16,
            label: {
              show: true,
              position: 'right',
              color: '#0f1724',
              fontSize: 11,
              fontWeight: 600
            }
          }
        ]
      }
    }
  }
}
</script>
