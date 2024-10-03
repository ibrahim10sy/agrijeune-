import 'package:get/get.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/service/remote_service.dart';


class ItemController extends GetxController{
  var isLoading = true.obs;
  var isAddLoading = false.obs;
  var itemList = List<Stock>.empty(growable: true).obs;
  // var itemList = List<Item>.empty(growable: true).obs;


  @override
  void onInit() {
    fetchItem(0);
    super.onInit();
  }

  void fetchItem(int start) async {
    try{
      isLoading(true);
      itemList.clear();
      var response = await RemoteServices().fetchItem(start);
      if(response.statusCode == 200){
        Stock items = Stock.fromJson(response.body);
        itemList.add(items);
      }
    }
    finally{
      isLoading(false);
    }
  }

  void addItem(int start) async {
    try{
      isAddLoading(true);
      var response = await RemoteServices().fetchItem(start);
      if(response.statusCode == 200){
        Stock items = Stock.fromJson(response.body);
        itemList.add(items);
      }
    }
    finally{
      isAddLoading(false);
    }
  }
}