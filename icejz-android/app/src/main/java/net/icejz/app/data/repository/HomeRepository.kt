package net.icejz.app.data.repository

import net.icejz.app.data.model.MessageItem
import net.icejz.app.data.model.SysOrg
import net.icejz.app.data.model.SysRole
import net.icejz.app.data.model.SysUser
import net.icejz.app.data.model.UserInfo
import net.icejz.app.data.remote.ApiClient
import net.icejz.app.data.remote.apiCall
import net.icejz.app.data.remote.apiCallNullable
import java.util.Calendar

data class HomeStats(
    val userTotal: Int = 0,
    val orgTotal: Int = 0,
    val roleTotal: Int = 0,
    val msgUnread: Int = 0,
    val msgTotal: Int = 0,
    val msgRead: Int = 0,
    val readPercent: Int = 0,
    val weekBars: List<Int> = List(7) { 0 },
    val users: List<SysUser> = emptyList(),
    val orgs: List<SysOrg> = emptyList(),
    val roles: List<SysRole> = emptyList()
)

class HomeRepository {
    private val api get() = ApiClient.api

    suspend fun userInfo(): UserInfo = apiCall { api.userInfo() }

    suspend fun unreadCount(): Int = apiCallNullable { api.unreadCount() } ?: 0

    suspend fun fetchHomeStats(): HomeStats {
        val week = buildWeekBuckets()
        return try {
            val users = runCatching {
                apiCall { api.userPage(mapOf("page" to "1", "limit" to "100", "t" to now())) }
            }.getOrNull()
            val orgs = runCatching { apiCall { api.orgList() } }.getOrNull().orEmpty()
            val roles = runCatching {
                apiCall { api.rolePage(mapOf("page" to "1", "limit" to "100", "t" to now())) }
            }.getOrNull()
            val messages = runCatching {
                apiCall { api.messagePage(mapOf("page" to "1", "limit" to "50", "t" to now())) }
            }.getOrNull()
            val unread = runCatching { apiCallNullable { api.unreadCount() } ?: 0 }.getOrDefault(0)

            val flatOrgs = flattenOrg(orgs)
            val msgList = messages?.list.orEmpty()
            val msgTotal = (messages?.total ?: msgList.size.toLong()).toInt()
            val read = (msgTotal - unread).coerceAtLeast(0)
            val percent = if (msgTotal > 0) Math.round(read * 100f / msgTotal) else 0

            msgList.forEach { msg ->
                val key = dayKey(msg.sendTime ?: msg.createTime)
                if (key != null && week.containsKey(key)) {
                    week[key] = (week[key] ?: 0) + 1
                }
            }

            HomeStats(
                userTotal = (users?.total ?: users?.list?.size?.toLong() ?: 0L).toInt(),
                orgTotal = flatOrgs.size,
                roleTotal = (roles?.total ?: roles?.list?.size?.toLong() ?: 0L).toInt(),
                msgUnread = unread,
                msgTotal = msgTotal,
                msgRead = read,
                readPercent = percent,
                weekBars = week.values.toList(),
                users = users?.list.orEmpty(),
                orgs = flatOrgs,
                roles = roles?.list.orEmpty()
            )
        } catch (_: Exception) {
            HomeStats()
        }
    }

    suspend fun messagePage(page: Int = 1, limit: Int = 20) =
        apiCall { api.messagePage(mapOf("page" to "$page", "limit" to "$limit", "t" to now())) }

    suspend fun readMessage(id: Long) = apiCallNullable { api.readMessage(id) }
    suspend fun readAll() = apiCallNullable { api.readAllMessages() }
    suspend fun messageDetail(id: Long): MessageItem = apiCall { api.messageDetail(id) }

    suspend fun userPage(page: Int = 1, limit: Int = 20) =
        apiCall { api.userPage(mapOf("page" to "$page", "limit" to "$limit", "t" to now())) }

    suspend fun orgList(): List<SysOrg> = apiCall { api.orgList() }

    suspend fun rolePage(page: Int = 1, limit: Int = 20) =
        apiCall { api.rolePage(mapOf("page" to "$page", "limit" to "$limit", "t" to now())) }

    private fun flattenOrg(nodes: List<SysOrg>, acc: MutableList<SysOrg> = mutableListOf()): List<SysOrg> {
        nodes.forEach {
            acc += it
            if (it.children.isNotEmpty()) flattenOrg(it.children, acc)
        }
        return acc
    }

    private fun buildWeekBuckets(): LinkedHashMap<String, Int> {
        val map = LinkedHashMap<String, Int>()
        val cal = Calendar.getInstance()
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        for (i in 6 downTo 0) {
            val c = cal.clone() as Calendar
            c.add(Calendar.DAY_OF_YEAR, -i)
            map[dayKey(c)] = 0
        }
        return map
    }

    private fun dayKey(cal: Calendar): String =
        "${cal.get(Calendar.YEAR)}-${cal.get(Calendar.MONTH) + 1}-${cal.get(Calendar.DAY_OF_MONTH)}"

    private fun dayKey(raw: String?): String? {
        if (raw.isNullOrBlank()) return null
        val text = raw.replace('-', '/').take(19)
        return runCatching {
            val parts = text.split(' ', 'T').first().split('/', '-')
            if (parts.size >= 3) {
                "${parts[0].toInt()}-${parts[1].toInt()}-${parts[2].toInt()}"
            } else null
        }.getOrNull()
    }

    private fun now() = System.currentTimeMillis().toString()
}
