<template>
	<div class="org-auth-page monitor-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>运维中心</span>
				<h2>服务监控</h2>
				<p>实时查看 CPU、内存、JVM、系统与磁盘资源</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip">{{ data.sys.computerName || '主机' }}</span>
				<span class="hero-chip">{{ data.sys.osName || '系统' }}</span>
				<span class="hero-chip"><em>{{ data.cpu.cpuNum || 0 }}</em>核</span>
			</div>
		</section>

		<div class="monitor-metric-grid">
			<article class="monitor-metric-card">
				<header>
					<strong>CPU</strong>
					<el-button :icon="Refresh" size="small" circle @click="refreshCpuInfo" />
				</header>
				<div class="metric-main">
					<span class="metric-value">{{ data.cpu.used }}<small>%</small></span>
					<span class="metric-label">用户使用率</span>
				</div>
				<el-progress :percentage="Number(data.cpu.used) || 0" :stroke-width="8" :show-text="false" color="#00a8e8" />
				<ul class="metric-list">
					<li><span>型号</span><b>{{ data.cpu.cpuModel || '—' }}</b></li>
					<li><span>核心数</span><b>{{ data.cpu.cpuNum }}</b></li>
					<li><span>系统使用率</span><b>{{ data.cpu.sys }}%</b></li>
					<li><span>空闲率</span><b>{{ data.cpu.free }}%</b></li>
				</ul>
			</article>

			<article class="monitor-metric-card">
				<header>
					<strong>系统内存</strong>
					<el-button :icon="Refresh" size="small" circle @click="refreshMemInfo" />
				</header>
				<div class="metric-main">
					<span class="metric-value">{{ data.mem.usage }}<small>%</small></span>
					<span class="metric-label">内存使用率</span>
				</div>
				<el-progress
					:percentage="Number(data.mem.usage) || 0"
					:stroke-width="8"
					:show-text="false"
					:color="usageColor(data.mem.usage)"
				/>
				<ul class="metric-list">
					<li><span>总量</span><b>{{ data.mem.total }} GB</b></li>
					<li><span>已用</span><b>{{ data.mem.used }} GB</b></li>
					<li><span>剩余</span><b>{{ data.mem.free }} GB</b></li>
				</ul>
			</article>

			<article class="monitor-metric-card">
				<header>
					<strong>JVM 内存</strong>
					<el-button :icon="Refresh" size="small" circle @click="refreshJvmInfo" />
				</header>
				<div class="metric-main">
					<span class="metric-value">{{ data.jvm.usage }}<small>%</small></span>
					<span class="metric-label">JVM 使用率</span>
				</div>
				<el-progress
					:percentage="Number(data.jvm.usage) || 0"
					:stroke-width="8"
					:show-text="false"
					:color="usageColor(data.jvm.usage)"
				/>
				<ul class="metric-list">
					<li><span>最大可用</span><b>{{ data.jvm.max }} GB</b></li>
					<li><span>总内存</span><b>{{ data.jvm.total }} GB</b></li>
					<li><span>已用 / 空闲</span><b>{{ data.jvm.used }} / {{ data.jvm.free }} GB</b></li>
				</ul>
			</article>
		</div>

		<el-card class="org-auth-card page-card" shadow="never">
			<div class="org-auth-toolbar">
				<strong class="section-title">JVM 详情</strong>
				<el-button :icon="Refresh" size="small" circle @click="refreshJvmInfo" />
			</div>
			<el-descriptions :column="2" border class="monitor-desc">
				<el-descriptions-item label="名称">{{ data.jvm.name }}</el-descriptions-item>
				<el-descriptions-item label="版本">{{ data.jvm.version }}</el-descriptions-item>
				<el-descriptions-item label="厂商">{{ data.jvm.vendor }}</el-descriptions-item>
				<el-descriptions-item label="运行时间">{{ data.jvm.runTime }}</el-descriptions-item>
				<el-descriptions-item label="启动时间">{{ data.jvm.startTime }}</el-descriptions-item>
				<el-descriptions-item label="Jvm 路径">{{ data.jvm.home }}</el-descriptions-item>
				<el-descriptions-item label="Jar 路径" :span="2">{{ data.jvm.userDir }}</el-descriptions-item>
				<el-descriptions-item label="运行参数" :span="2">{{ data.jvm.inputArguments }}</el-descriptions-item>
			</el-descriptions>
		</el-card>

		<el-card class="org-auth-card page-card" shadow="never">
			<div class="org-auth-toolbar">
				<strong class="section-title">系统信息</strong>
				<el-button :icon="Refresh" size="small" circle @click="refreshSysInfo" />
			</div>
			<el-descriptions :column="2" border class="monitor-desc">
				<el-descriptions-item label="操作系统">{{ data.sys.osName }}</el-descriptions-item>
				<el-descriptions-item label="系统架构">{{ data.sys.osArch }}</el-descriptions-item>
				<el-descriptions-item label="系统版本">{{ data.sys.osVersion }}</el-descriptions-item>
				<el-descriptions-item label="系统名称">{{ data.sys.computerName }}</el-descriptions-item>
				<el-descriptions-item label="系统 IP">{{ data.sys.computerIp }}</el-descriptions-item>
			</el-descriptions>
		</el-card>

		<el-card class="org-auth-card page-card" shadow="never">
			<div class="org-auth-toolbar">
				<strong class="section-title">磁盘信息</strong>
				<el-button :icon="Refresh" size="small" circle @click="refreshDiskInfo" />
			</div>
			<el-table :data="data.disks" class="layout-table" show-overflow-tooltip>
				<el-table-column prop="diskName" label="磁盘名称" min-width="120" />
				<el-table-column prop="diskType" label="磁盘类型" width="110" />
				<el-table-column prop="dirName" label="磁盘路径" min-width="140">
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.dirName }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="total" label="总容量" width="110" />
				<el-table-column prop="used" label="已用" width="110" />
				<el-table-column prop="free" label="空闲" width="110" />
				<el-table-column prop="usage" label="使用率" width="160">
					<template #default="scope">
						<div class="disk-usage">
							<el-progress
								:percentage="Number(scope.row.usage) || 0"
								:stroke-width="8"
								:color="usageColor(scope.row.usage)"
							/>
						</div>
					</template>
				</el-table-column>
			</el-table>
		</el-card>
	</div>
