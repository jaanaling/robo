import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';

import 'package:neuro_robot/src/feature/rituals/model/article.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';

import '../../../core/utils/size_utils.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;
  const ArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  Gap(15),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedButton(
                            child: AppIcon(
                              asset: IconProvider.back.buildImageUrl(),
                              width:isIpad(context)?90:63,
                              fit: BoxFit.fitWidth,
                            ),
                            onPressed: () {
                              context.pop();
                            }),
                        Gap(24),
                      ]),        Gap(45),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 43),
                      child: Text(
                        article.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Gap(45),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(206, 35, 0, 75),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      
                      child: Text(
                        article.content,
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 26, fontFamily: "F"),
                      ),
                    ),
                  ),
                  Gap(20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
