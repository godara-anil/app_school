import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/category_model.dart';
import 'package:app_school/services/session_service.dart';


class CategoryPage extends StatefulWidget {

  const CategoryPage({Key? key})
      : super(key: key);

  @override
  State<CategoryPage> createState() =>
      _CategoryPageState();
}

class _CategoryPageState
    extends State<CategoryPage> {

  final categoryController =
  TextEditingController();

  @override
  void dispose() {

    categoryController.dispose();

    super.dispose();
  }



  void showAddDialog() {

    bool categoryIsExpense = true;

    showDialog(

      context: context,

      builder: (context) {

        return StatefulBuilder(

          builder: (context, setDialogState) {

            return AlertDialog(

              title: const Text(
                "Add Category",
              ),

              content: Column(

                mainAxisSize:
                MainAxisSize.min,

                children: [

                  TextField(

                    controller:
                    categoryController,

                    decoration:
                    const InputDecoration(

                      hintText:
                      "Enter Category Name",

                      border:
                      OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,

                    children: [

                      ChoiceChip(

                        label:
                        const Text("Income"),

                        selected:
                        !categoryIsExpense,

                        onSelected: (val) {

                          setDialogState(() {

                            categoryIsExpense =
                            false;
                          });
                        },
                      ),

                      ChoiceChip(

                        label:
                        const Text("Expense"),

                        selected:
                        categoryIsExpense,

                        onSelected: (val) {

                          setDialogState(() {

                            categoryIsExpense =
                            true;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Cancel",
                  ),
                ),

                ElevatedButton(

                  onPressed: () async {

                    if (SessionService.getActiveSessionLockStatus()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            SessionService.lockedMessage,
                          ),
                        ),
                      );
                      return;
                    }

                    final name =
                    categoryController
                        .text
                        .trim();

                    if (name.isEmpty) {
                      return;
                    }

                    final alreadyExists =
                    CategoryBox
                        .getCategories()
                        .values
                        .any(
                          (c) =>
                      c.name
                          .toLowerCase() ==
                          name.toLowerCase() &&
                          c.isExpense ==
                              categoryIsExpense,
                    );

                    if (alreadyExists) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(

                        const SnackBar(
                          content: Text(
                            "Category already exists",
                          ),
                        ),
                      );

                      return;
                    }

                    final category =
                    Category(

                      name: name,

                      isExpense:
                      categoryIsExpense,

                      isActive: true,
                    );

                    await CategoryBox
                        .getCategories()
                        .add(category);

                    categoryController.clear();

                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Save",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> toggleCategory(

      Category category,
      ) async {
    if (SessionService.getActiveSessionLockStatus()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            SessionService.lockedMessage,
          ),
        ),
      );
      return;
    }
    category.isActive =
    !category.isActive;

    await category.save();
  }

  Future<void> deleteCategory(
      Category category,
      ) async {
    if (SessionService.getActiveSessionLockStatus()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            SessionService.lockedMessage,
          ),
        ),
      );
      return;
    }
    final response =
    await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Delete Category",
          ),

          content: Text(
            "Delete ${category.name} ?",
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                "Delete",
              ),
            ),
          ],
        );
      },
    );

    if (response == true) {

      await category.delete();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Categories",
        ),

        backgroundColor:
        Colors.green,
      ),

      floatingActionButton:
      FloatingActionButton(

        onPressed: showAddDialog,

        backgroundColor:
        Colors.green,

        child: const Icon(
          Icons.add,
        ),
      ),

      body:
      ValueListenableBuilder(

        valueListenable:
        CategoryBox
            .getCategories()
            .listenable(),

        builder:
            (context, box, _) {

          final categories =
          box.values
              .toList()
              .cast<Category>();

          categories.sort(
                (a, b) =>
                a.name.compareTo(
                  b.name,
                ),
          );

          if (categories.isEmpty) {

            return const Center(

              child: Text(
                "No Categories",
              ),
            );
          }

          return ListView.builder(

            itemCount:
            categories.length,

            itemBuilder:
                (context, index) {

              final category =
              categories[index];

              return Card(

                margin:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),

                child: ListTile(

                  leading: CircleAvatar(

                    backgroundColor:
                    !category.isActive
                        ? Colors.grey
                        : category.isExpense
                        ? Colors.red
                        : Colors.green,

                    child: Icon(

                      category.isActive
                          ? Icons.check
                          : Icons.close,

                      color:
                      Colors.white,
                    ),
                  ),

                  title: Text(
                    category.name,
                  ),

                  subtitle: Text(
                    category.isActive
                        ? "Active"
                        : "Inactive",
                  ),

                  trailing: Row(

                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      IconButton(

                        onPressed: () {

                          toggleCategory(
                            category,
                          );
                        },

                        icon: Icon(

                          category.isActive
                              ? Icons.visibility
                              : Icons.visibility_off,

                          color:
                          Colors.blue,
                        ),
                      ),

                      IconButton(

                        onPressed: () {

                          deleteCategory(
                            category,
                          );
                        },

                        icon: const Icon(

                          Icons.delete,

                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}