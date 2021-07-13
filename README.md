
# Meeter

A complete solution for organizing and scheduling your events.\
This software allows you to have group video calls and chats.


## Highlights

1. Take notes during the call and these notes will be available even after the meeting ends.
2. Access to the chatbox during meet which is not limited to meeting sessions.
3. The app is compatible with both Mobile and Computer screen sizes.
4. You can check and manage your events within the app using an integrated calendar.
5. It has the button to join the meeting with just one click directly from the calendar.
6. whenever you schedule a group call, an auto-generated message is added to the same group which lets you stay free from the pain of informing other members.





# Installation
## 1. Prerequisite
1. Setup for flutter development, [instructions for setup](https://flutter.dev/docs/get-started/install) given here.
2. Setup an editor for flutter development, using the [Editor setup instrustion](https://flutter.dev/docs/get-started/editor).
3. Basics of flutter development can be understood, using the instructions in [Getting Started with your first Flutter app](https://flutter.dev/docs/get-started/codelab).
4. The DataBase and the hosting service used are from [Firebase](https://firebase.google.com/).



## 2. Environment settings
1. The flutter version used in development is Flutter (Channel stable, 2.0.6).
2. The editor used in development is VS Code (version 1.58.0).
3. Browser used for testing the app is  Chrome - develop for the web.
4. NodeJs version used is v14.17.1.
5. Firebase CLI version is 9.14.0.

## 3. Clone and run
Either you can directly access the app, from this already [Hosted webapp](https://meeter-e2ad8.web.app/).

or 

you can test the app in the debug environment, by following the steps below:

### Step 1:
clone the repository by using the command.
```git
git clone https://github.com/salman-byte/meeter.git
```
### Step 2:
clean the project and remove build caches.
```dart
flutter clean
```
### Step 3:
get all dependancies
```dart
flutter pub get
```

### Step 4:
launch the app in browser
```dart
 flutter run -d chrome --web-renderer html
```


# Dependancies used

```dart
  velocity_x: ^3.3.0
  flutter_animated_dialog: ^2.0.0
  firebase_auth: ^1.4.1
  firebase_core: ^1.3.0
  cloud_firestore: ^2.2.2
  firebase_storage: ^9.0.0
  provider: ^5.0.0
  open_file: ^3.2.1
  file_picker: ^3.0.3
  uuid: ^3.0.4
  cr_calendar: ^0.0.8
  url_launcher: ^6.0.9
  webviewx: ^0.1.0
  shared_preferences: ^2.0.6
  flutter_chat_ui: ^1.1.5
  image_picker: ^0.8.1+1
  mime: ^1.0.0
```

**Note:** All the mentioned plugins are referenced in the [reference section](#references).  

# Known Issues
1. As we're employing third party service, i.e. [jitsi meet](https://jitsi.org/),through webview for video confrencing.
 In the mobile view of the web app when we switch to chat or notes tab during the meet, the web page gets reloaded everytime.
2. The font size is not adaptive in the event calendar.



# References
- [velocity_x](https://velocityx.dev/docs/vxnavigator/getting_started/)
- [flutter_animated_dialog](https://pub.dev/packages/flutter_animated_dialog)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [firebase_core](https://pub.dev/packages/firebase_co)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [firebase_storage](https://pub.dev/packages/firebase_storage)
- [provider](https://pub.dev/packages/provider)
- [open_file](https://pub.dev/packages/open_file)
- [file_picker](https://pub.dev/packages/file_picker)
- [uuid](https://pub.dev/packages/uuid)
- [cr_calendar](https://pub.dev/packages/cr_calendar)
- [url_launcher](https://pub.dev/packages/url_launcher)
- [webviewx](https://pub.dev/packages/webviewx)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [flutter_chat_ui](https://pub.dev/packages/flutter_chat_ui)
- [image_picker](https://pub.dev/packages/image_picker)
- [mime](https://pub.dev/packages/mime)
- [jitsi meet](https://jitsi.org/)
