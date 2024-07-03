import 'package:smart_home/apis/dio.dart';

dynamic createWindow(
    String roomId, String order, String name, int height) async {
  var res = await sendRequest("/api/v1/window/create", "POST",
      {"roomId": roomId, "name": name, "height": height, "windowOrder": order});

  print(res);

  return res;
}

// done
dynamic changeNameHeight(
    {required String windowId, String? name, int? height}) async {
  var res = await sendRequest("/api/v1/window/change-name-height", "POST",
      {"windowId": windowId, "name": name, "height": height});

  print(res);

  return res;
}

//done
dynamic controlManual(String windowId, int status) async {
  var res = await sendRequest("/api/v1/window/control-manual", "POST",
      {"windowId": windowId, "status": status});

  print(res);

  return res;
}

//done
dynamic changeMode(String windowId, String mode) async {
  var res = await sendRequest("/api/v1/window/change-mode", "POST",
      {"windowId": windowId, "mode": mode});

  print(res);

  return res;
}

//done
dynamic changeBreakpoint(String windowId, List<String> breakpoint) async {
  var res = await sendRequest("/api/v1/window/change-breakpoint", "POST",
      {"windowId": windowId, "breakpoints": breakpoint});

  print(res);

  return res;
}

//done
dynamic changeTimer(String windowId, List<String> timers) async {
  var res = await sendRequest("/api/v1/window/change-timers", "POST",
      {"windowId": windowId, "timers": timers});

  print(res);

  return res;
}

//done
dynamic delete(String windowId) async {
  var res = await sendRequest(
      "/api/v1/window/delete", "POST", {"windowId": windowId});

  print(res);

  return res;
}
