<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="robotName" :sub="statusText">
      <template #right>
        <view class="nav-actions">
          <text class="nav-btn" @click="openHistory">{{ $t('assistant.history') }}</text>
          <text class="nav-btn primary" @click="startNewChat">{{ $t('assistant.newChat') }}</text>
        </view>
      </template>
    </ice-nav-bar>

    <scroll-view
      class="msg-scroll"
      scroll-y
      :scroll-into-view="scrollInto"
      :scroll-with-animation="true"
    >
      <view class="msg-list">
        <view class="msg assistant">
          <image class="avatar" src="/static/mascot/xiaobing-main.png" mode="aspectFit" />
          <view class="bubble">
            <text class="greet">{{ hello }}</text>
            <text class="welcome">{{ welcome }}</text>
          </view>
        </view>

        <view
          v-for="(msg, idx) in messages"
          :id="'m' + idx"
          :key="idx"
          class="msg"
          :class="msg.role"
        >
          <image
            v-if="msg.role === 'assistant'"
            class="avatar"
            src="/static/mascot/xiaobing-main.png"
            mode="aspectFit"
          />
          <view class="bubble">
            <text class="content">{{ msg.content }}</text>
          </view>
        </view>

        <view v-if="loading" id="typing" class="msg assistant">
          <image class="avatar" src="/static/mascot/xiaobing-main.png" mode="aspectFit" />
          <view class="bubble typing">
            <view class="dot" />
            <view class="dot" />
            <view class="dot" />
          </view>
        </view>

        <view v-if="!messages.length && !loading" class="chips">
          <view
            v-for="chip in quickasks"
            :key="chip"
            class="chip"
            @click="askChip(chip)"
          >
            {{ chip }}
          </view>
        </view>

        <view id="bottom-anchor" class="bottom-space" />
      </view>
    </scroll-view>

    <view class="composer">
      <input
        class="input"
        v-model="input"
        :placeholder="$t('assistant.placeholder')"
        :disabled="loading"
        confirm-type="send"
        @confirm="send"
      />
      <view class="send" :class="{ disabled: loading || !input.trim() }" @click="send">
        {{ loading ? $t('assistant.sending') : $t('assistant.send') }}
      </view>
    </view>

    <view v-if="historyOpen" class="history-mask" @click="closeHistory" />
    <view class="history-panel" :class="{ open: historyOpen }">
      <view class="history-head">
        <text class="history-title">{{ $t('assistant.historyTitle') }}</text>
        <view class="history-head-actions">
          <text class="nav-btn primary" @click="onHistoryNew">{{ $t('assistant.newChat') }}</text>
          <text class="history-close" @click="closeHistory">×</text>
        </view>
      </view>

      <scroll-view class="history-scroll" scroll-y>
        <view v-if="sessionsLoading" class="history-empty">{{ $t('assistant.historyLoading') }}</view>
        <view v-else-if="!sessions.length" class="history-empty">{{ $t('assistant.historyEmpty') }}</view>
        <view
          v-for="item in sessions"
          :key="item.id"
          class="session-item"
          :class="{ active: item.id === currentSessionId }"
          @click="onSelectSession(item.id)"
        >
          <view class="session-main">
            <text class="session-title">{{ item.title || $t('assistant.untitled') }}</text>
            <text class="session-time">{{ formatSessionTime(item.lastMsgTime || item.createTime) }}</text>
          </view>
          <text class="session-del" @click.stop="onDeleteSession(item.id)">{{ $t('assistant.delete') }}</text>
        </view>
      </scroll-view>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'
import {
  useAiRobotInfoApi,
  useAiChatApi,
  useAiChatSessionListApi,
  useAiChatSessionMessagesApi,
  useAiChatSessionDeleteApi
} from '@/api/ai.js'

