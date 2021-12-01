import 'dart:ui';

import 'package:expend/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

Widget ExpenseCard(Map<String, dynamic> data) {
  return Card(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.amber.shade50, Colors.pink.shade50])),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data["shopName"],
            textScaleFactor: 1.3,
          ),
          Text(
            "₹${data['expense']}",
            textScaleFactor: 1.4,
          ),
          Text(data["detail"].toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Type: ${data['type']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                DateTime.fromMillisecondsSinceEpoch(data["timestamp"])
                    .toHumanDate(),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
