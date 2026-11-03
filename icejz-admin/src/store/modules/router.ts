import { defineStore } from 'pinia'
import { useMenuNavApi } from '@/api/sys/menu'
import { generateRoutes, constantMenu, dashboardMenu } from '@/router'
import { RouteRecordRaw } from 'vue-router'

export const useRouterStore = defineStore('routerStore', {
	state: () => ({
		menuRoutes: [] as RouteRecordRaw[],
		searchMenu: [] as RouteRecordRaw[],
		routes: [] as RouteRecordRaw[]
	}),
	actions: {
		async getMenuRoutes() {
			const { data } = await useMenuNavApi()
			const routes = generateRoutes(data)

			// 控制台菜单
			const dashboardRoutes = generateRoutes(dashboardMenu)
			// 常量菜单
			const constantRoutes = generateRoutes(constantMenu)

			// 每次拉取都整体替换，避免换账号后叠加旧菜单
			this.menuRoutes = [...dashboardRoutes, ...routes, ...constantRoutes]

			return this.menuRoutes
		},
		setSearchMenu(routers: RouteRecordRaw[]) {
			this.searchMenu = routers
		},
		setRoutes(routers: RouteRecordRaw[]) {
			this.routes = routers
		},
		/** 退出登录时清空菜单/路由缓存，避免下一账号沿用旧菜单导致 404 */
		resetMenuRoutes() {
			this.menuRoutes = []
			this.searchMenu = []
			this.routes = []
		}
	}
})
