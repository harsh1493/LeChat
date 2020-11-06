import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:le_chat/screens/chat_messages.dart';
import 'package:le_chat/screens/chat_screen.dart';
import 'package:le_chat/screens/editPages/profile_page.dart';
import 'package:le_chat/screens/group_info_screen.dart';
import 'package:le_chat/screens/home_page.dart';
import 'package:le_chat/screens/login_screen.dart';
import 'package:le_chat/screens/pages/add_room.dart';
import 'package:le_chat/screens/pages/confirm_image.dart';
import 'package:le_chat/screens/pages/confirm_new_group.dart';
import 'package:le_chat/screens/pages/confirm_story.dart';
import 'package:le_chat/screens/pages/image_gallery.dart';
import 'package:le_chat/screens/pages/new_group.dart';
import 'package:le_chat/screens/pages/nw_group.dart';
import 'package:le_chat/screens/pages/splash_screen.dart';
import 'package:le_chat/screens/pages/status_screen.dart';
import 'package:le_chat/screens/pages/stories.dart';
import 'package:le_chat/screens/registration_screen.dart';
import 'package:le_chat/screens/slivers.dart';
import 'package:le_chat/screens/welcome_screen.dart';

List<CameraDescription> cameras;
Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  await Firebase.initializeApp();
  return runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  //Enum
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.transparent),
        // appBarTheme: AppBarTheme(color: Colors.black12),
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        StatusScreen.id:(context)=>StatusScreen(),
        GroupInfoScreen.id: (context) => GroupInfoScreen(),
        Slivers.id: (context) => Slivers(),
        ChatMessages.id: (context) => ChatMessages(),
        ProfilePage.id: (context) => ProfilePage(),
        HomePage.id: (context) => HomePage(),
        AddRoom.id: (context) => AddRoom(),
        NewGroup.id: (context) => NewGroup(),
        NwGroup.id: (context) => NwGroup(),
        ConfirmNewGroup.id: (context) => ConfirmNewGroup(),
        ConfirmImage.id: (context) => ConfirmImage(),
        Stories.id: (context) => Stories(),
        // ignore: equal_keys_in_map
        ImageGallery.id: (context) => ImageGallery(),
        ConfirmStory.id: (context) => ConfirmStory(),
      },
    );
  }
}
