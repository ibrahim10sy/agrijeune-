import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Snack{

  static success({required String titre,required String message}){
    Get.snackbar(titre, message,  duration: Duration(seconds: 5) ,icon:Image.asset("assets/images/logo.png"));
  }

  static error({ required String titre,required String message}){
    Get.snackbar(titre, message,  duration: Duration(seconds: 8),icon:Image.asset("assets/images/logo.png")  );
  }

  static info({required String message}){
    Get.snackbar('Info', message,  duration: Duration(seconds: 5) ,icon:Image.asset("assets/images/logo.png"));
  }



  
  
}