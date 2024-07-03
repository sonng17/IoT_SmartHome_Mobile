import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Container(
        margin: const EdgeInsets.all(20),
        child: const CupertinoActivityIndicator(radius: 20.0),
      );
    }
    return Container(
      margin: const EdgeInsets.all(20),
      child: const SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(
          strokeWidth: 6,
        ),
      ),
    );
  }
}
