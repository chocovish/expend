import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expend/components/expense_card.dart';
import 'package:expend/pages/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  DateTime? rangeStartDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime? rangeEndDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  List<Map<String, dynamic>> data = [];

  static const types = ["None", "Grocery", "Bills", "Dine-In", "Other"];
  String _selectedType = "None";

  double sum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCalendar(),
            const Divider(),
            buildTypeSelect(),
            const Divider(),
            Text(
              "   Total: ₹$sum",
              textScaleFactor: 1.3,
            ),
            buildExpensesList()
          ],
        ),
      ),
    );
  }

  Flexible buildExpensesList() {
    return Flexible(
      flex: 3,
      child: SizedBox(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => buildExpenseActions(index),
        ),
      ),
    );
  }

  CupertinoContextMenu buildExpenseActions(int index) {
    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          child: const Text("Delete"),
          onPressed: () async {
            await expenseCollection.doc(data[index]["id"]).delete();
            await makeExpenseData();
            Get.back();
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          isDestructiveAction: true,
          trailingIcon: Icons.delete_forever_rounded,
        ),
        CupertinoContextMenuAction(
          child: const Text("Update"),
          trailingIcon: Icons.update_rounded,
          isDefaultAction: true,
          onPressed: () async {
            var thisdata = Map.of(data[index]);
            thisdata["expense"] = thisdata["expense"].toString();
            thisdata["timestamp"] =
                DateTime.fromMillisecondsSinceEpoch(thisdata["timestamp"]);
            bool? result = await Get.dialog(Dialog(
              child: AddExpenseWidget(
                initialData: thisdata,
              ),
            ));
            if (result != null) {
              await makeExpenseData();
              setState(() {});
            }
          },
        ),
      ],
      child: ExpenseCard(data[index]),
    );
  }

  Center buildTypeSelect() {
    return Center(
      child: CupertinoSlidingSegmentedControl(
        children: Map.fromEntries(types.map((e) => MapEntry(e, Text(e)))),
        groupValue: _selectedType,
        onValueChanged: (String? value) async {
          _selectedType = value!;
          await makeExpenseData();
          setState(() {});
        },
      ),
    );
  }

  TableCalendar buildCalendar() {
    return TableCalendar(
        rowHeight: 30,
        daysOfWeekHeight: 14,
        rangeSelectionMode: RangeSelectionMode.toggledOff,
        headerStyle: const HeaderStyle(headerPadding: EdgeInsets.all(0)),
        calendarFormat: _calendarFormat,
        firstDay: DateTime(2020),
        focusedDay: focusedDay,
        lastDay: DateTime.now(),
        rangeStartDay: rangeStartDay,
        rangeEndDay: rangeEndDay,
        // calendarBuilders: CalendarBuilders(
        //     // defaultBuilder: (context, day, focusedDay) {
        //     //   final color = giveColour(day);
        //     //   return CircleAvatar(
        //     //     backgroundColor: color,
        //     //     child: Center(
        //     //       child: Text(
        //     //         day.day.toString(),
        //     //       ),
        //     //     ),
        //     //   );
        //     // },
        //     ),
        onFormatChanged: (f) {
          setState(() {
            _calendarFormat = f;
          });
        },
        onRangeSelected: (start, end, focusedDay) async {
          Get.log("on range selected being called");
          Get.log(start.toString());
          Get.log(end.toString());
          Get.log(focusedDay.toString());
          if (rangeStartDay != null && rangeEndDay == null) {
            setState(() {
              rangeEndDay = focusedDay;
              this.focusedDay = focusedDay;
            });

            await makeExpenseData();
            setState(() {});
          } else {
            setState(() {
              rangeStartDay = start;
              rangeEndDay = end;
              this.focusedDay = focusedDay;
            });
          }
        },
        onDaySelected: (selectedDay, focusedDay) async {
          setState(() {
            rangeStartDay = selectedDay;
            rangeEndDay = selectedDay;
            this.focusedDay = focusedDay;
          });

          await makeExpenseData();
          setState(() {});
        });
  }

  Future<void> makeExpenseData() async {
    Get.log("calling make expenses data");
    final data = await getExpenseData();
    this.data.clear();
    sum = 0.0;
    for (var doc in data.docs) {
      final d = doc.data();
      d["id"] = doc.id;
      Get.log(d.toString());
      this.data.add(d);
      sum += d["expense"];
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getExpenseData() {
    Get.log("Querying with $rangeStartDay $rangeEndDay $_selectedType");
    final start =
        DateTime(rangeStartDay!.year, rangeStartDay!.month, rangeStartDay!.day);
    final end = DateTime(
        rangeEndDay!.year, rangeEndDay!.month, rangeEndDay!.day, 23, 59, 59);
    Get.log(
        "ACTUALLY Querying with ${start.millisecondsSinceEpoch} ${end.millisecondsSinceEpoch} $_selectedType");
    var query = expenseCollection.where("timestamp",
        isGreaterThanOrEqualTo: start.millisecondsSinceEpoch,
        isLessThanOrEqualTo: end.millisecondsSinceEpoch);
    if (_selectedType != "None") {
      query = query.where("type", isEqualTo: _selectedType);
    }
    return query.orderBy("timestamp", descending: true).get();
  }
}

giveColour(DateTime dateTime) {
  switch (dateTime.weekday) {
    case 1:
      return Colors.green;
    case 2:
      return Colors.greenAccent;
    case 3:
      return Colors.amber;
    case 4:
      return Colors.amberAccent;
    case 5:
      return Colors.orange;
    case 6:
      return Colors.red;
    case 7:
      return Colors.redAccent;

    default:
      return Colors.lightBlue;
  }
}
