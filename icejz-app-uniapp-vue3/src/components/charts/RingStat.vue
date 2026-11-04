<template>
  <ice-echart :option="chartOption" :height="height" />
</template>

<script>
import IceEchart from './IceEchart.vue'

export default {
  name: 'RingStat',
  components: { IceEchart },
  props: {
    percent: { type: Number, default: 0 },
    label: { type: String, default: '完成率' },
    legend: { type: Array, default: () => [] },
    height: { type: String, default: '280rpx' }
  },
  computed: {
    chartOption() {
      const data = (this.legend.length
        ? this.legend
        : [
            { label: this.label, value: this.percent, color: '#00a8e8' },
            { label: '其余', value: Math.max(0, 100 - this.percent), color: '#e2e8f0' }
          ]
      ).map((item) => ({
        name: item.label,
        value: Number(item.value) || 0,
        itemStyle: { color: item.color || '#00a8e8' }
      }))

      const total = data.reduce((sum, d) => sum + d.value, 0)
      const centerText = `${Math.max(0, Math.min(100, Math.round(Number(this.percent) || 0)))}%`

      return {
        tooltip: {
          trigger: 'item',
          confine: true,
          backgroundColor: 'rgba(15, 23, 36, 0.88)',
          borderWidth: 0,
          textStyle: { color: '#fff', fontSize: 12 }
        },
        legend: {
          orient: 'vertical',
          right: 8,
          top: 'center',
          itemWidth: 10,
          itemHeight: 10,
          textStyle: { color: '#5b7388', fontSize: 12 },
          formatter: (name) => {
            const hit = data.find((d) => d.name === name)
            return `${name}  ${hit ? hit.value : ''}`
          }
        },
        series: [
          {
            type: 'pie',
            radius: ['58%', '78%'],
            center: ['34%', '50%'],
            avoidLabelOverlap: true,
            label: { show: false },
            labelLine: { show: false },
            data: total > 0 ? data : [{ name: '暂无', value: 1, itemStyle: { color: '#e2e8f0' } }],
            emphasis: {
              scale: true,
              scaleSize: 4
            }
          }
        ],
        graphic: [
          {
            type: 'text',
            left: '26%',
            top: '42%',
            style: {
              text: total > 0 ? centerText : '—',
              fill: '#0b4f6e',
              fontSize: 22,
              fontWeight: 800,
              align: 'center'
            }
          },
          {
            type: 'text',
            left: '26%',
            top: '56%',
            style: {
              text: this.label,
              fill: '#7a8899',
              fontSize: 11,
              align: 'center'
            }
          }
        ]
      }
    }
  }
}
</script>
