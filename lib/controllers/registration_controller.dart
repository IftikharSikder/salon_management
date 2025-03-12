import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegistrationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var showSearch = false.obs;
  var searchQuery = ''.obs;
  var searchFocusNode = FocusNode();

  var customer = Rx<Customer?>(null);
  var maleServices = <Service>[].obs;
  var femaleServices = <Service>[].obs;
  var filteredServices = <Service>[].obs;
  var selectedServices = <Service>[].obs;
  var totalAmount = 0.0.obs;

  var searchResults = <Customer>[].obs;
  var searchController = TextEditingController();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  var selectedGender = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();

    // Set up listener for search input changes
    searchController.addListener(() {
      search(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void toggleSearch() {
    showSearch.value = !showSearch.value;
    if (showSearch.value) {
      searchController.clear();
      searchResults.clear();
      // Request focus when search is shown
      Future.delayed(Duration(milliseconds: 100), () {
        searchFocusNode.requestFocus();
      });
    } else {
      searchQuery.value = '';
      searchResults.clear();
    }
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    _firestore.collection('customer')
        .get()
        .then((snapshot) {
      searchResults.clear();
      for (var doc in snapshot.docs) {
        var customerData = doc.data();
        String phone = customerData['phone'] ?? '';

        if (phone.contains(query)) {
          searchResults.add(Customer.fromJson({...customerData, 'id': doc.id}));
        }
      }
      isLoading.value = false;
    })
        .catchError((error) {
      print("Error searching customers: $error");
      isLoading.value = false;
    });
  }

  void selectCustomer(Customer selectedCustomer) {
    customer.value = selectedCustomer;
    nameController.text = selectedCustomer.name;
    emailController.text = selectedCustomer.email;
    phoneController.text = selectedCustomer.phone;
    addressController.text = selectedCustomer.address;
    selectedGender.value = selectedCustomer.gender;

    updateServicesByGender();
    showSearch.value = false;
  }

// In registration_controller.dart
  void setGender(String gender) {
    print("Setting gender from '${selectedGender.value}' to '$gender'");
    selectedGender.value = gender;
    updateServicesByGender();
  }

  void updateServicesByGender() {
    print("Updating services for gender: ${selectedGender.value}");

    filteredServices.clear();
    selectedServices.clear();
    totalAmount.value = 0.0;

    if (selectedGender.value.toLowerCase() == 'male') {
      // Create a new list with fresh copies to avoid reference issues
      filteredServices.value = maleServices.map((service) => Service(
        id: service.id,
        name: service.name,
        price: service.price,
        isSelected: false,
      )).toList();

      print("Male services assigned: ${filteredServices.length}");
    } else if (selectedGender.value.toLowerCase() == 'female') {
      // Create a new list with fresh copies to avoid reference issues
      filteredServices.value = femaleServices.map((service) => Service(
        id: service.id,
        name: service.name,
        price: service.price,
        isSelected: false,
      )).toList();

      print("Female services assigned: ${filteredServices.length}");
    }
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    try {
      // Fetch male services
      QuerySnapshot maleSnapshot = await _firestore.collection('services_male').get();
      maleServices.value = maleSnapshot.docs
          .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Use the document ID as the service ID
        return Service(
          id: doc.id, // Changed from data['id'] to doc.id
          name: data['s_name'] ?? '',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
        );
      })
          .toList();

      // Fetch female services
      QuerySnapshot femaleSnapshot = await _firestore.collection('services_female').get();
      femaleServices.value = femaleSnapshot.docs
          .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Service(
          id: doc.id, // Changed from data['id'] to doc.id
          name: data['s_name'] ?? '',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
        );
      })
          .toList();

      isLoading.value = false;
    } catch (e) {
      print('Error fetching services: $e');
      isLoading.value = false;
    }
  }

  void toggleService(Service service) {
    print("Attempting to toggle service: ${service.id} - ${service.name}");
    int index = filteredServices.indexWhere((s) => s.id == service.id);
    if (index >= 0) {
      filteredServices[index].isSelected = !filteredServices[index].isSelected;

      if (filteredServices[index].isSelected) {
        selectedServices.add(filteredServices[index]);
      } else {
        selectedServices.removeWhere((s) => s.id == service.id);
      }

      // Calculate total
      calculateTotal();
    }
  }

  void calculateTotal() {
    totalAmount.value = 0.0;
    for (var service in selectedServices) {
      totalAmount.value += service.price;
    }
  }

  void resetForm() {
    customer.value = null;
    nameController.text = '';
    emailController.text = '';
    phoneController.text = '';
    addressController.text = '';
    selectedGender.value = '';
    selectedServices.clear();
    filteredServices.clear();
    totalAmount.value = 0.0;
  }

  Future<void> bookAppointment() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedGender.value.isEmpty ||
        selectedServices.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields and select at least one service',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // If customer already exists, update their info
      if (customer.value != null) {
        await _firestore.collection('customer').doc(customer.value!.id).update({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'gender': selectedGender.value,
        });
      } else {
        // Create new customer
        DocumentReference docRef = await _firestore.collection('customer').add({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'gender': selectedGender.value,
        });

        // After creating customer, you could create an appointment document as well
        // For simplicity, I'm not implementing that part
      }

      Get.snackbar(
        'Success',
        'Appointment booked successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      resetForm();
      isLoading.value = false;
    } catch (e) {
      print('Error booking appointment: $e');
      Get.snackbar(
        'Error',
        'Failed to book appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
    }
  }
}

// lib/models/customer_model.dart
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}

// lib/models/service_model.dart
class Service {
  final String id;
  final String name;
  final double price;
  bool isSelected;

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
  });
}