import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showErrorToast(String errorText) {
  Fluttertoast.showToast(
      msg: errorText,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

void showWarningToast(String warningMessage) {
  Fluttertoast.showToast(
      msg: warningMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

void showSuccessToast(String successMessage) {
  Fluttertoast.showToast(
      msg: successMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );
}