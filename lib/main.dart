import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mealapp/Meal.dart';

import './Meals.dart';
import './Meal.dart';
import './Categories.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Categories> futureCategories;
  late Future<Meals> futureMeals;
  late Future<MealDetails> futureMeal;
  bool showMealsPage = false;
  bool showMealPage = false;

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
          if (showMealsPage)
            MaterialPage(
                child: MealsPage(
              futureMeals: futureMeals,
              onTapMeal: _handleMealsTapped,
            )),
          if (showMealPage)
            MaterialPage(
                child: MealPage(
              futureMealDetails: futureMeal,
            )),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          setState(() {
            showMealsPage = false;
            showMealPage = false;
          });

          return true;
        },
      ),
    );
  }

  void _handleCategoryTapped(String categoryName) {
    setState(() {
      futureMeals = fetchMeals(categoryName);
      showMealsPage = true;
    });
  }

  void _handleMealsTapped(String mealId) {
    setState(() {
      futureMeal = fetchMealDetails(mealId);
      showMealPage = true;
    });
  }
}
