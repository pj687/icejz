<template>
	<div class="org-auth-page captcha-config">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>验证码配置</h2>
				<p>按登录入口分别选择验证方式。PC 管理端、短信发码、移动端可互不影响；下方可先浏览各方式说明再下发配置。</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip" :class="{ on: form.enabled }">
					{{ form.enabled ? '账号登录验证码 · 开' : '账号登录验证码 · 关' }}
				</span>
				<span class="hero-chip">三端独立</span>
			</div>
		</section>

		<div class="captcha-stack" v-loading="loading">
			<!-- 1. 总开关：独立配置卡片 -->
			<el-card class="org-auth-card page-card section-card" shadow="never">
				<div class="card-head">
					<div class="card-head-copy">
						<span class="card-kicker">配置</span>
						<strong>总开关</strong>
						<em>只影响「账号密码登录」是否必须过图形/交互验证码；短信发码前的图形码始终会校验，不受此开关影响。</em>
					</div>
				</div>
				<div class="switch-panel" :class="{ on: form.enabled }">
					<div class="switch-copy">
						<span class="switch-title">账号密码登录验证码</span>
						<span class="switch-desc">
							{{
								form.enabled
									? '已开启：PC / App 账号登录提交时会校验对应端所选验证码。'
									: '已关闭：账号密码可直接登录；短信发码入口仍会要求图形验证码。'
							}}
						</span>
					</div>
					<el-switch v-model="form.enabled" active-text="开启" inactive-text="关闭" />
				</div>
			</el-card>

			<!-- 2. 说明：独立介绍卡片，与配置区分离 -->
			<el-card class="org-auth-card page-card section-card guide-section" shadow="never">
				<div class="card-head">
					<div class="card-head-copy">
						<span class="card-kicker">介绍</span>
						<strong>验证方式说明</strong>
						<em>选择前可先浏览各类交互差异。点选 / 拼图防刷更强；PoW 几乎无感；Turnstile 依赖 Cloudflare（免费档可用）。</em>
					</div>
					<span class="card-hint">只读参考 · 不直接改配置</span>
				</div>
				<div class="guide-grid">
					<article
						v-for="guide in modeGuides"
						:key="guide.mode"
						class="guide-card"
						:class="['mode-' + guide.mode, { active: usedModes.has(guide.mode) }]"
					>
						<header class="guide-head">
							<span class="guide-badge">{{ guide.badge }}</span>
							<strong>{{ guide.title }}</strong>
							<em v-if="usedModes.has(guide.mode)" class="guide-used">使用中</em>
						</header>
						<p class="guide-desc">{{ guide.desc }}</p>
						<ul class="guide-points">
							<li v-for="(point, idx) in guide.points" :key="idx">{{ point }}</li>
						</ul>
						<span class="guide-when">适合：{{ guide.when }}</span>
					</article>
				</div>
			</el-card>

			<!-- 3. 分端类型：场景说明与选择器分层 -->
			<el-card class="org-auth-card page-card section-card" shadow="never">
				<div class="card-head">
					<div class="card-head-copy">
						<span class="card-kicker">配置</span>
						<strong>分端验证码类型</strong>
						<em>三个入口各自独立；改某一端不会影响另外两端。保存后对新发起的验证码请求立即生效。</em>
					</div>
				</div>
				<div class="channel-grid">
					<div
						v-for="item in channels"
						:key="item.key"
						class="channel-card"
						:data-mode="resolveOption(form[item.key])?.mode || 'input'"
					>
						<div class="channel-head">
							<span class="channel-index">{{ item.index }}</span>
							<div class="channel-title">
								<span class="channel-name">{{ item.title }}</span>
								<span class="channel-tip">{{ item.desc }}</span>
							</div>
						</div>

						<div class="channel-scene">
							<span class="scene-label">适用场景</span>
							<p>{{ item.scene }}</p>
							<ul>
								<li v-for="(line, idx) in item.notes" :key="idx">{{ line }}</li>
							</ul>
						</div>

						<div class="channel-config">
							<label class="field-label">验证码类型</label>
							<el-select
								v-model="form[item.key]"
								class="type-select"
								popper-class="captcha-type-popper"
								placeholder="选择验证码类型"
								:teleported="true"
							>
								<template #prefix>
									<span class="select-mode" :class="'mode-' + (resolveOption(form[item.key])?.mode || 'input')">
										{{ modeLabel(resolveOption(form[item.key])?.mode) }}
									</span>
								</template>
								<el-option-group v-for="group in optionGroups" :key="group.mode" :label="group.label">
									<el-option
										v-for="opt in group.items"
										:key="opt.code"
										:label="opt.label"
										:value="opt.code"
									>
										<div class="opt-item" :class="{ active: form[item.key] === opt.code }">
											<span class="opt-mode" :class="'mode-' + opt.mode">{{ modeLabel(opt.mode) }}</span>
											<div class="opt-copy">
												<span class="opt-label">{{ opt.label }}</span>
												<small class="opt-tip">{{ typeGuide(opt.code).short || opt.tip || '—' }}</small>
											</div>
											<code class="opt-code">{{ opt.code }}</code>
											<i v-if="form[item.key] === opt.code" class="opt-check" aria-hidden="true"></i>
										</div>
									</el-option>
								</el-option-group>
							</el-select>

							<div class="type-preview">
								<span class="preview-label">当前</span>
								<div class="preview-body">
									<strong>{{ resolveOption(form[item.key])?.label || form[item.key] || '未选择' }}</strong>
									<em>{{ typeGuide(form[item.key]).detail || resolveOption(form[item.key])?.tip || '请选择验证码交互类型' }}</em>
									<span class="preview-extra">{{ typeGuide(form[item.key]).extra }}</span>
								</div>
							</div>
						</div>
					</div>
				</div>
			</el-card>

			<!-- 4. 高级参数：独立卡片 -->
			<el-card
				class="org-auth-card page-card section-card"
				:class="{ dimmed: !needsAdvanced }"
				shadow="never"
			>
				<div class="card-head">
					<div class="card-head-copy">
						<span class="card-kicker">可选</span>
						<strong>高级参数</strong>
						<em>
							仅当某端选用「算力校验 PoW」或「Cloudflare Turnstile」时需要配置。
							<template v-if="needsAdvanced">当前已有端点选用了相关类型。</template>
							<template v-else>当前三端均未选用，可先忽略本区。</template>
						</em>
					</div>
				</div>
				<el-form label-position="top" class="adv-form">
					<div class="adv-grid">
						<div class="adv-item" :class="{ highlight: usedModes.has('pow') }">
							<div class="adv-item-head">
								<span class="adv-tag mode-pow">算力</span>
								<strong>PoW 难度</strong>
							</div>
							<el-form-item label="前导 0 个数">
								<el-input-number v-model="form.powDifficulty" :min="2" :max="5" />
							</el-form-item>
							<p class="field-help">
								浏览器循环计算 <code>SHA256(challenge + nonce)</code>，直到哈希以若干个
								<code>0</code> 开头。难度越大越难被脚本刷，但用户等待越久。建议
								<strong>2～4</strong>，最大 5。
							</p>
						</div>
						<div class="adv-item" :class="{ highlight: usedModes.has('turnstile') }">
							<div class="adv-item-head">
								<span class="adv-tag mode-turnstile">人机</span>
								<strong>Turnstile Site Key</strong>
							</div>
							<el-form-item label="站点公钥（前端）">
								<el-input v-model="form.turnstileSiteKey" clearable placeholder="例如 0x4AAAAA..." />
							</el-form-item>
							<p class="field-help">
								登录页加载 Cloudflare 组件时使用。在
								<a href="https://dash.cloudflare.com/" target="_blank" rel="noopener">Cloudflare 控制台</a>
								创建 Turnstile 站点后复制 Site Key。免费档即可满足常规登录。
							</p>
						</div>
						<div class="adv-item" :class="{ highlight: usedModes.has('turnstile') }">
							<div class="adv-item-head">
								<span class="adv-tag mode-turnstile">人机</span>
								<strong>Turnstile Secret Key</strong>
							</div>
							<el-form-item label="服务端密钥（后端）">
								<el-input
									v-model="form.turnstileSecretKey"
									clearable
									show-password
									placeholder="请填写 Secret Key，勿泄露"
								/>
							</el-form-item>
							<p class="field-help">
								后端调用 Cloudflare
								<code>siteverify</code> 校验 token。须与 Site Key 成对配置，勿写入前端或公开仓库。
							</p>
						</div>
					</div>
				</el-form>
			</el-card>

			<!-- 5. 操作条 -->
			<el-card class="org-auth-card page-card section-card actions-card" shadow="never">
				<div class="actions">
					<div class="actions-copy">
						<strong>保存后立即生效</strong>
						<em>仅影响之后新发起的验证码请求，不影响已下发未使用的旧 key。</em>
					</div>
					<div class="actions-btns">
						<el-button type="primary" :loading="saving" @click="onSave">保存配置</el-button>
						<el-button :disabled="loading || saving" @click="loadConfig">重新加载</el-button>
					</div>
				</div>
			</el-card>
		</div>
	</div>
