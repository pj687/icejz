import 'package:flutter/material.dart';
import 'package:icejz_app/config/brand.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';

class _GuidePageData {
  const _GuidePageData(this.title, this.desc);
  final String title;
  final String desc;
}

class GuidePage extends StatefulWidget {
  const GuidePage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  static const pages = [
    _GuidePageData('欢迎使用 ICEJZ', Brand.description),
    _GuidePageData(
      '工作台一览',
      '与管理端同源数据，移动端快速查阅用户、机构、角色与消息。',
    ),
    _GuidePageData(
      '小冰助手',
      '随时唤起 AI 助手，整理待办、快速打开常用系统模块。',
    ),
  ];

  int page = 0;

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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: widget.onDone,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '跳过',
                        style: TextStyle(
                          color: AppColors.iceMute,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/xiaobing_main.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      const Wordmark(iceSize: 30, jzSize: 30),
                      const SizedBox(height: 18),
                      Text(
                        pages[page].title,
                        style: const TextStyle(
                          color: AppColors.iceInk,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          pages[page].desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.iceMute,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: page == i ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: page == i
                              ? AppColors.iceCyan
                              : AppColors.iceCyan.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                IcePrimaryButton(
                  text: page == pages.length - 1 ? '进入首页' : '下一步',
                  onPressed: () {
                    if (page == pages.length - 1) {
                      widget.onDone();
                    } else {
                      setState(() => page += 1);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
