package net.icejz.app.data.remote

import net.icejz.app.data.model.AiChatReply
import net.icejz.app.data.model.AiChatRequest
import net.icejz.app.data.model.AiMessage
import net.icejz.app.data.model.AiRobot
import net.icejz.app.data.model.AiSession
import net.icejz.app.data.model.ApiResult
import net.icejz.app.data.model.CaptchaData
import net.icejz.app.data.model.CompleteProfileRequest
import net.icejz.app.data.model.DeviceItem
import net.icejz.app.data.model.LoginRequest
import net.icejz.app.data.model.LoginSecurity
import net.icejz.app.data.model.MessageItem
import net.icejz.app.data.model.PageResult
import net.icejz.app.data.model.PasswordUpdate
import net.icejz.app.data.model.SendCodeRequest
import net.icejz.app.data.model.SysOrg
import net.icejz.app.data.model.SysRole
import net.icejz.app.data.model.SysUser
import net.icejz.app.data.model.TokenData
import net.icejz.app.data.model.UserInfo
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Path
import retrofit2.http.Query
import retrofit2.http.QueryMap

interface ApiService {
    @GET("/sys/auth/captcha/enabled")
    suspend fun captchaEnabled(): ApiResult<Boolean>

    @GET("/sys/auth/captcha")
    suspend fun captcha(@Query("channel") channel: String = "app"): ApiResult<CaptchaData>

    @GET("/sys/auth/public-key")
    suspend fun publicKey(): ApiResult<String>

    @POST("/sys/auth/login")
    suspend fun login(@Body body: LoginRequest): ApiResult<TokenData>

    @POST("/sys/auth/send/code")
    suspend fun sendCode(@Body body: SendCodeRequest): ApiResult<Any?>

    @POST("/sys/auth/mobile")
    suspend fun mobileLogin(@Body body: LoginRequest): ApiResult<TokenData>

    @POST("/sys/auth/complete-profile")
    suspend fun completeProfile(@Body body: CompleteProfileRequest): ApiResult<TokenData>

    @POST("/sys/auth/logout")
    suspend fun logout(): ApiResult<Any?>

    @GET("/sys/user/info")
    suspend fun userInfo(): ApiResult<UserInfo>

    @PUT("/sys/user/info")
    suspend fun updateUserInfo(@Body body: UserInfo): ApiResult<Any?>

    @PUT("/sys/user/password")
    suspend fun updatePassword(@Body body: PasswordUpdate): ApiResult<Any?>

    @GET("/sys/user/device")
    suspend fun devices(): ApiResult<List<DeviceItem>>

    @DELETE("/sys/user/device/{accessToken}")
    suspend fun kickDevice(@Path("accessToken") accessToken: String): ApiResult<Any?>

    @GET("/sys/user/login-security")
    suspend fun loginSecurity(): ApiResult<LoginSecurity>

    @PUT("/sys/user/login-security")
    suspend fun saveLoginSecurity(@Body body: LoginSecurity): ApiResult<Any?>

    @GET("/sys/user/page")
    suspend fun userPage(@QueryMap params: Map<String, String>): ApiResult<PageResult<SysUser>>

    @GET("/sys/org/list")
    suspend fun orgList(): ApiResult<List<SysOrg>>

    @GET("/sys/role/page")
    suspend fun rolePage(@QueryMap params: Map<String, String>): ApiResult<PageResult<SysRole>>

    @GET("/sys/message/my/page")
    suspend fun messagePage(@QueryMap params: Map<String, String>): ApiResult<PageResult<MessageItem>>

    @GET("/sys/message/my/unread-count")
    suspend fun unreadCount(): ApiResult<Int>

    @GET("/sys/message/my/{id}")
    suspend fun messageDetail(@Path("id") id: Long): ApiResult<MessageItem>

    @PUT("/sys/message/my/{id}/read")
    suspend fun readMessage(@Path("id") id: Long): ApiResult<Any?>

    @PUT("/sys/message/my/read-all")
    suspend fun readAllMessages(): ApiResult<Any?>

    @GET("/sys/ai/robot/info")
    suspend fun aiRobot(): ApiResult<AiRobot>

    @POST("/sys/ai/chat")
    suspend fun aiChat(@Body body: AiChatRequest): ApiResult<AiChatReply>

    @GET("/sys/ai/chat/session/list")
    suspend fun aiSessions(): ApiResult<List<AiSession>>

    @GET("/sys/ai/chat/session/{id}/messages")
    suspend fun aiSessionMessages(@Path("id") id: Long): ApiResult<List<AiMessage>>

    @POST("/sys/ai/chat/session")
    suspend fun createAiSession(@Body body: Map<String, String> = emptyMap()): ApiResult<AiSession>

    @DELETE("/sys/ai/chat/session")
    suspend fun deleteAiSessions(@Body ids: List<Long>): ApiResult<Any?>
}
