<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>消息管理</h2>
				<p>向全部或部分用户发送站内通知、公告与私信</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>条消息</span>
				<span class="hero-chip">站内触达</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="title">
					<el-input v-model="state.queryForm.title" clearable placeholder="标题"></el-input>
				</el-form-item>
				<el-form-item prop="type">
					<ma-dict-select v-model="state.queryForm.type" dict-type="message_type" clearable placeholder="类型"></ma-dict-select>
				</el-form-item>
				<el-form-item prop="status">
					<ma-dict-select v-model="state.queryForm.status" dict-type="message_status" clearable placeholder="状态"></ma-dict-select>
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
					<el-button v-auth="'sys:message:save'" icon="Plus" type="primary" @click="addOrUpdateHandle()">发送消息</el-button>
					<el-button v-auth="'sys:message:delete'" icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
			</div>

			<el-table :data="state.dataList" class="layout-table" @selection-change="selectionChangeHandle">
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="title" label="标题" min-width="180" show-overflow-tooltip></el-table-column>
				<ma-dict-column prop="type" label="类型" dict-type="message_type" width="100"></ma-dict-column>
				<el-table-column label="接收范围" width="110" align="center">
					<template #default="scope">
						{{ scope.row.receiverType === 0 ? '全部用户' : '指定用户' }}
					</template>
				</el-table-column>
				<el-table-column label="阅读" width="120" align="center">
					<template #default="scope">
						{{ scope.row.readCount || 0 }}/{{ scope.row.receiverCount || 0 }}
					</template>
				</el-table-column>
				<el-table-column prop="senderName" label="发送人" width="120"></el-table-column>
				<ma-dict-column prop="status" label="状态" dict-type="message_status" width="100"></ma-dict-column>
				<el-table-column prop="sendTime" label="发送时间" width="170"></el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="168">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button v-auth="'sys:message:info'" class="act-btn act-primary" @click="viewHandle(scope.row.id)">详情</el-button>
							<el-button v-auth="'sys:message:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
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

			<add-or-update ref="addOrUpdateRef" @refresh-data-list="getDataList"></add-or-update>
			<detail ref="detailRef"></detail>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="SysMessageIndex">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { Delete } from '@element-plus/icons-vue'
import AddOrUpdate from './add-or-update.vue'
import Detail from './detail.vue'
import { IHooksOptions } from '@/hooks/interface'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/message/page',
	deleteUrl: '/sys/message',
	queryForm: {
		title: '',
		type: '',
		status: ''
	}
})

const queryRef = ref()
const addOrUpdateRef = ref()
const detailRef = ref()
const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)

const addOrUpdateHandle = () => {
	addOrUpdateRef.value.init()
}

const viewHandle = (id: number) => {
	detailRef.value.init(id)
}
</script>
