<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>开发工具</span>
				<h2>短信发送</h2>
				<p>发送短信并查看各平台发送日志与结果</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>条记录</span>
				<span class="hero-chip">短信工具</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="platform">
					<ma-dict-select v-model="state.queryForm.platform" dict-type="sms_platform" clearable placeholder="平台类型"></ma-dict-select>
				</el-form-item>
				<el-form-item prop="mobile">
					<el-input v-model="state.queryForm.mobile" clearable placeholder="手机号"></el-input>
				</el-form-item>
				<el-form-item>
					<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
					<el-button icon="RefreshRight" @click="reset(queryRef)">重置</el-button>
				</el-form-item>
			</el-form>
		</el-card>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
			<div class="org-auth-toolbar">
				<el-space wrap>
					<el-button icon="Plus" type="primary" @click="sendHandle()">发送短信</el-button>
					<el-button icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
			</div>

			<el-table
				show-overflow-tooltip
				:data="state.dataList"
				class="layout-table"
				@selection-change="selectionChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="platformId" label="平台ID" width="100" align="center"></el-table-column>
				<ma-dict-column prop="platform" label="平台类型" dict-type="sms_platform" width="120"></ma-dict-column>
				<el-table-column prop="mobile" label="手机号" min-width="140">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar">{{ (scope.row.mobile || '?').slice(0, 1) }}</span>
							{{ scope.row.mobile || '—' }}
						</span>
					</template>
				</el-table-column>
				<ma-dict-column prop="status" label="状态" dict-type="success_fail" width="100"></ma-dict-column>
				<el-table-column prop="createTime" label="创建时间" width="170"></el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="100">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button class="act-btn act-primary" @click="detailHandle(scope.row)">详情</el-button>
						</div>
					</template>
				</el-table-column>
			</el-table>

			<el-pagination
				:current-page="state.page"
				:page-sizes="state.pageSizes"
				:page-size="state.limit"
				:total="state.total"
				layout="total, sizes, prev, pager, next, jumper"
				@size-change="sizeChangeHandle"
				@current-change="currentChangeHandle"
			>
			</el-pagination>

			<detail ref="detailRef"></detail>
			<send v-if="sendVisible" v-model="sendVisible" @refresh-data-list="getDataList"></send>
		</el-card>
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import Detail from './detail.vue'
import Send from './send.vue'
import { IHooksOptions } from '@/hooks/interface'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/sms/log/page',
	deleteUrl: '/sys/sms/log',
	queryForm: {
		mobile: '',
		platform: ''
	}
})

const queryRef = ref()
const detailRef = ref()
const detailHandle = (row: any) => {
	detailRef.value.init(row)
}

const sendVisible = ref()
const sendHandle = () => {
	sendVisible.value = true
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)
</script>
