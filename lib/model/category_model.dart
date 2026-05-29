import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class Category extends HiveObject {

  @HiveField(0)
  late String name;

  @HiveField(1)
  late bool isExpense;

  @HiveField(2)
  late bool isActive;

  @HiveField(3)
  late DateTime createdAt;

  Category({
    required this.name,
    required this.isExpense,
    this.isActive = true,
  }) {
    createdAt = DateTime.now();
  }
}