export default {
  components: { IceNavBar },
  data() {
    return {
      robotName: '小冰',
      welcome: '',
      messages: [],
      input: '',
      loading: false,
      currentSessionId: null,
      scrollInto: '',
      historyOpen: false,
      sessions: [],
      sessionsLoading: false,
      initialized: false
    }
  },
  computed: {
    statusText() {
      return this.loading ? this.$t('assistant.thinking') : this.$t('assistant.online')
    },
    hello() {
      const name = cache.getUserInfo()?.realName || this.$t('common.user')
      const h = new Date().getHours()
      let greet = this.$t('greet.hi')
      if (h < 6) greet = this.$t('greet.late')
      else if (h < 12) greet = this.$t('greet.morning')
      else if (h < 14) greet = this.$t('greet.noon')
      else if (h < 18) greet = this.$t('greet.afternoon')
      else greet = this.$t('greet.evening')
      return `${greet}，${name}`
    },
    quickasks() {
      void this.$i18n.locale
      return [
        this.$t('assistant.chip1'),
        this.$t('assistant.chip2'),
        this.$t('assistant.chip3'),
        this.$t('assistant.chip4')
      ]
    }
  },
  onShow() {
    if (!cache.getToken()) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.loadProfile()
    if (!this.initialized) {
      this.initialized = true
      this.loadLatestSession()
    }
  },
  methods: {
    formatSessionTime(raw) {
      if (!raw) return ''
      const m = String(raw).match(/(\d{2}-\d{2})\s+(\d{2}:\d{2})/)
      if (m) return `${m[1]} ${m[2]}`
      return String(raw).slice(5, 16)
    },
    formatAssistantError(raw) {
      const text = (raw || '').trim()
      if (!text) return this.$t('assistant.errGeneric')
      const lower = text.toLowerCase()
      if (
        lower.includes('authentication fails') ||
        lower.includes('governor') ||
        text.includes('鉴权失败') ||
        text.includes('(401)')
      ) {
        return this.$t('assistant.errAuth')
      }
      if (text.includes('额度不足') || lower.includes('402')) {
        return this.$t('assistant.errQuota')
      }
      if (text.includes('过于频繁') || lower.includes('429')) {
        return this.$t('assistant.errRate')
      }
      return text
    },
    async loadProfile() {
      try {
        const { data } = await useAiRobotInfoApi()
        this.robotName = data?.name || this.$t('assistant.defaultName')
        this.welcome = data?.welcome || this.$t('assistant.defaultWelcome')
      } catch (e) {
        this.robotName = this.$t('assistant.defaultName')
        this.welcome = this.$t('assistant.defaultWelcome')
      }
    },
    async loadSessions(preferId) {
      this.sessionsLoading = true
      try {
        const { data } = await useAiChatSessionListApi()
        this.sessions = Array.isArray(data) ? data : []
        const target =
          preferId && this.sessions.some((s) => s.id === preferId)
            ? preferId
            : this.currentSessionId && this.sessions.some((s) => s.id === this.currentSessionId)
              ? this.currentSessionId
              : this.sessions[0]?.id || null
        if (target && target !== this.currentSessionId) {
          await this.openSession(target)
        } else if (!target) {
          this.currentSessionId = null
        }
      } catch (e) {
        this.sessions = []
      } finally {
        this.sessionsLoading = false
      }
    },
    async loadLatestSession() {
      try {
        const { data } = await useAiChatSessionListApi()
        this.sessions = Array.isArray(data) ? data : []
        if (!this.sessions.length) return
        const first = this.sessions[0]
        if (!first?.id) return
        await this.openSession(first.id)
      } catch (e) {
        // keep empty chat
      }
    },
    async openSession(id) {
      if (this.loading) return
      try {
        const { data } = await useAiChatSessionMessagesApi(id)
        this.currentSessionId = id
        this.messages = (Array.isArray(data) ? data : [])
          .filter((m) => m?.role === 'user' || m?.role === 'assistant')
          .map((m) => ({ role: m.role, content: m.content }))
        this.$nextTick(() => this.scrollBottom())
      } catch (e) {
        uni.showToast({ title: this.$t('assistant.loadFail'), icon: 'none' })
      }
    },
    async openHistory() {
      this.historyOpen = true
      await this.loadSessions(this.currentSessionId)
    },
    closeHistory() {
      this.historyOpen = false
    },
    async onSelectSession(id) {
      if (!id || id === this.currentSessionId) {
        this.closeHistory()
        return
      }
      await this.openSession(id)
      this.closeHistory()
    },
    onHistoryNew() {
      this.startNewChat()
      this.closeHistory()
    },
    startNewChat() {
      if (this.loading) return
      this.currentSessionId = null
      this.messages = []
      this.input = ''
    },
    onDeleteSession(id) {
      uni.showModal({
        title: this.$t('assistant.historyTitle'),
        content: this.$t('assistant.deleteConfirm'),
        success: async (res) => {
          if (!res.confirm) return
          try {
            await useAiChatSessionDeleteApi([id])
            if (this.currentSessionId === id) {
              this.currentSessionId = null
              this.messages = []
            }
            await this.loadSessions()
            uni.showToast({ title: this.$t('assistant.deleted'), icon: 'none' })
          } catch (e) {
            // request layer toast
          }
        }
      })
    },
    askChip(text) {
      this.input = text
      this.send()
    },
    scrollBottom() {
      this.scrollInto = ''
      this.$nextTick(() => {
        this.scrollInto = this.loading ? 'typing' : 'bottom-anchor'
      })
    },
    async send() {
      const text = (this.input || '').trim()
      if (!text || this.loading) return
      this.messages.push({ role: 'user', content: text })
      this.input = ''
      this.loading = true
      this.scrollBottom()
      try {
        const history = this.messages
          .slice(0, -1)
          .slice(-8)
          .map((m) => ({ role: m.role, content: m.content }))
        const { data } = await useAiChatApi({
          message: text,
          sessionId: this.currentSessionId,
          history
        })
        if (data?.sessionId) this.currentSessionId = data.sessionId
        this.messages.push({
          role: 'assistant',
          content: data?.content || this.$t('assistant.emptyReply')
        })
        // 静默刷新会话列表，便于下次打开历史
        useAiChatSessionListApi()
          .then((res) => {
            this.sessions = Array.isArray(res.data) ? res.data : []
          })
          .catch(() => null)
      } catch (e) {
        const tip = this.formatAssistantError(e?.msg || e?.message || '')
        this.messages.push({ role: 'assistant', content: tip })
      } finally {
        this.loading = false
        this.scrollBottom()
      }
    }
  }
}
</script>

