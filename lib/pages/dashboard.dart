import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expend/components/expense_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ThisMonthWidget(),
              const Divider(),
              //AddExpenseWidget(),
              PreviousExpensesWidget()
            ],
          ),
        ),
      ),
      floatingActionButton: buildFAB(),
    );
  }

  FloatingActionButton buildFAB() {
    return FloatingActionButton.extended(
        onPressed: () {
          Get.dialog(Dialog(
            child: AddExpenseWidget(),
          ));
        },
        label: Row(
          children: const [
            Icon(Icons.add),
            Text("Add"),
          ],
        ));
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        "Expend.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.defaultDialog(
                radius: 5,
                middleText: "You sure wanna logout?",
                // middleText: "",
                onConfirm: () async {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                });
            //
          },
          icon: const Icon(Icons.logout_rounded),
        )
      ],
    );
  }
}

class ThisMonthWidget extends StatefulWidget {
  const ThisMonthWidget({
    Key? key,
  }) : super(key: key);

  static final total = 0.0.obs;

  static final exp = expenseCollection
      .where("timestamp",
          isGreaterThan: DateTime.now()
              .subtract(const Duration(days: 30))
              .millisecondsSinceEpoch)
      .snapshots();

  @override
  State<ThisMonthWidget> createState() => _ThisMonthWidgetState();
}

class _ThisMonthWidgetState extends State<ThisMonthWidget> {
  @override
  void initState() {
    super.initState();
    ThisMonthWidget.exp.listen((event) {
      var sum = 0.0;
      for (var doc in event.docs) {
        sum += doc.get("expense");
      }
      ThisMonthWidget.total.value = sum;

      Get.log("sum is $sum");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Hello, " +
                (FirebaseAuth.instance.currentUser?.displayName ?? "Umm..?"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
          const SizedBox(height: 6),
          const Text(
            "Total spends this month",
            textScaleFactor: 1.5,
          ),
          const SizedBox(height: 2),
          Obx(() => Text(
                "₹${ThisMonthWidget.total.value}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ))
        ],
      ),
    );
  }
}

class AddExpenseWidget extends StatelessWidget {
  AddExpenseWidget({Key? key, this.initialData = const <String, dynamic>{}})
      : super(key: key);
  final Map<String, dynamic> initialData;

  final _formKey = GlobalKey<FormBuilderState>();
  static const space = SizedBox(height: 0);
  final showdatePicker = false.obs;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      //color: Colors.lightBlue.shade400,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => FormBuilder(
                  initialValue: initialData,
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderSegmentedControl(
                        validator: FormBuilderValidators.required(context),
                        initialValue: initialData["type"] ?? "Other",
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(-20)),
                        name: "type",
                        options: const [
                          FormBuilderFieldOption(value: "Grocery"),
                          FormBuilderFieldOption(value: "Bills"),
                          FormBuilderFieldOption(value: "Dine-In"),
                          FormBuilderFieldOption(value: "Other")
                        ],
                      ),
                      FormBuilderTextField(
                          validator: FormBuilderValidators.required(context),
                          enableSuggestions: true,
                          name: "shopName",
                          decoration: const InputDecoration(
                              labelText: "Shop Name",
                              prefixIcon: Icon(Icons.house_rounded)),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      space,
                      FormBuilderTextField(
                        validator: FormBuilderValidators.required(context),
                        name: "expense",
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: "Amount", prefixIcon: Icon(Icons.money)),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        valueTransformer: (value) =>
                            double.tryParse(value ?? "0"),
                      ),
                      space,
                      FormBuilderTextField(
                          validator: FormBuilderValidators.required(context),
                          name: "detail",
                          decoration: const InputDecoration(
                              labelText: "Details of spends",
                              prefixIcon: Icon(Icons.details_rounded)),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      space,
                      showdatePicker.value
                          ? FormBuilderDateTimePicker(
                              valueTransformer: (value) =>
                                  value?.millisecondsSinceEpoch,
                              name: "timestamp",
                              decoration: const InputDecoration(
                                labelText: "Time",
                                prefixIcon: Icon(Icons.watch),
                              ),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          : OutlinedButton(
                              onPressed: () {
                                showdatePicker.value = true;
                              },
                              child: const Text("Show Clock")),
                      space,
                      ElevatedButton(
                          onPressed: () async {
                            final result =
                                _formKey.currentState!.saveAndValidate();
                            if (!result) return;
                            final data = Map<String, dynamic>.from(
                                _formKey.currentState!.value);

                            data["timestamp"] = data["timestamp"] ??
                                initialData["timestamp"]
                                    ?.millisecondsSinceEpoch ??
                                DateTime.now().millisecondsSinceEpoch;

                            if (initialData.isNotEmpty) {
                              await expenseCollection
                                  .doc(initialData["id"])
                                  .update(data);
                              Get.back(result: true);
                            } else {
                              expenseCollection.add(data);
                            }
                            _formKey.currentState?.reset();
                          },
                          child: const Text("Add to expenses"))
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}

CollectionReference<Map<String, dynamic>> get expenseCollection =>
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("expenses");

class PreviousExpensesWidget extends StatelessWidget {
  PreviousExpensesWidget({Key? key}) : super(key: key);
  final expenseStream = expenseCollection
      .where("timestamp",
          isGreaterThan: DateTime.now()
              .subtract(const Duration(days: 30))
              .millisecondsSinceEpoch)
      .orderBy("timestamp", descending: true)
      .limit(10)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //height: Get.height,
        child: StreamBuilder(
      stream: expenseStream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading Data");
        }
        if (snapshot.hasError) return Text(snapshot.error.toString());
        final docs = snapshot.data!.docs;
        var column = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Last Spendings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                MaterialButton(
                    onPressed: () {
                      Get.toNamed("/expenses");
                    },
                    child: const Text("Show All",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.teal)))
              ],
            ),
            const SizedBox(height: 6),
            ...docs.map((e) {
              final data = e.data();
              return ExpenseCard(data);
            }),
          ],
        );
        return column;
      },
    ));
  }
}
