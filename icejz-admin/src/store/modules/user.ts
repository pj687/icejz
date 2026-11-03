import { defineStore } from 'pinia'
import { useAccountLoginApi, useMobileLoginApi, useLogoutApi, useThirdLoginApi } from '@/api/auth'
import { useUserInfoApi } from '@/api/sys/user'
import cache from '@/utils/cache'
import { useAuthorityListApi } from '@/api/sys/menu'
import { useRouterStore } from '@/store/modules/router'
import { useTabsStore } from '@/store/modules/tabs'

export const useUserStore = defineStore('userStore', {
	state: () => ({
		// 用户信息
		user: {
			id: '',
			superAdmin: 0,
			username: '',
			realName: '',
			gender: 0,
			mobile: '',
			email: '',
			avatar: '',
			signature: '',
			orgName: '',
			postNameList: [],
			createTime: ''
		},
		// 权限列表
		authorityList: [],
		// 访问token
		token: cache.getToken(),
		// 刷新token
		refreshToken: cache.getRefreshToken()
	}),
	actions: {
		setUser(val: any) {
			this.user = val
		},
		setToken(val: any) {
			this.token = val
			cache.setToken(val)
		},
		setRefreshToken(val: any) {
			this.refreshToken = val
			cache.setRefreshToken(val)
		},
		// 账号登录
		async accountLoginAction(loginForm: any) {
			const { data } = await useAccountLoginApi(loginForm)
			// 重新登录先清菜单/路由/页签，避免沿用上一账号缓存
			await this.clearSessionState()
			this.setToken(data.access_token)
			this.setRefreshToken(data.refresh_token)
		},
		// 手机号登录
		async mobileLoginAction(loginForm: any) {
			const { data } = await useMobileLoginApi(loginForm)
			await this.clearSessionState()
			this.setToken(data.access_token)
			this.setRefreshToken(data.refresh_token)
		},
		// 第三方登录
		async thirdLoginAction(loginForm: any) {
			const { data } = await useThirdLoginApi(loginForm)
			await this.clearSessionState()
			this.setToken(data.access_token)
			this.setRefreshToken(data.refresh_token)
		},
		// 获取用户信息
		async getUserInfoAction() {
			const { data } = await useUserInfoApi()
			this.setUser(data)
		},
		// 获取权限
		async getAuthorityListAction() {
			const { data } = await useAuthorityListApi()
			this.authorityList = data || []
		},
		/** 清空会话相关状态：菜单、页签、跳转缓存、用户信息（避免换账号 404） */
		async clearSessionState() {
			try {
				useRouterStore().resetMenuRoutes()
			} catch (e) {
				/* ignore */
			}
			try {
				useTabsStore().delAllViews()
			} catch (e) {
				/* ignore */
			}
			try {
				// 动态 import 避免与 router ↔ user 循环依赖
				const { resetRouter } = await import('@/router')
				resetRouter?.()
			} catch (e) {
				/* ignore */
			}
			cache.clearRedirect()
			this.authorityList = []
			this.user = {
				id: '',
				superAdmin: 0,
				username: '',
				realName: '',
				gender: 0,
				mobile: '',
				email: '',
				avatar: '',
				signature: '',
				orgName: '',
				postNameList: [],
				createTime: ''
			}
		},
		// 用户退出
		async logoutAction() {
			try {
				await useLogoutApi()
			} catch (e) {
				/* 接口失败也继续本地清理 */
			}

			this.setToken(null)
			this.setRefreshToken(null)
			await this.clearSessionState()
		}
	}
})
