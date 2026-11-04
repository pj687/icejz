Component({
  properties: {
    percent: { type: Number, value: 0 },
    label: { type: String, value: '已读' },
    legend: { type: Array, value: [] },
    height: { type: String, value: '240rpx' },
    canvasId: { type: String, value: 'home-ring' }
  },
  data: {
    chartOption: null
  },
  observers: {
    'percent, label, legend'() {
      this.buildOption()
    }
  },
  lifetimes: {
    attached() {
      this.buildOption()
    }
  },
  methods: {
    buildOption() {
      const legend = this.data.legend || []
      const data = (
        legend.length
          ? legend
          : [
              { label: this.data.label, value: this.data.percent, color: '#00a8e8' },
              { label: '其余', value: Math.max(0, 100 - this.data.percent), color: '#e2e8f0' }
            ]
      ).map((item) => ({
        name: item.label,
        value: Number(item.value) || 0,
        itemStyle: { color: item.color || '#00a8e8' }
      }))
      const total = data.reduce((sum, d) => sum + d.value, 0)
      const centerText = `${Math.max(0, Math.min(100, Math.round(Number(this.data.percent) || 0)))}%`

      this.setData({
        chartOption: {
          tooltip: { trigger: 'item', confine: true },
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
              data: total > 0 ? data : [{ name: '暂无', value: 1, itemStyle: { color: '#e2e8f0' } }]
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
                text: this.data.label || '已读',
                fill: '#8492a6',
                fontSize: 12,
                align: 'center'
              }
            }
          ]
        }
      })
    }
  }
})
