
import 'package:askless/index.dart';

String formattedConnection(ConnectionStatus connection) => {
  ConnectionStatus.disconnected: "Disconnected",
  ConnectionStatus.connected: "Connected",
  ConnectionStatus.inProgress: "Connecting",
}[connection] ?? "Unknown: $connection";