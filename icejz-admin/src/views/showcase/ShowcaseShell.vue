<template>
	<div class="showcase-page">
		<header class="sc-hero">
			<div class="hero-copy">
				<span class="kicker">{{ kicker }}</span>
				<h1>{{ title }}</h1>
				<p v-if="desc">{{ desc }}</p>
			</div>
			<div v-if="$slots.actions" class="hero-actions">
				<slot name="actions" />
			</div>
		</header>
		<section class="sc-body">
			<slot />
		</section>
	</div>
</template>

<script setup lang="ts">
withDefaults(
	defineProps<{
		title: string
		desc?: string
		kicker?: string
	}>(),
	{ kicker: 'Showcase', desc: '' }
)
</script>

<style scoped lang="scss">
.showcase-page {
	--sc-ink: #0f1724;
	--sc-muted: #64748b;
	--sc-panel: #fff;
	--sc-soft: #ecf7fd;
	--sc-brand: #007eb8;
	display: flex;
	flex-direction: column;
	gap: 16px;
	min-height: calc(100vh - 140px);
	padding: 2px;
	animation: sc-rise 0.4s ease both;
	background:
		radial-gradient(820px 320px at 100% -10%, rgba(0, 168, 232, 0.1), transparent 55%),
		radial-gradient(640px 260px at 0% 100%, rgba(47, 191, 164, 0.07), transparent 50%);
}

.sc-hero {
	display: flex;
	align-items: flex-end;
	justify-content: space-between;
	gap: 16px;
	padding: 18px 20px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background:
		linear-gradient(135deg, color-mix(in srgb, var(--sc-panel) 96%, transparent), color-mix(in srgb, var(--sc-soft) 90%, transparent));
	box-shadow: 0 12px 28px rgba(15, 40, 64, 0.05);
}

.hero-copy {
	min-width: 0;

	.kicker {
		display: inline-block;
		margin-bottom: 6px;
		padding: 3px 10px;
		border-radius: 999px;
		font-size: 11px;
		font-weight: 750;
		letter-spacing: 0.04em;
		color: var(--sc-brand);
		background: rgba(0, 168, 232, 0.12);
		border: 1px solid rgba(0, 168, 232, 0.18);
	}

	h1 {
		margin: 0;
		font-size: 22px;
		font-weight: 780;
		color: var(--sc-ink);
		letter-spacing: -0.02em;
	}

	p {
		margin: 8px 0 0;
		font-size: 13.5px;
		line-height: 1.6;
		color: var(--sc-muted);
	}
}

.hero-actions {
	display: flex;
	align-items: center;
	gap: 10px;
	flex-shrink: 0;
}

.sc-body {
	flex: 1;
	min-height: 0;
}

@keyframes sc-rise {
	from {
		opacity: 0;
		transform: translateY(8px);
	}
	to {
		opacity: 1;
		transform: none;
	}
}

@media (max-width: 720px) {
	.sc-hero {
		flex-direction: column;
		align-items: stretch;
	}
}
</style>
