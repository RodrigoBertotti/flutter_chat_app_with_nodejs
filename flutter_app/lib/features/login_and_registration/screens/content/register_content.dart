import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/button_widget.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/my_custom_text_form_field.dart';
import '../../domain/entities/failures/email_already_exists_failure.dart';
import '../../domain/use_cases/register.dart';
import '../login_and_registration_screen.dart';
import '../widgets/icon/animated_icon.dart';
import 'login_content.dart';

typedef GoToLoginCallback = void Function(String message, String email);

class RegisterContent extends StatefulWidget implements LoginAndRegistrationContent {
  final GoToLoginCallback goToLogin;
  final ValueNotifier<String?> notifyError;

  const RegisterContent({Key? key, required this.notifyError, required this.goToLogin}) : super(key: key);

  @override
  State<RegisterContent> createState() => _RegisterContentState();

  @override
  String get title => "Register a new account";

  @override
  LoginAndRegistrationContent get nextContent => LoginContent(notifyError: notifyError, goToLogin: goToLogin,);

}

class _RegisterContentState extends State<RegisterContent> {
  final registerFormKey = GlobalKey<FormState>();

  final ValueNotifier<bool>    notifySuccess = ValueNotifier<bool>(false);
  final ValueNotifier<bool>    notifyIsLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> notifyInvalidEmail = ValueNotifier<String?>(null);
  final ValueNotifier<String?> notifyInvalidPassword2 = ValueNotifier<String?>(null);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();


  @override
  void dispose() {
    notifySuccess.dispose();
    notifyIsLoading.dispose();
    notifyInvalidEmail.dispose();
    notifyInvalidPassword2.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: registerFormKey,
      child: Column(
        children: [
          MyCustomTextFormField(
            hintText: 'First name',
            keyboardType: TextInputType.text,
            validator: validateRequired,
            prefixIcon: MyAnimatedIcon(icon: Icons.person, notifySuccess: notifySuccess),
            controller: firstNameController,
          ),
          separator,
          MyCustomTextFormField(
            hintText: 'Last name',
            keyboardType: TextInputType.text,
            validator: validateRequired,
            prefixIcon: MyAnimatedIcon(icon: Icons.person, notifySuccess: notifySuccess),
            controller: lastNameController,
          ),
          separator,
          MyCustomTextFormField(
            hintText: 'Email',
            notifyError: notifyInvalidEmail,
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: MyAnimatedIcon(icon: Icons.email_rounded, notifySuccess: notifySuccess,),
            controller: emailController,
          ),
          separator,
          MyCustomTextFormField(
            hintText: 'Password',
            keyboardType: TextInputType.text,
            obscureText: true,
            validator: validateCreatePassword,
            prefixIcon: MyAnimatedIcon(icon: Icons.key, notifySuccess: notifySuccess),
            controller: password1Controller,
          ),
          separator,
          MyCustomTextFormField(
            hintText: 'Confirm your password',
            keyboardType: TextInputType.text,
            validator: validateRequired,
            notifyError: notifyInvalidPassword2,
            obscureText: true,
            prefixIcon: MyAnimatedIcon(icon: Icons.key, notifySuccess: notifySuccess),
            controller: password2Controller,
          ),
          separator,

          ValueListenableBuilder(
              valueListenable: notifyIsLoading,
              builder: (context, isLoading, _) => ValueListenableBuilder(
                  valueListenable: notifySuccess,
                  builder: (context, success, __) => ButtonWidget(text: success ? "SUCCESS" : "REGISTER", isLoading: notifyIsLoading.value, onPressed: success ? null : () {
                    widget.notifyError.value = null;

                    if(password1Controller.text != password2Controller.text){
                      notifyInvalidPassword2.value = "The passwords doesn't match";
                      return;
                    }

                    if(registerFormKey.currentState!.validate()) {
                      notifyIsLoading.value = true;
                      getIt<Register>().call(
                        email: emailController.text,
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        password: password1Controller.text,
                      ).then((res) {
                        notifyIsLoading.value = false;
                        res.fold(registerFailed, (_) => registeredSuccessfully(context));
                      });
                    }
                  })
              )
          ),
        ],
      ),
    );
  }

  void registerFailed(Failure failure) {
    if (failure is EmailAlreadyExistsFailure) {
      notifyInvalidEmail.value = failure.error; //Email is already in use, please, try to login into your account
    } else {
      widget.notifyError.value = failure.error;
    }
  }

  void registeredSuccessfully(BuildContext context) {
    notifySuccess.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      widget.goToLogin("Your account was successfully created!\nPlease, sign in to your account", emailController.text);
    });
  }
}