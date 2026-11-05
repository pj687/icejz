package net.icejz.app.data.repository

import net.icejz.app.IcejzApp
import net.icejz.app.data.model.DeviceItem
import net.icejz.app.data.model.LoginSecurity
import net.icejz.app.data.model.PasswordUpdate
import net.icejz.app.data.model.UserInfo
import net.icejz.app.data.remote.ApiClient
import net.icejz.app.data.remote.apiCall
import net.icejz.app.data.remote.apiCallNullable
import net.icejz.app.util.Sm2Util

class UserRepository {
    private val api get() = ApiClient.api
    private val cache get() = IcejzApp.instance.cache

    suspend fun info(): UserInfo = apiCall { api.userInfo() }.also { cache.setUserInfo(it) }

    suspend fun updateInfo(user: UserInfo) {
        apiCallNullable { api.updateUserInfo(user) }
        cache.setUserInfo(user)
    }

    suspend fun updatePassword(old: String, newPwd: String) {
        apiCallNullable {
            api.updatePassword(
                PasswordUpdate(
                    password = Sm2Util.encrypt(old),
                    newPassword = Sm2Util.encrypt(newPwd)
                )
            )
        }
    }

    suspend fun devices(): List<DeviceItem> = apiCallNullable { api.devices() }.orEmpty()

    suspend fun kickDevice(token: String) {
        apiCallNullable { api.kickDevice(token) }
    }

    suspend fun loginSecurity(): LoginSecurity =
        apiCallNullable { api.loginSecurity() } ?: LoginSecurity()

    suspend fun saveLoginSecurity(security: LoginSecurity) {
        apiCallNullable { api.saveLoginSecurity(security) }
    }
}
