import 'package:flutter_starter_template/ui/auth/auth.dart';
import 'package:flutter_starter_template/ui/ui.dart';
import 'package:get/get.dart';

class AppRoutes {
  AppRoutes._(); // это сделано для того, чтобы никто не мог создать экземпляр этого объекта
  static final routes = [
    GetPage(name: '/', page: () => SplashUI()),
    GetPage(name: '/auth', page: () => AuthUI()),
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/reset_password', page: () => ResetPasswordUI()),
    GetPage(name: '/phone_auth', page: () => PhoneAuthUI()),
    GetPage(name: '/home', page: () => HomeUI()),
    GetPage(name: '/settings', page: () => SettingsUI()),
    GetPage(name: '/update_profile', page: () => UpdateProfileUI()),
  ];
}