</template>

<script setup lang="ts" name="SysCaptchaConfig">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useCaptchaConfigApi, useCaptchaConfigSaveApi } from '@/api/sys/captcha-config'

type CaptchaOption = { code: string; mode: string; tip: string; label: string }

const MODE_META: Record<string, string> = {
	input: '输入',
	click: '点选',
	slider: '拼图',
	word: '点字',
	curve: '滑动曲线',
	rotate: '旋转',
	angle: '角度',
	pow: '算力',
	turnstile: '人机'
}

const MODE_ORDER = ['input', 'click', 'slider', 'word', 'curve', 'rotate', 'angle', 'pow', 'turnstile']

/** 各验证方式说明（配置页引导用） */
const modeGuides = [
	{
		mode: 'input',
		badge: '输入',
		title: '字母 / 数字 / 汉字 / 算术',
		desc: '用户看图输入字符或计算结果，实现简单、兼容性最好。',
		points: ['经典图形验证码', '可被 OCR 脚本尝试破解', '适合内网或低风险场景'],
		when: '快速上线、兼容旧客户端'
	},
	{
		mode: 'click',
		badge: '点选',
		title: '点选图案',
		desc: '提示点击图中指定图标（如雨伞、飞机），点对才算通过。',
		points: ['交互明确，防刷强于输入', '需一次准确点击', '管理端已支持预校验反馈'],
		when: '管理后台希望更强防刷'
	},
	{
		mode: 'slider',
		badge: '拼图',
		title: '滑动拼图',
		desc: '拖动滑块将缺口拼块对齐；松手后服务端校验偏移。',
		points: ['常见行为验证形态', '对自动化脚本成本更高', '桌面端体验较好'],
		when: 'PC 登录默认推荐之一'
	},
	{
		mode: 'word',
		badge: '点字',
		title: '文字点选',
		desc: '按提示顺序依次点击图中汉字，顺序与位置都要正确。',
		points: ['多点确认，防刷更强', '手机端需注意点击精度', '点满后会预校验对错'],
		when: '安全要求更高的登录入口'
	},
	{
		mode: 'curve',
		badge: '曲线',
		title: '滑动曲线',
		desc: '底图两端固定端点与淡色绳影；亮绳两端钉死，拖动滑块摆动中点对齐后通过。',
		points: ['两端固定、中点摆动更直观', '仍为滑块交互，学习成本低', '适合中等风控场景'],
		when: '希望比普通拼图稍难、又保持滑块体验'
	},
	{
		mode: 'rotate',
		badge: '旋转',
		title: '旋转验证码',
		desc: '图片被随机旋转，拖动滑块转回正立（顶部标记朝上）。',
		points: ['行为验证，防脚本成本较高', '容差约 ±12°', 'PC / 触屏均可操作'],
		when: '需要更强行为验证、避免纯坐标拼图'
	},
	{
		mode: 'angle',
		badge: '角度',
		title: '角度验证码',
		desc: '表盘指针偏离正上方，拖动滑块旋转至绿色 12 点标记。',
		points: ['与旋转同类校验逻辑', '视觉为角度表盘更直观', '容差约 ±12°'],
		when: '希望用表盘交互替代风景旋转图'
	},
	{
		mode: 'pow',
		badge: '算力',
		title: '算力校验 PoW',
		desc: '浏览器静默算哈希找合法 nonce，用户几乎无操作。',
		points: ['无感或弱感验人', '提高批量撞库成本', '难度可在下方高级参数调节'],
		when: '希望少打扰用户、仍提高脚本成本'
	},
	{
		mode: 'turnstile',
		badge: '人机',
		title: 'Cloudflare Turnstile',
		desc: '嵌入 Cloudflare 人机组件，多数情况自动通过，偶发勾选。',
		points: ['官方免费档可用', '需配置 Site / Secret Key', '依赖外网访问 Cloudflare'],
		when: '可访问外网、希望托管式人机验证'
	}
]

