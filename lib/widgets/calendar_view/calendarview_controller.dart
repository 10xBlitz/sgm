import 'package:flutter/cupertino.dart';

class CalendarViewController extends ChangeNotifier {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  CalendarViewController({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  set selectedDate(DateTime date) {
    if (date.isBefore(firstDate) || date.isAfter(lastDate)) {
      throw ArgumentError('Selected date is out of range');
    }
    _selectedDate = date;
    notifyListeners();
  }

  void goToToday() {
    selectedDate = DateTime.now();
  }
}