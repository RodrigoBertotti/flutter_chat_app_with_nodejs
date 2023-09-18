import 'package:askless/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/screens/content/register_content.dart';
import '../../../core/widgets/center_content_widget.dart';
import '../../../core/widgets/my_appbar_widget.dart';
import '../../../core/widgets/waves_background/waves_background.dart';
import 'content/login_content.dart';


class LoginAndRegistrationScreen extends StatefulWidget {
  static const String route = '/login';

  const LoginAndRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<LoginAndRegistrationScreen> createState() => _LoginAndRegistrationScreenState();
}

class _LoginAndRegistrationScreenState extends State<LoginAndRegistrationScreen> {
  final ValueNotifier<String?> notifyError = ValueNotifier<String?>(null);
  late LoginAndRegistrationContent content;
  String? successMessage;

  connectionChanged(ConnectionDetails connectionDetails) {
    print("Connection status is ${connectionDetails.status} ${connectionDetails.disconnectionReason == null ? "" : " disconnected because ${connectionDetails.disconnectionReason}"}");
  }

  @override
  void initState() {
    super.initState();
    AsklessClient.instance.addOnConnectionChangeListener(connectionChanged, immediately: true);

    final List<dynamic> goToLoginHelper = [];
    loginContent({String? email}) => LoginContent(email: email, notifyError: notifyError, goToLogin: (message, email) => (goToLoginHelper[0] as GoToLoginCallback)(message, email));
    goToLoginHelper.add(
        (message, email) => setState(() {
          content = loginContent(email: email,);
          successMessage = message;
        })
    );
    content = loginContent();
  }

  @override
  void dispose() {
    AsklessClient.instance.removeOnConnectionChangeListener(connectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBarWidget(
          context: context,
          withBackground: true,
          child: Text(content.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        ),
        body: Stack(
          children: [
            const WavesBackground(),
            CenterContentWidget(
              child: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * .1,),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white.withOpacity(.95)
                        ),
                        padding: const EdgeInsets.all(30),
                        child: const Icon(Icons.person, size: 80, color: Colors.blue),
                      ),
                      const SizedBox(height: 45,),

                      content,

                      // error message
                      ValueListenableBuilder(
                          valueListenable: notifyError,
                          builder: (context, error, widget) => error == null || error.isEmpty
                              ? Container()
                              : Column(
                            children: [
                              separator,
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    child: Text(error, style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
                                  )
                              )
                            ],
                          )
                      ),

                      const SizedBox(height: 15,),
                      Align(
                        alignment: const Alignment(.93,0),
                        child: InkWell(
                          child: Ink(
                            child: Text(content.nextContent.title, style: const TextStyle(color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.w600)),
                          ),
                          onTap: () {
                            setState(() {
                              notifyError.value = null;
                              content = content.nextContent;
                            });
                          },
                        ),
                      ),

                      if(successMessage?.isNotEmpty == true)
                        ...[
                          const SizedBox(height: 20,),
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                child: Text(successMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.green[900], fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
                              )
                          )
                        ],

                      const SizedBox(height: 50,)
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
}

const separator = SizedBox(height: 15,);


abstract class LoginAndRegistrationContent extends Widget {
  const LoginAndRegistrationContent({super.key});

  String get title;
  LoginAndRegistrationContent get nextContent;
}

