class Global {
  static String token = "";
}

enum LoadingStatus {
  initial,
  loading,
  success,
  fail,
}

enum Mode {
  manual(code: "manual", name: "Thủ Công"),
  auto(code: "auto", name: "Tự Động"),
  timer(code: "timer", name: "Hẹn Giờ");

  final String name;
  final String code;

  const Mode({required this.name, required this.code});
}
