import 'package:flutter/material.dart';
import 'package:smart_home/model/window.dart';
import 'package:smart_home/views/window_page.dart';

class WindowCard extends StatelessWidget {
  final Window window;
  final void Function()? callback;
  const WindowCard({Key? key, required this.window, this.callback})
      : super(key: key);

  String get getMode {
    if (window.mode != null) {
      switch (window.mode) {
        case "manual":
          return "Thủ công";
        case "auto":
          return "Tự động";
        case "timer":
          return "Hẹn giờ";
        default:
          return "";
      }
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        highlightColor: Colors.lightBlue[50],
        splashColor: Colors.lightBlue[50],
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WindowPage(
                  args: window,
                ),
              ));
          callback?.call();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                window.name ?? "",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Chiều cao: ${window.height}",
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Trạng thái: ${window.status}",
              ),
              const SizedBox(
                height: 4,
              ),
              Text("Chế đô: $getMode"),
            ],
          ),
        ),
      ),
    );
  }
}
