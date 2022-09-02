import 'package:hive/hive.dart';
part 'Expenses.g.dart';

@HiveType(typeId:0)
class Expenses extends HiveObject {
  @HiveField(0)
  late double amount;
  @HiveField(1)
  late bool   isExpense = true;
  @HiveField(2)
  late DateTime date;
  @HiveField(3)
  late String category;
  @HiveField(5)
  late int? sessionKey;
  @HiveField(6)
  late bool? isBank = false;
  @HiveField(7)
  late String? remarks;
}
@HiveType(typeId:1)
class Sessions extends HiveObject {
  @HiveField(0)
  late bool   isActive = true;
  @HiveField(1)
  late String session;
}