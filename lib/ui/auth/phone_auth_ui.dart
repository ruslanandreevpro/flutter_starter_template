import 'package:flutter/material.dart';
import 'package:flutter_starter_template/controllers/controllers.dart';
import 'package:get/get.dart';
import 'package:phonenumbers/phonenumbers.dart';

class PhoneAuthUI extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          PhoneNumberFormField(
            controller: _authController.phoneController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            errorMessage: "Введите корректный номер телефона",
            decoration: InputDecoration(
              hintText: "Номер телефона",
              hintStyle: TextStyle(
                  color: Colors.black26
              ),
            ),
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
          SizedBox(height: 24.0,),
          ElevatedButton(
            onPressed: _authController.verifyPhoneNumber,
            child: Text("ВХОД"),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
