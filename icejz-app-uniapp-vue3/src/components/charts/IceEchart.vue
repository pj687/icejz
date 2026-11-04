<template>
  <view class="ice-echart" :style="{ width: '100%', height: height }">
    <l-echart ref="chartRef" :before-delay="beforeDelay" @finished="onFinished" />
  </view>
</template>

<script>
import * as echarts from 'echarts'
import LEchart from '@/uni_modules/lime-echart/components/l-echart/l-echart.vue'

export default {
  name: 'IceEchart',
  components: { LEchart },
  props: {
    option: {
      type: Object,
      default: () => ({})
    },
    height: {
      type: String,
      default: '280rpx'
    },
    beforeDelay: {
      type: Number,
      default: 30
    }
  },
  data() {
    return {
      chart: null,
      ready: false
    }
  },
  watch: {
    option: {
      deep: true,
      handler(val) {
        this.applyOption(val)
      }
    }
  },
  beforeUnmount() {
    if (this.chart) {
      this.chart.dispose()
      this.chart = null
    }
  },
  methods: {
    async onFinished() {
      this.ready = true
      await this.init()
    },
    async init() {
      if (!this.$refs.chartRef) return
      try {
        this.chart = await this.$refs.chartRef.init(echarts)
        this.applyOption(this.option)
      } catch (e) {
        console.error('[IceEchart] init failed', e)
      }
    },
    applyOption(option) {
      if (!this.chart || !option) return
      this.chart.setOption(option, true)
    },
    resize() {
      this.chart && this.chart.resize()
    }
  }
}
</script>

<style scoped>
.ice-echart {
  width: 100%;
}
</style>
