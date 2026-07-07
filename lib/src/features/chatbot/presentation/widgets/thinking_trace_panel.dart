import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ThinkingTracePanel extends StatefulWidget {
  final bool isThinking;
  final bool autoCollapsed;
  final VoidCallback? onTap;

  const ThinkingTracePanel({
    super.key,
    required this.isThinking,
    this.autoCollapsed = false,
    this.onTap,
  });

  @override
  State<ThinkingTracePanel> createState() => _ThinkingTracePanelState();
}

class _ThinkingTracePanelState extends State<ThinkingTracePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _heightController;
  late Animation<double> _heightFactor;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _expanded = !widget.autoCollapsed;
    _heightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heightFactor = CurvedAnimation(
      parent: _heightController,
      curve: Curves.easeOut,
    );
    if (_expanded) _heightController.value = 1.0;
  }

  @override
  void didUpdateWidget(ThinkingTracePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoCollapsed && !oldWidget.autoCollapsed) {
      _collapse();
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_expanded) {
      _collapse();
    } else {
      _expand();
    }
    widget.onTap?.call();
  }

  void _expand() {
    setState(() => _expanded = true);
    _heightController.forward();
  }

  void _collapse() {
    _heightController.reverse().then((_) {
      if (mounted) setState(() => _expanded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: SizeTransition(
        sizeFactor: _heightFactor,
        // ignore: deprecated_member_use
        axisAlignment: -1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: context.chatThinkingBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.isThinking
                                ? 'Analyzing your question...'
                                : 'Analyzed \u00b7 tap to collapse',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: widget.isThinking
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: context.muted,
                            ),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: _expanded ? 0.0 : -0.5,
                            duration: const Duration(milliseconds: 150),
                            child: Icon(
                              Icons.chevron_left,
                              size: 14,
                              color: context.muted,
                            ),
                          ),
                        ],
                      ),
                      if (_expanded && widget.isThinking)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Searching INTRA knowledge base for relevant answers\u2026',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              height: 1.55,
                              color: context.chatThinkingText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
