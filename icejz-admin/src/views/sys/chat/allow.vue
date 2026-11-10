<template>
	<div class="chat-allow-page">
		<header class="allow-hero">
			<div>
				<p class="kicker">Chat ACL</p>
				<h1>聊天权限</h1>
				<p>配置跨组织白名单例外；角色聊天范围请在「角色管理 → 数据权限」中设置</p>
			</div>
			<el-button v-auth="'sys:chat:acl'" type="primary" @click="openEdit()">新增白名单</el-button>
		</header>

		<el-card class="allow-card" shadow="never">
			<div class="toolbar">
				<el-select v-model="state.queryForm.type" clearable placeholder="类型" style="width: 160px" @change="getDataList()">
					<el-option :value="1" label="用户-用户" />
					<el-option :value="2" label="机构-机构" />
					<el-option :value="3" label="用户-机构" />
				</el-select>
				<el-select v-model="state.queryForm.status" clearable placeholder="状态" style="width: 120px" @change="getDataList()">
					<el-option :value="1" label="启用" />
					<el-option :value="0" label="停用" />
				</el-select>
				<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
				<el-button v-auth="'sys:chat:acl'" type="danger" plain @click="deleteBatchHandle()">删除</el-button>
			</div>

			<el-table v-loading="state.dataListLoading" :data="state.dataList" border @selection-change="selectionChangeHandle">
				<el-table-column type="selection" width="48" align="center" />
				<el-table-column label="类型" width="120">
					<template #default="{ row }">{{ typeLabel(row.type) }}</template>
				</el-table-column>
				<el-table-column prop="srcName" label="源" min-width="140" />
				<el-table-column prop="dstName" label="目标" min-width="140" />
				<el-table-column prop="remark" label="备注" min-width="160" show-overflow-tooltip />
				<el-table-column label="状态" width="90">
					<template #default="{ row }">
						<el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
					</template>
				</el-table-column>
				<el-table-column prop="createTime" label="创建时间" width="170" />
				<el-table-column label="操作" width="140" fixed="right" align="center">
					<template #default="{ row }">
						<el-button v-auth="'sys:chat:acl'" link type="primary" @click="openEdit(row)">编辑</el-button>
						<el-button v-auth="'sys:chat:acl'" link type="danger" @click="deleteBatchHandle(row.id)">删除</el-button>
					</template>
				</el-table-column>
			</el-table>

			<el-pagination
				v-if="state.total > 0"
				class="pager"
				:current-page="state.page"
				:page-sizes="state.pageSizes"
				:page-size="state.limit"
				:total="state.total"
				layout="total, sizes, prev, pager, next"
				@size-change="sizeChangeHandle"
				@current-change="currentChangeHandle"
			/>
		</el-card>

		<el-dialog v-model="editVisible" class="chat-dialog" :title="form.id ? '编辑白名单' : '新增白名单'" width="520px" align-center destroy-on-close>
			<el-form label-width="96px">
				<el-form-item label="类型" required>
					<el-radio-group v-model="form.type" @change="onTypeChange">
						<el-radio-button :value="1">用户-用户</el-radio-button>
						<el-radio-button :value="2">机构-机构</el-radio-button>
						<el-radio-button :value="3">用户-机构</el-radio-button>
					</el-radio-group>
				</el-form-item>
				<el-form-item :label="srcLabel" required>
					<ma-user-input v-if="form.type === 1 || form.type === 3" v-model="form.srcId" placeholder="选择用户" />
					<ma-org-select v-else v-model="form.srcId" placeholder="选择机构" />
				</el-form-item>
				<el-form-item :label="dstLabel" required>
					<ma-user-input v-if="form.type === 1" v-model="form.dstId" placeholder="选择用户" />
					<ma-org-select v-else v-model="form.dstId" placeholder="选择机构" />
				</el-form-item>
				<el-form-item label="状态">
					<el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" />
				</el-form-item>
				<el-form-item label="备注">
					<el-input v-model="form.remark" type="textarea" :rows="2" maxlength="200" show-word-limit />
				</el-form-item>
			</el-form>
			<template #footer>
				<el-button @click="editVisible = false">取消</el-button>
				<el-button type="primary" @click="submitEdit">保存</el-button>
			</template>
		</el-dialog>
	</div>
</template>

<script setup lang="ts" name="SysChatAllow">
import { computed, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { IHooksOptions } from '@/hooks/interface'
import { useCrud } from '@/hooks'
import { useChatAllowSubmitApi } from '@/api/sys/chat'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/chat/allow/page',
	deleteUrl: '/sys/chat/allow',
	queryForm: {
		type: undefined as number | undefined,
		status: undefined as number | undefined
	}
})

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle } = useCrud(state)

const editVisible = ref(false)
const form = reactive({
	id: undefined as number | undefined,
	type: 1,
	srcId: undefined as number | undefined,
	dstId: undefined as number | undefined,
	status: 1,
	remark: ''
})

const typeLabel = (type: number) => {
	if (type === 1) return '用户-用户'
	if (type === 2) return '机构-机构'
	if (type === 3) return '用户-机构'
	return String(type)
}

const srcLabel = computed(() => (form.type === 2 ? '源机构' : '源用户'))
const dstLabel = computed(() => (form.type === 1 ? '目标用户' : '目标机构'))

const openEdit = (row?: any) => {
	form.id = row?.id
	form.type = row?.type || 1
	form.srcId = row?.srcId
	form.dstId = row?.dstId
	form.status = row?.status ?? 1
	form.remark = row?.remark || ''
	editVisible.value = true
}

const onTypeChange = () => {
	form.srcId = undefined
	form.dstId = undefined
}

const submitEdit = async () => {
	if (!form.srcId || !form.dstId) {
		ElMessage.warning('请完整选择源与目标')
		return
	}
	await useChatAllowSubmitApi({ ...form })
	ElMessage.success('保存成功')
	editVisible.value = false
	getDataList()
}
</script>

<style scoped lang="scss">
.chat-allow-page {
	--ink: #122033;
	--muted: #64748b;
	--soft: #f8fbfd;
	--brand-deep: #007eb8;
	display: flex;
	flex-direction: column;
	gap: 16px;
	padding-bottom: 20px;
}

.allow-hero {
	display: flex;
	justify-content: space-between;
	align-items: flex-end;
	gap: 16px;
	padding: 20px 22px;
	border-radius: 18px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background: linear-gradient(145deg, #fff, var(--soft));
}

.kicker {
	margin: 0 0 6px;
	font-size: 12px;
	font-weight: 700;
	color: var(--brand-deep);
}

.allow-hero h1 {
	margin: 0;
	font-size: 24px;
	color: var(--ink);
}

.allow-hero p {
	margin: 8px 0 0;
	font-size: 13px;
	color: var(--muted);
}

.allow-card {
	border-radius: 16px;
	border: 1px solid #e7eef5;
}

.toolbar {
	display: flex;
	flex-wrap: wrap;
	gap: 10px;
	margin-bottom: 14px;
}

.pager {
	margin-top: 14px;
	justify-content: flex-end;
}
</style>
