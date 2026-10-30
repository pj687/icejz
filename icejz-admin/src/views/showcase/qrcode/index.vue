<template>
	<ShowcaseShell title="二维码生成" desc="输入内容、调整尺寸与颜色，即时预览高容错二维码">
		<div class="qr-layout">
			<div class="panel form-panel">
				<label>
					<span>文本内容</span>
					<el-input v-model="value" type="textarea" :rows="3" placeholder="链接或任意文本" />
				</label>
				<label>
					<span>尺寸 {{ size }}px</span>
					<el-slider v-model="size" :min="120" :max="420" :step="10" />
				</label>
				<label class="color-row">
					<span>前景色</span>
					<el-color-picker v-model="color" />
					<em>{{ color }}</em>
				</label>
				<div class="presets">
					<button v-for="p in presets" :key="p" type="button" @click="value = p">{{ p }}</button>
				</div>
			</div>
			<div class="panel preview-panel">
				<div class="qr-frame" :style="{ width: size + 32 + 'px', height: size + 32 + 'px' }">
					<qrcode-vue :value="value || 'icejz'" :size="size" :foreground="color" level="H" />
				</div>
				<p>容错等级 H · 预览实时刷新</p>
			</div>
		</div>
	</ShowcaseShell>
</template>

<script lang="ts" setup>
import { ref } from 'vue'
import QrcodeVue from 'qrcode.vue'
import ShowcaseShell from '../ShowcaseShell.vue'

const value = ref('https://icejz.net')
const size = ref(220)
const color = ref('#0f4f6e')
const presets = ['https://icejz.net', 'ICEJZ 小冰', 'hello@icejz.net']
</script>

<style scoped lang="scss">
.qr-layout {
	display: grid;
	grid-template-columns: minmax(280px, 1fr) minmax(280px, 1fr);
	gap: 16px;
}

.panel {
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.12);
	background: rgba(255, 255, 255, 0.9);
	box-shadow: 0 10px 24px rgba(15, 40, 64, 0.04);
}

.form-panel {
	display: flex;
	flex-direction: column;
	gap: 18px;
	padding: 20px;

	label {
		display: flex;
		flex-direction: column;
		gap: 8px;

		span {
			font-size: 13px;
			font-weight: 700;
			color: #334155;
		}
	}
}

.color-row {
	flex-direction: row !important;
	align-items: center;
	gap: 12px !important;

	em {
		font-style: normal;
		font-size: 12px;
		color: #94a3b8;
	}
}

.presets {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;

	button {
		height: 32px;
		padding: 0 12px;
		border-radius: 999px;
		border: 1px solid rgba(0, 168, 232, 0.16);
		background: rgba(0, 168, 232, 0.06);
		color: #0f4f6e;
		font-size: 12px;
		cursor: pointer;

		&:hover {
			background: rgba(0, 168, 232, 0.12);
		}
	}
}

.preview-panel {
	display: grid;
	place-items: center;
	padding: 28px 20px;
	background:
		radial-gradient(circle at 50% 30%, rgba(0, 168, 232, 0.08), transparent 55%),
		rgba(255, 255, 255, 0.9);

	p {
		margin: 16px 0 0;
		font-size: 12.5px;
		color: #94a3b8;
	}
}

.qr-frame {
	display: grid;
	place-items: center;
	border-radius: 18px;
	background: #fff;
	border: 1px solid rgba(15, 23, 36, 0.06);
	box-shadow: 0 16px 36px rgba(15, 40, 64, 0.08);
}

@media (max-width: 900px) {
	.qr-layout {
		grid-template-columns: 1fr;
	}
}
</style>
