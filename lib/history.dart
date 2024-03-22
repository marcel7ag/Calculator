// history_panel.dart
import 'package:flutter/material.dart';

class HistoryPanel extends StatelessWidget {
  final List<String> history;

  HistoryPanel({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
      child: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(history[index]),
          );
        },
      ),
    );
  }
}
