<template>
	<div class="settings-select" :class="{ disabled }">
		<span>{{ title }}</span>
		<el-select
			:model-value="modelValue"
			size="small"
			style="width: 112px"
			:disabled="disabled"
			@change="handleChange"
		>
			<el-option v-for="option in options" :key="option.value" :label="option.label" :value="option.value" />
		</el-select>
	</div>
</template>

<script setup lang="ts">
import type { PropType } from 'vue'

defineProps({
	modelValue: {
		type: String,
		required: true
	},
	title: {
		type: String,
		required: true
	},
	options: {
		type: Array as PropType<Array<{ label: string; value: string }>>,
		required: true,
		default: () => []
	},
	disabled: {
		type: Boolean,
		default: false
	}
})

const emit = defineEmits<{
	'update:modelValue': [value: string]
	change: []
}>()

const handleChange = (val: string) => {
	emit('update:modelValue', val)
	emit('change')
}
</script>

<style lang="scss" scoped>
.settings-select {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 12px;
	min-height: 36px;
	padding: 4px 0;
	color: var(--el-text-color-primary);
	font-size: 13px;

	&.disabled {
		opacity: 0.55;
	}
}
</style>
