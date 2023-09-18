import 'package:askless/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/users_repo.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/initialize_app.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/waves_background/waves_background.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/logout.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';
import '../../../screen_routes.dart';
import '../../../core/domain/repositories/auth_repo.dart';
import '../../call/presentation/screens/call_screen.dart';

bool _appStarted = false;
bool _started = false;

class LoadingScreen extends StatelessWidget {
  static const String route = '/';

  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _start(context);

    return Scaffold(
      body: Stack(
        children: [
          const WavesBackground(),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.white,),
                SizedBox(height: 15,),
                Text("Loading...", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> start() async {
    if(!_appStarted) {
      /// Starting Askless and other services
      await getIt.get<InitializeApp>().start(onAutoReauthenticationFails: _onAutoReauthenticationFails);

      /// Configuring Askless to receive calls
      AsklessClient.instance.addOnReceiveCallListener((ReceivingCall receivingCall) {
        print("receiving call");

        getIt.get<UsersRepo>().readUser(receivingCall.remoteUserId).then((res) {
          res.fold((l) {
            print("Accepting call failed! Could not read the remoteUser ${receivingCall.remoteUserId}: \"${l.error}\"");
          }, (remoteUser) {
            Navigator.of(navigatorKey.currentContext!).pushNamed(ScreenRoutes.requestCall, // global context is used to jump to the call page
                arguments: CallScreenArgs(
                  remoteUserId: receivingCall.remoteUserId,
                  callDirection: CallDirection.receivingCall,
                  remoteUserFullName: remoteUser.fullName,
                  videoCall: receivingCall.additionalData["videoCall"]!,
                  receivingCall: receivingCall,
                ));
          });
        });
      });
      _appStarted = true;
    }
  }

  void _start(BuildContext context) {
    if (!_started) {
      _started = true;
      (() async {
        start().then((_) {
          if (getIt.get<AuthRepo>().isAuthenticated()) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                ScreenRoutes.conversations, (_) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                ScreenRoutes.login, (_) => false);
          }
        });
      })();
    }
  }
}

final _onAutoReauthenticationFails = () {
  getIt.get<Logout>().call();
  Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(ScreenRoutes.login, (route) => false);
};
