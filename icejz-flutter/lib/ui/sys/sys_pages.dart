import 'package:flutter/material.dart';
import 'package:icejz_app/data/api_exception.dart';
import 'package:icejz_app/data/models.dart';
import 'package:icejz_app/data/repositories/home_repository.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _repo = HomeRepository();
  List<SysUser> list = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      list = (await _repo.userPage(limit: 100)).list;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : '加载失败'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '用户管理', onBack: widget.onBack),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(title: '暂无用户数据')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final user = list[i];
                        return _ListCard(
                          title: user.realName ?? user.username ?? '用户',
                          sub: [
                            user.username,
                            user.mobile,
                            user.orgName,
                          ].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
                          badge: user.status == 1 ? '正常' : '停用',
                          badgeActive: user.status == 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrgListPage extends StatefulWidget {
  const OrgListPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<OrgListPage> createState() => _OrgListPageState();
}

class _OrgListPageState extends State<OrgListPage> {
  final _repo = HomeRepository();
  List<SysOrg> list = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      list = _flatten(await _repo.orgList());
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : '加载失败'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '机构管理', onBack: widget.onBack),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(title: '暂无机构数据')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final org = list[i];
                        return _ListCard(
                          title: org.name ?? '机构',
                          sub: 'ID: ${org.id ?? '-'}',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleListPage extends StatefulWidget {
  const RoleListPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<RoleListPage> createState() => _RoleListPageState();
}

class _RoleListPageState extends State<RoleListPage> {
  final _repo = HomeRepository();
  List<SysRole> list = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      list = (await _repo.rolePage(limit: 100)).list;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : '加载失败'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '角色管理', onBack: widget.onBack),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(title: '暂无角色数据')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final role = list[i];
                        return _ListCard(
                          title: role.name ?? '角色',
                          sub: [
                            role.roleCode,
                            role.remark,
                          ].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.title,
    required this.sub,
    this.badge,
    this.badgeActive = true,
  });

  final String title;
  final String sub;
  final String? badge;
  final bool badgeActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.iceInk,
                  ),
                ),
              ),
              if (badge != null)
                Text(
                  badge!,
                  style: TextStyle(
                    color: badgeActive ? AppColors.iceCyan : AppColors.iceMute,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sub,
              style: const TextStyle(color: AppColors.iceMute, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

List<SysOrg> _flatten(List<SysOrg> nodes, [List<SysOrg>? acc]) {
  final out = acc ?? <SysOrg>[];
  for (final n in nodes) {
    out.add(n);
    if (n.children.isNotEmpty) _flatten(n.children, out);
  }
  return out;
}
