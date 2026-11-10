<template>
  <view class="page ice-page with-tab">
    <view class="ambient a1" />
    <view class="ambient a2" />

    <view class="top" :style="{ paddingTop: statusBarPx + 12 + 'px' }">
      <view class="idcard" @click="go('/pages/usercenter/userinfo/userinfo')">
        <view class="idcard-glow g1" />
        <view class="idcard-glow g2" />

        <view class="idcard-head">
          <view class="idcard-brand">
            <text class="idcard-ice">ICE</text><text class="idcard-jz">JZ</text>
            <text class="idcard-slash">/</text>
            <text class="idcard-sub">{{ $t('workbench.cardBrandSub') }}</text>
          </view>
        </view>

        <view class="idcard-main">
          <view class="idcard-avatar-wrap">
            <view class="idcard-halo" />
            <view class="idcard-ring">
              <image class="idcard-avatar" :src="avatar" mode="aspectFill" />
            </view>
          </view>

          <view class="idcard-copy">
            <text class="idcard-hello">{{ greeting }}</text>
            <text class="idcard-name">{{ displayName }}</text>
            <text class="idcard-meta">{{ badgeMeta }}</text>
          </view>

          <view class="idcard-date">
            <text class="idcard-week">{{ weekDay }}</text>
            <text class="idcard-day">{{ todayLabel }}</text>
          </view>
        </view>

        <view class="idcard-foot">
          <view class="idcard-foot-left">
            <text v-if="username" class="idcard-account">@{{ username }}</text>
            <text class="idcard-tip">{{ $t('workbench.statusLine') }}</text>
          </view>
          <view class="idcard-live">
            <view class="idcard-live-dot" />
            <text class="idcard-live-t">{{ $t('workbench.cardOnDuty') }}</text>
          </view>
        </view>
      </view>
    </view>

    <view class="body">
      <view class="kpi-row">
        <view v-for="item in kpiList" :key="item.key" class="kpi-card">
          <view class="kpi-top">
            <text class="kpi-lab">{{ item.label }}</text>
            <text class="kpi-trend">{{ $t('workbench.trendUp') }}</text>
          </view>
          <text class="kpi-num">{{ item.value }}</text>
          <view class="kpi-foot">
            <image class="spark-img" :src="item.sparkSrc" mode="scaleToFill" />
          </view>
        </view>
      </view>

      <view class="suggest" @click="go('/pages/assistant/chat')">
        <view class="suggest-ico">
          <image class="suggest-img" src="/static/mascot/xiaobing-head.png" mode="aspectFit" />
        </view>
        <view class="suggest-copy">
          <text class="suggest-title">{{ $t('workbench.suggestTitle') }}</text>
          <text class="suggest-body">{{ $t('workbench.suggestBody') }}</text>
        </view>
        <text class="suggest-go">{{ $t('workbench.suggestAction') }}</text>
      </view>

      <view class="card">
        <text class="sec-title">{{ $t('workbench.quickNav') }}</text>
        <view class="quick-grid">
          <view
            v-for="item in quickNav"
            :key="item.path"
            class="quick-item"
            @click="go(item.path, item.tab)"
          >
            <view class="quick-orb">
              <image class="quick-img" :src="item.icon" mode="aspectFit" />
            </view>
            <text class="quick-name">{{ item.name }}</text>
          </view>
        </view>
      </view>

      <view class="card">
        <view class="card-head">
          <view>
            <text class="sec-title">{{ $t('workbench.focusTitle') }}</text>
            <text class="sec-sub">{{ $t('workbench.focusSub') }}</text>
          </view>
          <text class="chip">{{ $t('workbench.focusCount', { n: projects.length }) }}</text>
        </view>
        <view class="project-list">
          <view
            v-for="item in projects"
            :key="item.id"
            class="project-row"
            :class="'tone-' + item.tone"
          >
            <view class="project-main">
              <view class="project-title">
                <text class="project-name">{{ item.title }}</text>
                <text class="project-days">{{ $t('workbench.daysLeft', { n: item.daysLeft }) }}</text>
              </view>
              <text class="project-desc">{{ item.desc }}</text>
              <view class="progress">
                <view class="track">
                  <view class="fill" :class="'fill-' + item.tone" :style="{ width: item.percent + '%' }" />
                </view>
                <text class="pct">{{ item.percent }}%</text>
              </view>
            </view>
            <view class="btn-enter" @click="go(item.path)">{{ $t('workbench.enter') }}</view>
          </view>
        </view>
      </view>

      <view class="cal-panel">
        <view class="cal-head">
          <view class="cal-head-copy">
            <text class="cal-year">{{ viewYear }}</text>
            <text class="cal-month">{{ monthTitle }}</text>
          </view>
          <view class="cal-nav">
            <view class="cal-nav-btn" @click="shiftMonth(-1)">‹</view>
            <view class="cal-nav-mid" @click="goToday">{{ $t('workbench.thisMonth') }}</view>
            <view class="cal-nav-btn" @click="shiftMonth(1)">›</view>
          </view>
        </view>

        <view class="cal-sheet">
          <view class="cal-week">
            <text v-for="w in weekHeaders" :key="w" class="cal-w">{{ w }}</text>
          </view>
          <view class="cal-days">
            <view
              v-for="day in calendarDays"
              :key="day.key"
              class="cal-day"
              :class="{
                mute: !day.current,
                today: day.today,
                has: day.noteCount > 0,
                active: day.dateKey === selectedDateKey
              }"
              @click="selectDay(day)"
            >
              <text class="cal-day-n">{{ day.n }}</text>
              <view v-if="day.tags.length" class="cal-day-tags">
                <view
                  v-for="tag in day.tags"
                  :key="tag.key"
                  class="cal-tag"
                  :data-type="tag.key"
                >
                  <view class="cal-tag-dot" />
                  <text class="cal-tag-t">{{ tag.label }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>

        <view class="cal-picked" :class="{ pulse: agendaPulse }">
          <view class="picked-day">
            <text class="picked-n">{{ selectedDayNum }}</text>
          </view>
          <view class="picked-copy">
            <text class="picked-title">{{ selectedDateLabel }}</text>
            <view class="picked-meta-row">
              <text class="picked-meta">
                {{
                  selectedNotes.length
                    ? $t('workbench.noteCount', { n: selectedNotes.length })
                    : $t('workbench.noteNone')
                }}
              </text>
              <view v-if="selectedDayTags.length" class="picked-tags">
                <view
                  v-for="tag in selectedDayTags"
                  :key="tag.key"
                  class="picked-tag"
                  :data-type="tag.key"
                >
                  <view class="picked-tag-dot" />
                  <text class="picked-tag-t">{{ tag.label }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>

        <view class="cal-agenda">
          <view class="note-seg">
            <view
              v-for="t in noteTypes"
              :key="t.key"
              class="note-seg-item"
              :class="{ active: draftType === t.key }"
              @click="draftType = t.key"
            >
              {{ t.label }}
            </view>
          </view>

          <view v-if="selectedNotes.length" class="note-list">
            <view
              v-for="note in selectedNotes"
              :key="note.id"
              class="note-item"
              :data-type="note.type"
            >
              <view class="note-mark" />
              <view class="note-body">
                <view class="note-top">
                  <view class="note-tag" :data-type="note.type">
                    <view class="note-tag-dot" />
                    <text class="note-tag-t">{{ noteTypeLabel(note.type) }}</text>
                  </view>
                  <text class="note-time">{{ note.createdAt }}</text>
                </view>
                <text class="note-text">{{ note.text }}</text>
              </view>
              <text class="note-del" @click="removeNote(note.id)">{{ $t('workbench.delete') }}</text>
            </view>
          </view>
          <view v-else class="note-empty">
            <text class="empty-text">{{ $t('workbench.noteEmpty') }}</text>
          </view>

          <view class="note-composer">
            <textarea
              v-model="draftText"
              class="note-input"
              :maxlength="120"
              :placeholder="draftPlaceholder"
              :disabled="noteSaving"
            />
            <view class="composer-foot">
              <text class="counter">{{ draftText.length }}/120</text>
              <view
                class="btn-primary"
                :class="{ disabled: !draftText.trim() || noteSaving }"
                @click="addNote"
              >
                {{
                  noteSaving
                    ? $t('workbench.saving')
                    : $t('workbench.addNote', { type: noteTypeLabel(draftType) })
                }}
              </view>
            </view>
          </view>
        </view>
      </view>

      <view class="card">
        <view class="card-head">
          <view>
            <text class="sec-title">{{ $t('workbench.todoTitle') }}</text>
            <text class="sec-sub">{{ $t('workbench.todoSub') }}</text>
          </view>
          <text class="chip soft">{{ todos.length }}</text>
        </view>
        <view class="todo-list">
          <view v-for="item in todos" :key="item.id" class="todo-row">
            <view class="check" :data-level="item.level" />
            <view class="todo-body">
              <text class="todo-title">{{ item.title }}</text>
              <text class="todo-time">{{ item.time }}</text>
            </view>
            <view class="todo-go" @click="go(item.path)">{{ $t('workbench.handle') }}</view>
          </view>
        </view>
      </view>

      <view class="card">
        <view class="card-head">
          <view>
            <text class="sec-title">{{ $t('workbench.msgTitle') }}</text>
            <text class="sec-sub">{{ $t('workbench.msgSub') }}</text>
          </view>
          <text class="link-btn" @click="go('/pages/message/inbox')">{{ $t('workbench.msgAll') }}</text>
        </view>
        <view class="msg-list">
          <view
            v-for="item in messages"
            :key="item.id"
            class="msg-row"
            @click="go('/pages/message/inbox')"
          >
            <view class="msg-mark" :class="'tone-' + item.tone">{{ item.short }}</view>
            <view class="msg-body">
              <text class="msg-name">{{ item.name }}</text>
              <text class="msg-text">{{ item.text }}</text>
            </view>
            <text class="msg-time">{{ item.time }}</text>
          </view>
          <view v-if="!messages.length" class="msg-empty">{{ $t('workbench.msgEmpty') }}</view>
        </view>
      </view>
    </view>

    <custom-tab-bar ref="tabBar" />
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import CustomTabBar from '@/custom-tab-bar/index.vue'
import { useMessageLatestApi } from '@/api/message.js'
import {
  useWorkbenchNoteListApi,
  useWorkbenchNoteSaveApi,
  useWorkbenchNoteDeleteApi
} from '@/api/workbench.js'
import { useMenuNavApi, flattenMenuLeaves } from '@/api/menu.js'

const pad2 = (n) => String(n).padStart(2, '0')
const toDateKey = (y, m, d) => `${y}-${pad2(m + 1)}-${pad2(d)}`

export default {
  components: { CustomTabBar },
  data() {
    const now = new Date()
    return {
      statusBarPx: 20,
      now,
      displayName: '',
      username: '',
      orgName: '',
      postName: '',
      avatar: '/static/logo.png',
      viewYear: now.getFullYear(),
      viewMonth: now.getMonth(),
      selectedDateKey: toDateKey(now.getFullYear(), now.getMonth(), now.getDate()),
      notes: [],
      draftType: 'nudge',
      draftText: '',
      noteSaving: false,
      agendaPulse: false,
      messages: [],
      remoteQuickNav: []
    }
  },
  computed: {
    selectedDayNum() {
      const parts = String(this.selectedDateKey || '').split('-')
      return Number(parts[2]) || 1
    },
    selectedDayShort() {
      void this.$i18n.locale
      const [y, m, d] = String(this.selectedDateKey || '')
        .split('-')
        .map(Number)
      if (!y || !m || !d) return ''
      if (String(this.$i18n.locale || '').startsWith('zh')) {
        return `${m}月${d}日`
      }
      return `${pad2(m)}-${pad2(d)}`
    },
    selectedDayTags() {
      void this.$i18n.locale
      return this.buildDayTags(this.selectedDateKey).map((tag) => ({
        ...tag,
        label: this.noteTypeLabel(tag.key)
      }))
    },
    greeting() {
      void this.$i18n.locale
      const h = this.now.getHours()
      if (h < 6) return this.$t('greet.late')
      if (h < 12) return this.$t('greet.morning')
      if (h < 14) return this.$t('greet.noon')
      if (h < 18) return this.$t('greet.afternoon')
      return this.$t('greet.evening')
    },
    helloText() {
      void this.$i18n.locale
      return this.$t('workbench.hello', {
        greet: this.greeting,
        name: this.displayName || this.$t('common.user')
      })
    },
    badgeMeta() {
      void this.$i18n.locale
      const org = this.orgName || this.$t('workbench.cardOrgEmpty')
      const post = this.postName || this.$t('workbench.cardPostEmpty')
      return [org, post].filter(Boolean).join(' · ')
    },
    weekDay() {
      void this.$i18n.locale
      const map = {
        zh: ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'],
        en: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      }
      const loc = String(this.$i18n.locale || '').startsWith('zh') ? 'zh' : 'en'
      return map[loc][this.now.getDay()]
    },
    todayLabel() {
      void this.$i18n.locale
      const m = this.now.getMonth() + 1
      const d = this.now.getDate()
      if (String(this.$i18n.locale || '').startsWith('zh')) return `${m}月${d}日`
      return `${m}/${d}`
    },
    todayKey() {
      return toDateKey(this.now.getFullYear(), this.now.getMonth(), this.now.getDate())
    },
    monthLabel() {
      void this.$i18n.locale
      if (String(this.$i18n.locale || '').startsWith('zh')) {
        return `${this.viewYear} 年 ${this.viewMonth + 1} 月`
      }
      return `${this.viewYear}-${pad2(this.viewMonth + 1)}`
    },
    monthTitle() {
      void this.$i18n.locale
      if (String(this.$i18n.locale || '').startsWith('zh')) {
        return `${this.viewMonth + 1} 月`
      }
      return pad2(this.viewMonth + 1)
    },
    weekHeaders() {
      void this.$i18n.locale
      return [
        this.$t('stats.dayMon'),
        this.$t('stats.dayTue'),
        this.$t('stats.dayWed'),
        this.$t('stats.dayThu'),
        this.$t('stats.dayFri'),
        this.$t('stats.daySat'),
        this.$t('stats.daySun')
      ]
    },
    noteTypes() {
      void this.$i18n.locale
      return [
        { key: 'nudge', label: this.$t('workbench.typeNudge') },
        { key: 'memo', label: this.$t('workbench.typeMemo') },
        { key: 'remind', label: this.$t('workbench.typeRemind') }
      ]
    },
    draftPlaceholder() {
      void this.$i18n.locale
      if (this.draftType === 'nudge') return this.$t('workbench.phNudge')
      if (this.draftType === 'remind') return this.$t('workbench.phRemind')
      return this.$t('workbench.phMemo')
    },
    storageKey() {
      const user = cache.getUserInfo() || {}
      const id = user.username || user.id || 'guest'
      return `icejz-workbench-notes:${id}`
    },
    notesByDate() {
      const map = {}
      for (const note of this.notes) {
        if (!map[note.dateKey]) map[note.dateKey] = []
        map[note.dateKey].push(note)
      }
      return map
    },
    selectedNotes() {
      return this.notesByDate[this.selectedDateKey] || []
    },
    selectedDateLabel() {
      void this.$i18n.locale
      const [y, m, d] = this.selectedDateKey.split('-').map(Number)
      const tip =
        this.selectedDateKey === this.todayKey
          ? this.$t('workbench.today')
          : this.weekDayFor(new Date(y, m - 1, d).getDay())
      if (String(this.$i18n.locale || '').startsWith('zh')) {
        return `${y}年${m}月${d}日 · ${tip}`
      }
      return `${y}-${pad2(m)}-${pad2(d)} · ${tip}`
    },
    calendarDays() {
      void this.$i18n.locale
      const y = this.viewYear
      const m = this.viewMonth
      const first = new Date(y, m, 1)
      const start = (first.getDay() + 6) % 7
      const daysInMonth = new Date(y, m + 1, 0).getDate()
      const prevDays = new Date(y, m, 0).getDate()
      const list = []

      for (let i = start - 1; i >= 0; i--) {
        const n = prevDays - i
        const pm = m === 0 ? 11 : m - 1
        const py = m === 0 ? y - 1 : y
        const dateKey = toDateKey(py, pm, n)
        const tags = this.buildDayTags(dateKey)
        list.push({
          key: `p-${i}`,
          n,
          current: false,
          today: false,
          noteCount: tags.length ? (this.notesByDate[dateKey] || []).length : 0,
          tags,
          dateKey
        })
      }
      for (let d = 1; d <= daysInMonth; d++) {
        const dateKey = toDateKey(y, m, d)
        const tags = this.buildDayTags(dateKey)
        list.push({
          key: `c-${d}`,
          n: d,
          current: true,
          today: dateKey === this.todayKey,
          noteCount: (this.notesByDate[dateKey] || []).length,
          tags,
          dateKey
        })
      }
      let next = 1
      const nm = m === 11 ? 0 : m + 1
      const ny = m === 11 ? y + 1 : y
      while (list.length % 7 !== 0) {
        const n = next++
        const dateKey = toDateKey(ny, nm, n)
        const tags = this.buildDayTags(dateKey)
        list.push({
          key: `n-${list.length}`,
          n,
          current: false,
          today: false,
          noteCount: (this.notesByDate[dateKey] || []).length,
          tags,
          dateKey
        })
      }
      return list
    },
    kpiList() {
      void this.$i18n.locale
      return [
        {
          key: 'focus',
          label: this.$t('workbench.metricFocus'),
          value: this.projects.length,
          sparkSrc: this.buildSparkSrc([36, 48, 42, 58, 64, 72, 70], '#00a8e8')
        },
        {
          key: 'todo',
          label: this.$t('workbench.metricTodo'),
          value: this.todos.length,
          sparkSrc: this.buildSparkSrc([28, 40, 52, 44, 60, 55, 68], '#0ea5e9')
        },
        {
          key: 'note',
          label: this.$t('workbench.metricNote'),
          value: this.notes.length,
          sparkSrc: this.buildSparkSrc([22, 30, 26, 38, 45, 40, 52], '#38bdf8')
        }
      ]
    },
    quickNav() {
      void this.$i18n.locale
      if (this.remoteQuickNav && this.remoteQuickNav.length) {
        return this.remoteQuickNav
      }
      return [
        {
          name: this.$t('workbench.userManage'),
          path: '/pages/sys/user/index',
          icon: '/static/icons/user.svg'
        },
        {
          name: this.$t('workbench.myMsg'),
          path: '/pages/message/inbox',
          icon: '/static/icons/msg.svg'
        },
        {
          name: this.$t('workbench.assistant'),
          path: '/pages/assistant/chat',
          icon: '/static/mascot/xiaobing-head.png'
        },
        {
          name: this.$t('workbench.profile'),
          path: '/pages/usercenter/userinfo/userinfo',
          icon: '/static/icons/profile.svg'
        }
      ]
    },
    projects() {
      void this.$i18n.locale
      return [
        {
          id: 1,
          title: this.$t('workbench.project1Title'),
          desc: this.$t('workbench.project1Desc'),
          percent: 72,
          daysLeft: 3,
          tone: 'blue',
          path: '/pages/sys/role/index'
        },
        {
          id: 2,
          title: this.$t('workbench.project2Title'),
          desc: this.$t('workbench.project2Desc'),
          percent: 58,
          daysLeft: 5,
          tone: 'teal',
          path: '/pages/message/inbox'
        },
        {
          id: 3,
          title: this.$t('workbench.project3Title'),
          desc: this.$t('workbench.project3Desc'),
          percent: 36,
          daysLeft: 2,
          tone: 'amber',
          path: '/pages/sys/org/index'
        }
      ]
    },
    todos() {
      void this.$i18n.locale
      return [
        {
          id: 1,
          title: this.$t('workbench.todo1'),
          time: this.$t('workbench.timeToday', { t: '10:20' }),
          level: 'high',
          path: '/pages/sys/user/index'
        },
        {
          id: 2,
          title: this.$t('workbench.todo2'),
          time: this.$t('workbench.timeToday', { t: '11:05' }),
          level: 'mid',
          path: '/pages/message/inbox'
        },
        {
          id: 3,
          title: this.$t('workbench.todo3'),
          time: this.$t('workbench.timeYesterday', { t: '16:40' }),
          level: 'mid',
          path: '/pages/sys/org/index'
        },
        {
          id: 4,
          title: this.$t('workbench.todo4'),
          time: this.$t('workbench.timeYesterday', { t: '09:15' }),
          level: 'low',
          path: '/pages/usercenter/userinfo/userinfo'
        }
      ]
    }
  },
  onLoad() {
    try {
      this.statusBarPx = uni.getSystemInfoSync().statusBarHeight || 20
    } catch (e) {
      this.statusBarPx = 20
    }
  },
  onShow() {
    try {
      uni.hideTabBar({ animation: false })
    } catch (e) {
      // ignore
    }
    if (!cache.getToken()) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.loadUser()
    this.fetchNotes()
    this.loadLatestMessages()
    this.loadQuickNav()
    this.$nextTick(() => this.$refs.tabBar && this.$refs.tabBar.init())
  },
  methods: {
    resolveClientType() {
      let clientType = 1
      // #ifdef MP-WEIXIN
      clientType = 2
      // #endif
      return clientType
    },
    async loadQuickNav() {
      try {
        const res = await useMenuNavApi(this.resolveClientType())
        const data = (res && res.data) || res || []
        this.remoteQuickNav = flattenMenuLeaves(Array.isArray(data) ? data : [])
      } catch (e) {
        this.remoteQuickNav = []
      }
    },
    buildSparkSrc(values = [], color = '#00a8e8') {
      const w = 160
      const h = 36
      const n = values.length
      if (!n) return ''
      const max = Math.max(...values, 1)
      const min = Math.min(...values, 0)
      const span = Math.max(max - min, 1)
      const padX = 2
      const pts = values.map((v, i) => {
        const x = n === 1 ? w / 2 : padX + (i / (n - 1)) * (w - padX * 2)
        const y = h - 4 - ((v - min) / span) * (h - 10)
        return [x, y]
      })
      const line = pts.map(([x, y]) => `${x.toFixed(1)},${y.toFixed(1)}`).join(' ')
      const area = `M${padX},${h} L${pts
        .map(([x, y]) => `${x.toFixed(1)},${y.toFixed(1)}`)
        .join(' L')} L${w - padX},${h} Z`
      const last = pts[pts.length - 1]
      const gid = `g${color.replace('#', '')}`
      const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="${w}" height="${h}" preserveAspectRatio="none">
  <defs>
    <linearGradient id="${gid}" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="${color}" stop-opacity="0.32"/>
      <stop offset="100%" stop-color="${color}" stop-opacity="0.02"/>
    </linearGradient>
  </defs>
  <path d="${area}" fill="url(#${gid})"/>
  <polyline points="${line}" fill="none" stroke="${color}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="${last[0].toFixed(1)}" cy="${last[1].toFixed(1)}" r="2.8" fill="#fff" stroke="${color}" stroke-width="1.6"/>
</svg>`
      return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`
    },
    loadUser() {
      const user = cache.getUserInfo() || {}
      const posts = user.postNameList
      this.displayName = user.realName || user.username || this.$t('common.user')
      this.username = user.username || ''
      this.orgName = user.orgName || ''
      this.postName =
        (Array.isArray(posts) && posts.length && posts[0]) || user.postName || ''
      this.avatar = user.avatar || '/static/logo.png'
    },
    weekDayFor(dayIndex) {
      const map = {
        zh: ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'],
        en: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      }
      const loc = String(this.$i18n.locale || '').startsWith('zh') ? 'zh' : 'en'
      return map[loc][dayIndex]
    },
    noteTypeLabel(type) {
      const hit = this.noteTypes.find((t) => t.key === type)
      return hit ? hit.label : this.$t('workbench.typeMemo')
    },
    noteTagShort(type) {
      if (type === 'nudge') return this.$t('workbench.tagNudge')
      if (type === 'remind') return this.$t('workbench.tagRemind')
      return this.$t('workbench.tagMemo')
    },
    buildDayTags(dateKey) {
      const notes = this.notesByDate[dateKey] || []
      const order = ['nudge', 'remind', 'memo']
      const seen = new Set()
      for (const note of notes) {
        seen.add(note.type || 'memo')
      }
      return order
        .filter((type) => seen.has(type))
        .map((type) => ({
          key: type,
          label: this.noteTagShort(type)
        }))
    },
    formatCreatedAt(createTime) {
      if (!createTime) return '--:--'
      const match = String(createTime).match(/(\d{2}):(\d{2})/)
      return match ? `${match[1]}:${match[2]}` : String(createTime).slice(11, 16) || '--:--'
    },
    mapRemoteNote(item) {
      return {
        id: String(item.id),
        dateKey: item.noteDate,
        type: item.noteType || 'memo',
        text: item.content,
        createdAt: this.formatCreatedAt(item.createTime)
      }
    },
    loadLocalNotes() {
      try {
        const raw = uni.getStorageSync(this.storageKey)
        if (!raw) return []
        const parsed = typeof raw === 'string' ? JSON.parse(raw) : raw
        return Array.isArray(parsed) ? parsed : []
      } catch (e) {
        return []
      }
    },
    clearLocalNotes() {
      try {
        uni.removeStorageSync(this.storageKey)
      } catch (e) {
        // ignore
      }
    },
    saveLocalNotes(list) {
      try {
        uni.setStorageSync(this.storageKey, JSON.stringify(list))
      } catch (e) {
        // ignore
      }
    },
    async fetchNotes() {
      const yearMonth = `${this.viewYear}-${pad2(this.viewMonth + 1)}`
      try {
        const res = await useWorkbenchNoteListApi(yearMonth)
        const list = Array.isArray(res?.data) ? res.data : []
        if (list.length) {
          this.notes = list.map((item) => this.mapRemoteNote(item))
          this.clearLocalNotes()
          return
        }
        const allRes = await useWorkbenchNoteListApi()
        const all = Array.isArray(allRes?.data) ? allRes.data : []
        if (all.length) {
          this.notes = all.map((item) => this.mapRemoteNote(item))
          this.clearLocalNotes()
          return
        }
        const local = this.loadLocalNotes()
        if (!local.length) {
          this.notes = []
          return
        }
        const migrated = []
        for (const item of local) {
          try {
            const saved = await useWorkbenchNoteSaveApi({
              noteDate: item.dateKey,
              noteType: item.type,
              content: item.text
            })
            if (saved?.data) migrated.push(this.mapRemoteNote(saved.data))
            else migrated.push(item)
          } catch (e) {
            migrated.push(item)
          }
        }
        this.notes = migrated
        if (migrated.every((n) => /^\d+$/.test(String(n.id)))) this.clearLocalNotes()
      } catch (e) {
        this.notes = this.loadLocalNotes()
        uni.showToast({ title: this.$t('workbench.noteSyncFail'), icon: 'none' })
      }
    },
    async loadLatestMessages() {
      try {
        const res = await useMessageLatestApi(5)
        const list = Array.isArray(res?.data) ? res.data : []
        this.messages = list.map((item) => ({
          id: item.id,
          name: item.senderName || this.$t('workbench.systemNotice'),
          short: String(item.senderName || this.$t('workbench.systemNotice')).slice(0, 1),
          text: item.title || item.content || '',
          time: String(item.sendTime || '').slice(11, 16) || '--:--',
          tone: item.type === 1 ? 'teal' : item.type === 2 ? 'amber' : 'blue'
        }))
      } catch (e) {
        this.messages = []
      }
    },
    pulseAgenda() {
      this.agendaPulse = false
      this.$nextTick(() => {
        this.agendaPulse = true
        clearTimeout(this._agendaPulseTimer)
        this._agendaPulseTimer = setTimeout(() => {
          this.agendaPulse = false
        }, 420)
      })
    },
    ensureSelectionInView() {
      const [sy, sm] = String(this.selectedDateKey || '')
        .split('-')
        .map(Number)
      if (sy === this.viewYear && sm === this.viewMonth + 1) return
      const today = new Date()
      if (today.getFullYear() === this.viewYear && today.getMonth() === this.viewMonth) {
        this.selectedDateKey = toDateKey(today.getFullYear(), today.getMonth(), today.getDate())
      } else {
        this.selectedDateKey = toDateKey(this.viewYear, this.viewMonth, 1)
      }
    },
    shiftMonth(delta) {
      const date = new Date(this.viewYear, this.viewMonth + delta, 1)
      this.viewYear = date.getFullYear()
      this.viewMonth = date.getMonth()
      this.ensureSelectionInView()
      this.pulseAgenda()
      this.fetchNotes()
    },
    goToday() {
      const now = new Date()
      this.now = now
      this.viewYear = now.getFullYear()
      this.viewMonth = now.getMonth()
      this.selectedDateKey = toDateKey(now.getFullYear(), now.getMonth(), now.getDate())
      this.pulseAgenda()
      this.fetchNotes()
    },
    selectDay(day) {
      if (!day || !day.dateKey) return
      if (!day.current) {
        const [y, m] = day.dateKey.split('-').map(Number)
        this.viewYear = y
        this.viewMonth = m - 1
        this.selectedDateKey = day.dateKey
        this.pulseAgenda()
        this.fetchNotes()
        return
      }
      if (this.selectedDateKey === day.dateKey) {
        this.pulseAgenda()
        return
      }
      this.selectedDateKey = day.dateKey
      this.pulseAgenda()
    },
    async addNote() {
      const text = this.draftText.trim()
      if (!text || this.noteSaving) return
      this.noteSaving = true
      try {
        const res = await useWorkbenchNoteSaveApi({
          noteDate: this.selectedDateKey,
          noteType: this.draftType,
          content: text
        })
        if (res?.data) {
          this.notes = [this.mapRemoteNote(res.data), ...this.notes]
        } else {
          await this.fetchNotes()
        }
        this.draftText = ''
        uni.showToast({
          title: this.$t('workbench.noteSaved', { type: this.noteTypeLabel(this.draftType) }),
          icon: 'success'
        })
      } catch (e) {
        uni.showToast({ title: this.$t('workbench.noteSaveFail'), icon: 'none' })
      } finally {
        this.noteSaving = false
      }
    },
    async removeNote(id) {
      const numericId = Number(id)
      if (!Number.isFinite(numericId)) {
        this.notes = this.notes.filter((n) => n.id !== id)
        this.saveLocalNotes(this.notes.filter((n) => String(n.id).startsWith('local-')))
        return
      }
      try {
        await useWorkbenchNoteDeleteApi([numericId])
        this.notes = this.notes.filter((n) => n.id !== id)
        uni.showToast({ title: this.$t('workbench.noteDeleted'), icon: 'success' })
      } catch (e) {
        uni.showToast({ title: this.$t('workbench.noteDeleteFail'), icon: 'none' })
      }
    },
    go(path, tab) {
      if (tab) uni.switchTab({ url: path })
      else uni.navigateTo({ url: path })
    }
  }
}
</script>

<style scoped>
.page {
  position: relative;
  background: #f3f6fa;
  overflow: hidden;
}

.ambient {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
  filter: blur(2px);
  z-index: 0;
}

.ambient.a1 {
  width: 460rpx;
  height: 460rpx;
  top: -140rpx;
  right: -100rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.14), transparent 70%);
}

