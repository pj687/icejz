import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icejz_app/theme/app_colors.dart';

class IceNavBar extends StatelessWidget {
  const IceNavBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.iceCanvas.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: AppColors.iceInk),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.iceInk,
              ),
            ),
          ),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class IceCard extends StatelessWidget {
  const IceCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.icePanel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: child,
    );
  }
}

class IcePrimaryButton extends StatelessWidget {
  const IcePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: active ? onPressed : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: active
                  ? const [AppColors.iceCyan, Color(0xFF2BB8EF)]
                  : const [Color(0xFFC5CED6), Color(0xFFC5CED6)],
            ),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class IceField extends StatefulWidget {
  const IceField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.trailing,
    this.tip,
    this.error = false,
    this.readOnly = false,
  });

  final String label;
  final String value;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? trailing;
  final String? tip;
  final bool error;
  final bool readOnly;

  @override
  State<IceField> createState() => _IceFieldState();
}

class _IceFieldState extends State<IceField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant IceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.iceMute,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.error
                  ? AppColors.iceDanger
                  : const Color(0x140F2337),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText,
                  readOnly: widget.readOnly,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  style: const TextStyle(color: AppColors.iceInk, fontSize: 15),
                  cursorColor: AppColors.iceCyan,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA8B6),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
        if (widget.tip != null && widget.tip!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.tip!,
            style: TextStyle(
              color: widget.error ? AppColors.iceDanger : AppColors.iceMute,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.iceSize = 28, this.jzSize = 28});

  final double iceSize;
  final double jzSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ICE',
          style: TextStyle(
            color: AppColors.iceInk,
            fontSize: iceSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        Text(
          'JZ',
          style: TextStyle(
            color: AppColors.iceCyan,
            fontSize: jzSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.title,
    this.hint,
    required this.onTap,
  });

  final String title;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.iceInk,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hint != null && hint!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      hint!,
                      style: const TextStyle(
                        color: AppColors.iceMute,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.iceMute),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.desc = ''});

  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.iceCyan.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.iceInk,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(color: AppColors.iceMute, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key, required this.values});

  final List<(String, int)> values;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<int>(1, (m, e) => e.$2 > m ? e.$2 : m);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: values.map((e) {
          final barH = (100.0 * e.$2 / max).clamp(4.0, 100.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 18,
                height: barH,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.iceCyan, Color(0xFF7DD3FC)],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                e.$1,
                style: const TextStyle(fontSize: 11, color: AppColors.iceMute),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
