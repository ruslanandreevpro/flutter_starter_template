import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_template/helpers/helpers.dart';
import 'package:flutter_starter_template/models/models.dart';
import 'package:flutter_starter_template/ui/components/components.dart';
import 'package:get/get.dart';
import 'package:phonenumbers/phonenumbers.dart';

class AuthController extends GetxController {
  static AuthController to = Get.find();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  PhoneNumberEditingController phoneController = PhoneNumberEditingController.fromCountryCode('RU');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> firestoreUser = Rxn<UserModel>();

  final RxBool admin = false.obs;

  String verificationID = "";

  @override
  void onReady() async {
    // запускать каждый раз при изменении состояния аутентификации
    ever(firebaseUser, handleAuthChanged);

    firebaseUser.bindStream(user);

    super.onReady();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  handleAuthChanged(_firebaseUser) async {

    // Получить данные пользователя из firestore
    if (_firebaseUser?.uid != null) {
      firestoreUser.bindStream(streamFirestoreUser());
      await isAdmin();
    }

    if (_firebaseUser == null) {
      Get.offAllNamed("/");
    } else {
      Get.offAllNamed("/home");
    }
  }

  // Одноразовое получение данных пользователем Firebase
  Future<User> get getUser async => _auth.currentUser!;

  // Пользователь Firebase поток в реальном времени
  Stream<User?> get user => _auth.authStateChanges();

  // Потоковая передача пользователя Firestore из коллекции Firestore
  Stream<UserModel> streamFirestoreUser() {
    return _db
        .doc('/users/${firebaseUser.value!.uid}')
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot.data()!));
  }

  // Получить пользователя Firestore из коллекции Firestore
  Future<UserModel> getFirestoreUser() {
    return _db.doc('/users/${firebaseUser.value!.uid}').get().then(
            (documentSnapshot) => UserModel.fromMap(documentSnapshot.data()!));
  }

  // Регистрация пользователя по электронной почте и паролю
  registerWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth
          .createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text)
          .then((result) async {
        //get photo url from gravatar if user has one
        Gravatar gravatar = Gravatar(emailController.text);
        String gravatarUrl = gravatar.imageUrl(
          size: 200,
          defaultImage: GravatarImage.retro,
          rating: GravatarRating.pg,
          fileExtension: true,
        );
        //создать новый объект пользователя
        UserModel _newUser = UserModel(
            uid: result.user!.uid,
            email: result.user!.email!,
            name: nameController.text,
            photoUrl: gravatarUrl);
        //создать пользователя в firestore
        _createUserFirestore(_newUser, result.user!);
        emailController.clear();
        passwordController.clear();
        hideLoadingIndicator();
      });
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.signUpErrorTitle'.tr, error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  // Авторизация пользователя по электронной почте и паролю
  signInWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      emailController.clear();
      passwordController.clear();
      hideLoadingIndicator();
    } catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.signInErrorTitle'.tr, 'auth.signInError'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  // Создание пользователя Firestore в коллекции пользователей
  void _createUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/users/${_firebaseUser.uid}').set(user.toJson());
    update();
  }

  // Обновление пользователя Firestore в коллекции пользователей
  void _updateUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/users/${_firebaseUser.uid}').update(user.toJson());
    update();
  }

  // Обновление пользователя при обновлении профиля
  Future<void> updateUser(BuildContext context, UserModel user, String oldEmail,
      String password) async {
    try {
      showLoadingIndicator();
      await _auth
          .signInWithEmailAndPassword(email: oldEmail, password: password)
          .then((_firebaseUser) {
        _firebaseUser.user!
            .updateEmail(user.email)
            .then((value) => _updateUserFirestore(user, _firebaseUser.user!));
      });
      hideLoadingIndicator();
      Get.snackbar('auth.updateUserSuccessNoticeTitle'.tr,
          'auth.updateUserSuccessNotice'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } on PlatformException catch (error) {
      //List<String> errors = error.toString().split(',');
      // print("Error: " + errors[1]);
      hideLoadingIndicator();
      String authError;
      switch (error.code) {
        case 'ERROR_WRONG_PASSWORD':
          authError = 'auth.wrongPasswordNotice'.tr;
          break;
        default:
          authError = 'auth.unknownError'.tr;
          break;
      }
      Get.snackbar('auth.wrongPasswordNoticeTitle'.tr, authError,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  // Сброс пароля по электронной почте
  Future<void> sendPasswordResetEmail(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      hideLoadingIndicator();
      Get.snackbar(
          'auth.resetPasswordNoticeTitle'.tr, 'auth.resetPasswordNotice'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.resetPasswordFailed'.tr, error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  // Авторизация по номеру телефона
  signInWithPhoneAuthCredential(AuthCredential phoneAuthCredential) async {
    showLoadingIndicator();
    try {
      final authCredential = await _auth.signInWithCredential(phoneAuthCredential).then((result) async {
        //get photo url from gravatar if user has one
        Gravatar gravatar = Gravatar(emailController.text);
        String gravatarUrl = gravatar.imageUrl(
          size: 200,
          defaultImage: GravatarImage.retro,
          rating: GravatarRating.pg,
          fileExtension: true,
        );
        //создать новый объект пользователя
        UserModel _user = UserModel(
            uid: result.user!.uid,
            email: result.user!.email ?? "",
            name: nameController.text,
            photoUrl: gravatarUrl);
        //создать пользователя в firestore
        _createUserFirestore(_user, result.user!);
        hideLoadingIndicator();
      });
      hideLoadingIndicator();
    } on FirebaseAuthException catch (e) {
      hideLoadingIndicator();
      Get.snackbar('Ошибка'.tr, e.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  // Проверка номера телефона при помощи СМС
  verifyPhoneNumber() async {
    showLoadingIndicator();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneController.value.toString(),
      verificationCompleted: (phoneAuthCredential) async {
        hideLoadingIndicator();
      },
      verificationFailed: (verificationFailed) async {
        hideLoadingIndicator();
        Get.snackbar('Ошибка'.tr, verificationFailed.message!,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5),
            backgroundColor: Get.theme.snackBarTheme.backgroundColor,
            colorText: Get.theme.snackBarTheme.actionTextColor);
      },
      codeSent: (verificationID, resendingToken) async {
        hideLoadingIndicator();
        this.verificationID = verificationID;
        otpVerification();
        return;
      },
      codeAutoRetrievalTimeout: (verificationID) async {},
    );
  }

  // Проверка является ли пользователь администратором
  isAdmin() async {
    await getUser.then((user) async {
      DocumentSnapshot adminRef =
      await _db.collection('admin').doc(user.uid).get();
      if (adminRef.exists) {
        admin.value = true;
      } else {
        admin.value = false;
      }
      update();
    });
  }

  // Выход
  Future<void> signOut() async {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    otpController.clear();
    await _auth.signOut();
    // Get.offAllNamed("/");
  }
}