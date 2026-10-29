import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class NotificationImageStrip extends StatelessWidget {
  final List<String> imageUrls;
  final ValueChanged<int> onTap;

  static const int maxVisible = 3;
  static const double thumbSize = 64;

  const NotificationImageStrip({
    super.key,
    required this.imageUrls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final visible = imageUrls.take(maxVisible).toList();
    final extra = imageUrls.length - visible.length;

    return Row(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _Thumbnail(
            key: ValueKey('notification-image-$i'),
            url: visible[i],
            extra: i == visible.length - 1 ? extra : 0,
            onTap: () => onTap(i),
          ),
        ],
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String url;
  final int extra;
  final VoidCallback onTap;

  const _Thumbnail({
    super.key,
    required this.url,
    required this.extra,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: NotificationImageStrip.thumbSize,
        height: NotificationImageStrip.thumbSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 20,
                  color: context.muted,
                ),
              ),
            ),
            if (extra > 0)
              ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+$extra',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

void showNotificationImage(
  BuildContext context,
  List<String> imageUrls,
  int index,
) {
  if (imageUrls.isEmpty || index < 0 || index >= imageUrls.length) return;

  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