/** 具体类型的短说明（下拉与预览） */
const TYPE_GUIDE: Record<string, { short: string; detail: string; extra: string }> = {
	spec: {
		short: '看图输入字母数字',
		detail: '显示扭曲字母与数字，用户手动输入。实现简单，防刷能力一般。',
		extra: '兼容性最好，适合低风险或配合短信二次校验。'
	},
	number: {
		short: '仅数字更易输入',
		detail: '验证码仅含数字，适合手机键盘快速输入。',
		extra: '比字母型更易被爆破，建议搭配登录失败锁定。'
	},
	chinese: {
		short: '输入图中汉字',
		detail: '显示汉字供用户输入，对海外 OCR 略有门槛。',
		extra: '注意字体渲染与移动端输入法体验。'
	},
	arithmetic: {
		short: '计算简单算式',
		detail: '如 3 + 5，用户填写结果。门槛低、实现快。',
		extra: '防刷弱，更适合演示或内网环境。'
	},
	pattern: {
		short: '点击指定图案',
		detail: '根据提示点击图中某个图标；位置偏差在容差内即通过。',
		extra: '管理端点选后会即时显示正确/错误。'
	},
	block_puzzle: {
		short: '拖动滑块对齐缺口',
		detail: '将拼图块拖到缺口位置，服务端校验横向偏移。',
		extra: 'PC 端体验佳；触屏设备注意拖动手感。'
	},
	click_word: {
		short: '按顺序点汉字',
		detail: '按提示依次点击图中文字，顺序与坐标均需正确。',
		extra: '点满后预校验；失败会自动换一张。'
	},
	curve: {
		short: '拖动滑块摆动绳子中点对齐',
		detail: '底图两端固定端点与淡色绳影；亮绳两端始终钉在端点上，拖动滑块只摆动中点，对齐绳影后通过。',
		extra: '两端固定、中点摆动，适合中等风控。'
	},
	rotate: {
		short: '旋转图片至正向',
		detail: '图片被随机旋转，拖动滑块转回正立方向。',
		extra: '容差约 ±12°；适合触屏与 PC。'
	},
	angle: {
		short: '旋转指针至正上方',
		detail: '表盘指针偏离 12 点方向，拖动滑块对齐绿色标记。',
		extra: '与旋转验证码同类校验，视觉为角度表盘。'
	},
	pow: {
		short: '浏览器静默算哈希',
		detail: '前端循环 SHA256，找到满足前导 0 的 nonce 后提交。',
		extra: '请在下方配置 PoW 难度（建议 2～4）。'
	},
	turnstile: {
		short: 'Cloudflare 人机组件',
		detail: '加载 Turnstile 小组件，通过后将 token 交后端 siteverify。',
		extra: '须配置 Site Key 与 Secret Key；服务器需能访问 Cloudflare。'
	}
}

