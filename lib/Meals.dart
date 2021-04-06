import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealsPage extends StatelessWidget {
  const MealsPage(
      {Key? key, required this.futureMeals, required this.onTapMeal})
      : super(key: key);

  final Future<Meals> futureMeals;
  final ValueChanged<String> onTapMeal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Database App'),
      ),
      body: Center(
        child: MealsScreen(futureMeals: futureMeals, onTapMeal: onTapMeal),
      ),
    );
  }
}

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
        title: Text(meal.strMeal),
        leading: Image.network(meal.strMealThumb),
        minVerticalPadding: 32,
        onTap: () => onTap(meal.idMeal));
  }
}

Future<Meals> fetchMeals(String categoryName) async {
  final response = await http.get(Uri.https(
      "www.themealdb.com", 'api/json/v1/1/filter.php', {"c": categoryName}));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return mealsFromJson(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Meals');
  }
}

// generated on app.quicktype.io
Meals mealsFromJson(String str) => Meals.fromJson(json.decode(str));

String mealsToJson(Meals data) => json.encode(data.toJson());

class Meals {
  Meals({
    required this.meals,
  });

  List<Meal> meals;

  factory Meals.fromJson(Map<String, dynamic> json) => Meals(
        meals: List<Meal>.from(json["meals"].map((x) => Meal.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "meals": List<dynamic>.from(meals.map((x) => x.toJson())),
      };
}

class Meal {
  Meal({
    required this.strMeal,
    required this.strMealThumb,
    required this.idMeal,
  });

  String strMeal;
  String strMealThumb;
  String idMeal;

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        strMeal: json["strMeal"],
        strMealThumb: json["strMealThumb"],
        idMeal: json["idMeal"],
      );

  Map<String, dynamic> toJson() => {
        "strMeal": strMeal,
        "strMealThumb": strMealThumb,
        "idMeal": idMeal,
      };
}
