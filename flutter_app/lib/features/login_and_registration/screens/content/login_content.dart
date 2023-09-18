import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/screens/content/register_content.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import '../../../../core/domain/entities/failures/failure.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/button_widget.dart';
import '../../../../core/widgets/my_custom_text_form_field.dart';
import '../../../../screen_routes.dart';
import '../../domain/entities/failures/invalid_email_failure.dart';
import '../../domain/entities/failures/invalid_password_failure.dart';
import '../../domain/use_cases/login.dart';
import '../login_and_registration_screen.dart';
import '../widgets/icon/animated_icon.dart';


class LoginContent extends StatefulWidget implements LoginAndRegistrationContent  {
  late final ValueNotifier<String?> notifyError;
  final GoToLoginCallback goToLogin;
  String? email;

  LoginContent({Key? key, ValueNotifier<String?>? notifyError, required this.goToLogin, this.email,}) : super(key: key) {
    this.notifyError = notifyError ?? ValueNotifier<String?>(null);
  }

  @override
  State<LoginContent> createState() => _LoginContentState();

  @override
  String get title => "Sign in to your account";

  @override
  LoginAndRegistrationContent get nextContent => RegisterContent(notifyError: notifyError, goToLogin: goToLogin,);

}

class _LoginContentState extends State<LoginContent> {

  final ValueNotifier<bool> notifyIsLoading = ValueNotifier<bool>(false);
  final loginFormKey = GlobalKey<FormState>();

  ValueNotifier<String?> notifyEmailError = ValueNotifier<String?>(null);
  ValueNotifier<String?> notifyPasswordError = ValueNotifier<String?>(null);
  ValueNotifier<bool> notifySuccess = ValueNotifier<bool>(false);

  late final TextEditingController emailController = TextEditingController(text: widget.email ?? "");
  final TextEditingController passwordController = TextEditingController();


  @override
  void dispose() {
    notifyIsLoading.dispose();
    notifyEmailError.dispose();
    notifyPasswordError.dispose();
    notifySuccess.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: loginFormKey,
      child: Column(
        children: [
          MyCustomTextFormField(
            controller: emailController,
            hintText: 'Your email',
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
            notifyError: notifyEmailError,
            prefixIcon: MyAnimatedIcon(icon: Icons.email_rounded, notifySuccess: notifySuccess, notifyError: notifyEmailError),
          ),
          separator,
          MyCustomTextFormField(
            controller: passwordController,
            hintText: 'Your password',
            validator: validateRequired,
            obscureText: true,
            notifyError: notifyPasswordError,
            keyboardType: TextInputType.text,
            prefixIcon: MyAnimatedIcon(icon: Icons.key, notifySuccess: notifySuccess, notifyError: notifyPasswordError),
          ),
          separator,
          ValueListenableBuilder(
            valueListenable: notifyIsLoading,
            builder: (__, isLoading, _) {
              return ValueListenableBuilder(
                  valueListenable: notifySuccess,
                  builder: (__, success, _) {
                    return ButtonWidget(
                        text: success ? "SUCCESS" : "LOGIN",
                        isLoading: isLoading && !success,
                        onPressed: success ? null : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          widget.notifyError.value = null;
                          notifyEmailError.value = notifyPasswordError.value = null;

                          if(loginFormKey.currentState!.validate()){
                            loginFormKey.currentState!.save();
                            notifyIsLoading.value = true;

                            getIt<Login>().call(email: emailController.text, password: passwordController.text,).then((res) {
                              notifyIsLoading.value = false;
                              res.fold(loginFailed, (_) => loginSuccessfully(context));
                            });
                          }
                        }
                    );
                  }
              );
            },
          )
        ],
      ),
    );
  }

  void loginFailed(Failure failure) {
    if(Failure is InvalidEmailFailure){
      notifyEmailError.value = failure.error;
    } else if(Failure is InvalidPasswordFailure){
      notifyPasswordError.value = failure.error;
    } else {
      widget.notifyError.value = failure.error;
    }
  }

  void loginSuccessfully(BuildContext context) {
    notifySuccess.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.conversations, (route) => false);
    });
  }


}

