import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:smart_home/apis/window_api.dart' as window_api;
import 'package:smart_home/const/global.dart';
import 'package:smart_home/model/window.dart';
import 'package:smart_home/widget/loading_indicator.dart';

class WindowPage extends StatefulWidget {
  final Window args;
  const WindowPage({Key? key, required this.args}) : super(key: key);

  @override
  State<WindowPage> createState() => _WindowPageState();
}

class _WindowPageState extends State<WindowPage> {
  LoadingStatus _loadingStatus = LoadingStatus.initial;
  Window window = Window.empty();

  TextEditingController textEditingController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  double tmpSliderValue = 0;
  double tmpSliderLightValue = 0;
  String currentStatus = "";

  bool isControlManual = false;

  bool isSettingAuto = false;

  bool isSettingTimer = false;

  List<String> tmpTimer = [];
  List<String> tmpBreakpoint = [];

  DateTime tmpTimePicker = DateTime.now();

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
      window = widget.args;
      tmpTimer = List.from(widget.args.timers!);
      tmpBreakpoint = List.from(widget.args.breakpoints!);
      textEditingController.text = widget.args.name!;
      heightController.text = widget.args.height.toString();

      currentStatus = calculateStatus(window.status!, window.height!);
    });

    setState(() {
      _loadingStatus = LoadingStatus.success;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    heightController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  String get getMode {
    if (window.mode == "auto") {
      return "tự động";
    } else if (window.mode == "timer") {
      return "hẹn giờ";
    } else {
      return "thủ công";
    }
  }

  String calculateStatus(int status, int height) {
    if (height == 0) {
      return "0.0";
    }

    double tmp = status / height;

    if (0 <= tmp && tmp < 0.25) {
      if ((tmp - 0) < (0.25 - tmp)) {
        return "0.0";
      } else {
        return "0.25";
      }
    } else if (0.25 <= tmp && tmp < 0.5) {
      if ((tmp - 0.25) < (0.5 - tmp)) {
        return "0.25";
      } else {
        return "0.5";
      }
    } else if (0.5 <= tmp && tmp < 0.75) {
      if ((tmp - 0.5) < (0.75 - tmp)) {
        return "0.5";
      } else {
        return "0.75";
      }
    } else if (0.75 <= tmp && tmp <= 1) {
      if ((tmp - 0.75) < (1 - tmp)) {
        return "0.75";
      } else {
        return "1.0";
      }
    }
    return "0.0";
  }

  String getStatus(String value) {
    switch (value) {
      case "0.25":
        return "Đóng 1/4 cửa sổ";
      case "0.5":
        return "Đóng 1/2 cửa sổ";
      case "0.75":
        return "Đóng 3/4 cửa sổ";
      case "1.0":
        return "Đóng toàn bộ cửa sổ";
      default:
        return "Mở cửa sổ";
    }
  }

  Widget _manualMode() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Trạng thái:  ${getStatus(currentStatus)}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (isControlManual) ...[
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isControlManual = false;
                  });
                },
                child: const Text(
                  "Huỷ",
                  style: TextStyle(color: Colors.red),
                ))
          ],
          const SizedBox(
            height: 8,
          ),
          ElevatedButton(
              onPressed: () {
                if (isControlManual) {
                  controlManual((tmpSliderValue * window.height!).round());
                }
                setState(() {
                  isControlManual = !isControlManual;
                });
              },
              child: Text(isControlManual ? "Lưu" : "Điều khiển cửa sổ")),
          if (isControlManual) ...[
            Slider(
              max: 1,
              min: 0,
              divisions: 4,
              value: tmpSliderValue,
              onChanged: (value) {
                setState(() {
                  tmpSliderValue = value;
                });
              },
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              getStatus(tmpSliderValue.toString()),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ]
        ],
      ),
    );
  }

  Widget _autoMode() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (window.breakpoints!.isEmpty) ...[
            const Text("Bạn chưa cài đặt chế độ tự động"),
            const SizedBox(
              height: 8,
            )
          ],
          if (isSettingAuto) ...[
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isSettingAuto = false;
                    tmpBreakpoint = List.from(widget.args.breakpoints!);
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
              onPressed: () {
                if (isSettingAuto) {
                  changeBreakpoint(tmpBreakpoint);
                }
                setState(() {
                  isSettingAuto = !isSettingAuto;
                });
              },
              child: Text(isSettingAuto ? "Lưu" : "Cài đặt")),
          if (isSettingAuto) ...[
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                            builder: ((context, setStateStf) {
                          return Dialog(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Thêm chế độ tự động",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  const Text(
                                    "Cường độ ánh sáng (lux)",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Slider(
                                    max: 10000,
                                    min: 0,
                                    value: tmpSliderLightValue,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          tmpSliderLightValue = value;
                                        },
                                      );
                                      setStateStf(
                                        () {
                                          tmpSliderLightValue = value;
                                        },
                                      );
                                    },
                                  ),
                                  Text(tmpSliderLightValue.round().toString()),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Slider(
                                    max: 1,
                                    min: 0,
                                    divisions: 4,
                                    value: tmpSliderValue,
                                    onChanged: (value) {
                                      setState(() {
                                        tmpSliderValue = value;
                                      });
                                      setStateStf(
                                        () {
                                          tmpSliderValue = value;
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    getStatus(tmpSliderValue.toString()),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(
                                          () {
                                            tmpBreakpoint.add(
                                                "${tmpSliderLightValue.round()}-${(tmpSliderValue * window.height!).round()}");
                                          },
                                        );
                                      },
                                      child: Text("Thêm"))
                                ],
                              ),
                            ),
                          );
                        }));
                      },
                    );
                  });
                },
                child: const Text(
                  "Thêm mới",
                )),
            const SizedBox(
              height: 12,
            )
          ],
          ...tmpBreakpoint
              .asMap()
              .map((index, element) {
                List<String> tmpString = element.split("-");

                return MapEntry(
                    index,
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cường độ ánh sáng: ${tmpString[0]}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    getStatus(calculateStatus(
                                        int.parse(tmpString[1]),
                                        window.height!)),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (isSettingAuto) ...[
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        tmpBreakpoint.removeAt(index);
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
                      ),
                    ));
              })
              .values
              .toList(),
          const Divider()
        ],
      ),
    );
  }

  Widget _timerMode() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (window.timers!.isEmpty) ...[
            const Text("Bạn chưa cài đặt chế độ hẹn giờ"),
            const SizedBox(
              height: 8,
            )
          ],
          if (isSettingTimer) ...[
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isSettingTimer = false;
                    tmpTimer = List.from(widget.args.timers!);
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
              onPressed: () {
                if (isSettingTimer) {}
                setState(() {
                  isSettingTimer = !isSettingTimer;
                });
              },
              child: Text(isSettingTimer ? "Lưu" : "Cài đặt")),
          if (isSettingTimer) ...[
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                            builder: ((context, setStateStf) {
                          return Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Thêm chế độ hẹn giờ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
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
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Slider(
                                    max: 1,
                                    min: 0,
                                    divisions: 4,
                                    value: tmpSliderValue,
                                    onChanged: (value) {
                                      setState(() {
                                        tmpSliderValue = value;
                                      });
                                      setStateStf(
                                        () {
                                          tmpSliderValue = value;
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    getStatus(tmpSliderValue.toString()),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(
                                          () {
                                            tmpTimer.add(
                                                "${tmpTimePicker.toString().substring(11, 16)}-${(tmpSliderValue * window.height!).round()}");
                                          },
                                        );
                                      },
                                      child: Text("Thêm"))
                                ],
                              ),
                            ),
                          );
                        }));
                      },
                    );
                  });
                },
                child: const Text(
                  "Thêm mới",
                )),
            const SizedBox(
              height: 12,
            )
          ],
          ...tmpTimer
              .asMap()
              .map((index, element) {
                List<String> tmpString = element.split("-");

                return MapEntry(
                    index,
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${tmpString[0]}: ${getStatus(calculateStatus(int.parse(tmpString[1]), window.height!))}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
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
                      ),
                    ));
              })
              .values
              .toList(),
          const Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(window.name ?? ""),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      title: const Text("Đổi tên cửa sổ"),
                      content: Container(
                        child: TextFormField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            hintText: "Nhập tên cửa sổ",
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
                                  msg: "Bạn cần nhập tên cửa sổ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (textEditingController.text ==
                                window.name) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                              setState(() {
                                _loadingStatus = LoadingStatus.loading;
                              });
                              var res = await window_api.changeNameHeight(
                                  windowId: window.windowId!,
                                  name: textEditingController.text);

                              if (res["result"] == "success") {
                                setState(() {
                                  window.name = textEditingController.text;
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
                      title: const Text("Bạn có chắc muốn xoá cửa sổ?"),
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
                            var res = await window_api.delete(window.windowId!);

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
                        "Chiều cao: ${window.height} cm",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    title: const Text("Đổi chiều cao cửa sổ"),
                                    content: Container(
                                      child: TextFormField(
                                        controller: heightController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: "Nhập chiều cao cửa sổ",
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
                                          if (heightController.text == "") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Bạn cần nhập chiều cao cửa sổ",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          } else if (heightController.text ==
                                              window.height.toString()) {
                                            Navigator.pop(context);
                                          } else {
                                            Navigator.pop(context);
                                            setState(() {
                                              _loadingStatus =
                                                  LoadingStatus.loading;
                                            });
                                            var res = await window_api
                                                .changeNameHeight(
                                                    windowId: window.windowId!,
                                                    height: int.parse(
                                                        heightController.text));

                                            if (res["result"] == "success") {
                                              setState(() {
                                                window.height = int.parse(
                                                    heightController.text);
                                                currentStatus = calculateStatus(
                                                    window.status!,
                                                    window.height!);
                                                _loadingStatus =
                                                    LoadingStatus.success;
                                              });
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: "Lỗi Khi Lấy Dữ Liệu",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                              setState(() {
                                                _loadingStatus =
                                                    LoadingStatus.fail;
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
                          child: Text("Chỉnh sửa"))
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
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
                                              if (window.mode != "manual") {
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
                                              if (window.mode != "auto") {
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
                                              if (window.mode != "timer") {
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
                  if (window.mode == "auto") ...[
                    _autoMode()
                  ] else if (window.mode == "timer") ...[
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

  Future<void> controlManual(int status) async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });

    var res = await window_api.controlManual(window.windowId!, status);
    if (res["result"] == "success") {
      setState(() {
        window.status = status;
        currentStatus = calculateStatus(window.status!, window.height!);
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

  Future<void> changeMode(String mode) async {
    Navigator.pop(context);
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });

    if (mode == "manual") {
      controlManual(window.status!);
    }
    if (mode == "timer") {}

    var res = await window_api.changeMode(window.windowId!, mode);

    if (res["result"] == "success") {
      setState(() {
        window.mode = mode;
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

  Future<void> changeBreakpoint(List<String> breakpoints) async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });

    var res = await window_api.changeBreakpoint(window.windowId!, breakpoints);

    if (res["result"] == "success") {
      setState(() {
        window.breakpoints = breakpoints;
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

  Future<void> changeTimer(List<String> timers) async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });

    var res = await window_api.changeTimer(window.windowId!, timers);

    if (res["result"] == "success") {
      setState(() {
        window.timers = timers;
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
}
