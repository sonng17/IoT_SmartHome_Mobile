class Window {
  String? windowId;
  String? roomId;
  String? name;
  int? status;
  int? height;
  String? mode;
  List<String>? timers;
  List<String>? breakpoints;

  Window(
      {this.windowId,
      this.roomId,
      this.name,
      this.status,
      this.height,
      this.mode,
      this.timers,
      this.breakpoints});

  Window.fromJson(Map<String, dynamic> json) {
    windowId = json['windowId'];
    roomId = json['roomId'];
    name = json['name'];
    status = json['status'];
    height = json['height'];
    mode = json['mode'];
    timers = json['timers'].cast<String>();
    breakpoints = json['breakpoints'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['windowId'] = this.windowId;
    data['roomId'] = this.roomId;
    data['name'] = this.name;
    data['status'] = this.status;
    data['height'] = this.height;
    data['mode'] = this.mode;
    data['timers'] = this.timers;
    data['breakpoints'] = this.breakpoints;
    return data;
  }

  Window.empty() {
    windowId = "";
    roomId = "";
    name = "";
    status = 0;
    height = 0;
    mode = "";
    timers = [];
    breakpoints = [];
  }
}
