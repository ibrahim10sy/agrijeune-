import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectionVerify extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxList<ConnectivityResult> _connectionStatus =
      <ConnectivityResult>[].obs;

  void initConnectivity() async {
    print("Initialisation de la connexion");
    List<ConnectivityResult> connectivityResults;
    try {
      connectivityResults = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
      return;
    }
    _connectionStatus.value = connectivityResults;
    if (connectivityResults.isNotEmpty) {
      checkConnection(connectivityResults.first);
    }
  }

  void checkConnection(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      print("Connexion non disponible !");
      showNoConnectionSnackbar();
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    _connectivity.onConnectivityChanged.listen((results) {
      _connectionStatus.value = results;
      if (results.isNotEmpty) {
        checkConnection(results.first);
      }
    });
  }

  void showNoConnectionSnackbar() {
    Get.rawSnackbar(
      titleText: Container(
        width: double.infinity,
        height: Get.size.height * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Icon(
                Icons.wifi_off,
                size: 120,
                color: Colors.white,
              ),
            ),
            Text(
              "Aucune connexion internet !",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                //  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              child: Text('Quitter'),
            ),
          ],
        ),
      ),
      messageText: Container(),
      backgroundColor: Colors.black87,
      isDismissible: true,
      duration: Duration(days: 1),
    );
  }
}
