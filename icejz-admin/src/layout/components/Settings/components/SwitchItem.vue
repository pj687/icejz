<template>
	<div class="settings-switch" :class="{ disabled }">
		<span>{{ title }}</span>
		<el-switch :model-value="modelValue" :disabled="disabled" @change="handleChange" />
	</div>
</template>

<script setup lang="ts">
defineProps({
	modelValue: {
		type: Boolean,
		required: true
	},
	title: {
		type: String,
		required: true
	},
	disabled: {
		type: Boolean,
		default: false
	}
})

const emit = defineEmits<{
	'update:modelValue': [value: boolean]
	change: []
}>()

const handleChange = (val: string | number | boolean) => {
	emit('update:modelValue', Boolean(val))
	emit('change')
}
</script>

<style lang="scss" scoped>
.settings-switch {
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
