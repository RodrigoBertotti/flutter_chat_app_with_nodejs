# Flutter Chat App with Node.js, WebSockets and MySQL

A Flutter Chat App built with Node.js, MySQL, and WebSockets.

This is a Flutter Chat App without Firebase, but if it doesn't fit for you,
it can still be an example of a template to build your Flutter Chat UI

The Node.js server uses [Askless](https://github.com/RodrigoBertotti/askless-flutter-client) 
for streaming data changes to the Flutter App
through WebSockets, 
so the Flutter widgets are updated in realtime.

Because this project uses TypeORM, you can easily change the database to make this
a Flutter Chat App with PostgreSQL, rather than with MySQL

The text messages are also saved in the user device with [Hive](https://pub.dev/packages/hive), 
so the user doesn't need to be connected to the internet to see his received messages.

https://github.com/RodrigoBertotti/flutter_chat_app_with_nodejs/assets/15431956/42428123-76ab-4c5c-8ba1-29321d11b74b

<sup> 🔊 The video above contains audio, click on the right side to turn it on</sup>

## ⚠️ Video and audio calls may not work when users are on different networks ⚠️

This project relies on the [flutter-webrtc](https://github.com/flutter-webrtc/flutter-webrtc) plugin, and even though there's a [similar issue](https://github.com/flutter-webrtc/flutter-webrtc/issues/1606) from a dev in the webrtc plugin page, 
I can't say for sure if it's either a bug in the plugin, in my code, or something else, but for some unknown reason, 
using TURN servers doesn't work in my tests (you can test this behavior by setting `'iceTransportPolicy': 'relay'`),
which means that video and audio calls may not work when users are on different networks,
[click here](https://github.com/RodrigoBertotti/flutter_chat_app_with_nodejs/issues/9) to make a suggestion or check the discussion

## Getting started

1. Go to `nodejs_websocket_backend` and install the dependencies by running `npm install`

2. The Node.js server uses TypeORM, TypeORM supports several databases like [MySQL, PostgreSQL, MariaDB, SQLite, MS SQL Server, Oracle, SAP Hana and WebSQL](https://www.tutorialspoint.com/typeorm/typeorm_quick_guide.htm#:~:text=TypeORM%20supports%20multiple%20databases%20like,functionality%20is%20RDBMS%2Dspecific%20concepts.).
   So the first step is to configure the database of your choice. Add your **database configuration** on `nodejs_websocket_backend/src/environment/db.ts`,
don't commit this file to your repository

3. In `nodejs_websocket_backend/src/environment/jwt-private.key`, replace the JWT private key with your own random text,
don't also commit this file to your repository

4. Start your node.js backend server by running the command `npm run dev`,
it will print its URL in the console (local network).

5. Go to the App created with Flutter on `flutter_app/lib/core/data/data_sources/connection_remote_ds.dart`
   and replace the `serverUrl` with the URL and port that your node.js backend is running

6. Go to `flutter_app/lib/environment.dart` and replace the `localStorageEncryptionKey` with your own random text.
don't commit this file to your repository as well.

7. Run `flutter pub get` to get the Flutter dependencies

8. Run the Flutter project on your device :) 

## WebRTC - STUN/TURN Servers

You can edit WebRTC configuration on the `flutter_app/lib/core/data/data_sources/connection_remote_ds.dart` file

## Alternative

For the Firebase version of this Chat, [click here](https://github.com/RodrigoBertotti/flutter_group_chat_app_with_firebase)

## License

[MIT](LICENSE)
