package net.icejz.app.data.repository

import net.icejz.app.IcejzApp
import net.icejz.app.data.model.CaptchaData
import net.icejz.app.data.model.CompleteProfileRequest
import net.icejz.app.data.model.LoginRequest
import net.icejz.app.data.model.SendCodeRequest
import net.icejz.app.data.model.TokenData
import net.icejz.app.data.model.UserInfo
import net.icejz.app.data.remote.ApiClient
import net.icejz.app.data.remote.apiCall
import net.icejz.app.data.remote.apiCallNullable
import net.icejz.app.util.Sm2Util

class AuthRepository {
    private val api get() = ApiClient.api
    private val cache get() = IcejzApp.instance.cache

    suspend fun captchaEnabled(): Boolean = apiCallNullable { api.captchaEnabled() } ?: true

    suspend fun loadCaptcha(channel: String = "app"): CaptchaData =
        apiCall { api.captcha(channel) }

    suspend fun loginAccount(username: String, password: String, key: String?, captcha: String?): TokenData {
        val body = LoginRequest(
            username = username,
            password = Sm2Util.encrypt(password),
            key = key,
            captcha = captcha
        )
        return apiCall { api.login(body) }
    }

    suspend fun sendCode(mobile: String, key: String, captcha: String) {
        apiCallNullable { api.sendCode(SendCodeRequest(mobile, key, captcha)) }
    }

    suspend fun loginMobile(mobile: String, code: String): TokenData =
        apiCall { api.mobileLogin(LoginRequest(mobile = mobile, code = code)) }

    suspend fun completeProfile(req: CompleteProfileRequest): TokenData =
        apiCall {
            api.completeProfile(
                req.copy(password = req.password ?: Sm2Util.encrypt(req.mobile.orEmpty()))
            )
        }

    suspend fun persistLogin(tokenData: TokenData): UserInfo? {
        val token = tokenData.resolveToken() ?: error("登录令牌为空")
        cache.setToken(token)
        return runCatching { apiCall { api.userInfo() }.also { cache.setUserInfo(it) } }.getOrNull()
    }

    suspend fun logout() {
        runCatching { api.logout() }
        cache.removeToken()
        cache.removeUserInfo()
    }

    fun currentToken(): String? = cache.getToken()
    fun currentUser(): UserInfo? = cache.getUserInfo()
}
