package net.icejz.app.data.repository

import net.icejz.app.data.model.AiChatReply
import net.icejz.app.data.model.AiChatRequest
import net.icejz.app.data.model.AiMessage
import net.icejz.app.data.model.AiRobot
import net.icejz.app.data.model.AiSession
import net.icejz.app.data.remote.ApiClient
import net.icejz.app.data.remote.apiCall
import net.icejz.app.data.remote.apiCallNullable

class AiRepository {
    private val api get() = ApiClient.api

    suspend fun robot(): AiRobot? = runCatching { apiCallNullable { api.aiRobot() } }.getOrNull()

    suspend fun chat(content: String, sessionId: Long? = null): AiChatReply =
        apiCall { api.aiChat(AiChatRequest(content = content, sessionId = sessionId)) }

    suspend fun sessions(): List<AiSession> =
        apiCallNullable { api.aiSessions() }.orEmpty()

    suspend fun messages(sessionId: Long): List<AiMessage> =
        apiCallNullable { api.aiSessionMessages(sessionId) }.orEmpty()

    suspend fun createSession(title: String? = null): AiSession? =
        apiCallNullable {
            api.createAiSession(if (title.isNullOrBlank()) emptyMap() else mapOf("title" to title))
        }
}
