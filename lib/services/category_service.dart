import 'package:app_school/boxes.dart';
import 'package:app_school/model/category_model.dart';

class CategoryService {

  static Future<void> addCategory({
    required String name,
    required bool isExpense,
  }) async {

    final category = Category(
      name: name.trim(),
      isExpense: isExpense,
    );

    await Boxes.getCategories().add(category);
  }

  static Future<void> updateCategory({
    required Category category,
    required String name,
    required bool isExpense,
  }) async {

    category.name = name.trim();
    category.isExpense = isExpense;

    await category.save();
  }

  static Future<void> deleteCategory(
      Category category,
      ) async {
    await category.delete();
  }

  static List<Category> getCategories({bool? isExpense,}) {

    var categories =
    Boxes.getCategories()
        .values
        .where((e) => e.isActive)
        .toList()
        .cast<Category>();

    if (isExpense != null) {

      categories = categories
          .where((e) => e.isExpense == isExpense)
          .toList();
    }

    categories.sort(
          (a, b) =>
          a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );

    return categories;
  }

  static Future<void> ensureTransferCategory() async {
    final exists =
    CategoryBox
        .getCategories()
        .values
        .any(
          (c) =>
      c.name
          .toLowerCase() ==
          "transfer",
    );

    if (exists) return;

    await CategoryBox
        .getCategories()
        .add(
      Category(
        name: "Transfer",
        isExpense: false,
        isActive: true,
      ),
    );
  }
}