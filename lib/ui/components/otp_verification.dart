import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/controllers/controllers.dart';
import 'package:get/get.dart';

void otpVerification() {
  final AuthController _authController = Get.find<AuthController>();

  Get.dialog(
    AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _authController.otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Код из СМС сообщения",
              ),
            ),
            SizedBox(height: 24.0,),
            ElevatedButton(
              onPressed: () {
                AuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: _authController.verificationID, smsCode: _authController.otpController.text);
                _authController.signInWithPhoneAuthCredential(phoneAuthCredential);
              },
              child: Text("Отправить".toUpperCase()),
            ),
          ],
        )
    ),
    arguments: {},
    barrierDismissible: false,
  );
}
