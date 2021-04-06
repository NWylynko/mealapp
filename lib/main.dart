import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Categories> futureCategories;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Database App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Navigator(
        pages: [
          MaterialPage(
            child: HomePage(
                futureCategories: futureCategories,
                onTapCategory: _handleCategoryTapped),
          ),
          if (selectedCategory != '')
            MaterialPage(child: Text('${selectedCategory}')),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          // Update the list of pages by setting _selectedBook to null
          setState(() {
            selectedCategory = '';
          });

          return true;
        },
      ),
    );
  }

  void _handleCategoryTapped(String categoryId) {
    setState(() {
      selectedCategory = categoryId;
    });
  }
}

// HomePage(futureCategories: futureCategories)

class HomePage extends StatelessWidget {
  const HomePage(
      {Key? key, required this.futureCategories, required this.onTapCategory})
      : super(key: key);

  final Future<Categories> futureCategories;
  final ValueChanged<String> onTapCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Database App'),
      ),
      body: Center(
        child: CategoriesScreen(
            futureCategories: futureCategories, onTapCategory: onTapCategory),
      ),
    );
  }
}

Future<Categories> fetchCategories() async {
  final response = await http
      .get(Uri.https("www.themealdb.com", 'api/json/v1/1/categories.php'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return categoriesFromJson(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Categories');
  }
}

// To parse this JSON data, do
//
//     final categories = categoriesFromJson(jsonString);
Categories categoriesFromJson(String str) =>
    Categories.fromJson(json.decode(str));

String categoriesToJson(Categories data) => json.encode(data.toJson());

class Categories {
  Categories({
    required this.categories,
  });

  List<Category> categories;

  factory Categories.fromJson(Map<String, dynamic> json) => Categories(
        categories: List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class Category {
  Category({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryThumb,
    required this.strCategoryDescription,
  });

  String idCategory;
  String strCategory;
  String strCategoryThumb;
  String strCategoryDescription;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        idCategory: json["idCategory"],
        strCategory: json["strCategory"],
        strCategoryThumb: json["strCategoryThumb"],
        strCategoryDescription: json["strCategoryDescription"],
      );

  Map<String, dynamic> toJson() => {
        "idCategory": idCategory,
        "strCategory": strCategory,
        "strCategoryThumb": strCategoryThumb,
        "strCategoryDescription": strCategoryDescription,
      };
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen(
      {Key? key, required this.futureCategories, required this.onTapCategory})
      : super(key: key);

  final Future<Categories> futureCategories;
  final ValueChanged<String> onTapCategory;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Categories>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // return Text(snapshot.data!.categories.first.strCategory);
          return CategoryList(
            categories: snapshot.data!.categories,
            onTapCategory: onTapCategory,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }
}

class CategoryList extends StatelessWidget {
  const CategoryList({
    required this.categories,
    required this.onTapCategory,
    Key? key,
  }) : super(key: key);

  final List<Category> categories;
  final ValueChanged<String> onTapCategory;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return CategoryItem(
              category: categories[index], onTap: onTapCategory);
        });
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    required this.category,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final Category category;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(category.strCategory),
        leading: Image.network(category.strCategoryThumb),
        onTap: () => onTap(category.idCategory));
  }
}
