import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:salon_management/models/customer_model.dart';

class CustomerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var customers = <Customer>[].obs;
  var filteredCustomers = <Customer>[].obs;
  var serviceTakenData = <Map<String, dynamic>>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
    fetchServicesTaken();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    try {
      QuerySnapshot snapshot = await _firestore.collection('customer')
          .orderBy('created_at', descending: true)
          .get();

      customers.value = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Convert timestamp to DateTime if it exists
        DateTime? createdAt;
        if (data['created_at'] != null) {
          if (data['created_at'] is Timestamp) {
            createdAt = (data['created_at'] as Timestamp).toDate();
          } else if (data['created_at'] is String) {
            createdAt = DateTime.parse(data['created_at']);
          }
        }

        return Customer(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          gender: data['gender'] ?? '',
          createdAt: createdAt,
        );
      }).toList();

      filteredCustomers.value = List.from(customers);
      isLoading.value = false;
    } catch (e) {
      print('Error fetching customers: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchServicesTaken() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('services_taken').get();

      serviceTakenData.value = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': data['id'] ?? '',
          't_cost': data['t_cost'] ?? 0.0,
          'services': data['services'] ?? '',
          'timestamp': data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
        };
      }).toList();
    } catch (e) {
      print('Error fetching services taken: $e');
    }
  }

  double getTotalSpent(String customerId) {
    double total = 0.0;
    for (var service in serviceTakenData) {
      if (service['id'] == customerId) {
        if (service['t_cost'] is double) {
          total += service['t_cost'];
        } else if (service['t_cost'] != null) {
          total += double.parse(service['t_cost'].toString());
        }
      }
    }
    return total;
  }

  String getFormattedDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(date);
  }

  void searchCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers.value = List.from(customers);
      return;
    }

    filteredCustomers.value = customers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone.contains(query);
    }).toList();
  }

  void viewCustomerDetails(Customer customer) {
    // Navigate to customer details screen
    // You can implement this later
    Get.toNamed('/customer_details', arguments: customer);
  }
}