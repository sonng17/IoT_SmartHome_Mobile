import 'package:flutter/material.dart';
import 'package:smart_home/model/lamp.dart';
import 'package:smart_home/views/lamp_page.dart';

class LampCard extends StatelessWidget {
  final Lamp lamp;
  final void Function()? callback;
  const LampCard({
    required this.lamp,
    Key? key,
    this.callback,
  }) : super(key: key);

  String get getStatus {
    if (lamp.status != null) {
      if (lamp.status!) {
        return "Bật";
      } else {
        return "Tắt";
      }
    } else {
      return "";
    }
  }

  String get getMode {
    if (lamp.mode != null) {
      switch (lamp.mode) {
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
                builder: (context) => LampPage(
                  args: lamp,
                ),
              ));
          callback!.call();
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
                lamp.name ?? "",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Trạng thái: $getStatus",
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
