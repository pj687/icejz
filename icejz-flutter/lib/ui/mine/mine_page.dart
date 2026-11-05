import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icejz_app/config/brand.dart';
import 'package:icejz_app/data/repositories/auth_repository.dart';
import 'package:icejz_app/data/repositories/home_repository.dart';
import 'package:icejz_app/navigation/routes.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';
import 'package:icejz_app/util/greeting.dart';

class MinePage extends StatefulWidget {
  const MinePage({
    super.key,
    required this.authEpoch,
    required this.onNavigate,
    required this.onLogout,
  });

  final int authEpoch;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final _homeRepo = HomeRepository();
  final _authRepo = AuthRepository();

  String name = '访客';
  String username = '';
  String? avatar;
  String orgName = '';
  int unread = 0;
  int userTotal = 0;
  int orgTotal = 0;
  int roleTotal = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authEpoch != widget.authEpoch) _load();
  }

  Future<void> _load() async {
    try {
      final user = await _homeRepo.userInfo();
      name = displayName(user.realName, user.username);
      username = user.username ?? '';
      avatar = user.avatar;
      orgName = user.orgName ?? '';
      unread = await _homeRepo.unreadCount();
      final stats = await _homeRepo.fetchHomeStats();
      userTotal = stats.userTotal;
      orgTotal = stats.orgTotal;
      roleTotal = stats.roleTotal;
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5FC), Color(0xFFF3F6FA)],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 12,
          bottom: 28,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wordmark(iceSize: 18, jzSize: 18),
                          Text(
                            '账号中心',
                            style: TextStyle(
                              color: AppColors.iceMute,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _roundIcon(
                      Icons.notifications_outlined,
                      () => widget.onNavigate(Routes.message),
                    ),
                    const SizedBox(width: 8),
                    _roundIcon(
                      Icons.settings_outlined,
                      () => widget.onNavigate(Routes.settings),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                IceCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.iceCyan.withValues(alpha: 0.12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: avatar != null && avatar!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: avatar!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greetingText(),
                                  style: const TextStyle(
                                    color: AppColors.iceMute,
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: AppColors.iceInk,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.iceCyan
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        '成员',
                                        style: TextStyle(
                                          color: AppColors.iceCyan,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    if (username.isNotEmpty)
                                      Text(
                                        '@$username',
                                        style: const TextStyle(
                                          color: AppColors.iceMute,
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(
                                      orgName.isEmpty ? '未绑定机构' : orgName,
                                      style: const TextStyle(
                                        color: AppColors.iceMute,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onNavigate(Routes.userInfo),
                            child: const Text(
                              '编辑',
                              style: TextStyle(
                                color: AppColors.iceCyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final item in [
                            ('$userTotal', '用户'),
                            ('$orgTotal', '机构'),
                            ('$roleTotal', '角色'),
                            ('$unread', '未读'),
                          ])
                            Column(
                              children: [
                                Text(
                                  item.$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  item.$2,
                                  style: const TextStyle(
                                    color: AppColors.iceMute,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: IceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '常用功能',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    '系统管理快捷入口',
                    style: TextStyle(color: AppColors.iceMute, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  MenuRow(
                    title: '我的消息',
                    hint: unread > 0 ? '$unread 未读' : '站内通知',
                    onTap: () => widget.onNavigate(Routes.message),
                  ),
                  MenuRow(
                    title: '用户管理',
                    hint: '账号查阅',
                    onTap: () => widget.onNavigate(Routes.sysUser),
                  ),
                  MenuRow(
                    title: '机构管理',
                    hint: '组织架构',
                    onTap: () => widget.onNavigate(Routes.sysOrg),
                  ),
                  MenuRow(
                    title: '角色管理',
                    hint: '权限编码',
                    onTap: () => widget.onNavigate(Routes.sysRole),
                  ),
                  MenuRow(
                    title: '小冰助手',
                    hint: '智能问答',
                    onTap: () => widget.onNavigate(Routes.assistant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: IceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '账号与安全',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  MenuRow(
                    title: '个人信息',
                    hint: '资料与头像',
                    onTap: () => widget.onNavigate(Routes.userInfo),
                  ),
                  MenuRow(
                    title: '修改密码',
                    hint: '账号安全',
                    onTap: () => widget.onNavigate(Routes.password),
                  ),
                  MenuRow(
                    title: '登录设备',
                    hint: '会话管理',
                    onTap: () => widget.onNavigate(Routes.devices),
                  ),
                  MenuRow(
                    title: '设置',
                    hint: '偏好与关于',
                    onTap: () => widget.onNavigate(Routes.settings),
                  ),
                  MenuRow(
                    title: '关于我们',
                    hint: Brand.version,
                    onTap: () => widget.onNavigate(Routes.about),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GestureDetector(
              onTap: () async {
                await _authRepo.logout();
                _toast('已退出登录');
                widget.onLogout();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '退出登录',
                  style: TextStyle(
                    color: AppColors.iceDanger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              Brand.footer,
              style: TextStyle(color: AppColors.iceMute, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.iceInk, size: 20),
      ),
    );
  }
}
