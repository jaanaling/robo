import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextWithBorder extends StatelessWidget {
  final String text;
  final Color? borderColor;
  final Color? color;
  final double? fontSize;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final String? fontFamily;
  final TextOverflow? overflow;
  final double? pBottom;
  final double? pTop;
  final double? pLeft;
  final double? pRight;

  const TextWithBorder(
    this.text, {
    super.key,
    this.borderColor,
    this.fontSize,
    this.letterSpacing,
    this.textAlign,
    this.fontFamily,
    this.color,
    this.overflow,
    this.pBottom = -2,
    this.pTop ,
    this.pLeft = -1,
    this.pRight ,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: pBottom ,
          top: pTop,
          left: pLeft,
          right: pRight,
          child: Text(
            text,
            textAlign: textAlign,
            overflow: overflow,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              letterSpacing: letterSpacing,
              fontFamily: fontFamily ?? 'F',
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 5
                ..color = borderColor ?? const Color(0xFF3F1BAD),
            ),
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          overflow: overflow,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            letterSpacing: letterSpacing,
            fontFamily: fontFamily ?? 'F',
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
