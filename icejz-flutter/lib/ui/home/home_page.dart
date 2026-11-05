import 'package:flutter/material.dart';
import 'package:icejz_app/config/brand.dart';
import 'package:icejz_app/data/repositories/home_repository.dart';
import 'package:icejz_app/navigation/routes.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';
import 'package:icejz_app/util/greeting.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.authEpoch,
    required this.onNavigate,
    required this.onOpenWorkbench,
  });

  final int authEpoch;
  final ValueChanged<String> onNavigate;
  final VoidCallback onOpenWorkbench;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = HomeRepository();
  String name = '访客';
  int unread = 0;
  HomeStats stats = HomeStats();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authEpoch != widget.authEpoch) _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final user = await _repo.userInfo();
      name = displayName(user.realName, user.username);
      unread = await _repo.unreadCount();
      stats = await _repo.fetchHomeStats();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  List<(String, int)> get weekChart {
    const dayLabels = ['日', '一', '二', '三', '四', '五', '六'];
    final now = DateTime.now();
    // Match Android Calendar.DAY_OF_WEEK: Sun=1..Sat=7 → index Sun=0
    final androidDow = now.weekday % 7;
    return List.generate(stats.weekBars.length, (i) {
      final idx = (androidDow - (6 - i) + 70) % 7;
      return (dayLabels[idx], stats.weekBars[i]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.only(
              bottom: 24 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  18,
                  MediaQuery.paddingOf(context).top + 14,
                  18,
                  14,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFDDF3FC), Color(0xFFF3F6FA)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 36,
                            height: 36,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ICEJZ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.iceInk,
                                ),
                              ),
                              Text(
                                Brand.tagline,
                                style: TextStyle(
                                  color: AppColors.iceMute,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.onNavigate(Routes.message),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.iceInk,
                              ),
                              if (unread > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.iceDanger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${greetingText()}，$name',
                      style: const TextStyle(
                        color: AppColors.iceMute,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Wordmark(iceSize: 36, jzSize: 36),
                    const SizedBox(height: 6),
                    const Text(
                      Brand.homeLine,
                      style: TextStyle(color: AppColors.iceMute, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            title: '进入工作台',
                            desc: '系统管理入口',
                            primary: true,
                            onTap: widget.onOpenWorkbench,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            title: '消息',
                            desc: unread > 0 ? '$unread 未读' : '暂无未读',
                            primary: false,
                            onTap: () => widget.onNavigate(Routes.message),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    for (final item in [
                      ('用户', stats.userTotal, Routes.sysUser),
                      ('机构', stats.orgTotal, Routes.sysOrg),
                      ('角色', stats.roleTotal, Routes.sysRole),
                      ('未读', stats.msgUnread, Routes.message),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => widget.onNavigate(item.$3),
                            child: IceCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$1,
                                    style: const TextStyle(
                                      color: AppColors.iceMute,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    loading ? '—' : '${item.$2}',
                                    style: const TextStyle(
                                      color: AppColors.iceInk,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
                        '快捷入口',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.iceInk,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final item in [
                            ('用户', Routes.sysUser),
                            ('机构', Routes.sysOrg),
                            ('角色', Routes.sysRole),
                            ('消息', Routes.message),
                          ])
                            GestureDetector(
                              onTap: () => widget.onNavigate(item.$2),
                              child: Column(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.iceCyan
                                          .withValues(alpha: 0.12),
                                    ),
                                    alignment: Alignment.center,
                                      child: Text(
                                      item.$1.substring(0, 1),
                                      style: const TextStyle(
                                        color: AppColors.iceCyan,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.$1,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.iceInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (!loading &&
                  (stats.userTotal + stats.orgTotal + stats.msgTotal) > 0) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: IceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '资源总览',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          '管理端同源',
                          style: TextStyle(
                            color: AppColors.iceMute,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SimpleBarChart(
                          values: [
                            ('用户', stats.userTotal),
                            ('机构', stats.orgTotal),
                            ('角色', stats.roleTotal),
                            ('消息', stats.msgTotal),
                          ],
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
                          '近 7 日消息',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SimpleBarChart(values: weekChart),
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
                          '消息已读率',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.readPercent}%',
                          style: const TextStyle(
                            color: AppColors.iceCyan,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '已读 ${stats.msgRead} · 未读 ${stats.msgUnread}',
                          style: const TextStyle(
                            color: AppColors.iceMute,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: IceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '平台能力',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < Brand.features.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  (i + 1).toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: AppColors.iceCyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Brand.features[i].title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.iceInk,
                                      ),
                                    ),
                                    Text(
                                      Brand.features[i].desc,
                                      style: const TextStyle(
                                        color: AppColors.iceMute,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  Brand.footer,
                  style: TextStyle(color: AppColors.iceMute, fontSize: 12),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: GestureDetector(
            onTap: () => widget.onNavigate(Routes.assistant),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/xiaobing_main.png'),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '小冰助手',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.iceCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.desc,
    required this.primary,
    required this.onTap,
  });

  final String title;
  final String desc;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primary ? AppColors.iceCyan : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: primary ? Colors.white : AppColors.iceInk,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                color: primary
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.iceMute,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
