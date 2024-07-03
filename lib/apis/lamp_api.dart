import 'package:smart_home/apis/dio.dart';

dynamic createLamp(String roomId, String order, String name) async {
  var res = await sendRequest("/api/v1/lamp/create", "POST",
      {"roomId": roomId, "name": name, "lampOrder": order});

  print(res);

  return res;
}

dynamic changeName(String lampId, String name) async {
  var res = await sendRequest(
      "/api/v1/lamp/change-name", "POST", {"lampId": lampId, "name": name});

  print(res);

  return res;
}

dynamic controlManual(String lampId, bool control) async {
  var res = await sendRequest("/api/v1/lamp/control-manual", "POST",
      {"lampId": lampId, "control": control});

  print(res);

  return res;
}

dynamic changeMode(String lampId, String mode) async {
  var res = await sendRequest(
      "/api/v1/lamp/change-mode", "POST", {"lampId": lampId, "mode": mode});

  print(res);

  return res;
}

dynamic changeBreakpoint(String lampId, int breakpoint) async {
  var res = await sendRequest("/api/v1/lamp/change-breakpoint", "POST",
      {"lampId": lampId, "breakpoint": breakpoint});

  print(res);

  return res;
}

dynamic changeTimer(String lampId, List<String> timers) async {
  var res = await sendRequest("/api/v1/lamp/change-timers", "POST",
      {"lampId": lampId, "timers": timers});

  print(res);

  return res;
}

dynamic delete(String lampId) async {
  var res =
      await sendRequest("/api/v1/lamp/delete", "POST", {"lampId": lampId});

  print(res);

  return res;
}
