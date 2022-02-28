import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    Key? key,
    this.trailing,
  }) : super(key: key);

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Stack(
        children: [
          Positioned(left: 0, child: SvgPicture.asset('assets/icons/back.svg', semanticsLabel: 'Back to menu')),
          if (trailing != null) Positioned(right: 0, child: trailing!),
        ],
      ),
    );
  }
}
