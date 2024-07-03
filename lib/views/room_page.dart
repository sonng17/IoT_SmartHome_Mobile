import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/apis/room_api.dart';
import 'package:smart_home/apis/lamp_api.dart' as lamp_api;
import 'package:smart_home/apis/window_api.dart' as window_api;
import 'package:smart_home/const/global.dart';
import 'package:smart_home/model/lamp.dart';
import 'package:smart_home/model/room.dart';
import 'package:smart_home/model/window.dart';
import 'package:smart_home/utils/websocket_helper.dart';
import 'package:smart_home/widget/lamp_card.dart';
import 'package:smart_home/widget/loading_indicator.dart';
import 'package:smart_home/widget/window_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _Data {
  _Data(this.time, this.data);

  final String? time;
  final double? data;
}

class RoomPage extends StatefulWidget {
  final Room args;
  const RoomPage({Key? key, required this.args}) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  LoadingStatus _loadingStatus = LoadingStatus.initial;

  TextEditingController textEditingController = TextEditingController();

  TextEditingController lampController = TextEditingController();

  TextEditingController windowNameController = TextEditingController();
  TextEditingController windowHeightController = TextEditingController();

  late StreamSubscription _streamSubscription;

  List<_Data> dataT = [
    _Data("0", 0),
    _Data("1", 0),
    _Data("2", 0),
    _Data("3", 0),
    _Data("4", 0),
  ];
  List<_Data> dataH = [
    _Data("0", 0),
    _Data("1", 0),
    _Data("2", 0),
    _Data("3", 0),
    _Data("4", 0),
  ];
  List<_Data> dataL = [
    _Data("0", 0),
    _Data("1", 0),
    _Data("2", 0),
    _Data("3", 0),
    _Data("4", 0),
  ];
  late int count;

  ChartSeriesController<_Data, String>? _chartSeriesControllerT;
  ChartSeriesController<_Data, String>? _chartSeriesControllerH;
  ChartSeriesController<_Data, String>? _chartSeriesControllerL;

  Room room = Room.empty();
  List<Lamp> lamps = [];
  List<Window> windows = [];

  String emptyLamp = "";
  String emptyWindow = "";

