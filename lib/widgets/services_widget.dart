import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import '../models/service_model.dart' as service_models;

class ServicesWidget extends StatelessWidget {
  final RegistrationController controller;

  const ServicesWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.spa, color: Color(0xFFE91E63), size: 20),
            SizedBox(width: 8),
            Text(
              'Select Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            if (controller.filteredServices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text("No services available for the selected gender."),
                ),
              );
            }

            return Column(
              children: controller.filteredServices.map((service) =>
                  _buildServiceItem(service)
              ).toList(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildServiceItem(service_models.Service service) {
    IconData serviceIcon;

    if (service.name.toLowerCase().contains('haircut')) {
      serviceIcon = Icons.content_cut;
    } else if (service.name.toLowerCase().contains('color')) {
      serviceIcon = Icons.color_lens;
    } else if (service.name.toLowerCase().contains('shave')) {
      serviceIcon = Icons.face;
    } else if (service.name.toLowerCase().contains('facial')) {
      serviceIcon = Icons.spa;
    } else {
      serviceIcon = Icons.spa;
    }

    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Row(
        children: [
          Icon(serviceIcon, color: Color(0xFFE91E63), size: 20),
          SizedBox(width: 8),
          Text(service.name),
        ],
      ),
      secondary: Text(
        '\$${service.price.toStringAsFixed(0)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFE91E63),
        ),
      ),
      value: service.isSelected,
      onChanged: (_) => controller.toggleService(service),
      activeColor: Color(0xFFE91E63),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}