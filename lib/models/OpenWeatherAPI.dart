class OpenWeatherAPI {

  String apiKey = '186189a7eeb32522dbcfc1af608bb4d8'; //weather stack
  // String apiKey = 'Api Key Giriniz// Api Key Here';

  String apiUrl(lat, lon) {
    return 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$apiKey';
  }
  
}