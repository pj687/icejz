<template>
	<ShowcaseShell title="富文本编辑器" desc="平台内置 MaEditor，适合公告、说明与内容编辑场景">
		<div class="editor-panel">
			<div class="toolbar-meta">
				<span>实时字数约 {{ plainLength }}</span>
				<em>内容会随输入同步到下方预览</em>
			</div>
			<ma-editor v-model="editorValue" placeholder="在这里开始书写…"></ma-editor>
			<div class="preview" v-html="editorValue"></div>
		</div>
	</ShowcaseShell>
</template>

<script lang="ts" setup name="ShowcaseEditorIndex">
import { computed, ref } from 'vue'
import ShowcaseShell from '../ShowcaseShell.vue'

const editorValue = ref('<p>欢迎使用 <strong>ICEJZ</strong> 富文本能力展示。</p><p>可以插入标题、列表与强调文本，体验后台内容编辑流程。</p>')
const plainLength = computed(() => editorValue.value.replace(/<[^>]+>/g, '').trim().length)
</script>

<style scoped lang="scss">
.editor-panel {
	display: flex;
	flex-direction: column;
	gap: 14px;
	padding: 16px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.12);
	background: rgba(255, 255, 255, 0.92);
	box-shadow: 0 10px 24px rgba(15, 40, 64, 0.04);
}

.toolbar-meta {
	display: flex;
	justify-content: space-between;
	gap: 12px;
	font-size: 12.5px;

	span {
		font-weight: 700;
		color: #0f4f6e;
	}
	em {
		font-style: normal;
		color: #94a3b8;
	}
}

.preview {
	min-height: 120px;
	padding: 14px 16px;
	border-radius: 14px;
	border: 1px dashed rgba(0, 168, 232, 0.22);
	background: linear-gradient(180deg, #f7fbfe, #fff);
	color: #1e293b;
	line-height: 1.7;

	:deep(p) {
		margin: 0 0 8px;
	}
}
</style>
