import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealsScreen extends StatelessWidget {
  const MealsScreen(
      {Key? key, required this.futureMeals, required this.onTapMeal})
      : super(key: key);

  final Future<Meals> futureMeals;
  final ValueChanged<String> onTapMeal;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Meals>(
      future: futureMeals,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // return Text(snapshot.data!.Meals.first.strMeal);
          return MealsList(
            meals: snapshot.data!.meals,
            onTapMeal: onTapMeal,
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

class MealsList extends StatelessWidget {
  const MealsList({
    required this.meals,
    required this.onTapMeal,
    Key? key,
  }) : super(key: key);

  final List<Meal> meals;
  final ValueChanged<String> onTapMeal;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: meals.length,
        itemBuilder: (BuildContext context, int index) {
          return MealsItem(meal: meals[index], onTap: onTapMeal);
        });
  }
}

class MealsItem extends StatelessWidget {
  const MealsItem({
    required this.meal,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final Meal meal;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(Meal.strMeal),
        leading: Image.network(Meal.strMealThumb),
        minVerticalPadding: 32,
        onTap: () => onTap(Meal.strMeal));
  }
}
