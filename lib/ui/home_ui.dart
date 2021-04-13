import 'package:flutter/material.dart';
import 'package:flutter_starter_template/controllers/controllers.dart';
import 'package:get/get.dart';

class HomeUI extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(),
            ElevatedButton(onPressed: _authController.signOut, child: Text("Выход"),),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
