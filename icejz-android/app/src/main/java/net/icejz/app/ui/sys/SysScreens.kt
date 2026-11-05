package net.icejz.app.ui.sys

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.icejz.app.data.model.SysOrg
import net.icejz.app.data.model.SysRole
import net.icejz.app.data.model.SysUser
import net.icejz.app.data.remote.ApiException
import net.icejz.app.data.repository.HomeRepository
import net.icejz.app.ui.components.EmptyState
import net.icejz.app.ui.components.IceNavBar
import net.icejz.app.ui.theme.IceCanvas
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute

@Composable
fun UserListScreen(onBack: () -> Unit) {
    val repo = remember { HomeRepository() }
    val context = LocalContext.current
    var list by remember { mutableStateOf<List<SysUser>>(emptyList()) }
    LaunchedEffect(Unit) {
        runCatching { list = repo.userPage(limit = 100).list }
            .onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "加载失败", Toast.LENGTH_SHORT).show() }
    }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("用户管理", onBack)
        if (list.isEmpty()) EmptyState("暂无用户数据")
        else LazyColumn(Modifier.padding(horizontal = 16.dp)) {
            items(list, key = { it.id ?: it.hashCode().toLong() }) { user ->
                ListCard(
                    title = user.realName ?: user.username ?: "用户",
                    sub = listOfNotNull(user.username, user.mobile, user.orgName).joinToString(" · "),
                    badge = if (user.status == 1) "正常" else "停用",
                    badgeActive = user.status == 1
                )
            }
        }
    }
}

@Composable
fun OrgListScreen(onBack: () -> Unit) {
    val repo = remember { HomeRepository() }
    val context = LocalContext.current
    var list by remember { mutableStateOf<List<SysOrg>>(emptyList()) }
    LaunchedEffect(Unit) {
        runCatching { list = flatten(repo.orgList()) }
            .onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "加载失败", Toast.LENGTH_SHORT).show() }
    }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("机构管理", onBack)
        if (list.isEmpty()) EmptyState("暂无机构数据")
        else LazyColumn(Modifier.padding(horizontal = 16.dp)) {
            items(list, key = { it.id ?: it.hashCode().toLong() }) { org ->
                ListCard(title = org.name ?: "机构", sub = "ID: ${org.id ?: "-"}")
            }
        }
    }
}

@Composable
fun RoleListScreen(onBack: () -> Unit) {
    val repo = remember { HomeRepository() }
    val context = LocalContext.current
    var list by remember { mutableStateOf<List<SysRole>>(emptyList()) }
    LaunchedEffect(Unit) {
        runCatching { list = repo.rolePage(limit = 100).list }
            .onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "加载失败", Toast.LENGTH_SHORT).show() }
    }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("角色管理", onBack)
        if (list.isEmpty()) EmptyState("暂无角色数据")
        else LazyColumn(Modifier.padding(horizontal = 16.dp)) {
            items(list, key = { it.id ?: it.hashCode().toLong() }) { role ->
                ListCard(
                    title = role.name ?: "角色",
                    sub = listOfNotNull(role.roleCode, role.remark).joinToString(" · ")
                )
            }
        }
    }
}

@Composable
private fun ListCard(title: String, sub: String, badge: String? = null, badgeActive: Boolean = true) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(Color.White)
            .padding(14.dp)
    ) {
        Row {
            Text(title, fontWeight = FontWeight.SemiBold, color = IceInk, modifier = Modifier.weight(1f))
            if (badge != null) {
                Text(
                    badge,
                    color = if (badgeActive) IceCyan else IceMute,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }
        if (sub.isNotBlank()) {
            Spacer(Modifier.height(4.dp))
            Text(sub, color = IceMute, fontSize = 12.sp)
        }
    }
}

private fun flatten(nodes: List<SysOrg>, acc: MutableList<SysOrg> = mutableListOf()): List<SysOrg> {
    nodes.forEach {
        acc += it
        if (it.children.isNotEmpty()) flatten(it.children, acc)
    }
    return acc
}
