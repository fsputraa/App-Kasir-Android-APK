import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kasir/mainscreen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('images/logo.png', height: 200.0, width: 200.0),
            LoadingAnimationWidget.flickr(
              size: 50,
              leftDotColor: Colors.orangeAccent,
              rightDotColor: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}
