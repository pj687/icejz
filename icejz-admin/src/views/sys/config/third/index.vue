<template>
	<div class="config-pane">
		<div class="org-auth-toolbar">
			<el-space wrap>
				<el-button type="primary" icon="Plus" @click="addOrUpdateHandle()">新增配置</el-button>
				<el-button type="danger" icon="Delete" plain @click="deleteBatchHandle()">批量删除</el-button>
			</el-space>
		</div>

		<el-table
			v-loading="state.dataListLoading"
			:data="state.dataList"
			show-overflow-tooltip
			class="layout-table"
			@selection-change="selectionChangeHandle"
		>
			<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
			<el-table-column prop="openType" label="平台类型" min-width="150">
				<template #default="scope">
					<span class="platform-cell">
						<template v-if="scope.row.openType === 'wechat_work'"><ma-icon icon="icon-workweixin" size="16" /> 企业微信</template>
						<template v-else-if="scope.row.openType === 'dingtalk'"><ma-icon icon="icon-dingding" size="16" /> 钉钉</template>
						<template v-else-if="scope.row.openType === 'feishu'"><ma-icon icon="icon-feishu" size="16" /> 飞书</template>
						<template v-else-if="scope.row.openType === 'wechat_open'"><ma-icon icon="icon-weixin" size="16" /> 微信</template>
						<template v-else>{{ scope.row.openType }}</template>
					</span>
				</template>
			</el-table-column>
			<el-table-column prop="clientId" label="ClientID" min-width="160">
				<template #default="scope">
					<span class="sys-route-code">{{ scope.row.clientId }}</span>
				</template>
			</el-table-column>
			<el-table-column prop="clientSecret" label="ClientSecret" min-width="160" show-overflow-tooltip></el-table-column>
			<el-table-column prop="redirectUri" label="RedirectUri" min-width="180" show-overflow-tooltip></el-table-column>
			<el-table-column label="操作" fixed="right" align="center" width="168">
				<template #default="scope">
					<div class="org-auth-actions">
						<el-button class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
						<el-button class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
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

		<add-or-update ref="addOrUpdateRef" @refreshDataList="getDataList"></add-or-update>
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { Delete, Edit } from '@element-plus/icons-vue'
import { IHooksOptions } from '@/hooks/interface'
import AddOrUpdate from './add-or-update.vue'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/third/config/page',
	deleteUrl: '/sys/third/config'
})

const addOrUpdateRef = ref()
const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle } = useCrud(state)
</script>

<style scoped lang="scss">
.config-pane {
	padding-top: 4px;
}

.platform-cell {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	font-weight: 650;
	color: #122033;
}
</style>
