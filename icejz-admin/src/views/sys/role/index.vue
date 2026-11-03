<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>组织权限</span>
				<h2>角色管理</h2>
				<p>配置菜单权限、数据范围，并为角色分配用户</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>个角色</span>
				<span class="hero-chip">权限中枢</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="name">
					<el-input v-model="state.queryForm.name" clearable placeholder="角色名称"></el-input>
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
					<el-button v-auth="'sys:role:save'" icon="Plus" type="primary" @click="addOrUpdateHandle()">新增角色</el-button>
					<el-button v-auth="'sys:role:delete'" icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
				<ma-view-mode v-model="viewMode" />
			</div>

			<template v-if="viewMode === 'table'">
				<el-table :data="state.dataList" class="layout-table" @selection-change="selectionChangeHandle">
					<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
					<el-table-column prop="name" label="角色名称" min-width="160">
						<template #default="scope">
							<span class="org-auth-name">
								<span class="avatar role">{{ (scope.row.name || '角').slice(0, 1) }}</span>
								{{ scope.row.name }}
							</span>
						</template>
					</el-table-column>
					<el-table-column prop="roleCode" label="编码" min-width="140">
						<template #default="scope">
							<span class="org-auth-code">{{ scope.row.roleCode || '—' }}</span>
						</template>
					</el-table-column>
					<el-table-column prop="remark" label="备注" min-width="180" show-overflow-tooltip></el-table-column>
					<el-table-column prop="createTime" label="创建时间" min-width="170"></el-table-column>
					<el-table-column label="操作" fixed="right" align="center" width="320">
						<template #default="scope">
							<div class="org-auth-actions">
								<el-button v-auth="'sys:role:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
								<el-button v-auth="'sys:role:update'" class="act-btn act-warn" :icon="Key" @click="handleCommand('dataScope', scope.row)">数据权限</el-button>
								<el-button v-auth="'sys:role:update'" class="act-btn act-success" :icon="User" @click="handleCommand('user', scope.row)">分配用户</el-button>
								<el-button v-auth="'sys:role:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
							</div>
						</template>
					</el-table-column>
				</el-table>
			</template>

			<div v-else class="org-auth-card-grid">
				<article v-for="row in state.dataList" :key="row.id" class="org-auth-entity-card">
					<div class="card-top">
						<div class="card-identity">
							<span class="card-avatar role">{{ (row.name || '角').slice(0, 1) }}</span>
							<div class="card-title">
								<strong>{{ row.name }}</strong>
								<em>{{ row.createTime || '—' }}</em>
							</div>
						</div>
						<span class="org-auth-code">{{ row.roleCode || '—' }}</span>
					</div>
					<div class="card-meta">
						<div class="meta-row"><span>备注</span><b>{{ row.remark || '暂无备注' }}</b></div>
					</div>
					<div class="card-foot">
						<span></span>
						<div class="org-auth-actions">
							<el-button v-auth="'sys:role:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(row.id)">修改</el-button>
							<el-button v-auth="'sys:role:update'" class="act-btn act-warn" :icon="Key" @click="handleCommand('dataScope', row)">数据权限</el-button>
							<el-button v-auth="'sys:role:update'" class="act-btn act-success" :icon="User" @click="handleCommand('user', row)">分配用户</el-button>
							<el-button v-auth="'sys:role:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(row.id)">删除</el-button>
						</div>
					</div>
				</article>
				<div v-if="!state.dataList?.length" class="org-auth-empty-card">暂无角色数据</div>
			</div>

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
			<data-scope ref="dataScopeRef"></data-scope>
			<el-drawer v-if="userVisible" v-model="userVisible" class="role-user-drawer" :title="userTitle" :size="960" :close-on-press-escape="false">
				<user-panel :role-id="roleId"></user-panel>
			</el-drawer>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="SysRoleIndex">
import { useCrud } from '@/hooks'
import { useViewMode } from '@/hooks/useViewMode'
import { reactive, ref } from 'vue'
import { Delete, Edit, Key, User } from '@element-plus/icons-vue'
import AddOrUpdate from './add-or-update.vue'
import DataScope from './data-scope.vue'
import UserPanel from './user.vue'
import MaViewMode from '@/components/ma-view-mode/index.vue'
import { IHooksOptions } from '@/hooks/interface'

const { viewMode } = useViewMode('sys-role')

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/role/page',
	deleteUrl: '/sys/role',
	queryForm: {
		name: ''
	}
})

const queryRef = ref()
const addOrUpdateRef = ref()
const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const dataScopeRef = ref()
const userVisible = ref(false)
const roleId = ref()
const userTitle = ref()
const handleCommand = (command: string, row: any) => {
	if (command === 'dataScope') {
		dataScopeRef.value.init(row.id)
	} else if (command === 'user') {
		roleId.value = row.id
		userTitle.value = '分配用户 · ' + row.name
		userVisible.value = true
	}
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)
</script>

<style lang="scss">
.role-user-drawer {
	.el-drawer__header {
		margin-bottom: 8px;
		padding: 18px 20px 10px;
		border-bottom: 1px solid #eef3f8;
	}

	.el-drawer__title {
		font-weight: 740;
		color: #122033;
	}

	.el-drawer__body {
		padding: 14px 20px 20px;
		background:
			radial-gradient(520px 180px at 100% 0%, rgba(0, 168, 232, 0.05), transparent 60%),
			#fff;
	}
}
</style>
