import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_management/models/customer_model.dart';
import '../controllers/registration_controller.dart';
import '../widgets/personal_info_widget.dart';
import '../widgets/services_widget.dart';

class RegistrationScreen extends StatelessWidget {
  final RegistrationController controller = Get.put(RegistrationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beauty Registration'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: controller.toggleSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _buildMainContent(),

          // Search overlay
          Obx(() => controller.showSearch.value
              ? _buildSearchOverlay()
              : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Salon Image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    //image: AssetImage('assets/images/salon.jpg'),
                    image: NetworkImage("https://img.freepik.com/premium-photo/clean-modern-hair-salon-with-white-furniture-woodpaneled-wall_36682-102642.jpg?semt=ais_hybrid"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        'Get Pampered Today',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Personal Information
              PersonalInfoWidget(controller: controller),
              SizedBox(height: 20),

              // Services Section
              if (controller.selectedGender.value.isNotEmpty)
                ServicesWidget(controller: controller),

              SizedBox(height: 20),

              // Total Amount
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${controller.totalAmount.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Book Appointment Button
              ElevatedButton(
                onPressed: controller.bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE91E63),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Book Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchOverlay() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: controller.toggleSearch,
                ),
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    focusNode: controller.searchFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Search by phone number',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.searchResults.clear();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Search results
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.searchResults.isEmpty && controller.searchQuery.value.isNotEmpty) {
                return Center(child: Text('No customers found'));
              }

              return ListView.builder(
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  Customer customer = controller.searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFE91E63),
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(customer.name),
                    subtitle: Text(customer.phone),
                    onTap: () => controller.selectCustomer(customer),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