.ambient.a2 {
  width: 340rpx;
  height: 340rpx;
  top: 260rpx;
  left: -140rpx;
  background: radial-gradient(circle, rgba(15, 23, 42, 0.05), transparent 70%);
}

.top,
.body {
  position: relative;
  z-index: 1;
}

.top {
  padding: 0 28rpx 8rpx;
}

.idcard {
  position: relative;
  overflow: hidden;
  border-radius: 32rpx;
  padding: 24rpx 26rpx 26rpx;
  background:
    linear-gradient(160deg, rgba(232, 247, 253, 0.95) 0%, rgba(255, 255, 255, 0.98) 42%, #ffffff 100%);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 18rpx 44rpx rgba(15, 35, 55, 0.06);
}

.idcard:active {
  opacity: 0.96;
}

.idcard-glow {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
}

.idcard-glow.g1 {
  width: 240rpx;
  height: 240rpx;
  top: -100rpx;
  right: -60rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.16), transparent 70%);
}

.idcard-glow.g2 {
  width: 160rpx;
  height: 160rpx;
  left: -50rpx;
  bottom: -70rpx;
  background: radial-gradient(circle, rgba(125, 211, 252, 0.14), transparent 70%);
}

.idcard-head {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12rpx;
}

.idcard-brand {
  display: flex;
  align-items: baseline;
  min-width: 0;
}

