import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Get.toNamed("/signin");
              },
              child: Text("По электронной почте"),
            ),
            SizedBox(height: 24.0,),
            ElevatedButton(
              onPressed: () {
                Get.toNamed("/phone_auth");
              },
              child: Text("По номеру телефона"),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