<style scoped>
.page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  position: relative;
  overflow: hidden;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.nav-btn {
  padding: 10rpx 18rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 8rpx 18rpx rgba(15, 35, 55, 0.06);
  font-size: 22rpx;
  font-weight: 600;
  color: #3d4b5c;
}

.nav-btn.primary {
  color: #0284c7;
  background: rgba(0, 168, 232, 0.12);
  border-color: transparent;
  box-shadow: none;
}

.msg-scroll {
  flex: 1;
  min-height: 0;
  height: 0;
}

.msg-list {
  padding: 8rpx 24rpx 24rpx;
}

.msg {
  display: flex;
  align-items: flex-start;
  gap: 14rpx;
  margin-top: 20rpx;
}

.msg.user {
  flex-direction: row-reverse;
}

.avatar {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  background: rgba(0, 168, 232, 0.1);
  flex-shrink: 0;
  box-shadow: 0 8rpx 16rpx rgba(0, 168, 232, 0.12);
}

.bubble {
  max-width: 72%;
  padding: 20rpx 22rpx;
  border-radius: 24rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 12rpx 28rpx rgba(15, 35, 55, 0.05);
}

.msg.user .bubble {
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  border: none;
  color: #fff;
  box-shadow: 0 12rpx 24rpx rgba(0, 168, 232, 0.22);
}

.greet {
  display: block;
  font-size: 24rpx;
  font-weight: 700;
  color: #0c1520;
}

.welcome {
  display: block;
  margin-top: 8rpx;
  font-size: 26rpx;
  color: #3d4b5c;
  line-height: 1.55;
}

.content {
  font-size: 28rpx;
  line-height: 1.6;
  color: inherit;
  white-space: pre-wrap;
  word-break: break-word;
}

.msg.assistant .content {
  color: #0c1520;
}

