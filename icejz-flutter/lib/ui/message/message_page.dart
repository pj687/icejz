import 'package:flutter/material.dart';
import 'package:icejz_app/data/api_exception.dart';
import 'package:icejz_app/data/models.dart';
import 'package:icejz_app/data/repositories/home_repository.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/components/common.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _repo = HomeRepository();
  List<MessageItem> list = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      list = (await _repo.messagePage()).list;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : '加载失败'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
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
              title: '我的消息',
              onBack: widget.onBack,
              trailing: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () async {
                    await _repo.readAll();
                    await _refresh();
                  },
                  child: const Text(
                    '全部已读',
                    style: TextStyle(color: AppColors.iceCyan, fontSize: 13),
                  ),
                ),
              ),
            ),
            Expanded(
              child: !loading && list.isEmpty
                  ? const EmptyState(
                      title: '暂无站内消息',
                      desc: '系统通知会显示在这里',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final item = list[i];
                        final unread = item.readStatus != 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: GestureDetector(
                            onTap: () async {
                              if (item.id != null) {
                                try {
                                  await _repo.readMessage(item.id!);
                                } catch (_) {}
                                await _refresh();
                              }
                            },
                            child: Container(
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
                                      if (unread) ...[
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.iceCyan,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          item.title ?? '系统通知',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.iceInk,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.content ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.iceMute,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.sendTime ?? item.createTime ?? '',
                                    style: const TextStyle(
                                      color: AppColors.iceMute,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
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