.idcard-ice,
.idcard-jz {
  font-size: 24rpx;
  font-weight: 800;
  letter-spacing: 0.04em;
}

.idcard-ice {
  color: #3d4b5c;
}

.idcard-jz {
  color: #2bb8ef;
}

.idcard-slash {
  margin: 0 8rpx 0 10rpx;
  font-size: 18rpx;
  color: #cbd5e1;
}

.idcard-sub {
  font-size: 16rpx;
  font-weight: 650;
  color: #9aa8b6;
  letter-spacing: 0.14em;
}

.idcard-main {
  position: relative;
  z-index: 1;
  margin-top: 22rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.idcard-foot {
  position: relative;
  z-index: 1;
  margin-top: 20rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid rgba(226, 232, 240, 0.85);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
}

.idcard-foot-left {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.idcard-account {
  font-size: 20rpx;
  color: #64748b;
  font-weight: 620;
  letter-spacing: 0.02em;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.idcard-tip {
  font-size: 20rpx;
  color: #94a3b8;
  font-weight: 520;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.idcard-live {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 8rpx 14rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(226, 232, 240, 0.9);
}

.idcard-live-dot {
  width: 10rpx;
  height: 10rpx;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 0 4rpx rgba(34, 197, 94, 0.14);
}

.idcard-live-t {
  font-size: 18rpx;
  font-weight: 650;
  color: #64748b;
}

.idcard-avatar-wrap {
  position: relative;
  width: 132rpx;
  height: 132rpx;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.idcard-halo {
  position: absolute;
  width: 132rpx;
  height: 132rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.2), transparent 68%);
}

.idcard-ring {
  position: relative;
  z-index: 1;
  width: 114rpx;
  height: 114rpx;
  border-radius: 50%;
  padding: 6rpx;
  background: linear-gradient(145deg, #ffffff, #d9f1fb 55%, #b8e4f7);
  box-shadow:
    0 12rpx 24rpx rgba(0, 140, 200, 0.14),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95);
  box-sizing: border-box;
}

.idcard-avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: #e8f0f5;
  display: block;
}

.idcard-copy {
  flex: 1;
  min-width: 0;
}

.idcard-hello {
  display: block;
  font-size: 22rpx;
  color: #8492a6;
  font-weight: 560;
}

.idcard-name {
  display: block;
  margin-top: 6rpx;
  font-size: 40rpx;
  font-weight: 820;
  color: #0f1b2d;
  letter-spacing: 0.01em;
  line-height: 1.15;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.idcard-meta {
  display: block;
  margin-top: 8rpx;
  font-size: 22rpx;
  color: #8492a6;
  font-weight: 520;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.idcard-date {
  flex-shrink: 0;
  align-self: center;
  text-align: right;
  padding: 10rpx 14rpx;
  border-radius: 16rpx;
  background: rgba(255, 255, 255, 0.88);
  border: 1rpx solid rgba(226, 232, 240, 0.85);
}

.idcard-week {
  display: block;
  font-size: 16rpx;
  color: #94a3b8;
  font-weight: 600;
}

.idcard-day {
  display: block;
  margin-top: 2rpx;
  font-size: 22rpx;
  color: #0f1b2d;
  font-weight: 750;
}

.body {
  padding: 12rpx 24rpx 28rpx;
}

.kpi-row {
  display: flex;
  gap: 12rpx;
}

.kpi-card {
  flex: 1;
  padding: 22rpx 16rpx 18rpx;
  border-radius: 24rpx;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 32rpx rgba(15, 35, 55, 0.06);
}

.kpi-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8rpx;
}

.kpi-lab {
  font-size: 20rpx;
  color: #8492a6;
  font-weight: 600;
}

.kpi-trend {
  flex-shrink: 0;
  font-size: 18rpx;
  color: #00a8e8;
  font-weight: 700;
  padding: 4rpx 10rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.1);
}

.kpi-num {
  display: block;
  margin-top: 10rpx;
  font-size: 44rpx;
  font-weight: 800;
  color: #0f1b2d;
  line-height: 1;
  letter-spacing: -0.02em;
}

.kpi-foot {
  margin-top: 14rpx;
  width: 100%;
}

.spark-img {
  display: block;
  width: 100%;
  height: 44rpx;
}

.suggest {
  margin-top: 16rpx;
  padding: 22rpx 20rpx;
  border-radius: 26rpx;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.96), rgba(232, 246, 253, 0.95));
  border: 1rpx solid rgba(0, 168, 232, 0.12);
  box-shadow: 0 14rpx 32rpx rgba(0, 120, 180, 0.08);
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.suggest-ico {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 18rpx rgba(0, 168, 232, 0.14);
  flex-shrink: 0;
}

.suggest-img {
  width: 44rpx;
  height: 44rpx;
}

.suggest-copy {
  flex: 1;
  min-width: 0;
}

.suggest-title {
  display: block;
  font-size: 26rpx;
  font-weight: 800;
  color: #0f1b2d;
}

.suggest-body {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #8492a6;
  line-height: 1.45;
}

.suggest-go {
  flex-shrink: 0;
  font-size: 20rpx;
  font-weight: 750;
  color: #00a8e8;
}

.card {
  margin-top: 16rpx;
  padding: 26rpx 22rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.card-head {
  margin-bottom: 18rpx;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12rpx;
}

.sec-title {
  display: block;
  font-size: 30rpx;
  font-weight: 800;
  color: #0f1b2d;
}

.sec-sub {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #8492a6;
  line-height: 1.4;
}

.chip {
  flex-shrink: 0;
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.1);
  color: #0284c7;
  font-size: 20rpx;
  font-weight: 700;
}

.chip.soft {
  background: #eef3f7;
  color: #64748b;
}

.quick-grid {
  margin-top: 18rpx;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8rpx;
}

.quick-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
}

