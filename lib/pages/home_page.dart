import 'package:flutter/material.dart';
import 'package:habittrackertute/components/habit_tile.dart';
import 'package:habittrackertute/components/month_summary.dart';
import 'package:habittrackertute/components/my_fab.dart';
import 'package:habittrackertute/components/my_alert_box.dart';
import 'package:habittrackertute/data/habit_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  //veri tabanı ornegı olusturuyoruz
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  //kullanıcının uygulmaya ilk kezmı acıp acmadıgını  konttrol edıyoruz
 //bunun için veri tabanımızda zaten bir liste olup olmadıgına bakkıyoruz  
  
  @override
  void initState() {
    // egerbir liste yoksa, uygulamayı ilk kez açmak anlamına gelıyor
    // ardından varsayılan verileri oluştur
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    }

// zaten verimiz varsa 
    else {
      db.loadData();
    }

    // update the database
    db.updateDatabase();

    super.initState();
  }

  // onay kutucuguna dokunuyoruz ve veritbanından bugunun lıstesıne gıdıyor vve guncellıyoruz
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  //yenı alıskanlık eklıyoruz 
  final _newHabitNameController = TextEditingController();
  void createNewHabit() {
    // kullanıcının yeni alışkanlık ayrıntılarını girmesi için uyarı iletişim kutusunu görüyoruz 
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: 'Enter habit name..',
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  //  alıkanlıgı kayıtetme
  void saveNewHabit() {
// bugünün alışkanlık listesine yeni bir alışkanlık ekliyoruz
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });

    // metnı temızlıyoruz
    _newHabitNameController.clear();
    // pop dialog box
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  // cancel new habit
  void cancelDialogBox() {
    // clear textfield
    _newHabitNameController.clear();

    // pop dialog box
    Navigator.of(context).pop();
  }

  // düzenlemek için alışkanlık ayarlarını aç
  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: db.todaysHabitList[index][0],
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
        );
      },
    );
  }

// mevcut alışkanlığı yeni bir adla kaydet
  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.pop(context);
    db.updateDatabase();
  }

  // alışkanlıgı sıl 
  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[300],
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabit),
      //alışkanlık lıstesını aldık yenı bır lısteye koyduk lıstenınn basınada aylık ısı harıtası eklıyoruz
      body: ListView(
        children: [
          // aylık ısı harıtası
          MonthlySummary(
            datasets: db.heatMapDataSet,
            startDate: _myBox.get("START_DATE"),
          ),

          // list of habits
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),// harıtayı yana kaydırmamam a durumu 
            itemCount: db.todaysHabitList.length,
            itemBuilder: (context, index) {
              return HabitTile(
                habitName: db.todaysHabitList[index][0],
                habitCompleted: db.todaysHabitList[index][1],
                onChanged: (value) => checkBoxTapped(value, index),
                settingsTapped: (context) => openHabitSettings(index),
                deleteTapped: (context) => deleteHabit(index),
              );
            },
          )
        ],
      ),
    );
  }
}
