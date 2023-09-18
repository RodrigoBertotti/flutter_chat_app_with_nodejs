import 'dart:async';

import 'package:askless/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/utils/snackbar.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/stopwatch/stopwatch_controller.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/stopwatch/stopwatch_widget.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/widgets/center_content_widget.dart';

/// You may ask why did I choose to not create subfolders (repository, datasource, etc)
/// That's a good question, the reason is that I want to show you how Askless can simplify webrtc and websockets
/// Putting everything in a single file can make easier for understanding
/// Search in this file for "AsklessClient.instance" in your editor and you will have
/// everything you need to create your own video and/or audio call chat!
/// Thank you so much for checking the code


enum CallDirection { receivingCall, requestingCall }

class CallScreenArgs {
  final String remoteUserFullName;
  final int remoteUserId;
  final CallDirection callDirection;
  final bool videoCall;
  final ReceivingCall? receivingCall;

  CallScreenArgs({required this.callDirection, this.receivingCall, required this.remoteUserFullName, required this.remoteUserId, required this.videoCall});
}

class CallScreen extends StatefulWidget {
  static const String route = '/request-call';

  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late CallStatus callStatus;
  late CallScreenArgs args;
  bool initialized = false;
  bool isMicrophoneOn = true;
  late bool isVideoOn;
  final remoteVideoRenderer = RTCVideoRenderer();
  final localVideoRenderer = RTCVideoRenderer();
  MediaStream? localUserStream;
  bool frontCamera = true;
  RequestCallToUserInstance? callInstance;
  String? message;
  LiveCall? liveCall;
  DateTime? disconnectedAt;
  static const Duration expirationInSecondsToCloseCallWhenRemoteUserIsDisconnected = Duration(seconds: 15);
  bool disposed = false;

  final stopwatchController = StopwatchController();
  final reverseStopwatchController = StopwatchController(reverseDuration: expirationInSecondsToCloseCallWhenRemoteUserIsDisconnected);

