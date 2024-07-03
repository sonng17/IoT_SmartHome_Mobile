import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:smart_home/const/global.dart';

var dio = Dio();
void configureDio() {
  // Set default configs
  // dio.options.baseUrl = "https://binht1-iot-smarthome-be.onrender.com";
  dio.options.baseUrl = 'http://10.0.2.2:8000';
  dio.options.connectTimeout = const Duration(seconds: 15);
  dio.options.receiveTimeout = const Duration(seconds: 15);
}

dynamic sendRequest(path, method, [params, formData = false, headers]) async {
  try {
    Response response;

    var dictHeaders = {
      "Authorization": Global.token.isNotEmpty ? "Bearer " + Global.token : null
    };
    if (headers != null) {
      dictHeaders = {...dictHeaders, ...headers};
    }

    response = await dio.request(
      path,
      data: (params != null)
          ? formData
              ? FormData.fromMap(params)
              : json.encode(params)
          : null,
      options: Options(method: method, headers: dictHeaders),
    );
    if (response.data is String) {
      var jData = jsonDecode(response.data);
      return jData;
    } else {
      return response.data;
    }
  } on DioError catch (e) {
    //hiện thông báo lỗi
    switch (e.response?.statusCode) {
      case 401:
        break;
      case 402:
        break;
      case 403:
        break;
      default:
    }

    print(e);

    if (e.response?.data is String) {
      return e.response?.data != null
          ? json.decode(e.response?.data)
          : {"Result": "Failed"};
    } else {
      return e.response?.data ?? {"Result": "Failed"};
    }
  }
}