const loading = ref(false)
const saving = ref(false)
const typeOptions = ref<CaptchaOption[]>([])

const form = reactive({
	enabled: false,
	pcType: 'spec',
	smsType: 'spec',
	appType: 'spec',
	powDifficulty: 3,
	turnstileSiteKey: '',
	turnstileSecretKey: ''
})

const channels = [
	{
		key: 'pcType' as const,
		index: '01',
		title: 'PC 管理端 · 账号登录',
		desc: '管理后台「账号登录」页使用的验证码',
		scene: '浏览器访问管理控制台，使用用户名 + 密码登录时弹出的验证交互。',
		notes: [
			'受上方「总开关」控制：关闭后账号登录可不做图形校验',
			'推荐：滑动拼图 / 滑动曲线 / 旋转 / 点选',
			'若选 Turnstile，请确保办公网络可访问 Cloudflare'
		]
	},
	{
		key: 'smsType' as const,
		index: '02',
		title: '短信发送 · 图形码',
		desc: '发短信验证码之前的人机校验',
		scene: 'PC「手机登录」、App/小程序点击「获取短信验证码」前，先过这一关，防止短信接口被刷。',
		notes: [
			'不受账号登录总开关影响，发短信前始终校验',
			'推荐：滑动拼图或输入型（操作快）',
			'避免过重交互导致用户拿不到短信'
		]
	},
	{
		key: 'appType' as const,
		index: '03',
		title: '移动端登录',
		desc: 'App / 小程序 / H5 账号密码登录',
		scene: '移动端使用账号密码直接登录时的验证码（与短信发码前的图形码是两套配置）。',
		notes: [
			'受账号登录总开关控制',
			'推荐：滑动拼图、滑动曲线、旋转；触屏点字需留足点击区域',
			'Turnstile / PoW 在小程序内可能受限，请先真机验证'
		]
	}
]

const optionGroups = computed(() => {
	const map = new Map<string, CaptchaOption[]>()
	for (const opt of typeOptions.value) {
		const mode = opt.mode || 'input'
		if (!map.has(mode)) map.set(mode, [])
		map.get(mode)!.push(opt)
	}
	return MODE_ORDER.filter(m => map.has(m)).map(mode => ({
		mode,
		label: `${MODE_META[mode] || mode}类`,
		items: map.get(mode)!
	}))
})

