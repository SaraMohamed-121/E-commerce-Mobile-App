import 'package:flutter/material.dart';
import 'admin.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  final TextEditingController _categoryController = TextEditingController();

  void addCategory(String name) {
    setState(() {
      if (name.isNotEmpty && !categories.contains(name)) {
        categories.add(name);
      }
    });
  }

  void updateCategoryName(String oldName, String newName) {
    setState(() {
      for (var product in products) {
        if (product.category == oldName) {
          product.category = newName;
        }
      }
    });
  }

  void editCategory(String oldName, String newName) {
    if (newName.isEmpty || categories.contains(newName)) {
      showErrorDialog('Category name is invalid or already exists.');
      return;
    }

    setState(() {
      int index = categories.indexOf(oldName);
      if (index != -1) {
        categories[index] = newName;
        updateCategoryName(oldName, newName);
      }
    });
  }

  void deleteCategory(String name) {
    bool hasLinkedProducts =
        products.any((product) => product.category == name);
    if (hasLinkedProducts) {
      showErrorDialog(
          'Cannot delete category "$name". Products are linked to it.');
      return;
    }

    setState(() {
      categories.remove(name);
    });
  }

  void showCategoryDialog({String? category}) {
    _categoryController.text = category ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (category == null) {
                  addCategory(_categoryController.text);
                } else {
                  editCategory(category, _categoryController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(category == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Add New Category'),
            trailing: const Icon(Icons.add),
            onTap: () => showCategoryDialog(),
          ),
          const Divider(),
          ...categories.map((category) {
            return ListTile(
              title: Text(category),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showCategoryDialog(category: category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteCategory(category),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
