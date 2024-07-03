import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_home/apis/lamp_api.dart' as lamp_api;
import 'package:smart_home/const/global.dart';
import 'package:smart_home/model/lamp.dart';
import 'package:smart_home/widget/loading_indicator.dart';

class LampPage extends StatefulWidget {
  final Lamp args;
  const LampPage({Key? key, required this.args}) : super(key: key);

  @override
  State<LampPage> createState() => _LampPageState();
}

class _LampPageState extends State<LampPage> {
  LoadingStatus _loadingStatus = LoadingStatus.initial;
  TextEditingController textEditingController = TextEditingController();
  Lamp lamp = Lamp.empty();

  double currentBreakpoint = 0;
  bool isSettingBreakpoint = false;

  bool isSettingTimer = false;

  List<String> tmpTimer = [];

  DateTime tmpTimePicker = DateTime.now();

  String get getMode {
    if (lamp.mode == "auto") {
      return "tự động";
    } else if (lamp.mode == "timer") {
      return "hẹn giờ";
    } else {
      return "thủ công";
    }
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });

    setState(() {
      lamp = widget.args;
      tmpTimer = List.from(widget.args.timers!);
      currentBreakpoint = widget.args.breakpoint!.toDouble();
      textEditingController.text = widget.args.name!;
    });

    setState(() {
      _loadingStatus = LoadingStatus.success;
    });
  }

  Widget _manualMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Trạng thái: ${lamp.status! ? "Bật" : "Tắt"}"),
        ElevatedButton(
            onPressed: () {
              controlManual(!lamp.status!);
            },
            child: Text("${lamp.status! ? "Tắt" : "Bật"} đèn"))
      ],
    );
  }

  Widget _autoMode() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Ngưỡng cường độ ánh sáng khi đèn bật/tắt",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Slider(
              max: 10000,
              min: 0,
              value: currentBreakpoint,
              onChanged: isSettingBreakpoint
                  ? (value) {
                      setState(() {
                        currentBreakpoint = value;
                      });
                    }
                  : null),
          Text(currentBreakpoint.round().toString()),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
              onPressed: () {
                if (isSettingBreakpoint) {
                  // gọi api
                  changeBreakpoint(currentBreakpoint.round());
                }
                setState(() {
                  isSettingBreakpoint = !isSettingBreakpoint;
                });
              },
              child: Text(isSettingBreakpoint ? "Lưu" : "Chỉnh sửa"))
        ],
      ),
    );
  }

  Widget _timerMode() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSettingTimer) ...[
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    tmpTimer = List.from(widget.args.timers!);
                    isSettingTimer = false;
                  });
                },
                child: const Text(
                  "Huỷ",
                  style: TextStyle(color: Colors.red),
                )),
            const SizedBox(
              height: 12,
            )
          ],
          ElevatedButton(
              onPressed: () async {
                if (isSettingTimer) {
                  changeTimer();
                }

                setState(() {
                  isSettingTimer = !isSettingTimer;
                });
              },
              child: Text(isSettingTimer ? "Lưu" : "Chỉnh Sửa")),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: isSettingTimer
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              const Text(
                "Hẹn giờ bật",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              if (isSettingTimer) ...[
                ElevatedButton(
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 300,
                            padding: const EdgeInsets.only(top: 6.0),
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 216,
                                  child: CupertinoDatePicker(
                                    initialDateTime: tmpTimePicker,
                                    mode: CupertinoDatePickerMode.time,
                                    onDateTimeChanged: (DateTime newTime) {
                                      setState(() {
                                        tmpTimePicker = newTime;
                                      });
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        tmpTimer.add(
                                            "${tmpTimePicker.toString().substring(11, 16)}-1");
                                      });
                                      print(tmpTimePicker
                                          .toString()
                                          .substring(11, 16));
                                    },
                                    child: const Text("Thêm"))
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Thêm"))
              ]
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          ...tmpTimer
              .asMap()
              .map((index, element) => MapEntry(
                  index,
                  Container(
                    child: element.endsWith("1")
                        ? Column(
                            children: [
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    element.substring(0, 5),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (isSettingTimer) ...[
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            tmpTimer.removeAt(index);
                                          });
                                        },
                                        child: const Text(
                                          "xoá",
                                          style: TextStyle(color: Colors.red),
                                        ))
                                  ]
                                ],
                              ),
                            ],
                          )
                        : null,
                  )))
              .values
              .toList(),
          Divider(),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: isSettingTimer
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              const Text(
                "Hẹn giờ tắt",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              if (isSettingTimer) ...[
                ElevatedButton(
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 300,
                            padding: const EdgeInsets.only(top: 6.0),
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 216,
                                  child: CupertinoDatePicker(
                                    initialDateTime: tmpTimePicker,
                                    mode: CupertinoDatePickerMode.time,
                                    onDateTimeChanged: (DateTime newTime) {
                                      setState(() {
                                        tmpTimePicker = newTime;
                                      });
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        tmpTimer.add(
                                            "${tmpTimePicker.toString().substring(11, 16)}-0");
                                      });
                                      print(tmpTimePicker
                                          .toString()
                                          .substring(11, 16));
                                    },
                                    child: const Text("Thêm"))
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Thêm"))
              ]
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          ...tmpTimer
              .asMap()
              .map((index, element) => MapEntry(
                  index,
                  Container(
                    child: element.endsWith("0")
                        ? Column(
                            children: [
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    element.substring(0, 5),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (isSettingTimer) ...[
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            tmpTimer.removeAt(index);
                                          });
                                        },
                                        child: Text(
                                          "xoá",
                                          style: TextStyle(color: Colors.red),
                                        ))
                                  ]
                                ],
                              ),
                            ],
                          )
                        : null,
                  )))
              .values
              .toList(),
          Divider(),
        ],
      ),
    );
  }

  Future<void> changeMode(String mode) async {
    Navigator.pop(context);
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });

    if (mode == "manual") {
      controlManual(lamp.status!);
    }
    if (mode == "timer") {}

    var res = await lamp_api.changeMode(lamp.lampId!, mode);

    if (res["result"] == "success") {
      setState(() {
        lamp.mode = mode;
      });
      setState(() {
        _loadingStatus = LoadingStatus.success;
      });
    } else {
      Fluttertoast.showToast(
          msg: "Lỗi Khi Lấy Dữ Liệu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _loadingStatus = LoadingStatus.fail;
      });
    }
  }

  Future<void> controlManual(bool control) async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });
    var res = await lamp_api.controlManual(lamp.lampId!, control);
    if (res["result"] == "success") {
      setState(() {
        _loadingStatus = LoadingStatus.success;
        lamp.status = control;
      });
    } else {
      Fluttertoast.showToast(
          msg: "Lỗi Khi Lấy Dữ Liệu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _loadingStatus = LoadingStatus.fail;
      });
    }
  }

  Future<void> changeBreakpoint(int breakpoint) async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });
    var res = await lamp_api.changeBreakpoint(lamp.lampId!, breakpoint);
    if (res["result"] == "success") {
      setState(() {
        _loadingStatus = LoadingStatus.success;
        currentBreakpoint = breakpoint.toDouble();
      });
    } else {
      Fluttertoast.showToast(
          msg: "Lỗi Khi Lấy Dữ Liệu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _loadingStatus = LoadingStatus.fail;
      });
    }
  }

  Future<void> changeTimer() async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });
    var res = await lamp_api.changeTimer(lamp.lampId!, tmpTimer);
    if (res["result"] == "success") {
      setState(() {
        _loadingStatus = LoadingStatus.success;
      });
    } else {
      Fluttertoast.showToast(
          msg: "Lỗi Khi Lấy Dữ Liệu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _loadingStatus = LoadingStatus.fail;
        tmpTimer = List.from(widget.args.timers!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lamp.name ?? ""),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      title: const Text("Đổi tên đèn"),
                      content: Container(
                        child: TextFormField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            hintText: "Nhập tên đèn",
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Huỷ',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (textEditingController.text == "") {
                              Fluttertoast.showToast(
                                  msg: "Bạn cần nhập tên đèn",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (textEditingController.text ==
                                lamp.name) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                              setState(() {
                                _loadingStatus = LoadingStatus.loading;
                              });
                              var res = await lamp_api.changeName(
                                  lamp.lampId!, textEditingController.text);

                              if (res["result"] == "success") {
                                setState(() {
                                  lamp.name = textEditingController.text;
                                  _loadingStatus = LoadingStatus.success;
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Lỗi Khi Lấy Dữ Liệu",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                setState(() {
                                  _loadingStatus = LoadingStatus.fail;
                                });
                              }
                            }
                          },
                          child: const Text('Đồng ý'),
                        ),
                      ],
                    );
                  }));
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Bạn có chắc muốn xoá đèn?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Huỷ',
                            style: TextStyle(),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            var res = await lamp_api.delete(lamp.lampId!);

                            if (res["result"] == "success") {
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Lỗi Khi Lấy Dữ Liệu",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          },
                          child: const Text(
                            'Đồng ý',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Chế độ : $getMode",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            "Chọn Chế độ",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (lamp.mode != "manual") {
                                                changeMode("manual");
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text("Thủ công"),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (lamp.mode != "auto") {
                                                changeMode("auto");
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text("Tự động"),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (lamp.mode != "timer") {
                                                changeMode("timer");
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text("Hẹn giờ"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: const Text("Đổi chế độ"))
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Divider(
                    height: 1,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  if (lamp.mode == "auto") ...[
                    _autoMode()
                  ] else if (lamp.mode == "timer") ...[
                    _timerMode()
                  ] else ...[
                    _manualMode()
                  ],
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          if (_loadingStatus == LoadingStatus.loading) ...[
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
      ),
    );
  }
}