</template>

<script setup lang="ts">
import { useCpuInfoApi, useMemInfoApi, useJvmInfoApi, useSysInfoApi, useServerInfoApi, useDiskInfoApi } from '@/api/monitor/server'
import { onMounted, reactive } from 'vue'
import { Refresh } from '@element-plus/icons-vue'

const data = reactive({
	cpu: {
		cpuModel: '',
		cpuNum: 0,
		used: 0,
		sys: 0,
		free: 0
	},
	mem: {
		total: 0,
		used: 0,
		free: 0,
		usage: 0
	},
	jvm: {
		name: '',
		version: '',
		vendor: '',
		max: 0,
		total: 0,
		used: 0,
		free: 0,
		usage: 0,
		home: '',
		userDir: '',
		startTime: '',
		runTime: '',
		inputArguments: ''
	},
	sys: {
		osName: '',
		osArch: '',
		osVersion: '',
		computerName: '',
		computerIp: ''
	},
	disks: [] as any[]
})

onMounted(() => {
	getServerInfo()
})

const usageColor = (value: number | string) => {
	const n = Number(value) || 0
	if (n >= 90) return '#ef4444'
	if (n >= 75) return '#f59e0b'
	return '#00a8e8'
}

const getServerInfo = () => {
	useServerInfoApi().then((res: any) => {
		Object.assign(data, res.data)
	})
}

const refreshCpuInfo = () => {
	useCpuInfoApi().then((res: any) => {
		data.cpu = res.data
	})
}

const refreshMemInfo = () => {
	useMemInfoApi().then((res: any) => {
		data.mem = res.data
	})
}

const refreshJvmInfo = () => {
	useJvmInfoApi().then((res: any) => {
		data.jvm = res.data
	})
}

const refreshSysInfo = () => {
	useSysInfoApi().then((res: any) => {
		data.sys = res.data
	})
}

const refreshDiskInfo = () => {
	useDiskInfoApi().then((res: any) => {
		data.disks = res.data
	})
}
</script>
