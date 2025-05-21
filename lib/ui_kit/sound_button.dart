import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';
import 'package:just_audio/just_audio.dart';

import '../src/core/utils/size_utils.dart';

final player = AudioPlayer();
ValueNotifier<bool> isPlaying = ValueNotifier(true);

class SoundButton extends StatefulWidget {
  const SoundButton({super.key});

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPlaying,
      builder: (context, value, child) {
        return AnimatedButton(
          onPressed: () {
            setState(() {
              if (value) {
                stopMusic();
                isPlaying.value = false;
              } else {
                playMusic();
                isPlaying.value = true;
              }
            });
          },
          child: Icon(
            isPlaying.value
                ? CupertinoIcons.speaker_1_fill
                : CupertinoIcons.speaker_zzz,
            size: isIpad(context) ? 90 : 63,
          ),
        );
      },
    );
  }
}

void playMusic() async {
  await player.setAsset('assets/music/music.mp3');
  await player.setLoopMode(LoopMode.one); // Зацикливаем трек
  await player.setVolume(0.35);
  await player.play();
}

void stopMusic() async {
  await player.stop();
}
