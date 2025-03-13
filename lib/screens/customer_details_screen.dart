import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_management/models/customer_model.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final CustomerDetailsController controller = Get.put(CustomerDetailsController());

  @override
  Widget build(BuildContext context) {
    final Customer customer = Get.arguments as Customer;

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
        backgroundColor: Color(0xFF7E57C2),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => controller.editCustomer(customer),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer profile header
              Container(
                color: Color(0xFF7E57C2).withOpacity(0.1),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF7E57C2),
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Customer since: ${controller.getFormattedDate(customer.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildContactButton(Icons.call, 'Call', () => controller.callCustomer(customer.phone)),
                        SizedBox(width: 16),
                        _buildContactButton(Icons.sms, 'Text', () => controller.textCustomer(customer.phone)),
                        SizedBox(width: 16),
                        _buildContactButton(Icons.email, 'Email', () => controller.emailCustomer(customer.email)),
                      ],
                    ),
                  ],
                ),
              ),

              // Information cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard('Contact Information', [
                      {'icon': Icons.phone, 'label': 'Phone', 'value': customer.phone},
                      {'icon': Icons.email, 'label': 'Email', 'value': customer.email},
                      {'icon': Icons.location_on, 'label': 'Address', 'value': customer.address},
                      {'icon': Icons.person, 'label': 'Gender', 'value': customer.gender.capitalizeFirst!},
                    ]),

                    SizedBox(height: 16),

                    _buildInfoCard('Service History', [
                      {'label': 'Total Visits', 'value': controller.getTotalVisits(customer.id).toString()},
                      {'label': 'Total Spent', 'value': '\$${controller.getTotalSpent(customer.id).toStringAsFixed(2)}'},
                      {'label': 'Last Service', 'value': controller.getLastServiceInfo(customer.id)},
                    ]),

                    SizedBox(height: 16),

                    // Service History List
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Services',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            ...controller.getCustomerServices(customer.id).map((service) =>
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF7E57C2).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.content_cut,
                                          color: Color(0xFF7E57C2),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service['services'] ?? 'Unknown Service',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              controller.getFormattedDate(service['timestamp']),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\$${service['t_cost'].toString()}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7E57C2),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE91E63),
        child: Icon(Icons.add),
        onPressed: () => Get.toNamed('/registration', arguments: customer),
        tooltip: 'New Appointment',
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Color(0xFF7E57C2),
            ),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Map<String, dynamic>> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  if (item.containsKey('icon'))
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  if (item.containsKey('icon'))
                    SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item['value'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}