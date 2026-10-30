<template>
	<ShowcaseShell title="Icon 图标库" :desc="`共 ${iconList.length} 个图标，点击即可复制 <ma-icon> 代码`">
		<template #actions>
			<el-input
				v-model="keyword"
				clearable
				placeholder="搜索图标名…"
				style="width: 220px"
			/>
		</template>

		<div class="icon-board">
			<button
				v-for="icon in filtered"
				:key="icon"
				type="button"
				class="icon-cell"
				@click="handleCopy(icon)"
			>
				<ma-icon :icon="icon" class-name="svg-size" />
				<span>{{ icon.replace(/^icon-/, '') }}</span>
			</button>
			<div v-if="!filtered.length" class="empty">没有匹配的图标</div>
		</div>
	</ShowcaseShell>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useClipboard } from '@vueuse/core'
import { getIconList } from '@/utils/tool'
import { ElMessage } from 'element-plus'
import ShowcaseShell from '../ShowcaseShell.vue'

const iconList = getIconList()
const keyword = ref('')
const filtered = computed(() => {
	const q = keyword.value.trim().toLowerCase()
	if (!q) return iconList
	return iconList.filter(i => i.toLowerCase().includes(q))
})

const { copy } = useClipboard()
const handleCopy = (icon: string) => {
	copy(`<ma-icon icon="${icon}"></ma-icon>`)
	ElMessage.success(`已复制 ${icon}`)
}
</script>

<style scoped lang="scss">
.icon-board {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(118px, 1fr));
	gap: 10px;
	padding: 14px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.12);
	background: rgba(255, 255, 255, 0.86);
	box-shadow: 0 10px 24px rgba(15, 40, 64, 0.04);
}

.icon-cell {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	gap: 10px;
	min-height: 104px;
	padding: 12px 8px;
	border: 1px solid transparent;
	border-radius: 16px;
	background: linear-gradient(180deg, #f7fbfe, #fff);
	cursor: pointer;
	transition: transform 0.15s ease, border-color 0.15s ease, box-shadow 0.15s ease;

	span {
		font-size: 11.5px;
		color: #64748b;
		word-break: break-all;
		text-align: center;
		line-height: 1.35;
	}

	&:hover {
		transform: translateY(-2px);
		border-color: rgba(0, 168, 232, 0.28);
		box-shadow: 0 10px 20px rgba(0, 140, 200, 0.1);

		span {
			color: #007eb8;
		}
	}
}

:deep(.svg-size) {
	width: 28px !important;
	height: 28px !important;
	color: #0f4f6e;
}

.empty {
	grid-column: 1 / -1;
	padding: 40px;
	text-align: center;
	color: #94a3b8;
}
</style>
