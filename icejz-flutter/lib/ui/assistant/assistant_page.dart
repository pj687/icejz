import 'package:flutter/material.dart';
import 'package:icejz_app/data/api_exception.dart';
import 'package:icejz_app/data/repositories/ai_repository.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';

class _ChatBubble {
  _ChatBubble(this.id, this.mine, this.content);
  final int id;
  final bool mine;
  final String content;
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _repo = AiRepository();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final messages = <_ChatBubble>[];
  bool sending = false;
  int sessionId = 0;
  String greeting = '你好，我是小冰助手，有什么可以帮你？';
  int seq = 1;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final robot = await _repo.robot();
      final g = robot?.greeting;
      if (g != null && g.isNotEmpty) greeting = g;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      messages.add(_ChatBubble(seq++, false, greeting));
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || sending) return;
    setState(() {
      messages.add(_ChatBubble(seq++, true, text));
      _inputController.clear();
      sending = true;
    });
    _scrollToEnd();
    try {
      final reply = await _repo.chat(
        text,
        sessionId: sessionId > 0 ? sessionId : null,
      );
      if (reply.sessionId != null) sessionId = reply.sessionId!;
      final content = (reply.content == null || reply.content!.isEmpty)
          ? '我暂时没有合适的回答'
          : reply.content!;
      setState(() {
        messages.add(_ChatBubble(seq++, false, content));
      });
    } catch (e) {
      final msg = e is ApiException ? e.message : '请求失败，请稍后重试';
      setState(() {
        messages.add(_ChatBubble(seq++, false, msg));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : '发送失败')),
        );
      }
    } finally {
      if (mounted) setState(() => sending = false);
      _scrollToEnd();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            IceNavBar(title: '小冰助手', onBack: widget.onBack),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/xiaobing_head.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '小冰',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.iceInk,
                        ),
                      ),
                      Text(
                        'ICEJZ AI Assistant',
                        style: TextStyle(
                          color: AppColors.iceMute,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final msg = messages[i];
                  return Align(
                    alignment: msg.mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: msg.mine ? AppColors.iceCyan : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(
                          color: msg.mine ? Colors.white : AppColors.iceInk,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(
                          color: AppColors.iceInk,
                          fontSize: 15,
                        ),
                        cursorColor: AppColors.iceCyan,
                        decoration: const InputDecoration(
                          hintText: '输入问题…',
                          hintStyle: TextStyle(color: Color(0xFF9AA8B6)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Builder(
                      builder: (context) {
                        final canSend =
                            !sending && _inputController.text.trim().isNotEmpty;
                        return GestureDetector(
                          onTap: canSend ? _send : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: canSend
                                  ? AppColors.iceCyan
                                  : const Color(0xFFC5CED6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '发送',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
