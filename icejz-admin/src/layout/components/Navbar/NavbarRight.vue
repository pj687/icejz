<template>
	<div class="navbar-right">
		<Lang />
		<ComponentSize />
		<Search />
		<Fullscreen />
		<User />
		<ThemeSettings />
	</div>
</template>

<script setup lang="ts">
import Lang from './components/Lang.vue'
import Search from './components/Search.vue'
import ComponentSize from './components/ComponentSize.vue'
import Fullscreen from './components/Fullscreen.vue'
import User from './components/User.vue'
import ThemeSettings from './components/ThemeSettings.vue'
</script>

<style lang="scss" scoped>
.navbar-right {
	display: flex;
	align-items: center;
	justify-content: flex-end;
	gap: 2px;
}
</style>
