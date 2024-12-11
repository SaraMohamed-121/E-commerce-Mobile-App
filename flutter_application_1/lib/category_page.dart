import 'package:flutter/material.dart';
import 'main.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
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
    bool hasLinkedProducts = products.any((product) => product.category == name);
    if (hasLinkedProducts) {
      showErrorDialog('Cannot delete category "$name". Products are linked to it.');
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
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
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
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Categories')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Add New Category'),
            trailing: Icon(Icons.add),
            onTap: () => showCategoryDialog(),
          ),
          Divider(),
          ...categories.map((category) {
            return ListTile(
              title: Text(category),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => showCategoryDialog(category: category),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
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
