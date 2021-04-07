import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'Meal.dart';

class SearchPage extends StatelessWidget {
  const SearchPage(
      {Key? key, required this.futureMealSearch, required this.onTapMeal})
      : super(key: key);

  final Future<MealDetails> futureMealSearch;
  final ValueChanged<String> onTapMeal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text('Meal Database App'),
      ),
      body: Center(
        child: SearchScreen(
            futureMealSearch: futureMealSearch, onTapMeal: onTapMeal),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen(
      {Key? key, required this.futureMealSearch, required this.onTapMeal})
      : super(key: key);

  final Future<MealDetails> futureMealSearch;
  final ValueChanged<String> onTapMeal;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MealDetails>(
      future: futureMealSearch,
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
        return CupertinoActivityIndicator();
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
        title: Text(meal.strMeal),
        leading: Image.network(meal.strMealThumb),
        minVerticalPadding: 32,
        onTap: () => onTap(meal.idMeal));
  }
}

Future<MealDetails> searchMealDetails(String mealName) async {
  final response = await http.get(Uri.https(
      "www.themealdb.com", 'api/json/v1/1/search.php', {"s": mealName}));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return mealDetailsFromJson(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Meals');
  }
}
