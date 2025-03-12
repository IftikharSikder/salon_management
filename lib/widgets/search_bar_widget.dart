
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';

class SearchBarWidget extends StatelessWidget {
  final RegistrationController controller;

  SearchBarWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Search by phone number',
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            controller.searchQuery.value = '';
            controller.searchResults.clear();
          },
        ),
      ),
      onChanged: (value) => controller.search(value),
    );
  }
}