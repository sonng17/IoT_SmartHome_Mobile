import 'package:smart_home/apis/dio.dart';

dynamic signUp(String email, String password) async {
  var res = await sendRequest(
      "/api/v1/user/sign-up", "POST", {"email": email, "password": password});

  print(res);

  return res;
}

dynamic signIn(String email, String password) async {
  var res = await sendRequest(
      "/api/v1/user/sign-in", "POST", {"email": email, "password": password});

  print(res);

  return res;
}

dynamic changePassword(String password, String newPassword) async {
  var res = await sendRequest("/api/v1/user/change_password", "PUT", {
    "password": password,
    "newPassword": newPassword,
  });
  print(res);
  return res;
}

dynamic resetPassword(String email) async {
  var res = await sendRequest("/api/v1/user/request-reset-password", "POST", {
    "email": email,
  });
  print(res);
  return res;
}
