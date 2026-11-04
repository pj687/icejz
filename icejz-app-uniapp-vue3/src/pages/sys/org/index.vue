<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('sys.orgTitle')" :sub="$t('sys.orgSub')" />

    <view class="body">
      <view v-if="loading" class="empty">
        <view class="empty-mark">···</view>
        <view class="empty-title">{{ $t('sys.loadingOrg') }}</view>
      </view>
      <view v-else-if="!flatList.length" class="empty">
        <view class="empty-mark">机</view>
        <view class="empty-title">{{ $t('sys.emptyOrg') }}</view>
      </view>

      <view v-if="flatList.length" class="tree">
        <view class="tree-head">
          <text class="tree-count">共 {{ flatList.length }} 个节点</text>
          <view class="tree-actions">
            <text class="tree-action" @click="expandAll">{{ $t('sys.expandAll') }}</text>
            <text class="tree-sep">|</text>
            <text class="tree-action" @click="collapseAll">{{ $t('sys.collapseAll') }}</text>
          </view>
        </view>
        <view
          v-for="item in visibleList"
          :key="item.id"
          class="node"
          :class="[
            'lv-' + Math.min(item._level, 2),
            { root: item._level === 0, foldable: item._hasChildren, leaf: !item._hasChildren }
          ]"
          :style="{ paddingLeft: 24 + item._level * 36 + 'rpx' }"
          @click="onToggle(item)"
        >
          <view v-if="item._level > 0" class="guide">
            <view class="guide-v" />
            <view class="guide-h" />
          </view>
          <view class="node-icon" :class="'tone-' + Math.min(item._level, 2)">
            {{ item._level === 0 ? '组' : '机' }}
          </view>
          <view class="node-main">
            <view class="node-name">{{ item.name }}</view>
            <view class="node-meta">
              <text class="pill">L{{ item._level + 1 }}</text>
              <text v-if="item._hasChildren">{{ item._childCount }} 个子机构</text>
              <text v-else>{{ item.parentName || $t('sys.topOrg') }}</text>
              <text class="dot">·</text>
              <text>{{ $t('sys.sort') }} {{ item.sort }}</text>
            </view>
          </view>
          <view v-if="item._hasChildren" class="caret" :class="{ open: expanded[item.id] }">›</view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import { useOrgListApi } from '@/api/sys.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'

export default {
  components: { IceNavBar },
  data() {
    return {
      loading: false,
      flatList: [],
      expanded: {}
    }
  },
  computed: {
    visibleList() {
      const expanded = this.expanded || {}
      const visible = []
      const openAncestors = { null: true, undefined: true }
      this.flatList.forEach((item) => {
        if (!openAncestors[item.parentId]) return
        visible.push(item)
        openAncestors[item.id] = !!expanded[item.id]
      })
      return visible
    }
  },
  onShow() {
    if (!cache.getToken()) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.loadData()
  },
  methods: {
    async loadData() {
      this.loading = true
      try {
        const { data } = await useOrgListApi()
        const flatList = this.flattenTree(data || [])
        const expanded = {}
        flatList.forEach((item) => {
          if (item._hasChildren) expanded[item.id] = true
        })
        this.flatList = flatList
        this.expanded = expanded
      } catch (e) {
        this.flatList = []
        this.expanded = {}
        uni.showToast({
          title: (e && e.msg) || this.$t('sys.emptyOrg'),
          icon: 'none'
        })
      } finally {
        this.loading = false
      }
    },
    flattenTree(nodes, level = 0, parentId = null, parentName = '') {
      const result = []
      const list = nodes || []
      list.forEach((node, index) => {
        const children = node.children || []
        const hasChildren = children.length > 0
        result.push({
          id: node.id,
          name: node.name,
          sort: node.sort,
          parentName,
          parentId,
          _level: level,
          _last: index === list.length - 1,
          _hasChildren: hasChildren,
          _childCount: children.length
        })
        if (hasChildren) {
          result.push(...this.flattenTree(children, level + 1, node.id, node.name))
        }
      })
      return result
    },
    onToggle(item) {
      if (!item || !item._hasChildren) return
      this.expanded = {
        ...this.expanded,
        [item.id]: !this.expanded[item.id]
      }
    },
    expandAll() {
      const expanded = {}
      this.flatList.forEach((item) => {
        if (item._hasChildren) expanded[item.id] = true
      })
      this.expanded = expanded
    },
    collapseAll() {
      this.expanded = {}
    }
  }
}
</script>

<style scoped>
.page {
  min-height: 100vh;
  box-sizing: border-box;
}

.body {
  padding: 8rpx 28rpx 48rpx;
}