  @override
  void didChangeDependencies() {
    init();
    super.didChangeDependencies();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CenterContentWidget(
            withBackground: true,
            padding: EdgeInsets.zero,
            child: !initialized ? Container() : Column(
              children: [
                if (callStatus != CallStatus.callRunning || !args.videoCall)
                  Expanded(
                    child: InfoContent(
                      remoteUserFullName: args.remoteUserFullName,
                      message: message,
                      stopwatchController: stopwatchController,
                      args: args, callStatus: callStatus,
                      disconnectedAt: disconnectedAt,
                      loggedUserIsDisconnected: AsklessClient.instance.connection.status != ConnectionStatus.connected,
                      reverseStopwatchController: reverseStopwatchController,
                    ),
                  ),
                if (callStatus == CallStatus.callRunning && args.videoCall)
                  Expanded(
                    child: VideoCallContent(
                      remoteUserFullName: args.remoteUserFullName,
                      stopwatchController: stopwatchController,
                      localVideoRenderer: localVideoRenderer,
                      remoteVideoRenderer: remoteVideoRenderer,
                      disconnectedAt: disconnectedAt,
                      reverseStopwatchController: reverseStopwatchController,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.indigo,
                      boxShadow: [
                        BoxShadow(color: Colors.indigo[400]!, offset: const Offset(0,0), spreadRadius: 1, blurRadius: 1)
                      ]
                  ),
                  height: 60,
                  width: double.infinity,
                  child: Center(
                    child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 30,
                        children: [
                          _BottomButton(
                            iconData: Icons.call_end,
                            backgroundColor: Colors.red[300]!,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),

                          if (callStatus == CallStatus.receivingCall)
                            _BottomButton(
                              iconData: Icons.call,
                              backgroundColor: Colors.green[800],
                              onTap: () {
                                if (localUserStream == null) {
                                  print("localUserStream is null");
                                  return;
                                }
                                args.receivingCall!.acceptCall(localStream: localUserStream!)
                                    .then((AcceptingCallResult result) {
                                  print("call accepted by me: ${result.liveCall != null}");
                                  if (result.success){
                                    handleCallStarted(result.liveCall!);
                                  } else {
                                    handleCallFailed(error: result.error, message: "Ops, sorry, an error occurred when accepting the call, please try again later");
                                  }
                                });
                              },
                            ),
                          if (callStatus == CallStatus.callRunning)
                            ...[
                              _BottomButton(iconData: isMicrophoneOn ? Icons.mic_off_sharp : Icons.mic_sharp, onTap: toggleAudioOnOff),
                              if (args.videoCall)
                                _BottomButton(iconData: isVideoOn ? Icons.videocam_off : Icons.videocam, onTap: toggleVideoOnOff),
                            ]
                        ],
                    ),
                  ),
                )
              ],
            ),
        )
    );
  }

  @override
  void dispose() {
    disposed = true;
    args.receivingCall?.dispose();
    liveCall?.dispose();
    callInstance?.dispose();

    localVideoRenderer.dispose();
    localUserStream!.dispose();

    stopwatchController.dispose();
    reverseStopwatchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    callStatus = args.receivingCall != null ? CallStatus.receivingCall : CallStatus.requestingCall;
    isVideoOn = args.videoCall;
    localVideoRenderer.initialize();
    remoteVideoRenderer.initialize();

    args.receivingCall?.addOnCanceledListener(onCallRequestCanceled);

    AsklessClient.instance.addOnConnectionChangeListener((connection) {
      if (!disposed) {
        closesCallAutomaticallyIfDisconnected(
            connected: connection.status == ConnectionStatus.connected,
            customReverseDuration: const Duration(seconds: 30));
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      localUserStream?.dispose();
      navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': args.videoCall ? {
          'facingMode': 'user',
        } : false,
      }).then((localUserStream) {
        setState(() {
          this.localUserStream = localVideoRenderer.srcObject = localUserStream;
          if (args.callDirection == CallDirection.requestingCall) {
            callStatus = CallStatus.requestingCall;
            callInstance = AsklessClient.instance.requestCallToUser(
              userId: args.remoteUserId,
              localStream: localUserStream,
              additionalData: {
                "videoCall": args.videoCall,
              },
            );
            callInstance!.response().then(handleCallResult);
          } else {
            callStatus = CallStatus.receivingCall;
          }
        });
      }, onError: (error) {
        print("Could not get access to camera and/or microphone ${error.toString()}");
        showSnackBarWarning(context: context, message: 'Please, check the ${args.videoCall ? "camera and/or microphone permissions" : "microphone permission"}');
        Navigator.of(context).pop();
      });
    });
  }

  void init() {
    if (initialized) {
      print("args already initialized");
      return;
    }
    initialized = true;
    assert(ModalRoute.of(context)!.settings.arguments != null, "Please, inform the arguments. More info on https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#4-navigate-to-the-widget");
    args = ModalRoute.of(context)!.settings.arguments as CallScreenArgs;

    _init();

    setState(() {});
  }

  void toggleVideoOnOff() {
    setState(() {
      isVideoOn = !isVideoOn;
      localUserStream!.getVideoTracks().forEach((track) {
        track.enabled = isVideoOn;
      });
    });
  }
  void toggleAudioOnOff() {
    setState(() {
      isMicrophoneOn = !isMicrophoneOn;
      localUserStream!.getAudioTracks().forEach((track) {
        track.enabled = isMicrophoneOn;
      });
    });
  }

  void onCallRequestCanceled() {
    print ("onCallRequestCanceled");
    handleCallFailed(message: "Call has been cancelled by the caller");
  }

  void handleCallResult(RequestCallResult response) {
    print(">>> handleCallResult: callAccepted -> ${response.callAccepted}: ${response.liveCall != null}");
    if (response.callAccepted) {
      handleCallStarted(response.liveCall!);
    } else {
      handleCallFailed(message: "Ops! wasn't accepted", error: response.error);
    }
  }

  void handleCallStarted(LiveCall liveCall) {
    setState(() {
      this.liveCall = liveCall;
      remoteVideoRenderer.srcObject = liveCall.remoteStream;
      callStatus = CallStatus.callRunning;
      stopwatchController.start();
      liveCall.addOnRemoteUserConnectionChangeListener(closesCallAutomaticallyIfRemoteUserIsDisconnected);
      liveCall.addOnCallClosesListener(listener: () {
        print("on call closed listener called (disposed: $disposed)");
        if (!disposed) {
          setState(() {
            callStatus = CallStatus.closed;
            stopwatchController.stop();
            reverseStopwatchController.stop();
            this.liveCall = null;
            message = "Call has been closed";
            disconnectedAt = null;
          });
        }
      });
    });
  }

  void handleCallFailed({String? error, String? message}) {
    if (!disposed) {
      setState(() {
        print(error ?? message ?? "handleCallFailed called");
        this.message =
            message ?? "Ops, sorry, an error occurred, please try again later";
        callStatus = CallStatus.closed;
      });
    }
  }

  void closesCallAutomaticallyIfRemoteUserIsDisconnected(bool connected) {
    return closesCallAutomaticallyIfDisconnected(connected: connected);
  }

  /// If the connection of the remote user or even the connection of the logged user doesn't come back,
  /// the logged user will disconnect from the call automatically
  void closesCallAutomaticallyIfDisconnected({required bool connected, Duration? customReverseDuration}) {
    setState(() {
      if (disposed) {
        print("closesCallAutomaticallyIfDisconnected: disposed");
        return;
      }
      if (disconnectedAt != null && !connected){
        print("closesCallAutomaticallyIfDisconnected: nothing have changed");
        return;
      }
      if (liveCall == null) {
        print("closesCallAutomaticallyIfDisconnected: call has been closed");
        return;
      }
      disconnectedAt = connected ? null : DateTime.now();

      if (connected) {
        reverseStopwatchController.stop();
      } else {
        reverseStopwatchController.start(customReverseDuration: customReverseDuration);
        Future.delayed(reverseStopwatchController.reverseDuration!, () {
          if (disconnectedAt != null) {
            final diff = DateTime.now().millisecondsSinceEpoch - disconnectedAt!.millisecondsSinceEpoch;
            if (diff >= expirationInSecondsToCloseCallWhenRemoteUserIsDisconnected.inMilliseconds - 10) {
              liveCall?.closeCall();
            }
          }
        });
      }
    });
  }
}

