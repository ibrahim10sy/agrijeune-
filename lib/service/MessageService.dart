import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';
import 'package:koumi/models/MessageWa.dart';

class MessageService extends ChangeNotifier{

  static const String baseUrl = '$apiOnlineUrl/send';
  List<MessageWa> messageList = [];
  
  Future<void> SendMessageWa({
    required String whatsAppActeur,
    required String message,
  }) async {
    var addMessage = jsonEncode({
      'idMessage':null,
      'whatsAppActeur': whatsAppActeur,
      'message': message,

    });

    final response = await http.post(Uri.parse("$baseUrl/sendAndSaveMessages"),
        headers: {'Content-Type': 'application/json'}, body: addMessage);
    // debugPrint(addPays.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

Future<List<MessageWa>> fetchMessage() async {
    final response = await http.get(Uri.parse('$baseUrl/readAllMessage'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Duration(seconds: 5);
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      messageList = body.map((item) => MessageWa.fromMap(item)).toList();
      debugPrint(response.body);
      return messageList;
    } else {
      messageList = [];
      print('Échec de la requête mess avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }
Future<List<MessageWa>> fetchMessageByActeur(String idActeur) async {
    final response = await http.get(Uri.parse('$baseUrl/messageByActeur/$idActeur'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Duration(seconds: 5);
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      messageList = body.map((item) => MessageWa.fromMap(item)).toList();
      debugPrint(response.body);
      return messageList;
    } else {
      messageList = [];
      print('Échec de la requête mesa acteur avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

   Future<void> deleteMessage(String idMessage, String idActeur) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/deleteMessage/$idMessage/$idActeur"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> deleteAllMessages() async {
    final response =
        await http.delete(Uri.parse("$baseUrl/deleteAllMessage"));
    if (response.statusCode == 200 || response.statusCode == 204) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }


  void applyChange() {
    notifyListeners();
  }
}