import 'package:flutter/material.dart';
import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/src/core/utils/size_utils.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';

class TipsBlock extends StatelessWidget {
  final int tipsCount;
  final VoidCallback? onPressed;
  const TipsBlock({
    super.key,
    required this.tipsCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool ipad = isIpad(context);
    final double iconSize = ipad ? 90 : 63;
    final double badgeSize = ipad ? 40 : 30; // чуть меньше иконки

    return AnimatedButton(
      onPressed: onPressed ?? () {},
      child: SizedBox(
        width: ipad ? 100 : 73,
        child: Stack(
          clipBehavior: Clip.none,          // 1️⃣ даём вылезти за границы
          children: [
            // --- основная иконка ---
            Center(
              child: AppIcon(
                asset: IconProvider.hint.buildImageUrl(),
                width: iconSize,
              ),
            ),

            // --- бейдж ---
            Positioned(
              // 2️⃣ смещаем за угол (top-right). Подберите значение под дизайн
              top: -badgeSize * 0.3,
              right: -badgeSize * 0.3,
              child: Container(
                height: badgeSize,
                width: badgeSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 247, 2, 206),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tipsCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ipad ? 24 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
