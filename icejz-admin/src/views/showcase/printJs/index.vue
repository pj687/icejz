<template>
	<ShowcaseShell title="页面打印" desc="基于 Print.js，一键将当前演示区域输出为打印预览">
		<template #actions>
			<el-button type="primary" @click="handlePrintJs">打印当前区域</el-button>
		</template>

		<div id="printJs-vue" class="print-board">
			<article class="print-sheet">
				<header>
					<strong>ICEJZ 打印预览样张</strong>
					<em>{{ today }}</em>
				</header>
				<p>
					这是能力展示页中的打印示例。点击右上角按钮后，将仅打印本卡片内容，适合导出确认单、巡检记录等轻量文档。
				</p>
				<ul>
					<li>支持指定 DOM 区域打印</li>
					<li>可引入外部样式保证版式</li>
					<li>无需额外后端服务</li>
				</ul>
				<footer>powered by print-js · icejz showcase</footer>
			</article>
		</div>
	</ShowcaseShell>
</template>

<script lang="ts" setup>
import printJs from 'print-js'
import ShowcaseShell from '../ShowcaseShell.vue'

const today = new Date().toLocaleDateString('zh-CN')

const handlePrintJs = () => {
	printJs({
		printable: 'printJs-vue',
		type: 'html',
		css: ['//unpkg.com/element-plus/dist/index.css'],
		scanStyles: false
	})
}
</script>

<style scoped lang="scss">
.print-board {
	padding: 8px;
}

.print-sheet {
	max-width: 720px;
	margin: 0 auto;
	padding: 28px 30px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background: linear-gradient(180deg, #fff, #f7fbfe);
	box-shadow: 0 14px 32px rgba(15, 40, 64, 0.06);

	header {
		display: flex;
		justify-content: space-between;
		align-items: baseline;
		gap: 12px;
		margin-bottom: 16px;
		padding-bottom: 12px;
		border-bottom: 1px dashed rgba(0, 168, 232, 0.25);

		strong {
			font-size: 18px;
			color: #0f1724;
		}
		em {
			font-style: normal;
			font-size: 12px;
			color: #94a3b8;
		}
	}

	p {
		margin: 0;
		line-height: 1.75;
		color: #334155;
		font-size: 14px;
	}

	ul {
		margin: 16px 0;
		padding-left: 18px;
		color: #475569;
		line-height: 1.9;
		font-size: 13.5px;
	}

	footer {
		margin-top: 18px;
		font-size: 12px;
		color: #94a3b8;
	}
}
</style>
