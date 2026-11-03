<template>
	<div class="ma-view-mode" role="group" aria-label="显示方式">
		<button type="button" class="mode-btn" :class="{ active: modelValue === 'table' }" title="列表视图" @click="emit('update:modelValue', 'table')">
			<svg viewBox="0 0 24 24" aria-hidden="true">
				<path
					d="M4 6h16M4 12h16M4 18h16"
					fill="none"
					stroke="currentColor"
					stroke-width="1.8"
					stroke-linecap="round"
				/>
			</svg>
			<span>列表</span>
		</button>
		<button type="button" class="mode-btn" :class="{ active: modelValue === 'card' }" title="卡片视图" @click="emit('update:modelValue', 'card')">
			<svg viewBox="0 0 24 24" aria-hidden="true">
				<path
					d="M4 4h7v7H4V4zm9 0h7v7h-7V4zM4 13h7v7H4v-7zm9 0h7v7h-7v-7z"
					fill="none"
					stroke="currentColor"
					stroke-width="1.6"
					stroke-linejoin="round"
				/>
			</svg>
			<span>卡片</span>
		</button>
	</div>
</template>

<script setup lang="ts">
import type { ViewMode } from '@/hooks/useViewMode'

defineProps<{
	modelValue: ViewMode
}>()

const emit = defineEmits<{
	'update:modelValue': [value: ViewMode]
}>()
</script>

<style scoped lang="scss">
.ma-view-mode {
	display: inline-flex;
	padding: 3px;
	border-radius: 12px;
	background: #f5f9fc;
	border: 1px solid #e7eef5;
}

.mode-btn {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	height: 30px;
	padding: 0 10px;
	border: none;
	border-radius: 9px;
	background: transparent;
	color: #64748b;
	font-size: 12px;
	font-weight: 650;
	cursor: pointer;
	transition: background 0.15s ease, color 0.15s ease, transform 0.15s ease;

	svg {
		width: 14px;
		height: 14px;
		display: block;
	}

	&:hover:not(.active) {
		color: #007eb8;
	}

	&.active {
		background: var(--icejz-card-bg, #fff);
		color: #007eb8;
		box-shadow: 0 4px 10px rgba(0, 168, 232, 0.12);
	}

	&:active {
		transform: scale(0.97);
	}
}
</style>
