Component({
  properties: {
    items: { type: Array, value: [] },
    height: { type: String, value: '280rpx' },
    type: { type: String, value: 'bar' },
    canvasId: { type: String, value: 'home-bar' }
  },
  data: {
    chartOption: null
  },
  observers: {
    'items, type'() {
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
      const items = this.data.items || []
      const labels = items.map((i) => i.label)
      const values = items.map((i) => Number(i.value) || 0)
      const colors = items.map((i, idx) => i.color || ['#00a8e8', '#38bdf8', '#0ea5e9', '#0284c7'][idx % 4])
      const isLine = this.data.type === 'line'

      const option = {
        color: colors,
        grid: {
          left: 8,
          right: 8,
          top: 28,
          bottom: 8,
          containLabel: true
        },
        tooltip: {
          trigger: 'axis',
          confine: true
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
                  color: {
                    type: 'linear',
                    x: 0,
                    y: 0,
                    x2: 0,
                    y2: 1,
                    colorStops: [
                      { offset: 0, color: 'rgba(0,168,232,0.28)' },
                      { offset: 1, color: 'rgba(0,168,232,0.02)' }
                    ]
                  }
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
                barWidth: '42%'
              }
        ]
      }
      this.setData({ chartOption: option })
    }
  }
})
