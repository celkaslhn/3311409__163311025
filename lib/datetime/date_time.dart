//bugunun tarıhını yyyymmdd
String todaysDateFormatted() {
  // today
  var dateTimeObject = DateTime.now();

//yyy biçiminde yıl 
  String year = dateTimeObject.year.toString();

  // mm biçiminde ay
  String month = dateTimeObject.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  // dd formatında gun
  String day = dateTimeObject.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  // son durum
  String yyyymmdd = year + month + day;

  return yyyymmdd;
}

//yyyymmdd tarıh nesnesı olrak donustuyoruz
DateTime createDateTimeObject(String yyyymmdd) {
  int yyyy = int.parse(yyyymmdd.substring(0, 4));
  int mm = int.parse(yyyymmdd.substring(4, 6));
  int dd = int.parse(yyyymmdd.substring(6, 8));

  DateTime dateTimeObject = DateTime(yyyy, mm, dd);
  return dateTimeObject;
}

//tarıh nesnesını yyyymmdd ye dönustuyoruz
String convertDateTimeToString(DateTime dateTime) {
  // yyyy formatında yıl
  String year = dateTime.year.toString();

  //mm formatında ay
  String month = dateTime.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

//dd formatındad gun
  String day = dateTime.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  // sonn
  String yyyymmdd = year + month + day;

  return yyyymmdd;
}
