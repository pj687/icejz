<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>系统配置</h2>
				<p>集中维护短信、邮件与第三方登录等基础设施接入</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip">通道配置</span>
				<span class="hero-chip">安全接入</span>
			</div>
		</section>

		<el-card class="org-auth-card page-card config-shell" shadow="never">
			<el-tabs v-model="activeName" class="sys-admin-tabs">
				<el-tab-pane v-auth="'sys:sms:config'" label="短信配置" name="sms">
					<SmsConfig />
				</el-tab-pane>
				<el-tab-pane v-auth="'sys:mail:config'" label="邮件配置" name="email">
					<MailConfig />
				</el-tab-pane>
				<el-tab-pane v-auth="'sys:third:config'" label="第三方登录" name="third">
					<ThirdConfig />
				</el-tab-pane>
			</el-tabs>
		</el-card>
	</div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import SmsConfig from './sms/index.vue'
import MailConfig from './mail/index.vue'
import ThirdConfig from './third/index.vue'

const activeName = ref('sms')
</script>

<style scoped lang="scss">
.config-shell {
	:deep(.el-tabs__content) {
		overflow: visible;
	}
}
</style>
