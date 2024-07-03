import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_home/apis/auth_api.dart';
import 'package:smart_home/const/global.dart';
import 'package:smart_home/utils/websocket_helper.dart';
import 'package:smart_home/widget/loading_indicator.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool isForgotPassword = false;
  LoadingStatus loadingStatus = LoadingStatus.initial;

  String? _validateEmail(String? value) {
    if (value == null ||
        value.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter correct email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password at least 6 character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(color: Colors.blue),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isForgotPassword
                                      ? "QUÊN MẬT KHẨU"
                                      : isLogin
                                          ? "ĐĂNG NHẬP"
                                          : "ĐĂNG KÝ",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: _controllerEmail,
                                  validator: (value) => _validateEmail(value),
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text("Email"),
                                      icon: Icon(Icons.person),
                                      hintText: "Email"),
                                ),
                                if (!isForgotPassword) ...[
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: _controllerPassword,
                                    validator: (value) =>
                                        _validatePassword(value),
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Text("Mật Khẩu"),
                                        icon: Icon(
                                          Icons.security,
                                        ),
                                        hintText: "Mật Khẩu"),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isLogin = !isLogin;
                                            });
                                            setState(() {
                                              _controllerEmail.text == "";
                                              _controllerPassword.text == "";
                                            });
                                          },
                                          child: Text(isLogin
                                              ? "Bạn chưa có tài khoản? Đăng Ký"
                                              : "Bạn đã có tài khoản? Đăng Nhập")),
                                    ],
                                  ),
                                ],
                                isLogin
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isForgotPassword =
                                                      !isForgotPassword;
                                                  _controllerEmail.text == "";
                                                  _controllerPassword.text ==
                                                      "";
                                                });
                                              },
                                              child: Text(isForgotPassword
                                                  ? "Quay Lại Đăng Nhập"
                                                  : isLogin
                                                      ? "Quên Mật Khẩu"
                                                      : "")),
                                        ],
                                      )
                                    : Container(),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (isForgotPassword) ...[
                                  SizedBox(
                                    height: 50,
                                    width: 180,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            loadingStatus =
                                                LoadingStatus.loading;
                                          });
                                          var res = await resetPassword(
                                              _controllerEmail.text);
                                          if (res["result"] == "success") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Mật Khẩu Đã Gửi Về Email Của Bạn",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            setState(() {
                                              loadingStatus =
                                                  LoadingStatus.success;
                                            });
                                          } else {
                                            setState(() {
                                              loadingStatus =
                                                  LoadingStatus.fail;
                                            });
                                            Fluttertoast.showToast(
                                                msg: "Thất Bại",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        }
                                      },
                                      child: const Text("LẤY LẠI MẬT KHẨU"),
                                    ),
                                  ),
                                ] else if (isLogin) ...[
                                  SizedBox(
                                    height: 50,
                                    width: 180,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            loadingStatus =
                                                LoadingStatus.loading;
                                          });
                                          var res = await signIn(
                                              _controllerEmail.text,
                                              _controllerPassword.text);
                                          if (res["result"] == "success") {
                                            var user = res["user"];
                                            // ignore: use_build_context_synchronously
                                            Global.token = user["accessToken"];
                                            WebsocketHelper().initWebsocket();
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    '/home',
                                                    (Route<dynamic> route) =>
                                                        false);
                                          } else {
                                            setState(() {
                                              loadingStatus =
                                                  LoadingStatus.fail;
                                            });
                                            Fluttertoast.showToast(
                                                msg: "Login fail",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        }
                                      },
                                      child: const Text("ĐĂNG NHẬP"),
                                    ),
                                  ),
                                ] else ...[
                                  SizedBox(
                                    height: 50,
                                    width: 180,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            loadingStatus =
                                                LoadingStatus.loading;
                                          });
                                          var res = await signUp(
                                              _controllerEmail.text,
                                              _controllerPassword.text);
                                          if (res["result"] == "success") {
                                            setState(() {
                                              loadingStatus =
                                                  LoadingStatus.success;
                                            });
                                            Fluttertoast.showToast(
                                                msg: "Success",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 16.0);

                                            setState(() {
                                              isLogin = true;
                                            });
                                          } else {
                                            setState(() {
                                              loadingStatus =
                                                  LoadingStatus.fail;
                                            });
                                            Fluttertoast.showToast(
                                                msg: "Sign up fail",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }

                                          setState(() {
                                            _controllerEmail.text == "";
                                            _controllerPassword.text == "";
                                          });
                                        }
                                      },
                                      child: const Text("ĐĂNG KÝ"),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (loadingStatus == LoadingStatus.loading) ...[
          const Opacity(
            opacity: 0.2,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black,
            ),
          ),
          const Center(child: LoadingIndicator())
        ]
      ],
    );
  }
}
