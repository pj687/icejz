<template>
	<div class="org-auth-page monitor-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>运维中心</span>
				<h2>缓存监控</h2>
				<p>查看 Redis 运行状态、内存占用与命令统计</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip">v{{ data.info.redis_version || '—' }}</span>
				<span class="hero-chip">{{ data.info.redis_mode == 'standalone' ? '单机' : '集群' }}</span>
				<span class="hero-chip"><em>{{ data.keyCount || 0 }}</em> Keys</span>
			</div>
		</section>

		<div class="monitor-metric-grid">
			<article class="monitor-metric-card">
				<header>
					<strong>已用内存</strong>
				</header>
				<div class="metric-main">
					<span class="metric-value metric-text">{{ data.info.used_memory_human || '—' }}</span>
					<span class="metric-label">当前占用</span>
				</div>
				<ul class="metric-list">
					<li><span>最大内存</span><b>{{ data.info.maxmemory_human || '—' }}</b></li>
					<li><span>使用 CPU</span><b>{{ data.info.used_cpu_user_children }}%</b></li>
				</ul>
			</article>

			<article class="monitor-metric-card">
				<header>
					<strong>连接与运行</strong>
				</header>
				<div class="metric-main">
					<span class="metric-value">{{ data.info.connected_clients || 0 }}</span>
					<span class="metric-label">客户端连接</span>
				</div>
				<ul class="metric-list">
					<li><span>端口</span><b>{{ data.info.tcp_port }}</b></li>
					<li><span>运行天数</span><b>{{ data.info.uptime_in_days }}</b></li>
					<li><span>Key 数量</span><b>{{ data.keyCount }}</b></li>
				</ul>
			</article>

			<article class="monitor-metric-card">
				<header>
					<strong>持久化与网络</strong>
				</header>
				<div class="metric-main">
					<span class="metric-value metric-text">{{ data.info.aof_enabled === 0 ? 'AOF 关' : 'AOF 开' }}</span>
					<span class="metric-label">持久化状态</span>
				</div>
				<ul class="metric-list">
					<li><span>RDB 状态</span><b>{{ data.info.rdb_last_bgsave_status }}</b></li>
					<li><span>入口 / 出口</span><b>{{ data.info.instantaneous_input_kbps }} / {{ data.info.instantaneous_output_kbps }} kps</b></li>
				</ul>
			</article>
		</div>

		<el-card class="org-auth-card page-card" shadow="never">
			<div class="org-auth-toolbar">
				<strong class="section-title">基本信息</strong>
			</div>
			<el-descriptions :column="3" border class="monitor-desc">
				<el-descriptions-item label="Redis 版本">{{ data.info.redis_version }}</el-descriptions-item>
				<el-descriptions-item label="运行模式">{{ data.info.redis_mode == 'standalone' ? '单机' : '集群' }}</el-descriptions-item>
				<el-descriptions-item label="端口">{{ data.info.tcp_port }}</el-descriptions-item>
				<el-descriptions-item label="客户端">{{ data.info.connected_clients }}</el-descriptions-item>
				<el-descriptions-item label="运行时间（天）">{{ data.info.uptime_in_days }}</el-descriptions-item>
				<el-descriptions-item label="Key 数量">{{ data.keyCount }}</el-descriptions-item>
				<el-descriptions-item label="最大内存配置">{{ data.info.maxmemory_human }}</el-descriptions-item>
				<el-descriptions-item label="使用 CPU">{{ data.info.used_cpu_user_children }}%</el-descriptions-item>
				<el-descriptions-item label="已用内存">{{ data.info.used_memory_human }}</el-descriptions-item>
				<el-descriptions-item label="AOF 是否开启">{{ data.info.aof_enabled === 0 ? '否' : '是' }}</el-descriptions-item>
				<el-descriptions-item label="RDB 是否成功">{{ data.info.rdb_last_bgsave_status }}</el-descriptions-item>
				<el-descriptions-item label="网络入口/出口">
					{{ data.info.instantaneous_input_kbps }}kps / {{ data.info.instantaneous_output_kbps }}kps
				</el-descriptions-item>
			</el-descriptions>
		</el-card>

		<el-card class="org-auth-card page-card" shadow="never">
			<div class="org-auth-toolbar">
				<strong class="section-title">命令统计</strong>
			</div>
			<el-table :data="data.commandStats" class="layout-table" show-overflow-tooltip>
				<el-table-column prop="name" label="命令" min-width="160">
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.name }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="value" label="调用次数" min-width="140">
					<template #default="scope">
						<span class="cmd-value">{{ scope.row.value }}</span>
					</template>
				</el-table-column>
			</el-table>
		</el-card>
	</div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useCacheInfoApi } from '@/api/monitor/cache'

const data = ref({
	info: {
		redis_version: '',
		redis_mode: 'standalone',
		tcp_port: 6379,
		connected_clients: 1,
		uptime_in_days: 0,
		used_memory_human: 0 as any,
		used_cpu_user_children: 0,
		maxmemory_human: 0 as any,
		aof_enabled: 0,
		rdb_last_bgsave_status: '0',
		instantaneous_input_kbps: '0.00',
		instantaneous_output_kbps: '0.00'
	},
	keyCount: 0,
	commandStats: [] as any[]
})

onMounted(() => {
	getCacheInfo()
})

const getCacheInfo = () => {
	useCacheInfoApi().then(res => {
		data.value = res.data
	})
}
</script>

<style scoped lang="scss">
.cmd-value {
	font-variant-numeric: tabular-nums;
	font-weight: 650;
	color: #334155;
}
</style>
