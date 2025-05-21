import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/src/core/utils/size_utils.dart';
import 'package:neuro_robot/src/core/utils/text_with_border.dart';
import 'package:neuro_robot/ui_kit/sound_button.dart';

import 'animated_button.dart';

class AppButton extends StatelessWidget {
  final bool isMenu;
  final VoidCallback onPressed;
  final String title;
  const AppButton({
    super.key,
    required this.isMenu,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppIcon(
            width: isIpad(context) ? 800 : null,
            asset: isMenu
                ? IconProvider.menuButton.buildImageUrl()
                : IconProvider.button.buildImageUrl(),
            fit: isIpad(context) ? BoxFit.fitWidth : BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: FittedBox(
                child: isMenu
                    ? TextWithBorder(title)
                    : Text(
                        title.toUpperCase(),
                        style: TextStyle(
                            color: Color(
                              (0xFF8200EE),
                            ),
                            fontFamily: "F",
                            fontSize: 30),
                      )),
          ),
        ],
      ),
      onPressed: () {
        onPressed();
      },
    );
  }
}
