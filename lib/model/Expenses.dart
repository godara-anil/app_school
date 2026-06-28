import 'package:hive/hive.dart';
part 'Expenses.g.dart';

@HiveType(typeId: 0)
class Expenses extends HiveObject {
  @HiveField(0)
  late double amount;
  @HiveField(1)
  late bool isExpense = true;
  @HiveField(2)
  late DateTime date;
  @HiveField(3)
  late String category;
  @HiveField(4)
  late int? sessionKey;
  @HiveField(5)
  late String accountId;
  @HiveField(6)
  late String? remarks;
  @HiveField(7)
  late DateTime createdAt = DateTime.now();
  @HiveField(8)
  String? transferId;
}

@HiveType(typeId: 1)
class Sessions extends HiveObject {
  @HiveField(0)
  late bool isActive = true;
  @HiveField(1)
  late String session;
  @HiveField(2)
  late bool isLocked = false;
}

@HiveType(typeId: 2)
class Account extends HiveObject {
  @HiveField(0)
  late String name;
  @HiveField(1)
  late double openingBalance;
  @HiveField(2)
  late String type;
  @HiveField(3)
  late bool isActive = true;
  @HiveField(4)
  late DateTime createdAt = DateTime.now();
  Account({
    required this.name,
    required this.openingBalance,
    required this.type,
    this.isActive = true,
  });
}
