import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PersonalInfoWidget extends StatelessWidget {
  final RegistrationController controller;

  PersonalInfoWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: Color(0xFFE91E63), size: 20),
            SizedBox(width: 8),
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        SizedBox(height: 16),

        // Email
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        SizedBox(height: 16),

        IntlPhoneField(
          controller: controller.phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
          initialCountryCode: 'IN',
          onChanged: (phone) {
            controller.phoneNumber.value = phone.completeNumber;
          },
        ),
        SizedBox(height: 16),

        TextField(
          controller: controller.addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Icon(Icons.location_on_outlined),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 16),

        Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(
                    () => RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(Icons.male, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Male'),
                    ],
                  ),
                  value: 'male',
                  groupValue: controller.selectedGender.value.toLowerCase(),
                  onChanged: (value) {
                    controller.setGender(value.toString());
                  },
                  activeColor: Color(0xFFE91E63),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                    () => RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(Icons.female, color: Colors.pink),
                      SizedBox(width: 8),
                      Text('Female'),
                    ],
                  ),
                  value: 'female',
                  groupValue: controller.selectedGender.value.toLowerCase(),
                  onChanged: (value) => controller.setGender(value!),
                  activeColor: Color(0xFFE91E63),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}