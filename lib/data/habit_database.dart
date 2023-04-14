import 'package:habittrackertute/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

//öncelikle bir hive kutusu açıyoruz
final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todaysHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  // eger uygulamayı ilk kullanıyorsak 
  //varsayılan degerler olusturyoruz
  void createDefaultData() {
    todaysHabitList = [
      ["Run", false],
      ["Read", false],
    ];

    _myBox.put("START_DATE", todaysDateFormatted());
  }

  //uygulama ilk açışımı değilmi konttrol edıyoruz
  void loadData() {
//eger yenı bır gunse olusturdugumuz alışkanlık listesini verıtabanından alıyoruz
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");

      //yeni gün oldugu ıcın bıten tum alıskanlıkları false olsrsk sysrlıyoruz
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }
//yenı gunn degılse bugunun lıstesını yukluyoruz
    else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }
  }

  // veritabanını guncelleyıyoruz
  void updateDatabase() {
//bugunun gırısı 
    _myBox.put(todaysDateFormatted(), todaysHabitList);

//bilgilerin degısmesı sonucunda alışkanlık listesini guncelle
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);

    // calculate habit complete percentages for each day
    calculateHabitPercentages();

    // load heat map
    loadHeatMap();
  }

  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));

    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      print(heatMapDataSet);
    }
  }
}
