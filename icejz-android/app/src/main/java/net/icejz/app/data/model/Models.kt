package net.icejz.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class ApiResult<T>(
    val code: Int = -1,
    val msg: String? = null,
    val data: T? = null
)

@Serializable
data class PageResult<T>(
    val total: Long = 0,
    val list: List<T> = emptyList()
)

@Serializable
data class CaptchaData(
    val key: String? = null,
    val image: String? = null,
    val tip: String? = null,
    val mode: String? = null,
    val type: String? = null,
    val siteKey: String? = null,
    val jigsawImage: String? = null,
    val jigsawY: Int = 0,
    val words: List<String> = emptyList(),
    val challenge: String? = null,
    val difficulty: Int = 3
)

@Serializable
data class LoginRequest(
    val username: String? = null,
    val password: String? = null,
    val key: String? = null,
    val captcha: String? = null,
    val mobile: String? = null,
    val code: String? = null
)

@Serializable
data class SendCodeRequest(
    val mobile: String,
    val key: String,
    val captcha: String
)

@Serializable
data class CompleteProfileRequest(
    val userId: Long? = null,
    val roleId: Long? = null,
    val realName: String? = null,
    val gender: Int = 2,
    val mobile: String? = null,
    val orgId: Long? = null,
    val password: String? = null
)

@Serializable
data class TokenData(
    @SerialName("access_token") val accessTokenSnake: String? = null,
    val accessToken: String? = null,
    val token: String? = null,
    val needCompleteProfile: Boolean = false,
    val firstLogin: Boolean = false,
    val userId: Long? = null,
    val mobile: String? = null,
    val roleIdList: List<Long> = emptyList()
) {
    fun resolveToken(): String? = accessTokenSnake ?: accessToken ?: token
}

@Serializable
data class UserInfo(
    val id: Long? = null,
    val username: String? = null,
    val realName: String? = null,
    val avatar: String? = null,
    val gender: Int? = null,
    val email: String? = null,
    val mobile: String? = null,
    val orgId: Long? = null,
    val orgName: String? = null,
    val postNameList: List<String> = emptyList(),
    val status: Int? = null
)

@Serializable
data class SysUser(
    val id: Long? = null,
    val username: String? = null,
    val realName: String? = null,
    val mobile: String? = null,
    val email: String? = null,
    val gender: Int? = null,
    val status: Int? = null,
    val orgName: String? = null,
    val createTime: String? = null
)

@Serializable
data class SysOrg(
    val id: Long? = null,
    val name: String? = null,
    val parentId: Long? = null,
    val sort: Int? = null,
    val children: List<SysOrg> = emptyList()
)

@Serializable
data class SysRole(
    val id: Long? = null,
    val name: String? = null,
    val roleCode: String? = null,
    val remark: String? = null,
    val createTime: String? = null
)

@Serializable
data class MessageItem(
    val id: Long? = null,
    val title: String? = null,
    val content: String? = null,
    val type: Int? = null,
    val readStatus: Int? = null,
    val sendTime: String? = null,
    val createTime: String? = null
)

@Serializable
data class DeviceItem(
    val accessToken: String? = null,
    val deviceType: String? = null,
    val deviceName: String? = null,
    val ip: String? = null,
    val loginTime: String? = null,
    val current: Boolean = false
)

@Serializable
data class LoginSecurity(
    val multiDeviceLogin: Int = 1
)

@Serializable
data class PasswordUpdate(
    val password: String,
    val newPassword: String
)

@Serializable
data class AiChatRequest(
    val content: String,
    val sessionId: Long? = null,
    val modelId: Long? = null
)

@Serializable
data class AiChatReply(
    val content: String? = null,
    val sessionId: Long? = null,
    val modelId: Long? = null
)

@Serializable
data class AiSession(
    val id: Long? = null,
    val title: String? = null,
    val createTime: String? = null
)

@Serializable
data class AiMessage(
    val id: Long? = null,
    val role: String? = null,
    val content: String? = null,
    val createTime: String? = null
)

@Serializable
data class AiRobot(
    val name: String? = null,
    val greeting: String? = null,
    val avatar: String? = null
)

@Serializable
data class JsonBag(
    val raw: JsonElement? = null
)
