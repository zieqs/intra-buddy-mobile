import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';

class ChatMessageBubble extends StatelessWidget {
  final Widget child;
  final bool isUser;
  final bool showCopy;
  final String? copyText;

  const ChatMessageBubble({
    super.key,
    required this.child,
    required this.isUser,
    this.showCopy = false,
    this.copyText,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) return _buildUserBubble(context);

    return _buildAssistantBubble(context);
  }

  Widget _buildUserBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: context.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: AppColors.primary.withAlpha(76),
                ),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 9,
                backgroundColor: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'INTRA Buddy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DefaultTextStyle(
            style: TextStyle(
              color: context.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
            child: child,
          ),
          if (showCopy && copyText != null) ...[
            const SizedBox(height: 8),
            _CopyButton(copyText: copyText!),
          ],
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String copyText;

  const _CopyButton({required this.copyText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: copyText));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.copy, size: 16, color: context.muted),
          const SizedBox(width: 4),
          Text(
            'Copy',
            style: TextStyle(
              fontSize: 12,
              color: context.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
