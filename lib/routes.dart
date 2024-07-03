import 'package:smart_home/views/auth.dart';
import 'package:smart_home/views/home.dart';
import 'package:smart_home/views/lamp_page.dart';
import 'package:smart_home/views/room_page.dart';
import 'package:smart_home/views/setting.dart';
import 'package:smart_home/views/window_page.dart';

class PageNames {
  static const auth = "/";
  static const home = "/home";
  // static const room = "/room";
  static const setting = "/setting";
  // static const lamp = "/lamp";
  static const window = "/window";
}

dynamic getPages(context) {
  return {
    PageNames.auth: (context) => const Auth(),
    PageNames.home: (context) => const Home(),
    // PageNames.room: (context) => const RoomPage(),
    PageNames.setting: (context) => const Setting(),
    // PageNames.lamp: (context) => const LampPage(),
    // PageNames.window: (context) => const WindowPage()
  };
}
