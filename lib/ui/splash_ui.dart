import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Get.toNamed("/auth");
              },
              child: Text("Авторизация"),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