  @override
  void initState() {
    count = 4;
    _streamSubscription = WebsocketHelper().stream.listen((message) {
      updateData(jsonDecode(message));
    });
    initData();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    lampController.dispose();
    windowNameController.dispose();
    windowHeightController.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  void initData() async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });

    final args = widget.args;

    var res = await detailRoom(args.roomId!);

    if (res["result"] == "success") {
      var data = res["data"];
      var resLamps = data["lamps"] as List;
      var resWindows = data["windows"] as List;
      var resRoom = data["room"];

      Room tmpRoom = Room.fromJson(resRoom);
      List<Lamp> tmpLamps = resLamps.map((e) => Lamp.fromJson(e)).toList();
      List<Window> tmpWindows =
          resWindows.map((e) => Window.fromJson(e)).toList();

      setState(() {
        lamps = tmpLamps;
        windows = tmpWindows;
        room = tmpRoom;
        textEditingController.text = tmpRoom.name ?? "";
      });
      setState(() {
        _loadingStatus = LoadingStatus.success;
      });
    } else {
      setState(() {
        _loadingStatus = LoadingStatus.fail;
      });
      Fluttertoast.showToast(
          msg: "Lỗi Khi Lấy Dữ Liệu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    setState(() {
      emptyLamp = "Phòng chưa có đèn nào";
      emptyWindow = "Phòng chưa có sửa sổ nào";
    });
  }

  Future<void> addLamp() async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Chọn vị trí đèn bạn muốn thêm",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      ...List.generate(2, (index) {
                        return Expanded(
                          flex: 1,
                          child: (Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text("Vị trí ${index + 1}"),
                                if (room.connectedLamp!
                                    .contains((index + 1).toString())) ...[
                                  const ElevatedButton(
                                    onPressed: null,
                                    child: Text("Đã có đèn ở chân này"),
                                  )
                                ] else ...[
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        showModalAddLamp(index + 1);
                                      },
                                      child: Text("Thêm"))
                                ]
                              ],
                            ),
                          )),
                        );
                      })
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> showModalAddLamp(int order) async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Nhập tên đèn"),
                  TextFormField(
                    controller: lampController,
                    decoration: const InputDecoration(hintText: "Nhập tên đèn"),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (lampController.text == "") {
                          Fluttertoast.showToast(
                              msg: "Bạn cần nhập tên đèn",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          setState(() {
                            _loadingStatus = LoadingStatus.loading;
                          });
                          Navigator.pop(context);

                          var res = await lamp_api.createLamp(room.roomId!,
                              order.toString(), lampController.text);
                          if (res["result"] == "success") {
                            initData();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Lỗi khi lấy dữ liệu",
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
                          setState(() {
                            lampController.text = "";
                          });
                        }
                      },
                      child: const Text("Thêm Đèn"))
                ],
              ),
            ),
          );
        });
  }

  Future<void> addWindow() async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Chọn vị trí đèn bạn muốn thêm",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      ...List.generate(1, (index) {
                        return Expanded(
                          flex: 1,
                          child: (Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text("Vị trí ${index + 1}"),
                                if (room.connectedWindow!
                                    .contains((index + 1).toString())) ...[
                                  const ElevatedButton(
                                    onPressed: null,
                                    child: Text("Đã có cửa sổ ở chân này"),
                                  )
                                ] else ...[
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        showModalAddWindow(index + 1);
                                      },
                                      child: const Text("Thêm"))
                                ]
                              ],
                            ),
                          )),
                        );
                      })
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> showModalAddWindow(int order) async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Nhập tên cửa sổ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: windowNameController,
                    decoration: const InputDecoration(hintText: "Nhập tên"),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "Nhập chiều cao cửa sổ (cm)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: windowHeightController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Nhập chiều cao"),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (windowNameController.text == "" ||
                            windowHeightController.text == "") {
                          Fluttertoast.showToast(
                              msg: "Bạn cần nhập đủ các thông tin",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          setState(() {
                            _loadingStatus = LoadingStatus.loading;
                          });
                          Navigator.pop(context);

                          var res = await window_api.createWindow(
                              room.roomId!,
                              order.toString(),
                              windowNameController.text,
                              int.parse(windowHeightController.text));
                          if (res["result"] == "success") {
                            initData();
                            setState(() {
                              windowHeightController.text = "";
                              windowNameController.text = "";
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg: "Lỗi khi lấy dữ liệu",
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
                      child: const Text("Thêm cửa sổ"))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            initData();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(room.name ?? ""),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: ((context) {
                          return AlertDialog(
                            title: const Text("Đổi tên phòng"),
                            content: Container(
                              child: TextFormField(
                                controller: textEditingController,
                                decoration: const InputDecoration(
                                  hintText: "Nhập tên phòng",
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
                                        msg: "Bạn cần nhập tên phòng",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  } else if (textEditingController.text ==
                                      room.name) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pop(context);
                                    setState(() {
                                      _loadingStatus = LoadingStatus.loading;
                                    });
                                    var res = await changeName(room.roomId!,
                                        textEditingController.text);

                                    if (res["result"] == "success") {
                                      initData();
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
                            title: const Text("Bạn có chắc muốn xoá phòng?"),
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

                                  var res = await delete(room.roomId!);

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
                    icon: Icon(Icons.delete))
              ],
            ),
            body: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Biểu đồ"),
                    SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        // Chart title
                        title: ChartTitle(text: 'Nhiệt Độ, Độ Ẩm'),
                        // Enable legend
                        legend: Legend(isVisible: true),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <LineSeries<_Data, String>>[
                          LineSeries<_Data, String>(
                              onRendererCreated:
                                  (ChartSeriesController<_Data, String>?
                                      controller) {
                                _chartSeriesControllerT = controller;
                              },
                              dataSource: dataT,
                              xValueMapper: (_Data sales, _) => sales.time,
                              yValueMapper: (_Data sales, _) => sales.data,
                              color: Colors.red,
                              name: 'Nhiệt Độ',
                              // Enable data label
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true)),
                          LineSeries<_Data, String>(
                              onRendererCreated:
                                  (ChartSeriesController<_Data, String>?
                                      controller) {
                                _chartSeriesControllerH = controller;
                              },
                              dataSource: dataH,
                              xValueMapper: (_Data sales, _) => sales.time,
                              yValueMapper: (_Data sales, _) => sales.data,
                              color: Colors.blue,
                              name: 'Độ Ẩm',
                              // Enable data label
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true))
                        ]),
                    const SizedBox(
                      height: 12,
                    ),
                    const Divider(
                      height: 1,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bóng Đèn",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              addLamp();
                            },
                            child: const Text("Thêm đèn"))
                      ],
                    ),
                    lamps.isEmpty
                        ? Text(emptyLamp)
                        : GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            children: List.generate(lamps.length, (index) {
                              return Center(
                                child: LampCard(
                                  lamp: lamps[index],
                                  callback: initData,
                                ),
                              );
                            }),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Cửa Sổ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              addWindow();
                            },
                            child: const Text("Thêm cửa sổ"))
                      ],
                    ),
                    windows.isEmpty
                        ? Text(emptyWindow)
                        : GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            children: List.generate(windows.length, (index) {
                              return Center(
                                child: WindowCard(
                                  window: windows[index],
                                  callback: initData,
                                ),
                              );
                            }),
                          ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
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
    );
  }

  void updateData(Map<dynamic, dynamic> data) {
    String time = DateFormat.Hms().format(DateTime.now());

    setState(() {
      dataT.add(_Data(time, data["temperature"].toDouble()));
      dataH.add(_Data(time, data["humidity"].toDouble()));
      dataL.add(_Data(time, data["lightIntensity"].toDouble()));

      if (dataT.length < 6) {
        _chartSeriesControllerT
            ?.updateDataSource(addedDataIndexes: <int>[dataT.length - 1]);
        _chartSeriesControllerH
            ?.updateDataSource(addedDataIndexes: <int>[dataH.length - 1]);
        _chartSeriesControllerL
            ?.updateDataSource(addedDataIndexes: <int>[dataL.length - 1]);
      } else {
        dataT.removeAt(0);
        dataH.removeAt(0);
        dataL.removeAt(0);
        _chartSeriesControllerT?.updateDataSource(
            addedDataIndexes: <int>[dataT.length - 1],
            removedDataIndexes: <int>[0]);
        _chartSeriesControllerH?.updateDataSource(
            addedDataIndexes: <int>[dataT.length - 1],
            removedDataIndexes: <int>[0]);
        _chartSeriesControllerL?.updateDataSource(
            addedDataIndexes: <int>[dataT.length - 1],
            removedDataIndexes: <int>[0]);
      }

      count = count + 1;
    });
  }
}
