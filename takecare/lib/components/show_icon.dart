import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShowIcon extends StatelessWidget {
  const ShowIcon({
    super.key,
    this.icon,
    this.iconData,
    required this.iconColor,
    required this.bgColor,
    required this.size,
  });

  final String? icon;
  final IconData? iconData;
  final Color bgColor;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: icon != null
          ? SvgPicture.asset(
        icon!,
        width: size/2.5,
        height: size/2.5,
        colorFilter: ColorFilter.mode(
          iconColor,
          BlendMode.srcIn,
        ),
      )
          : Icon(
        iconData,
        color: iconColor,
        size: size/2,
      ),
    );
  }
}