.quick-orb {
  width: 92rpx;
  height: 92rpx;
  border-radius: 50%;
  background: linear-gradient(160deg, #eaf7fd, #dff2fb);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow:
    0 10rpx 22rpx rgba(0, 140, 200, 0.1),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.85);
}

.quick-img {
  width: 40rpx;
  height: 40rpx;
}

.quick-name {
  font-size: 22rpx;
  color: #0f1b2d;
  font-weight: 650;
}

.project-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.project-row {
  display: flex;
  align-items: center;
  gap: 14rpx;
  padding: 20rpx 18rpx;
  border-radius: 22rpx;
  background: #f7fafc;
  border: 1rpx solid #e9eef4;
}

.project-row.tone-blue {
  background: linear-gradient(180deg, #f4fbfe, #f7fafc);
}

.project-row.tone-teal {
  background: linear-gradient(180deg, #f3fbfa, #f7fafc);
}

.project-row.tone-amber {
  background: linear-gradient(180deg, #fffaf3, #f7fafc);
}

.project-main {
  flex: 1;
  min-width: 0;
}

.project-title {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 12rpx;
}

.project-name {
  font-size: 28rpx;
  font-weight: 750;
  color: #0f1b2d;
}

.project-days {
  font-size: 20rpx;
  color: #8492a6;
  font-weight: 600;
}

.project-desc {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #8492a6;
}

.progress {
  margin-top: 14rpx;
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.track {
  flex: 1;
  height: 10rpx;
  border-radius: 999rpx;
  background: rgba(148, 163, 184, 0.18);
  overflow: hidden;
}

.fill {
  height: 100%;
  border-radius: 999rpx;
  background: linear-gradient(90deg, #00a8e8, #67d4f8);
}

.fill-blue {
  background: linear-gradient(90deg, #00a8e8, #67d4f8);
}

.fill-teal {
  background: linear-gradient(90deg, #14b8a6, #5eead4);
}

.fill-amber {
  background: linear-gradient(90deg, #f59e0b, #fcd34d);
}

.pct {
  font-size: 20rpx;
  color: #64748b;
  font-weight: 750;
  min-width: 64rpx;
  text-align: right;
}

.btn-enter {
  flex-shrink: 0;
  padding: 14rpx 22rpx;
  border-radius: 999rpx;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  color: #fff;
  font-size: 22rpx;
  font-weight: 750;
  box-shadow: 0 10rpx 20rpx rgba(0, 168, 232, 0.24);
}



.cal-panel {
  margin-top: 16rpx;
  border-radius: 28rpx;
  overflow: hidden;
  background: #ffffff;
  border: 1rpx solid rgba(214, 228, 238, 0.85);
  box-shadow: 0 12rpx 32rpx rgba(36, 74, 98, 0.05);
}

.cal-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
  padding: 24rpx 24rpx 8rpx;
  background: linear-gradient(180deg, #f3f9fc 0%, #ffffff 100%);
}

.cal-head-copy {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
  min-width: 0;
}

.cal-year {
  font-size: 22rpx;
  color: #8aa0b2;
  font-weight: 620;
}

.cal-month {
  font-size: 36rpx;
  color: #173247;
  font-weight: 800;
  line-height: 1;
}

.cal-nav {
  display: flex;
  align-items: center;
  flex-shrink: 0;
  padding: 4rpx;
  border-radius: 16rpx;
  background: rgba(232, 242, 248, 0.9);
}

.cal-nav-btn {
  width: 52rpx;
  height: 52rpx;
  border-radius: 14rpx;
  color: #3d5568;
  font-size: 28rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cal-nav-btn:active {
  background: rgba(255, 255, 255, 0.85);
}

.cal-nav-mid {
  min-width: 88rpx;
  height: 52rpx;
  margin: 0 2rpx;
  padding: 0 16rpx;
  border-radius: 14rpx;
  background: #ffffff;
  color: #1f8fbd;
  font-size: 22rpx;
  font-weight: 720;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4rpx 10rpx rgba(36, 74, 98, 0.05);
}

.cal-sheet {
  padding: 8rpx 16rpx 12rpx;
}

.cal-week,
.cal-days {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 6rpx;
}

.cal-w {
  text-align: center;
  font-size: 20rpx;
  color: #8aa0b2;
  font-weight: 650;
  padding: 6rpx 0 10rpx;
}

.cal-day {
  min-height: 88rpx;
  padding: 8rpx 2rpx 10rpx;
  border-radius: 18rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  box-sizing: border-box;
  background: #f5f9fc;
}

.cal-day-n {
  font-size: 24rpx;
  color: #173247;
  font-weight: 680;
  line-height: 1.2;
}

.cal-day-tags {
  margin-top: 6rpx;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 4rpx;
  max-width: 100%;
}

.cal-tag {
  height: 24rpx;
  padding: 0 7rpx 0 5rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  gap: 4rpx;
  box-sizing: border-box;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(138, 160, 178, 0.22);
  box-shadow: 0 2rpx 6rpx rgba(36, 74, 98, 0.04);
}

.cal-tag-dot {
  width: 6rpx;
  height: 6rpx;
  border-radius: 50%;
  flex-shrink: 0;
  background: #8aa0b2;
}

.cal-tag-t {
  font-size: 15rpx;
  font-weight: 740;
  line-height: 1;
  color: #5b7386;
}

.cal-tag[data-type='nudge'] {
  background: rgba(223, 242, 251, 0.95);
  border-color: rgba(31, 143, 189, 0.18);
}

.cal-tag[data-type='nudge'] .cal-tag-dot {
  background: #2bb8ef;
}

.cal-tag[data-type='nudge'] .cal-tag-t {
  color: #1a86b3;
}

.cal-tag[data-type='memo'] {
  background: rgba(240, 244, 247, 0.96);
  border-color: rgba(91, 115, 134, 0.16);
}

.cal-tag[data-type='memo'] .cal-tag-dot {
  background: #8aa0b2;
}

.cal-tag[data-type='memo'] .cal-tag-t {
  color: #5b7386;
}

.cal-tag[data-type='remind'] {
  background: rgba(228, 246, 243, 0.96);
  border-color: rgba(47, 154, 143, 0.18);
}

.cal-tag[data-type='remind'] .cal-tag-dot {
  background: #4db5aa;
}

.cal-tag[data-type='remind'] .cal-tag-t {
  color: #2a8f85;
}

.cal-day.mute {
  background: transparent;
  opacity: 0.28;
}

.cal-day.today {
  background: #eaf6fc;
  box-shadow: inset 0 0 0 1rpx rgba(43, 184, 239, 0.28);
}

.cal-day.today .cal-day-n {
  color: #1f8fbd;
  font-weight: 780;
}

.cal-day.active {
  background: #d8effa;
  box-shadow: inset 0 0 0 2rpx rgba(43, 184, 239, 0.55);
}

.cal-day.active .cal-day-n {
  color: #0f6f96;
  font-weight: 820;
}

.cal-day.active .cal-tag {
  background: rgba(255, 255, 255, 0.95);
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: none;
}

.cal-picked {
  margin: 4rpx 20rpx 0;
  padding: 18rpx;
  border-radius: 22rpx;
  background: #f0f7fb;
  display: flex;
  align-items: center;
  gap: 16rpx;
  transition: background 0.3s ease;
}

.cal-picked.pulse {
  background: #e5f3fa;
}

.picked-day {
  width: 72rpx;
  height: 72rpx;
  border-radius: 20rpx;
  background: #ffffff;
  box-shadow: 0 6rpx 16rpx rgba(36, 74, 98, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.picked-n {
  font-size: 34rpx;
  font-weight: 820;
  color: #1f8fbd;
  line-height: 1;
}

.picked-copy {
  flex: 1;
  min-width: 0;
}

.picked-title {
  display: block;
  font-size: 26rpx;
  font-weight: 760;
  color: #173247;
}

.picked-meta-row {
  margin-top: 8rpx;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8rpx;
}

.picked-meta {
  font-size: 20rpx;
  color: #6f8496;
  font-weight: 600;
}

.picked-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.picked-tag {
  height: 36rpx;
  padding: 0 14rpx 0 10rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;
  box-sizing: border-box;
  background: #ffffff;
  border: 1rpx solid rgba(138, 160, 178, 0.16);
  box-shadow: 0 3rpx 10rpx rgba(36, 74, 98, 0.04);
}

.picked-tag-dot {
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  flex-shrink: 0;
  background: #8aa0b2;
}

.picked-tag-t {
  font-size: 18rpx;
  font-weight: 700;
  line-height: 1;
  color: #5b7386;
}

.picked-tag[data-type='nudge'] {
  background: #edf8fd;
  border-color: rgba(31, 143, 189, 0.16);
}

.picked-tag[data-type='nudge'] .picked-tag-dot {
  background: #2bb8ef;
}

.picked-tag[data-type='nudge'] .picked-tag-t {
  color: #1a86b3;
}

.picked-tag[data-type='memo'] {
  background: #f4f7f9;
  border-color: rgba(91, 115, 134, 0.14);
}

.picked-tag[data-type='memo'] .picked-tag-dot {
  background: #8aa0b2;
}

.picked-tag[data-type='memo'] .picked-tag-t {
  color: #5b7386;
}

.picked-tag[data-type='remind'] {
  background: #eef9f7;
  border-color: rgba(47, 154, 143, 0.16);
}

.picked-tag[data-type='remind'] .picked-tag-dot {
  background: #4db5aa;
}

.picked-tag[data-type='remind'] .picked-tag-t {
  color: #2a8f85;
}

.cal-agenda {
  padding: 18rpx 24rpx 22rpx;
  background: #ffffff;
}

.note-seg {
  display: flex;
  margin-bottom: 16rpx;
  padding: 6rpx;
  border-radius: 16rpx;
  background: #f0f5f8;
}

.note-seg-item {
  flex: 1;
  height: 60rpx;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22rpx;
  font-weight: 650;
  color: #6f8496;
}

.note-seg-item.active {
  background: #ffffff;
  color: #1f8fbd;
  box-shadow: 0 4rpx 12rpx rgba(36, 74, 98, 0.05);
}

.note-list {
  display: flex;
  flex-direction: column;
}

.note-item {
  display: flex;
  align-items: flex-start;
  gap: 14rpx;
  padding: 18rpx 0;
  border-bottom: 1rpx solid #edf2f6;
}

.note-item:last-child {
  border-bottom: none;
}

.note-mark {
  width: 12rpx;
  height: 12rpx;
  margin-top: 10rpx;
  border-radius: 50%;
  background: #3eb5e4;
  flex-shrink: 0;
  box-shadow: 0 0 0 5rpx rgba(62, 181, 228, 0.14);
}

.note-item[data-type='remind'] .note-mark {
  background: #4db5aa;
  box-shadow: 0 0 0 5rpx rgba(77, 181, 170, 0.14);
}

.note-item[data-type='memo'] .note-mark {
  background: #8aa0b2;
  box-shadow: 0 0 0 5rpx rgba(138, 160, 178, 0.14);
}

.note-body {
  flex: 1;
  min-width: 0;
}

.note-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10rpx;
  margin-bottom: 6rpx;
}

.note-tag {
  height: 34rpx;
  padding: 0 12rpx 0 10rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;
  box-sizing: border-box;
  background: #edf8fd;
  border: 1rpx solid rgba(31, 143, 189, 0.14);
}

.note-tag-dot {
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  flex-shrink: 0;
  background: #2bb8ef;
}

.note-tag-t {
  font-size: 18rpx;
  font-weight: 700;
  line-height: 1;
  color: #1a86b3;
}

.note-tag[data-type='memo'] {
  background: #f4f7f9;
  border-color: rgba(91, 115, 134, 0.14);
}

.note-tag[data-type='memo'] .note-tag-dot {
  background: #8aa0b2;
}

.note-tag[data-type='memo'] .note-tag-t {
  color: #5b7386;
}

.note-tag[data-type='remind'] {
  background: #eef9f7;
  border-color: rgba(47, 154, 143, 0.14);
}

.note-tag[data-type='remind'] .note-tag-dot {
  background: #4db5aa;
}

.note-tag[data-type='remind'] .note-tag-t {
  color: #2a8f85;
}

.note-text {
  display: block;
  font-size: 26rpx;
  color: #173247;
  line-height: 1.5;
}

.note-time {
  font-size: 20rpx;
  color: #8aa0b2;
  font-weight: 560;
}

.note-del {
  flex-shrink: 0;
  margin-top: 4rpx;
  font-size: 22rpx;
  color: #8aa0b2;
  font-weight: 620;
}

.note-empty {
  padding: 28rpx 8rpx 12rpx;
}

.empty-text {
  font-size: 24rpx;
  color: #8aa0b2;
  line-height: 1.55;
}

.note-composer {
  margin-top: 12rpx;
  padding: 16rpx;
  border-radius: 20rpx;
  background: #f5f9fc;
}

.note-input {
  width: 100%;
  min-height: 120rpx;
  box-sizing: border-box;
  font-size: 24rpx;
  color: #173247;
}

.composer-foot {
  margin-top: 10rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
}

.counter {
  font-size: 20rpx;
  color: #8aa0b2;
}

.btn-primary {
  padding: 14rpx 28rpx;
  border-radius: 999rpx;
  background: linear-gradient(145deg, #2bb8ef, #4ec6f3);
  color: #fff;
  font-size: 24rpx;
  font-weight: 750;
  box-shadow: 0 10rpx 20rpx rgba(43, 184, 239, 0.22);
}

.btn-primary.disabled {
  opacity: 0.45;
  box-shadow: none;
}

.todo-list {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.todo-row {
  display: flex;
  align-items: center;
  gap: 14rpx;
  padding: 18rpx 16rpx;
  border-radius: 20rpx;
  background: #f7fafc;
}

.check {
  width: 28rpx;
  height: 28rpx;
  border-radius: 50%;
  border: 3rpx solid #cbd5e1;
  flex-shrink: 0;
  box-sizing: border-box;
}

.check[data-level='high'] {
  border-color: #fb7185;
  background: rgba(251, 113, 133, 0.12);
}

.check[data-level='mid'] {
  border-color: #fbbf24;
  background: rgba(251, 191, 36, 0.14);
}

.check[data-level='low'] {
  border-color: #00a8e8;
  background: rgba(0, 168, 232, 0.1);
}

.todo-body {
  flex: 1;
  min-width: 0;
}

.todo-title {
  display: block;
  font-size: 26rpx;
  font-weight: 700;
  color: #0f1b2d;
}

.todo-time {
  display: block;
  margin-top: 4rpx;
  font-size: 20rpx;
  color: #94a3b8;
}

.todo-go {
  flex-shrink: 0;
  padding: 12rpx 18rpx;
  border-radius: 999rpx;
  background: #fff;
  color: #0284c7;
  font-size: 22rpx;
  font-weight: 750;
  border: 1rpx solid rgba(0, 168, 232, 0.18);
}

.link-btn {
  font-size: 22rpx;
  color: #00a8e8;
  font-weight: 750;
  padding-top: 6rpx;
}

.msg-list {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.msg-row {
  display: flex;
  align-items: center;
  gap: 14rpx;
  padding: 16rpx;
  border-radius: 20rpx;
  background: #f7fafc;
}

.msg-mark {
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 24rpx;
  font-weight: 800;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  flex-shrink: 0;
}

.msg-mark.tone-teal {
  background: linear-gradient(145deg, #14b8a6, #2dd4bf);
}

.msg-mark.tone-amber {
  background: linear-gradient(145deg, #f59e0b, #fbbf24);
}

.msg-body {
  flex: 1;
  min-width: 0;
}

.msg-name {
  display: block;
  font-size: 26rpx;
  font-weight: 750;
  color: #0f1b2d;
}

.msg-text {
  display: block;
  margin-top: 4rpx;
  font-size: 22rpx;
  color: #8492a6;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.msg-time {
  flex-shrink: 0;
  font-size: 20rpx;
  color: #94a3b8;
}

.msg-empty {
  padding: 36rpx 0 8rpx;
  text-align: center;
  font-size: 24rpx;
  color: #94a3b8;
}
</style>
