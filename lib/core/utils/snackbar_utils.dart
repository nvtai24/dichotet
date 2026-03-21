import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

void showErrorSnackBar(ScaffoldMessengerState messenger, Object error) {
  final msg = error.toString().replaceAll('Exception: ', '');
  messenger.showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
