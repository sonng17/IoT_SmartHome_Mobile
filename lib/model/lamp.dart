class Lamp {
  String? lampId;
  String? name;
  String? roomId;
  bool? status;
  String? mode;
  List<String>? timers;
  int? breakpoint;

  Lamp(
      {this.lampId,
      this.name,
      this.roomId,
      this.status,
      this.mode,
      this.timers,
      this.breakpoint});

  Lamp.fromJson(Map<String, dynamic> json) {
    lampId = json['lampId'];
    name = json['name'];
    roomId = json['roomId'];
    status = json['status'];
    mode = json['mode'];
    timers = json['timers'].cast<String>();
    breakpoint = json['breakpoint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lampId'] = this.lampId;
    data['name'] = this.name;
    data['roomId'] = this.roomId;
    data['status'] = this.status;
    data['mode'] = this.mode;
    data['timers'] = this.timers;
    data['breakpoint'] = this.breakpoint;
    return data;
  }

  Lamp.empty() {
    lampId = "";
    name = "";
    roomId = "";
    status = false;
    mode = "";
    timers = [];
    breakpoint = 0;
  }
}