.empty {
  margin-top: 48rpx;
  padding: 48rpx 24rpx;
  text-align: center;
}

.empty-mark {
  width: 80rpx;
  height: 80rpx;
  margin: 0 auto 16rpx;
  border-radius: 24rpx;
  background: rgba(0, 168, 232, 0.12);
  color: #00a8e8;
  font-size: 32rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #0f1724;
}

.tree {
  margin-top: 8rpx;
  padding: 8rpx 8rpx 16rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.tree-head {
  padding: 16rpx 20rpx 10rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12rpx;
}

.tree-count {
  font-size: 22rpx;
  color: #8492a6;
}

.tree-actions {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.tree-action {
  font-size: 22rpx;
  font-weight: 650;
  color: #00a8e8;
  padding: 4rpx 0;
}

.tree-sep {
  font-size: 20rpx;
  color: #c5ced6;
}

.node {
  position: relative;
  display: flex;
  align-items: center;
  gap: 18rpx;
  min-height: 108rpx;
  margin: 10rpx 8rpx 0;
  padding-top: 18rpx;
  padding-right: 16rpx;
  padding-bottom: 18rpx;
  border-radius: 22rpx;
  background: #f7fafc;
  box-sizing: border-box;
}

.node.foldable:active {
  opacity: 0.88;
}

.node.root {
  background: linear-gradient(135deg, #eef9fe, #e3f4fb);
  border: 1rpx solid rgba(0, 168, 232, 0.14);
}

.guide {
  position: absolute;
  left: 18rpx;
  top: 0;
  bottom: 50%;
  width: 28rpx;
  pointer-events: none;
}

.guide-v {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 2rpx;
  background: rgba(0, 168, 232, 0.28);
}

.guide-h {
  position: absolute;
  left: 0;
  bottom: 0;
  width: 22rpx;
  height: 2rpx;
  background: rgba(0, 168, 232, 0.28);
}

.node-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 18rpx;
  background: #dff2fb;
  color: #0284c7;
  font-size: 24rpx;
  font-weight: 740;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.node-icon.tone-0 {
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  color: #fff;
  box-shadow: 0 8rpx 18rpx rgba(0, 168, 232, 0.24);
}

.node-icon.tone-1 {
  background: #dff2fb;
  color: #0284c7;
}

.node-icon.tone-2 {
  background: #eef2f7;
  color: #5b6b7c;
}

.node-main {
  flex: 1;
  min-width: 0;
}

.node-name {
  font-size: 28rpx;
  font-weight: 700;
  color: #111827;
  letter-spacing: 0.2rpx;
  word-break: break-word;
}

.node-meta {
  margin-top: 8rpx;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8rpx;
  font-size: 22rpx;
  color: #64748b;
}

/* L1 顶级：字号最大、字重最重 */
.node.lv-0 .node-name {
  font-size: 32rpx;
  font-weight: 780;
  color: #0b1220;
  letter-spacing: 0.4rpx;
}

.node.lv-0 .node-meta {
  font-size: 22rpx;
  color: #5b7a8c;
}

.node.lv-0 .pill {
  background: rgba(0, 168, 232, 0.16);
  color: #0284c7;
  font-size: 18rpx;
}

/* L2 中间层：中等字号、半粗 */
.node.lv-1 .node-name {
  font-size: 28rpx;
  font-weight: 680;
  color: #1e293b;
}

.node.lv-1 .node-meta {
  font-size: 21rpx;
  color: #64748b;
}

/* L3+ 末级：更小、更轻、略灰 */
.node.lv-2 .node-name {
  font-size: 26rpx;
  font-weight: 560;
  color: #475569;
  letter-spacing: 0;
}

.node.lv-2 .node-meta {
  font-size: 20rpx;
  color: #94a3b8;
}

.node.lv-2 .pill {
  background: #eef2f7;
  color: #64748b;
  font-weight: 620;
}

/* 叶子节点再轻一档，和可展开父节点区分 */
.node.leaf .node-name {
  font-weight: 520;
}

.node.lv-0.leaf .node-name {
  font-weight: 720;
}

.pill {
  padding: 2rpx 10rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.1);
  color: #00a8e8;
  font-size: 18rpx;
  font-weight: 720;
}

.dot {
  opacity: 0.5;
}

.caret {
  flex-shrink: 0;
  width: 44rpx;
  height: 44rpx;
  border-radius: 14rpx;
  background: rgba(0, 168, 232, 0.1);
  color: #00a8e8;
  font-size: 32rpx;
  font-weight: 700;
  line-height: 44rpx;
  text-align: center;
  transform: rotate(0deg);
  transition: transform 0.2s ease;
}

.caret.open {
  transform: rotate(90deg);
}
</style>
