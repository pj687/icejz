import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icejz_app/data/repositories/home_repository.dart';
import 'package:icejz_app/navigation/routes.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';
import 'package:icejz_app/util/greeting.dart';
import 'package:intl/intl.dart';

class WorkbenchPage extends StatefulWidget {
  const WorkbenchPage({
    super.key,
    required this.authEpoch,
    required this.onNavigate,
  });

  final int authEpoch;
  final ValueChanged<String> onNavigate;

  @override
  State<WorkbenchPage> createState() => _WorkbenchPageState();
}

class _WorkbenchPageState extends State<WorkbenchPage> {
  final _repo = HomeRepository();
  String name = '访客';
  String username = '';
  String? avatar;
  String orgName = '未绑定机构';
  int unread = 0;
  DateTime viewCal = DateTime.now();
  int selectedDay = DateTime.now().day;

  static const projects = [
    (('用户权限梳理', '角色菜单授权复核', 72), Routes.sysRole),
    (('消息中心巡检', '未读通知与推送核对', 45), Routes.message),
    (('组织架构对齐', '机构树与人员归属核对', 58), Routes.sysOrg),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant WorkbenchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authEpoch != widget.authEpoch) _load();
  }

  Future<void> _load() async {
    try {
      final user = await _repo.userInfo();
      name = displayName(user.realName, user.username);
      username = user.username ?? '';
      avatar = user.avatar;
      orgName = (user.orgName == null || user.orgName!.isEmpty)
          ? '未绑定机构'
          : user.orgName!;
      unread = await _repo.unreadCount();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekDay = DateFormat.EEEE('zh_CN').format(today);
    final todayLabel = DateFormat('M月d日', 'zh_CN').format(today);

    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 12,
        bottom: 24,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: GestureDetector(
            onTap: () => widget.onNavigate(Routes.userInfo),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F1B2D),
                    Color(0xFF16324A),
                    Color(0xFF0C5F84),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Wordmark(iceSize: 16, jzSize: 16),
                      Text(
                        ' / WORKSPACE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
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
                                  width: 34,
                                  height: 34,
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
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              orgName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            weekDay,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            todayLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username.isNotEmpty ? '@$username' : '今天也保持高效推进',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '在岗',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              for (final item in [
                ('进行中', '3'),
                ('待办', '4'),
                ('消息', '$unread'),
                ('记事', '0'),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: IceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(
                              color: AppColors.iceMute,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: AppColors.iceInk,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
          child: GestureDetector(
            onTap: () => widget.onNavigate(Routes.assistant),
            child: IceCard(
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/xiaobing_head.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '智能建议',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '可让小冰帮你整理今日待办',
                          style: TextStyle(
                            color: AppColors.iceMute,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '问问小冰',
                    style: TextStyle(
                      color: AppColors.iceCyan,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
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
                  '快捷入口',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final item in [
                      ('用户', Routes.sysUser),
                      ('消息', Routes.message),
                      ('小冰', Routes.assistant),
                      ('资料', Routes.userInfo),
                    ])
                      GestureDetector(
                        onTap: () => widget.onNavigate(item.$2),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.iceCyan.withValues(alpha: 0.12),
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
                            Text(item.$1, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
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
                  '进行中的事项',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Text(
                  '按优先级推进今日关键交付',
                  style: TextStyle(color: AppColors.iceMute, fontSize: 12),
                ),
                const SizedBox(height: 10),
                for (final project in projects)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.$1.$1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    project.$1.$2,
                                    style: const TextStyle(
                                      color: AppColors.iceMute,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => widget.onNavigate(project.$2),
                              child: const Text(
                                '进入',
                                style: TextStyle(
                                  color: AppColors.iceCyan,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: project.$1.$3 / 100,
                            minHeight: 6,
                            color: AppColors.iceCyan,
                            backgroundColor: const Color(0xFFE8EEF5),
                          ),
                        ),
                      ],
                    ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${viewCal.year}',
                          style: const TextStyle(
                            color: AppColors.iceMute,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${viewCal.month}月',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            viewCal = DateTime(viewCal.year, viewCal.month - 1);
                          }),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('‹', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            viewCal = DateTime.now();
                            selectedDay = today.day;
                          }),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              '本月',
                              style: TextStyle(color: AppColors.iceCyan),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            viewCal = DateTime(viewCal.year, viewCal.month + 1);
                          }),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('›', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final d in ['日', '一', '二', '三', '四', '五', '六'])
                      SizedBox(
                        width: 36,
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: AppColors.iceMute,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                _CalendarGrid(
                  viewCal: viewCal,
                  selectedDay: selectedDay,
                  today: today,
                  onSelect: (d) => setState(() => selectedDay = d),
                ),
                const SizedBox(height: 10),
                Text(
                  '${viewCal.month}月$selectedDay日 · 暂无记事',
                  style: const TextStyle(
                    color: AppColors.iceMute,
                    fontSize: 13,
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

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.viewCal,
    required this.selectedDay,
    required this.today,
    required this.onSelect,
  });

  final DateTime viewCal;
  final int selectedDay;
  final DateTime today;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(viewCal.year, viewCal.month, 1);
    // Android: (DAY_OF_WEEK + 5) % 7 with Sun=1 → Mon-based offset for Sun-first grid
    final firstWeekday = (first.weekday % 7); // Sun=0 ... Sat=6 for Sun-first
    final maxDay = DateTime(viewCal.year, viewCal.month + 1, 0).day;
    final cells = <int?>[
      ...List.filled(firstWeekday, null),
      ...List.generate(maxDay, (i) => i + 1),
    ];

    final weeks = <List<int?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, (i + 7).clamp(0, cells.length)));
    }

    return Column(
      children: [
        for (final week in weeks)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in week)
                _dayCell(day),
              for (var i = 0; i < 7 - week.length; i++)
                const SizedBox(width: 36, height: 36),
            ],
          ),
      ],
    );
  }

  Widget _dayCell(int? day) {
    final isToday = day != null &&
        viewCal.year == today.year &&
        viewCal.month == today.month &&
        day == today.day;
    final selected = day == selectedDay;
    return GestureDetector(
      onTap: day == null ? null : () => onSelect(day),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? AppColors.iceCyan
              : isToday
                  ? AppColors.iceCyan.withValues(alpha: 0.15)
                  : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: day == null
            ? null
            : Text(
                '$day',
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : isToday
                          ? AppColors.iceCyan
                          : AppColors.iceInk,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}
