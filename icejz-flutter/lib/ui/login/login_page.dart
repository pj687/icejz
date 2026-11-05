import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icejz_app/config/brand.dart';
import 'package:icejz_app/data/api_exception.dart';
import 'package:icejz_app/data/models.dart';
import 'package:icejz_app/data/repositories/auth_repository.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';
import 'package:icejz_app/util/sm2_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLoggedIn});

  final VoidCallback onLoggedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _repo = AuthRepository();

  String mode = 'account';
  bool agreed = false;
  bool logging = false;
  bool captchaEnabled = true;
  String captchaKey = '';
  String captchaValue = '';
  String? captchaImage;
  String captchaTip = '';

  String username = 'admin';
  String password = '123456';
  String mobile = '';
  String smsCode = '';
  int smsLeft = 0;

  bool showComplete = false;
  TokenData? pending;
  String realName = '';
  int? roleId;
  int gender = 2;
  bool completing = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    captchaEnabled = await _repo.captchaEnabled().catchError((_) => true);
    if (!showComplete) await _loadCaptcha();
    if (mounted) setState(() {});
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadCaptcha() async {
    try {
      final channel = mode == 'mobile' ? 'sms' : 'app';
      final data = await _repo.loadCaptcha(channel: channel);
      if (!mounted) return;
      setState(() {
        captchaKey = data.key ?? '';
        captchaImage = data.image;
        captchaTip = data.tip ?? '';
        captchaValue = '';
      });
    } catch (e) {
      _toast(e is ApiException ? e.message : '验证码加载失败');
    }
  }

  bool _ensureAgreement() {
    if (!agreed) {
      _toast('请先同意用户协议与隐私政策');
      return false;
    }
    return true;
  }

  Future<void> _handleSuccess(TokenData token) async {
    try {
      await _repo.persistLogin(token);
      _toast('登录成功');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      widget.onLoggedIn();
    } catch (e) {
      _toast(e.toString());
    }
  }

  Future<void> _tickSms() async {
    while (smsLeft > 0 && mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => smsLeft -= 1);
    }
  }

  Future<void> _switchMode(String next) async {
    setState(() => mode = next);
    if (!showComplete) await _loadCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEF6FB), Color(0xFFF3F6FA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 56,
                          height: 56,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Wordmark(iceSize: 34, jzSize: 34),
                    const SizedBox(height: 6),
                    const Text(
                      Brand.slogan,
                      style: TextStyle(color: AppColors.iceMute, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      Brand.tagline,
                      style: TextStyle(color: Color(0xFF7AA8C4), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '欢迎回来',
                        style: TextStyle(
                          color: AppColors.iceCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        Brand.loginHint,
                        style:
                            TextStyle(color: AppColors.iceMute, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      if (!showComplete) ...[
                        _modeTabs(),
                        const SizedBox(height: 16),
                        if (mode == 'account') ...[
                          IceField(
                            label: '账号',
                            value: username,
                            placeholder: '请输入账号',
                            onChanged: (v) => setState(() => username = v),
                          ),
                          const SizedBox(height: 12),
                          IceField(
                            label: '密码',
                            value: password,
                            placeholder: '请输入密码',
                            obscureText: true,
                            onChanged: (v) => setState(() => password = v),
                          ),
                        ] else ...[
                          IceField(
                            label: '手机号',
                            value: mobile,
                            placeholder: '请输入手机号',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (v) => setState(() => mobile = v),
                          ),
                          const SizedBox(height: 12),
                          IceField(
                            label: '短信验证码',
                            value: smsCode,
                            placeholder: '请输入验证码',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: (v) => setState(() => smsCode = v),
                            trailing: GestureDetector(
                              onTap: smsLeft > 0 ? null : _sendCode,
                              child: Text(
                                smsLeft > 0 ? '${smsLeft}s' : '发送验证码',
                                style: TextStyle(
                                  color: smsLeft > 0
                                      ? AppColors.iceMute
                                      : AppColors.iceCyan,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (captchaEnabled) ...[
                          const SizedBox(height: 12),
                          IceField(
                            label: '安全验证',
                            value: captchaValue,
                            placeholder:
                                captchaTip.isEmpty ? '请输入验证码' : captchaTip,
                            onChanged: (v) =>
                                setState(() => captchaValue = v),
                          ),
                          const SizedBox(height: 8),
                          _CaptchaImage(
                            image: captchaImage,
                            onRefresh: _loadCaptcha,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: agreed,
                              activeColor: AppColors.iceCyan,
                              onChanged: (v) =>
                                  setState(() => agreed = v ?? false),
                            ),
                            const Expanded(
                              child: Text(
                                '我已阅读并同意用户协议与隐私政策',
                                style: TextStyle(
                                  color: AppColors.iceMute,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        IcePrimaryButton(
                          text: logging ? '登录中...' : '登录',
                          loading: logging,
                          onPressed: _login,
                        ),
                      ] else ...[
                        const Text(
                          '完善信息',
                          style: TextStyle(
                            color: AppColors.iceInk,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '选择身份并补充资料后进入系统。首次默认密码为当前手机号。',
                          style:
                              TextStyle(color: AppColors.iceMute, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '选择身份',
                          style:
                              TextStyle(color: AppColors.iceMute, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final item in const [
                              (2, '研发'),
                              (3, '运维'),
                              (4, '产品'),
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => roleId = item.$1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: roleId == item.$1
                                            ? AppColors.iceCyan
                                                .withValues(alpha: 0.12)
                                            : const Color(0xFFF3F6FA),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: roleId == item.$1
                                              ? AppColors.iceCyan
                                              : Colors.transparent,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        item.$2,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.iceInk,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        IceField(
                          label: '姓名',
                          value: realName,
                          placeholder: '请输入真实姓名',
                          onChanged: (v) => setState(() => realName = v),
                        ),
                        const SizedBox(height: 12),
                        IceField(
                          label: '手机号',
                          value: pending?.mobile ?? mobile,
                          placeholder: '',
                          onChanged: (_) {},
                          readOnly: true,
                          tip: '不可修改',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final item in const [
                              (0, '男'),
                              (1, '女'),
                              (2, '未知'),
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => gender = item.$1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: gender == item.$1
                                            ? AppColors.iceCyan
                                                .withValues(alpha: 0.12)
                                            : const Color(0xFFF3F6FA),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(item.$2),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        IcePrimaryButton(
                          text: '完成并进入系统',
                          loading: completing,
                          onPressed: _completeProfile,
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() => showComplete = false),
                            child: const Text(
                              '返回登录',
                              style: TextStyle(
                                color: AppColors.iceMute,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final t in ['国密加密', '统一认证', '操作审计'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.iceCyan.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '${Brand.footer} · 安全登录',
                  style: const TextStyle(
                    color: AppColors.iceMute,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final item in const [
            ('account', '账号登录'),
            ('mobile', '手机登录'),
          ])
            Expanded(
              child: GestureDetector(
                onTap: () => _switchMode(item.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: mode == item.$1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      color: mode == item.$1
                          ? AppColors.iceInk
                          : AppColors.iceMute,
                      fontWeight: mode == item.$1
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendCode() async {
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(mobile)) {
      _toast('请输入正确手机号');
      return;
    }
    if (captchaEnabled && captchaValue.isEmpty) {
      _toast('请先填写图形验证码');
      return;
    }
    try {
      await _repo.sendCode(mobile, captchaKey, captchaValue);
      _toast('验证码已发送');
      setState(() => smsLeft = 60);
      _tickSms();
      await _loadCaptcha();
    } catch (e) {
      await _loadCaptcha();
      _toast(e is ApiException ? e.message : '发送失败');
    }
  }

  Future<void> _login() async {
    if (!_ensureAgreement()) return;
    setState(() => logging = true);
    try {
      if (mode == 'account') {
        if (username.isEmpty || password.isEmpty) {
          throw Exception('请输入账号和密码');
        }
        if (captchaEnabled && captchaValue.isEmpty) {
          throw Exception('请先完成安全验证');
        }
        final token = await _repo.loginAccount(
          username,
          password,
          captchaEnabled ? captchaKey : null,
          captchaEnabled ? captchaValue : null,
        );
        await _handleSuccess(token);
      } else {
        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(mobile)) {
          throw Exception('请输入正确手机号');
        }
        if (smsCode.isEmpty) throw Exception('请输入短信验证码');
        final token = await _repo.loginMobile(mobile, smsCode);
        if (token.needCompleteProfile) {
          setState(() {
            pending = token;
            realName = '';
            roleId = token.roleIdList.isNotEmpty ? token.roleIdList.first : null;
            gender = 2;
            showComplete = true;
          });
          _toast(token.firstLogin ? '首次登录，请完善信息' : '请完善信息后继续');
        } else {
          await _handleSuccess(token);
        }
      }
    } catch (e) {
      if (mode == 'account') await _loadCaptcha();
      _toast(e is ApiException ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => logging = false);
    }
  }

  Future<void> _completeProfile() async {
    if (realName.isEmpty) {
      _toast('请输入真实姓名');
      return;
    }
    if (roleId == null) {
      _toast('请选择身份角色');
      return;
    }
    setState(() => completing = true);
    try {
      final phone = pending?.mobile ?? mobile;
      final token = await _repo.completeProfile(
        CompleteProfileRequest(
          userId: pending?.userId,
          roleId: roleId,
          realName: realName,
          gender: gender,
          mobile: phone,
          password: await Sm2Util.encrypt(phone),
        ),
      );
      await _handleSuccess(token);
    } catch (e) {
      _toast(e is ApiException ? e.message : '提交失败');
    } finally {
      if (mounted) setState(() => completing = false);
    }
  }
}

class _CaptchaImage extends StatelessWidget {
  const _CaptchaImage({required this.image, required this.onRefresh});

  final String? image;
  final VoidCallback onRefresh;

  Uint8List? _decode() {
    if (image == null || image!.isEmpty) return null;
    try {
      final raw = image!.contains('base64,')
          ? image!.substring(image!.indexOf('base64,') + 7)
          : image!;
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode();
    return Row(
      children: [
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            width: 120,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.fill)
                : const Center(
                    child: Text(
                      '点击刷新',
                      style:
                          TextStyle(color: AppColors.iceMute, fontSize: 12),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onRefresh,
          child: const Text(
            '看不清？点击刷新',
            style: TextStyle(color: AppColors.iceMute, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
