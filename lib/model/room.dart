class Room {
  String? roomId;
  String? user;
  String? name;
  List<String>? connectedLamp;
  List<String>? connectedWindow;
  num? humidity;
  num? temperature;
  num? lightIntensity;

  Room(
      {this.roomId,
      this.user,
      this.name,
      this.connectedLamp,
      this.connectedWindow,
      this.humidity,
      this.temperature,
      this.lightIntensity});

  Room.fromJson(Map<String, dynamic> json) {
    roomId = json['roomId'];
    user = json['user'];
    name = json['name'];
    connectedLamp = json['connectedLamp'].cast<String>();
    connectedWindow = json['connectedWindow'].cast<String>();
    humidity = json['humidity'];
    temperature = json['temperature'];
    lightIntensity = json['lightIntensity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = this.roomId;
    data['user'] = this.user;
    data['name'] = this.name;
    data['connectedLamp'] = this.connectedLamp;
    data['connectedWindow'] = this.connectedWindow;
    data['humidity'] = this.humidity;
    data['temperature'] = this.temperature;
    data['lightIntensity'] = this.lightIntensity;
    return data;
  }

  Room.empty() {
    roomId = "";
    user = "";
    name = "";
    connectedLamp = [];
    connectedWindow = [];
    humidity = 0;
    temperature = 0;
    lightIntensity = 0;
  }
}