const usedModes = computed(() => {
	const modes = new Set<string>()
	for (const key of ['pcType', 'smsType', 'appType'] as const) {
		const opt = resolveOption(form[key])
		if (opt?.mode) modes.add(opt.mode)
	}
	return modes
})

const needsAdvanced = computed(() => usedModes.value.has('pow') || usedModes.value.has('turnstile'))

const resolveOption = (code: string) => typeOptions.value.find(o => o.code === code)

const modeLabel = (mode?: string) => MODE_META[mode || 'input'] || mode || '类型'

const typeGuide = (code?: string) => TYPE_GUIDE[code || ''] || { short: '', detail: '', extra: '' }

const loadConfig = async () => {
	loading.value = true
	try {
		const { data } = await useCaptchaConfigApi()
		form.enabled = !!data?.enabled
		form.pcType = data?.pcType || 'spec'
		form.smsType = data?.smsType || data?.mobileType || 'spec'
		form.appType = data?.appType || 'spec'
		form.powDifficulty = data?.powDifficulty || 3
		form.turnstileSiteKey = data?.turnstileSiteKey || ''
		form.turnstileSecretKey = data?.turnstileSecretKey || ''
		typeOptions.value = Array.isArray(data?.typeOptions) ? data.typeOptions : []
	} catch (e: any) {
		ElMessage.error(e?.msg || '加载验证码配置失败')
	} finally {
		loading.value = false
	}
}

const onSave = async () => {
	if (usedModes.value.has('turnstile') && (!form.turnstileSiteKey || !form.turnstileSecretKey)) {
		ElMessage.warning('已选用 Cloudflare Turnstile，请填写 Site Key 与 Secret Key')
	}
	saving.value = true
	try {
		await useCaptchaConfigSaveApi({
			enabled: form.enabled,
			pcType: form.pcType,
			smsType: form.smsType,
			mobileType: form.smsType,
			appType: form.appType,
			powDifficulty: form.powDifficulty,
			turnstileSiteKey: form.turnstileSiteKey,
			turnstileSecretKey: form.turnstileSecretKey
		})
		ElMessage.success('验证码配置已保存')
		await loadConfig()
	} catch (e: any) {
		ElMessage.error(e?.msg || '保存失败')
	} finally {
		saving.value = false
	}
}

onMounted(loadConfig)
</script>

<style scoped lang="scss">
.captcha-stack {
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.section-card {
	:deep(.el-card__body) {
		padding: 20px 22px 22px;
	}
}

.card-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 16px;
	margin-bottom: 16px;
	padding-bottom: 14px;
	border-bottom: 1px solid #eef2f6;
}

.card-head-copy {
	min-width: 0;
	flex: 1;
}

.card-kicker {
	display: inline-flex;
	align-items: center;
	height: 22px;
	padding: 0 8px;
	margin-bottom: 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 720;
	letter-spacing: 0.06em;
	color: #0879a8;
	background: rgba(0, 168, 232, 0.1);
	border: 1px solid rgba(0, 168, 232, 0.16);
}

