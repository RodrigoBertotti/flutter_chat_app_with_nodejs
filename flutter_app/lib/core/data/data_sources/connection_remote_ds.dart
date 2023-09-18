


import 'package:askless/index.dart';

class ConnectionRemoteDS {
  final String serverUrl = "ws://192.168.0.8:3000"; // TODO: Replace with your websocket server URL here (e.g. IPv4)

  void start({required OnAutoReauthenticationFails onAutoReauthenticationFails}) {
    AsklessClient.instance.start(
      serverUrl: serverUrl,
      debugLogs: false,
      onAutoReauthenticationFails: (String credentialErrorCode, void Function() clearAuthentication) {
        print("Credential failed with credentialErrorCode = $credentialErrorCode");
        onAutoReauthenticationFails(credentialErrorCode, clearAuthentication);
      },
    );
  }


  Stream<ConnectionDetails> streamConnectionChanges({bool immediately = false}) {
    // Converting Askless Connection status (Connection enum) to this App connection status (ConnectionStatus enum)
    // This separation is good so the upper layers (repository, use cases, widgets) don't rely on the
    // data source implementation

    return AsklessClient.instance.streamConnectionChanges(immediately: immediately);
  }
}
