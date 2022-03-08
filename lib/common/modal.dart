import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colors.dart';
import 'text.dart';

class Modal extends StatelessWidget {
  const Modal({
    Key? key,
    required this.message,
    this.cancelText = 'Cancel',
    this.acceptText = 'OK',
    this.onCancel,
    this.onSuccess,
  }) : super(key: key);

  final String message;
  final String cancelText;
  final String acceptText;
  final VoidCallback? onCancel;
  final VoidCallback? onSuccess;

  show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'modalBarrier',
      pageBuilder: (context, _, __) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();

    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: min(300, constraints.maxWidth * 0.7)),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(message),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      if (onCancel != null) onCancel!();
                      Navigator.of(context).pop();
                    },
                    child: AppText(cancelText),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      if (onSuccess != null) onSuccess!();
                      Navigator.of(context).pop();
                    },
                    child: AppText(acceptText),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
