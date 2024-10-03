import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';

class RemoteServices {
  static var client = http.Client();
  int page = 1;
  int size = sized;
   var baseURL = '$apiOnlineUrl/Stock/getAllStocksWithPagination';

   Future<dynamic> fetchItem(int start) async {
    var response = await client.get(
      Uri.parse('$baseURL/?page=$page&size=$size'),
    );
    return response;
  }

}