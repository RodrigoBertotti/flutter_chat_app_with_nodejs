import 'package:askless/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/stream_connection_changes.dart';
import '../../injection_container.dart';
import '../utils/formatted_text.dart';


class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  Color getColor (ConnectionStatus connectionStatus){
    if (connectionStatus == ConnectionStatus.connected) {
      return Colors.blue[900]!;
    }
    if (connectionStatus == ConnectionStatus.disconnected) {
      return Colors.red[300]!;
    }
    if (connectionStatus == ConnectionStatus.inProgress) {
      return Colors.grey[500]!;
    }
    throw "TODO: $connectionStatus";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionDetails>(
      stream: getIt.get<StreamConnectionChanges>().call(immediately: true),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Container();
        }
        final status = snapshot.data!.status;

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: getColor(status)
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(status == ConnectionStatus.connected)
                  const Icon(Icons.link, size: 14, color: Colors.white),
                if(status == ConnectionStatus.inProgress)
                  const Icon(Icons.wifi_protected_setup, size: 14, color: Colors.white),
                if(status == ConnectionStatus.disconnected)
                  const Icon(Icons.link_off_outlined, size: 14, color: Colors.white),
                const SizedBox(width: 2,),
                Text(formattedConnection(status), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.white))
              ],
            ),
          ),
        );
      },
    );
  }
}