.typing {
  display: flex;
  align-items: center;
  gap: 10rpx;
  min-width: 88rpx;
  min-height: 40rpx;
}

.dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #00a8e8;
  opacity: 0.35;
  animation: blink 1.2s infinite ease-in-out;
}

.dot:nth-child(2) {
  animation-delay: 0.2s;
}

.dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes blink {
  0%,
  80%,
  100% {
    opacity: 0.28;
    transform: translateY(0);
  }
  40% {
    opacity: 1;
    transform: translateY(-4rpx);
  }
}

.chips {
  margin-top: 28rpx;
  display: flex;
  flex-wrap: wrap;
  gap: 14rpx;
}

.chip {
  padding: 14rpx 22rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.1);
  color: #0284c7;
  font-size: 24rpx;
  font-weight: 600;
}

.bottom-space {
  height: 24rpx;
}

.composer {
  padding: 16rpx 24rpx calc(16rpx + env(safe-area-inset-bottom));
  display: flex;
  gap: 14rpx;
  align-items: center;
  background: rgba(255, 255, 255, 0.88);
  border-top: 1rpx solid rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(12px);
}

.input {
  flex: 1;
  height: 80rpx;
  padding: 0 28rpx;
  border-radius: 999rpx;
  background: #f7fafc;
  border: 1rpx solid rgba(232, 238, 245, 0.9);
  font-size: 28rpx;
  color: #0c1520;
}

.send {
  min-width: 128rpx;
  height: 80rpx;
  padding: 0 22rpx;
  border-radius: 999rpx;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  color: #fff;
  font-size: 28rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 22rpx rgba(0, 168, 232, 0.24);
}

.send.disabled {
  opacity: 0.45;
}

.history-mask {
  position: fixed;
  inset: 0;
  z-index: 40;
  background: rgba(12, 21, 32, 0.36);
}

.history-panel {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  width: 78%;
  max-width: 560rpx;
  z-index: 41;
  background: #f5f8fb;
  box-shadow: -12rpx 0 36rpx rgba(12, 21, 32, 0.12);
  transform: translateX(105%);
  transition: transform 0.28s cubic-bezier(0.22, 1, 0.36, 1);
  display: flex;
  flex-direction: column;
  padding-top: env(safe-area-inset-top);
}

.history-panel.open {
  transform: translateX(0);
}

.history-head {
  padding: 24rpx 24rpx 16rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12rpx;
}

.history-title {
  font-size: 32rpx;
  font-weight: 800;
  color: #0c1520;
}

.history-head-actions {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.history-close {
  width: 56rpx;
  height: 56rpx;
  border-radius: 16rpx;
  background: #fff;
  border: 1rpx solid rgba(12, 21, 32, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36rpx;
  color: #7d8b9a;
  line-height: 1;
}

.history-scroll {
  flex: 1;
  min-height: 0;
  height: 0;
  padding: 8rpx 20rpx 28rpx;
  box-sizing: border-box;
}

.history-empty {
  margin-top: 80rpx;
  text-align: center;
  font-size: 24rpx;
  color: #7d8b9a;
  line-height: 1.6;
}

.session-item {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 22rpx 18rpx;
  margin-bottom: 12rpx;
  border-radius: 20rpx;
  background: #fff;
  border: 1rpx solid rgba(12, 21, 32, 0.06);
}

.session-item.active {
  border-color: rgba(0, 168, 232, 0.4);
  background: rgba(0, 168, 232, 0.08);
  box-shadow: 0 8rpx 18rpx rgba(0, 168, 232, 0.1);
}

.session-main {
  flex: 1;
  min-width: 0;
}

.session-title {
  display: block;
  font-size: 26rpx;
  font-weight: 700;
  color: #0c1520;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.session-time {
  display: block;
  margin-top: 6rpx;
  font-size: 20rpx;
  color: #7d8b9a;
}

.session-del {
  flex-shrink: 0;
  padding: 8rpx 14rpx;
  border-radius: 12rpx;
  background: rgba(225, 29, 72, 0.08);
  color: #e11d48;
  font-size: 22rpx;
  font-weight: 600;
}
</style>
