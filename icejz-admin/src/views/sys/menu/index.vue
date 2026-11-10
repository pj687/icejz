<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>菜单管理</h2>
				<p>维护 PC / APP / 小程序导航菜单，以及按钮权限与接口授权标识</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ nodeCount }}</em>项</span>
				<span class="hero-chip">树形权限</span>
			</div>
		</section>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
			<div class="org-auth-toolbar">
				<el-radio-group v-model="clientType" class="client-tabs" @change="onClientChange">
					<el-radio-button :value="0">PC 管理端</el-radio-button>
					<el-radio-button :value="1">APP</el-radio-button>
					<el-radio-button :value="2">小程序</el-radio-button>
				</el-radio-group>
				<el-space wrap>
					<el-button v-auth="'sys:menu:save'" icon="Plus" type="primary" @click="addOrUpdateHandle(false, null)">新增菜单</el-button>
					<el-button plain @click="toggleExpandAll()">
						<template v-if="!isExpandAll">
							全部展开&nbsp;<el-icon><ArrowDown /></el-icon>
						</template>
						<template v-else>
							全部收起&nbsp;<el-icon><ArrowUp /></el-icon>
						</template>
					</el-button>
				</el-space>
			</div>

			<el-table
				v-if="refreshTable"
				:default-expand-all="isExpandAll"
				:data="state.dataList"
				show-overflow-tooltip
				row-key="id"
				class="layout-table"
			>
				<el-table-column prop="name" label="名称" min-width="180">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar" :class="typeAvatar(scope.row.type)">
								<template v-if="scope.row.icon"><ma-icon :icon="scope.row.icon" /></template>
								<template v-else>{{ (scope.row.name || '菜').slice(0, 1) }}</template>
							</span>
							{{ scope.row.name }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="type" label="类型" width="100" align="center">
					<template #default="scope">
						<span class="sys-type-pill" :class="typeClass(scope.row.type)">{{ typeLabel(scope.row.type) }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="openStyle" label="打开方式" width="110" align="center">
					<template #default="scope">
						<template v-if="scope.row.type === 0">
							<span class="sys-type-pill" :class="scope.row.openStyle === 0 ? 'open-in' : 'open-out'">
								{{ scope.row.openStyle === 0 ? '内部' : '外部' }}
							</span>
						</template>
						<span v-else class="muted">—</span>
					</template>
				</el-table-column>
				<el-table-column prop="sort" label="排序" width="90" align="center"></el-table-column>
				<el-table-column prop="url" :label="clientType === 0 ? '路由' : '页面路径'" min-width="180">
					<template #default="scope">
						<span v-if="scope.row.url" class="sys-route-code">{{ scope.row.url }}</span>
						<span v-else class="muted">—</span>
					</template>
				</el-table-column>
				<el-table-column prop="authority" label="授权标识" min-width="160">
					<template #default="scope">
						<span v-if="scope.row.authority" class="org-auth-code">{{ scope.row.authority }}</span>
						<span v-else class="muted">—</span>
					</template>
				</el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="220">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button
								v-if="scope.row.type === 0"
								v-auth="'sys:menu:save'"
								class="act-btn act-success"
								:icon="Plus"
								@click="addOrUpdateHandle(false, scope.row)"
							>
								下级
							</el-button>
							<el-button v-auth="'sys:menu:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(true, scope.row)">
								修改
							</el-button>
							<el-button v-auth="'sys:menu:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteHandle(scope.row.id)">
								删除
							</el-button>
						</div>
					</template>
				</el-table-column>
			</el-table>

			<add-or-update ref="addOrUpdateRef" @refresh-data-list="getDataList"></add-or-update>
		</el-card>
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { computed, nextTick, reactive, ref } from 'vue'
import AddOrUpdate from './add-or-update.vue'
import { IHooksOptions } from '@/hooks/interface'
import { ArrowDown, ArrowUp, Delete, Edit, Plus } from '@element-plus/icons-vue'

const clientType = ref(0)

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/menu/list',
	deleteUrl: '/sys/menu',
	isPage: false,
	queryForm: {
		clientType: 0
	}
})

const addOrUpdateRef = ref()
const addOrUpdateHandle = (isUpdate: Boolean, row: any) => {
	addOrUpdateRef.value.init(isUpdate, row, clientType.value)
}

const { getDataList, deleteHandle } = useCrud(state)

const onClientChange = () => {
	state.queryForm.clientType = clientType.value
	getDataList()
}

const isExpandAll = ref(false)
const refreshTable = ref(true)

const countNodes = (list: any[] = []): number =>
	list.reduce((sum, item) => sum + 1 + countNodes(item.children || []), 0)

const nodeCount = computed(() => countNodes(state.dataList || []))

const typeLabel = (type: number) => {
	if (type === 1) return '按钮'
	if (type === 2) return '接口'
	return '菜单'
}

const typeClass = (type: number) => {
	if (type === 1) return 'button'
	if (type === 2) return 'api'
	return 'menu'
}

const typeAvatar = (type: number) => {
	if (type === 1) return 'role'
	if (type === 2) return 'post'
	return ''
}

const toggleExpandAll = () => {
	refreshTable.value = false
	isExpandAll.value = !isExpandAll.value
	nextTick(() => {
		refreshTable.value = true
	})
}
</script>

<style scoped lang="scss">
.muted {
	color: #94a3b8;
}

.org-auth-toolbar {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
}

.client-tabs {
	flex-shrink: 0;
}

.org-auth-name .avatar :deep(svg),
.org-auth-name .avatar :deep(i) {
	font-size: 14px;
	line-height: 1;
	color: inherit;
}
</style>
