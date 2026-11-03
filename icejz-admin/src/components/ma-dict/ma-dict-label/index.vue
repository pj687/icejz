<template>
	<span class="ma-dict-tags">
		<span v-for="item in items" :key="item.value + '-' + item.label" class="icejz-dict-tag" :class="'tone-' + item.tone">
			<i class="dot" aria-hidden="true"></i>
			{{ item.label }}
		</span>
		<span v-if="!items.length" class="icejz-dict-tag tone-info empty">—</span>
	</span>
</template>

<script setup lang="ts" name="MaDictLabel">
import { computed } from 'vue'
import { getDictLabelItems } from '@/utils/tool'

const props = defineProps({
	dictType: {
		type: String,
		required: true
	},
	dictValue: {
		type: [String, Number],
		required: true
	}
})

const items = computed(() => getDictLabelItems(props.dictType, props.dictValue))
</script>

<style scoped lang="scss">
.ma-dict-tags {
	display: inline-flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 6px;
	vertical-align: middle;
}
</style>
