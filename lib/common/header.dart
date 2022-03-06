import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'text.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    Key? key,
    this.trailing,
    this.title = '',
  }) : super(key: key);

  final Widget? trailing;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: SvgPicture.asset('assets/icons/back.svg', semanticsLabel: 'Back to menu'),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: AppText.title(title),
            ),
          ),
          if (trailing != null) Positioned(right: 0, child: trailing!),
        ],
      ),
    );
  }
}
