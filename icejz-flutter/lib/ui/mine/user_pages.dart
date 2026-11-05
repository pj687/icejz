import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icejz_app/config/brand.dart';
import 'package:icejz_app/data/api_exception.dart';
import 'package:icejz_app/data/models.dart';
import 'package:icejz_app/data/repositories/user_repository.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';

void _toast(ScaffoldMessengerState messenger, String msg) {
  messenger.showSnackBar(SnackBar(content: Text(msg)));
}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key, required this.onBack, required this.onEdit});

  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _repo = UserRepository();
  UserInfo? user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      user = await _repo.info();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        _toast(
          ScaffoldMessenger.of(context),
          e is ApiException ? e.message : '加载失败',
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
            IceNavBar(
              title: '个人信息',
              onBack: widget.onBack,
              trailing: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: widget.onEdit,
                  child: const Text(
                    '编辑',
                    style: TextStyle(color: AppColors.iceCyan),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _BoxAvatar(avatar: user?.avatar),
                    const SizedBox(height: 12),
                    Text(
                      user?.realName ?? user?.username ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '@${user?.username ?? ''}',
                      style: const TextStyle(
                        color: AppColors.iceMute,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    IceCard(
                      child: Column(
                        children: [
                          _InfoLine('手机号', user?.mobile ?? '-'),
                          _InfoLine('邮箱', user?.email ?? '-'),
                          _InfoLine('机构', user?.orgName ?? '-'),
                          _InfoLine(
                            '性别',
                            switch (user?.gender) {
                              0 => '男',
                              1 => '女',
                              _ => '未知',
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserEditPage extends StatefulWidget {
  const UserEditPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _repo = UserRepository();
  String realName = '';
  String mobile = '';
  String email = '';
  UserInfo? user;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      user = await _repo.info();
      realName = user?.realName ?? '';
      mobile = user?.mobile ?? '';
      email = user?.email ?? '';
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '编辑资料', onBack: widget.onBack),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  IceField(
                    label: '姓名',
                    value: realName,
                    placeholder: '请输入姓名',
                    onChanged: (v) => setState(() => realName = v),
                  ),
                  const SizedBox(height: 12),
                  IceField(
                    label: '手机号',
                    value: mobile,
                    placeholder: '请输入手机号',
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => setState(() => mobile = v),
                  ),
                  const SizedBox(height: 12),
                  IceField(
                    label: '邮箱',
                    value: email,
                    placeholder: '请输入邮箱',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => setState(() => email = v),
                  ),
                  const SizedBox(height: 20),
                  IcePrimaryButton(
                    text: '保存',
                    loading: saving,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => saving = true);
                      try {
                        final updated = (user ?? UserInfo()).copyWith(
                          realName: realName,
                          mobile: mobile,
                          email: email,
                        );
                        await _repo.updateInfo(updated);
                        if (mounted) {
                          _toast(messenger, '保存成功');
                          widget.onBack();
                        }
                      } catch (e) {
                        if (mounted) {
                          _toast(
                            messenger,
                            e is ApiException ? e.message : '保存失败',
                          );
                        }
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _repo = UserRepository();
  String oldPwd = '';
  String newPwd = '';
  String confirm = '';
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '修改密码', onBack: widget.onBack),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  IceField(
                    label: '原密码',
                    value: oldPwd,
                    placeholder: '请输入原密码',
                    obscureText: true,
                    onChanged: (v) => setState(() => oldPwd = v),
                  ),
                  const SizedBox(height: 12),
                  IceField(
                    label: '新密码',
                    value: newPwd,
                    placeholder: '请输入新密码',
                    obscureText: true,
                    onChanged: (v) => setState(() => newPwd = v),
                  ),
                  const SizedBox(height: 12),
                  IceField(
                    label: '确认密码',
                    value: confirm,
                    placeholder: '请再次输入新密码',
                    obscureText: true,
                    onChanged: (v) => setState(() => confirm = v),
                  ),
                  const SizedBox(height: 20),
                  IcePrimaryButton(
                    text: '提交',
                    loading: saving,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (newPwd.length < 6) {
                        _toast(messenger, '新密码至少 6 位');
                        return;
                      }
                      if (newPwd != confirm) {
                        _toast(messenger, '两次密码不一致');
                        return;
                      }
                      setState(() => saving = true);
                      try {
                        await _repo.updatePassword(oldPwd, newPwd);
                        if (!mounted) return;
                        _toast(messenger, '修改成功');
                        widget.onBack();
                      } catch (e) {
                        if (!mounted) return;
                        _toast(
                          messenger,
                          e is ApiException ? e.message : '修改失败',
                        );
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _repo = UserRepository();
  List<DeviceItem> list = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final messenger = mounted ? ScaffoldMessenger.of(context) : null;
    try {
      list = await _repo.devices();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted && messenger != null) {
        _toast(messenger, e is ApiException ? e.message : '加载失败');
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
            IceNavBar(title: '登录设备', onBack: widget.onBack),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(title: '暂无登录设备')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final device = list[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: IceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.deviceName ??
                                      device.deviceType ??
                                      '设备',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${device.ip ?? ''} · ${device.loginTime ?? ''}',
                                  style: const TextStyle(
                                    color: AppColors.iceMute,
                                    fontSize: 12,
                                  ),
                                ),
                                if (!device.current &&
                                    (device.accessToken?.isNotEmpty ??
                                        false)) ...[
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      try {
                                        await _repo
                                            .kickDevice(device.accessToken!);
                                        _toast(messenger, '已下线');
                                        await _refresh();
                                      } catch (e) {
                                        _toast(
                                          messenger,
                                          e is ApiException
                                              ? e.message
                                              : '操作失败',
                                        );
                                      }
                                    },
                                    child: const Text(
                                      '下线该设备',
                                      style: TextStyle(
                                        color: AppColors.iceDanger,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ] else if (device.current) ...[
                                  const SizedBox(height: 6),
                                  const Text(
                                    '当前设备',
                                    style: TextStyle(
                                      color: AppColors.iceCyan,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.onBack,
    required this.onOpenAbout,
    required this.onOpenDevices,
    required this.onOpenPassword,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenAbout;
  final VoidCallback onOpenDevices;
  final VoidCallback onOpenPassword;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _repo = UserRepository();
  bool multi = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      multi = (await _repo.loginSecurity()).multiDeviceLogin == 1;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '设置', onBack: widget.onBack),
            Padding(
              padding: const EdgeInsets.all(16),
              child: IceCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '允许多设备登录',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '关闭后仅保留最新会话',
                                style: TextStyle(
                                  color: AppColors.iceMute,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: multi,
                          activeTrackColor: AppColors.iceCyan,
                          onChanged: (enabled) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final previous = multi;
                            setState(() => multi = enabled);
                            try {
                              await _repo.saveLoginSecurity(
                                LoginSecurity(multiDeviceLogin: enabled ? 1 : 0),
                              );
                              if (mounted) _toast(messenger, '已保存');
                            } catch (_) {
                              if (mounted) {
                                setState(() => multi = previous);
                                _toast(messenger, '保存失败');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    MenuRow(
                      title: '修改密码',
                      onTap: widget.onOpenPassword,
                    ),
                    MenuRow(
                      title: '登录设备',
                      onTap: widget.onOpenDevices,
                    ),
                    MenuRow(
                      title: '关于我们',
                      onTap: widget.onOpenAbout,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '关于我们', onBack: onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 72,
                        height: 72,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      Brand.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const Text(
                      Brand.version,
                      style:
                          TextStyle(color: AppColors.iceMute, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      Brand.aboutIntro,
                      style:
                          TextStyle(color: AppColors.iceMute, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    for (final f in Brand.features)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: IceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                f.desc,
                                style: const TextStyle(
                                  color: AppColors.iceMute,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      Brand.footer,
                      style:
                          TextStyle(color: AppColors.iceMute, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoxAvatar extends StatelessWidget {
  const _BoxAvatar({this.avatar});

  final String? avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.iceCyan.withValues(alpha: 0.12),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatar != null && avatar!.isNotEmpty
          ? CachedNetworkImage(imageUrl: avatar!, fit: BoxFit.cover)
          : Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 52,
                height: 52,
              ),
            ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.iceMute),
            ),
          ),
          Text(value, style: const TextStyle(color: AppColors.iceInk)),
        ],
      ),
    );
  }
}
