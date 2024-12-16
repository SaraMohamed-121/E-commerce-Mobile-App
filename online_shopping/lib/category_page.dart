import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  final TextEditingController _categoryController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _categoryImageController =
      TextEditingController();

  static Future<bool> checkIfNameExists(String? name) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Category')
        .where('name', isEqualTo: name)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addCategory(String name, String image) async {
    await firestore.collection('Category').add({
      'name': name,
      'image': image,
    });
  }

  Future<void> editCategory(String id, String newName, String image) async {
    await firestore.collection('Category').doc(id).update({
      'name': newName,
      'image': image,
    });
  }

  Future<void> deleteCategory(String id) async {
    await firestore.collection('Category').doc(id).delete();
  }

  void showCategoryDialog({String? id, String? initialName}) {
    _categoryController.text = initialName ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Category' : 'Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                TextField(
                  controller: _categoryImageController,
                  decoration:
                      const InputDecoration(labelText: 'Category Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _categoryController.text.trim();
                final image = _categoryImageController.text.trim();
                if (name.isEmpty) {
                  showErrorDialog('Category name cannot be empty.');
                  return;
                }
                if (id == null) {
                  await addCategory(name, image);
                } else {
                  await editCategory(id, name, image);
                }
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Add' : 'Save'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('Category').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
          final categories = snapshot.data!.docs;
          return ListView(
            children: [
              ListTile(
                title: const Text('Add New Category'),
                trailing: const Icon(Icons.add),
                onTap: () => showCategoryDialog(),
              ),
              const Divider(),
              ...categories.map((doc) {
                final categoryName = doc['name'];
                return ListTile(
                  title: Text(categoryName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showCategoryDialog(
                          id: doc.id,
                          initialName: categoryName,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                        'Are you sure you want to delete this category?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (confirmDelete) {
                            await deleteCategory(doc.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