class _BottomButton extends StatelessWidget {
  final IconData iconData;
  final bool disabled;
  late final Color backgroundColor;
  final void Function()? onTap;

  _BottomButton({this.onTap, required this.iconData, super.key, this.disabled = false, Color? backgroundColor}) {
    this.backgroundColor = backgroundColor ?? Colors.indigo[600]!;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Ink(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: backgroundColor,
              border: Border.all(color: Colors.white, width: 1)
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(iconData, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}

class InfoContent extends StatelessWidget {
  final CallScreenArgs args;
  final CallStatus callStatus;
  final StopwatchController stopwatchController;
  final String? message;
  final DateTime? disconnectedAt;
  final StopwatchController reverseStopwatchController;
  final String remoteUserFullName;
  final bool loggedUserIsDisconnected;

  const InfoContent({required this.loggedUserIsDisconnected, required this.args, required this.remoteUserFullName, required this.reverseStopwatchController, this.disconnectedAt, this.message, required this.stopwatchController, required this.callStatus, super.key});


  String get statusInfo {
    if (callStatus == CallStatus.callRunning) {
      return "talking to ${args.remoteUserFullName}..";
    }
    return args.callDirection == CallDirection.requestingCall
        ? "calling..."
        : "receiving call...";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30,),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white.withOpacity(.95)
            ),
            padding: const EdgeInsets.all(30),
            child: const Icon(Icons.person, size: 60, color: Colors.blue),
          ),
          const SizedBox(height: 10,),
          Text(args.remoteUserFullName, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800),),
          const SizedBox(height: 5,),
          if (callStatus != CallStatus.closed)
            Text(statusInfo, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),),
          if (message?.isNotEmpty == true)
            ...[
              const SizedBox(height: 20,),
              Container(height: 1, width: MediaQuery.of(context).size.width * .95, color: Colors.white.withOpacity(.3),),
              const SizedBox(height: 20,),
              Text(message!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center,)
            ],
          if (callStatus == CallStatus.callRunning || stopwatchController.seconds > 0)
            ...[
              Expanded(child: Container()),
              if (disconnectedAt != null)
                ...[
                  Text(loggedUserIsDisconnected ? "You are disconnected" : "$remoteUserFullName is disconnected", style: TextStyle(color: Colors.grey[200]!, fontWeight: FontWeight.w700, fontSize: 14), ),
                  const SizedBox(height: 2,),
                  StopwatchWidget(color: Colors.red[200]!, controller: reverseStopwatchController, fontSize: 16),
                  const SizedBox(height: 20,),
                ],
              StopwatchWidget(controller: stopwatchController),
              const SizedBox(height: 20,),
            ]
        ],
      ),
    );
  }
}

class VideoCallContent extends StatelessWidget {
  final StopwatchController stopwatchController;
  final StopwatchController reverseStopwatchController;
  final RTCVideoRenderer remoteVideoRenderer;
  final RTCVideoRenderer localVideoRenderer;
  final DateTime? disconnectedAt;
  final String remoteUserFullName;

  const VideoCallContent({required this.remoteUserFullName, required this.reverseStopwatchController, this.disconnectedAt, required this.stopwatchController, required this.remoteVideoRenderer, required this.localVideoRenderer, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: RTCVideoView(remoteVideoRenderer),
        ),
        Positioned(
          bottom: 0,
          right: 8,
          child: SizedBox(
            height: 200,
            width: 120,
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: RTCVideoView(localVideoRenderer)),
          ),
        ),
        Positioned(
          bottom: 6,
          left: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue[200],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (disconnectedAt != null)
                  ...[
                    Text("$remoteUserFullName is disconnected", style: TextStyle(color: Colors.grey[200]!, fontWeight: FontWeight.w700, fontSize: 14), ),
                    const SizedBox(height: 2,),
                    StopwatchWidget(color: Colors.red[200]!, controller: reverseStopwatchController,)
                  ],
                if (disconnectedAt == null)
                  StopwatchWidget(color: Colors.indigo[900]!, controller: stopwatchController,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}


enum CallStatus {
  requestingCall, receivingCall, callRunning, closed
}
