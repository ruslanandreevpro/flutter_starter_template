import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_template/controllers/controllers.dart';
import 'package:get/get.dart';

class SignUpUI extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 48.0),
                  TextFormField(
                    controller: authController.nameController,
                    validator: (value) {
                      String pattern =
                          r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$";
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value!))
                        return 'validator.name'.tr;
                      else
                        return null;
                    },
                    onChanged: (value) => null,
                    onSaved: (value) =>
                    authController.nameController.text = value!,
                  ),
                  SizedBox(height: 16.0,),
                  TextFormField(
                    controller: authController.emailController,
                    validator: (value) {
                      String pattern =
                          r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value!))
                        return 'validator.email'.tr;
                      else
                        return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => null,
                    onSaved: (value) =>
                    authController.emailController.text = value!,
                  ),
                  SizedBox(height: 16.0,),
                  TextFormField(
                    controller: authController.passwordController,
                    validator: (value) {
                      String pattern = r'^.{6,}$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value!))
                        return 'validator.password'.tr;
                      else
                        return null;
                    },
                    obscureText: true,
                    onChanged: (value) => null,
                    onSaved: (value) =>
                    authController.passwordController.text = value!,
                    maxLines: 1,
                  ),
                  SizedBox(height: 16.0,),
                  ElevatedButton(
                      child: Text('auth.signUpButton'.tr),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          SystemChannels.textInput.invokeMethod(
                              'TextInput.hide'); //to hide the keyboard - if any
                          authController.registerWithEmailAndPassword(context);
                        }
                      }),
                  SizedBox(height: 16.0,),
                  TextButton(
                    child: Text('auth.signInLabelButton'.tr),
                    onPressed: () => Get.toNamed("/signin"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}