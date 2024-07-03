import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_home/apis/auth_api.dart';
import 'package:smart_home/const/global.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  LoadingStatus loadingStatus = LoadingStatus.initial;
  bool isChangePassword = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerNewPassword = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password at least 6 character';
    }
    return null;
  }

  @override
  void dispose() {
    _controllerNewPassword.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 100,
                ),
                const SizedBox(
                  height: 150,
                  width: 150,
                  child: Image(
                    image: AssetImage("assets/images/img_defaultAvatar.png"),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (isChangePassword) ...[
                  TextFormField(
                    controller: _controllerPassword,
                    validator: (value) => _validatePassword(value),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Mật Khẩu"),
                        hintText: "Mật Khẩu"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _controllerNewPassword,
                    validator: (value) => _validatePassword(value),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Mật Khẩu Mới"),
                        hintText: "Mật Khẩu Mới"),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
                ElevatedButton(
                    onPressed: () async {
                      if (isChangePassword == false) {
                        setState(() {
                          isChangePassword = true;
                        });
                      } else {
                        if (_controllerNewPassword.text == "" &&
                            _controllerPassword.text == "") {
                          setState(() {
                            isChangePassword = false;
                          });
                        } else {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loadingStatus = LoadingStatus.loading;
                            });
                            var res = await changePassword(
                                _controllerPassword.text,
                                _controllerNewPassword.text);
                            if (res["result"] == "success") {
                              setState(() {
                                loadingStatus = LoadingStatus.success;
                                isChangePassword = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "Thay Đổi Mật Khẩu Thành Công",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else {
                              setState(() {
                                loadingStatus = LoadingStatus.fail;
                              });
                              Fluttertoast.showToast(
                                  msg: "Thay Đổi Mật Khẩu Thất Bại",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          }
                        }
                      }
                    },
                    child: const Text("Đổi Mật Khẩu")),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () {
                      Global.token = "";
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false);
                    },
                    child: const Text(
                      "Đăng Xuất",
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