.guide-section {
	background:
		linear-gradient(180deg, #f8fafc 0%, #fff 48%),
		#fff;

	:deep(.el-card__body) {
		background: transparent;
	}
}

.guide-section .card-kicker {
	color: #64748b;
	background: #f1f5f9;
	border-color: #e2e8f0;
}

.card-head-copy strong {
	display: block;
	font-size: 16px;
	font-weight: 740;
	color: #0f1724;
}

.card-head-copy em {
	display: block;
	margin-top: 6px;
	font-style: normal;
	font-size: 13px;
	color: #8b93a7;
	line-height: 1.55;
	max-width: 920px;
}

.card-hint {
	flex-shrink: 0;
	margin-top: 28px;
	padding: 6px 10px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 650;
	color: #8492a6;
	background: #f8fafc;
	border: 1px dashed #e2e8f0;
	white-space: nowrap;
}

.switch-panel {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
	padding: 16px 18px;
	border-radius: 16px;
	border: 1px solid #e6eef5;
	background: linear-gradient(135deg, #f8fafc, #fff);

	&.on {
		border-color: rgba(0, 168, 232, 0.28);
		background: linear-gradient(135deg, rgba(0, 168, 232, 0.08), #fff);
	}
}

.switch-copy {
	min-width: 0;
}

.switch-title {
	display: block;
	font-size: 14px;
	font-weight: 700;
	color: #0f172a;
}

.switch-desc {
	display: block;
	margin-top: 6px;
	font-size: 12.5px;
	line-height: 1.5;
	color: #64748b;
}

.guide-grid {
	display: grid;
	grid-template-columns: repeat(3, minmax(0, 1fr));
	gap: 12px;
}

.guide-card {
	--accent: #3b82f6;
	display: flex;
	flex-direction: column;
	gap: 8px;
	padding: 14px 15px;
	border-radius: 14px;
	border: 1px solid var(--icejz-card-border, #e8eef5);
	background: var(--icejz-card-bg, #fff);
	transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;

	&.active {
		border-color: color-mix(in srgb, var(--accent) 40%, #e8eef5);
		box-shadow: 0 10px 22px color-mix(in srgb, var(--accent) 12%, transparent);
		transform: translateY(-1px);
	}

	&.mode-input {
		--accent: #3b82f6;
	}
	&.mode-click {
		--accent: #0d9488;
	}
	&.mode-slider {
		--accent: #d97706;
	}
	&.mode-word {
		--accent: #7c3aed;
	}
	&.mode-curve {
		--accent: #0891b2;
	}
	&.mode-rotate {
		--accent: #db2777;
	}
	&.mode-angle {
		--accent: #4f46e5;
	}
	&.mode-pow {
		--accent: #64748b;
	}
	&.mode-turnstile {
		--accent: #f97316;
	}
}

.guide-head {
	display: flex;
	align-items: center;
	gap: 8px;
	min-width: 0;

	strong {
		flex: 1;
		min-width: 0;
		font-size: 13px;
		font-weight: 720;
		color: #0f172a;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
}

.guide-badge {
	flex: none;
	height: 22px;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 720;
	color: var(--accent);
	background: color-mix(in srgb, var(--accent) 12%, #fff);
	border: 1px solid color-mix(in srgb, var(--accent) 18%, transparent);
	display: inline-flex;
	align-items: center;
}

.guide-used {
	flex: none;
	font-style: normal;
	font-size: 11px;
	font-weight: 700;
	color: var(--accent);
}

.guide-desc {
	margin: 0;
	font-size: 12.5px;
	line-height: 1.5;
	color: #475569;
}

.guide-points {
	margin: 0;
	padding-left: 16px;
	font-size: 12px;
	line-height: 1.55;
	color: #64748b;

	li + li {
		margin-top: 2px;
	}
}

.guide-when {
	margin-top: auto;
	padding-top: 6px;
	font-size: 11.5px;
	font-weight: 650;
	color: var(--accent);
	border-top: 1px dashed color-mix(in srgb, var(--accent) 22%, #e8eef5);
}

.channel-grid {
	display: grid;
	grid-template-columns: repeat(3, minmax(0, 1fr));
	gap: 16px;
}

.channel-config {
	display: flex;
	flex-direction: column;
	gap: 12px;
	padding-top: 12px;
	border-top: 1px dashed #e2e8f0;
}

.channel-card {
	--accent: #3b82f6;
	display: flex;
	flex-direction: column;
	gap: 12px;
	padding: 18px;
	border-radius: 16px;
	border: 1px solid #e6eef5;
	background:
		linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(247, 250, 252, 0.96)),
		linear-gradient(135deg, color-mix(in srgb, var(--accent) 10%, transparent), transparent 42%);
	transition: border-color 0.2s ease-out, transform 0.2s ease-out;

	&:hover {
		border-color: color-mix(in srgb, var(--accent) 35%, #e6eef5);
		transform: translateY(-1px);
	}

	&[data-mode='input'] {
		--accent: #3b82f6;
	}
	&[data-mode='click'] {
		--accent: #0d9488;
	}
	&[data-mode='slider'] {
		--accent: #d97706;
	}
	&[data-mode='word'] {
		--accent: #7c3aed;
	}
	&[data-mode='curve'] {
		--accent: #0891b2;
	}
	&[data-mode='rotate'] {
		--accent: #db2777;
	}
	&[data-mode='angle'] {
		--accent: #4f46e5;
	}
	&[data-mode='pow'] {
		--accent: #64748b;
	}
	&[data-mode='turnstile'] {
		--accent: #f97316;
	}
}

.channel-head {
	display: flex;
	align-items: flex-start;
	gap: 12px;
}

.channel-index {
	flex: none;
	width: 36px;
	height: 36px;
	border-radius: 10px;
	display: grid;
	place-items: center;
	font-size: 12px;
	font-weight: 700;
	letter-spacing: 0.04em;
	color: var(--accent);
	background: color-mix(in srgb, var(--accent) 12%, #fff);
	border: 1px solid color-mix(in srgb, var(--accent) 18%, #e6eef5);
}

.channel-name {
	display: block;
	font-size: 14px;
	font-weight: 700;
	color: #111827;
}

.channel-tip {
	display: block;
	margin-top: 4px;
	font-size: 12px;
	line-height: 1.45;
	color: #8b93a7;
}

.channel-scene {
	padding: 10px 12px;
	border-radius: 12px;
	background: rgba(255, 255, 255, 0.72);
	border: 1px dashed color-mix(in srgb, var(--accent) 22%, #e2e8f0);

	.scene-label {
		display: inline-block;
		margin-bottom: 4px;
		font-size: 11px;
		font-weight: 720;
		letter-spacing: 0.04em;
		color: var(--accent);
	}

	p {
		margin: 0 0 6px;
		font-size: 12.5px;
		line-height: 1.5;
		color: #334155;
	}

	ul {
		margin: 0;
		padding-left: 16px;
		font-size: 12px;
		line-height: 1.5;
		color: #64748b;

		li + li {
			margin-top: 2px;
		}
	}
}

.field-label {
	font-size: 12px;
	font-weight: 650;
	color: #64748b;
}

.type-select {
	width: 100%;

	:deep(.el-select__wrapper) {
		min-height: 48px;
		padding: 6px 12px;
		border-radius: 12px;
		box-shadow: 0 0 0 1px #e2e8f0 inset;
		background: var(--icejz-card-bg, #fff);
		transition: box-shadow 0.2s ease-out, background-color 0.2s ease-out;
	}

	:deep(.el-select__wrapper.is-focused),
	:deep(.el-select__wrapper:hover) {
		box-shadow: 0 0 0 1px color-mix(in srgb, var(--accent) 55%, #cbd5e1) inset;
	}

	:deep(.el-select__selection) {
		gap: 8px;
	}

	:deep(.el-select__placeholder),
	:deep(.el-select__selected-item) {
		font-size: 14px;
		font-weight: 600;
		color: #0f172a;
	}

	:deep(.el-select__prefix) {
		margin-right: 2px;
	}
}

.select-mode {
	display: inline-flex;
	align-items: center;
	height: 24px;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	letter-spacing: 0.02em;
	color: var(--accent, #3b82f6);
	background: color-mix(in srgb, var(--accent, #3b82f6) 14%, #fff);
	border: 1px solid color-mix(in srgb, var(--accent, #3b82f6) 22%, transparent);
}

.type-preview {
	display: grid;
	grid-template-columns: auto 1fr;
	column-gap: 10px;
	padding: 10px 12px;
	border-radius: 12px;
	background: color-mix(in srgb, var(--accent) 6%, #f8fafc);
	border: 1px solid color-mix(in srgb, var(--accent) 12%, #e8eef5);

	.preview-label {
		align-self: start;
		padding-top: 2px;
		font-size: 11px;
		font-weight: 700;
		color: var(--accent);
		writing-mode: vertical-lr;
		text-orientation: upright;
		letter-spacing: 0.12em;
	}

	.preview-body {
		min-width: 0;
		display: flex;
		flex-direction: column;
		gap: 4px;
	}

	strong {
		font-size: 13px;
		color: #0f172a;
	}

	em {
		font-style: normal;
		font-size: 12px;
		line-height: 1.45;
		color: #64748b;
	}

	.preview-extra {
		font-size: 11.5px;
		line-height: 1.45;
		color: #94a3b8;
	}
}

.section-card.dimmed {
	opacity: 0.72;
}

.adv-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 16px;
}

.adv-item {
	display: flex;
	flex-direction: column;
	gap: 4px;
	padding: 14px 16px;
	border-radius: 14px;
	border: 1px solid var(--icejz-card-border, #e8eef5);
	background: var(--icejz-card-bg, #fff);
	transition: border-color 0.18s ease, box-shadow 0.18s ease;

	:deep(.el-form-item) {
		margin-bottom: 8px;
	}

	&:first-child {
		grid-column: 1 / -1;
		max-width: 520px;
	}

	&.highlight {
		border-color: rgba(0, 168, 232, 0.28);
		box-shadow: 0 8px 18px rgba(0, 168, 232, 0.06);
	}
}

.adv-item-head {
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 6px;

	strong {
		font-size: 13px;
		color: #0f172a;
	}
}

.adv-tag {
	height: 22px;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 720;
	display: inline-flex;
	align-items: center;

	&.mode-pow {
		color: #be185d;
		background: #fce7f3;
	}

	&.mode-turnstile {
		color: #334155;
		background: #e2e8f0;
	}
}

.field-help {
	margin: 0;
	padding: 10px 12px;
	border-radius: 10px;
	font-size: 12px;
	line-height: 1.55;
	color: #64748b;
	background: #f8fafc;
	border: 1px solid #e8eef5;

	strong,
	code {
		color: #0f172a;
		font-weight: 650;
	}

	code {
		font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
		font-size: 11px;
		font-weight: 600;
		padding: 1px 4px;
		border-radius: 4px;
		background: #eef2f7;
	}

	a {
		color: #0284c7;
		text-decoration: none;

		&:hover {
			text-decoration: underline;
		}
	}
}

.actions-card {
	:deep(.el-card__body) {
		padding: 16px 22px;
	}
}

.actions {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
	flex-wrap: wrap;
}

.actions-copy {
	min-width: 0;

	strong {
		display: block;
		font-size: 14px;
		font-weight: 720;
		color: #0f172a;
	}

	em {
		display: block;
		margin-top: 4px;
		font-style: normal;
		font-size: 12px;
		color: #8492a6;
		line-height: 1.45;
	}
}

.actions-btns {
	display: flex;
	gap: 12px;
	flex-shrink: 0;
}

.hero-chip.on {
	color: #047857;
	border-color: rgba(16, 185, 129, 0.28);
	background: rgba(16, 185, 129, 0.08);
}

@media (max-width: 1200px) {
	.guide-grid {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}
}

@media (max-width: 1100px) {
	.channel-grid,
	.adv-grid,
	.guide-grid {
		grid-template-columns: 1fr;
	}

	.adv-item:first-child {
		max-width: none;
	}

	.card-hint {
		display: none;
	}

	.actions {
		align-items: stretch;
	}

	.actions-btns {
		width: 100%;
	}

	.actions-btns .el-button {
		flex: 1;
	}
}
</style>

<style lang="scss">
.captcha-type-popper.el-select__popper,
.captcha-type-popper {
	border: 1px solid #e2e8f0 !important;
	border-radius: 14px !important;
	overflow: hidden;
	box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12) !important;

	.el-select-dropdown__wrap {
		max-height: 360px;
	}

	.el-select-group__title {
		padding: 10px 14px 6px;
		font-size: 11px;
		font-weight: 700;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: #94a3b8;
	}

	.el-select-dropdown__item {
		height: auto;
		padding: 0;
		line-height: 1.3;
	}

	.el-select-dropdown__item.is-selected {
		background: transparent;
		font-weight: inherit;
		color: inherit;
	}

	.el-select-dropdown__item.is-hovering,
	.el-select-dropdown__item:hover {
		background: transparent;
	}

	.opt-item {
		display: grid;
		grid-template-columns: auto 1fr auto auto;
		align-items: center;
		gap: 10px;
		margin: 4px 8px;
		padding: 10px 12px;
		border-radius: 12px;
		border: 1px solid transparent;
		transition: background-color 0.18s ease-out, border-color 0.18s ease-out;

		&.active,
		&:hover {
			background: #f8fafc;
			border-color: #e2e8f0;
		}

		&.active {
			background: linear-gradient(90deg, #eff6ff, #f8fafc);
			border-color: #bfdbfe;
		}
	}

	.opt-mode {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		min-width: 40px;
		height: 24px;
		padding: 0 8px;
		border-radius: 8px;
		font-size: 11px;
		font-weight: 700;
		color: #334155;
		background: #eef2f7;
	}

	.opt-mode.mode-input {
		color: #1d4ed8;
		background: #dbeafe;
	}
	.opt-mode.mode-click {
		color: #0f766e;
		background: #ccfbf1;
	}
	.opt-mode.mode-slider {
		color: #b45309;
		background: #ffedd5;
	}
	.opt-mode.mode-curve {
		color: #0e7490;
		background: #cffafe;
	}
	.opt-mode.mode-rotate {
		color: #be185d;
		background: #fce7f3;
	}
	.opt-mode.mode-angle {
		color: #4338ca;
		background: #e0e7ff;
	}
	.opt-mode.mode-word {
		color: #6d28d9;
		background: #ede9fe;
	}
	.opt-mode.mode-pow {
		color: #be185d;
		background: #fce7f3;
	}
	.opt-mode.mode-turnstile {
		color: #334155;
		background: #e2e8f0;
	}

	.opt-copy {
		min-width: 0;
		display: flex;
		flex-direction: column;
		gap: 2px;
	}

	.opt-label {
		font-size: 13px;
		font-weight: 650;
		color: #0f172a;
	}

	.opt-tip {
		font-size: 12px;
		color: #94a3b8;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.opt-code {
		font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
		font-size: 11px;
		color: #64748b;
		background: #f1f5f9;
		border-radius: 6px;
		padding: 3px 6px;
	}

	.opt-check {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: #2563eb;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.16);
	}
}
</style>
