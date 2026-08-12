import 'package:flutter/material.dart';
import 'package:renjana/constant/app_colors.dart';
import 'package:renjana/constant/app_images.dart';

class TestDay20 extends StatelessWidget {
  const TestDay20({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(children: [Image.asset(AppImages.dragonBall)]),
    );
  }
}
