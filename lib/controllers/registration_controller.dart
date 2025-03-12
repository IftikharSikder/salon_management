import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salon_management/models/customer_model.dart';

import '../models/service_model.dart';


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
          searchResults.add(Customer.fromJson({...customerData, 'id': customerData['id'] ?? ''}));
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

  // Check if customer exists by phone number
  Future<Customer?> checkCustomerExists(String phone) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('customer')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        var data = doc.data() as Map<String, dynamic>;
        // Make sure we use the 'id' field from the customer document
        return Customer.fromJson({
          ...data,
          'id': data['id'] ?? '' // Use the stored numeric ID, not the document ID
        });
      }
      return null;
    } catch (e) {
      print('Error checking if customer exists: $e');
      return null;
    }
  }

  // Generate next customer ID
  Future<String> getNextCustomerId() async {
    try {
      // Get all customers sorted by numeric ID in descending order
      QuerySnapshot snapshot = await _firestore.collection('customer')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return '1'; // First customer
      }

      // Get the highest ID and increment by 1
      var highestDoc = snapshot.docs.first;
      var data = highestDoc.data() as Map<String, dynamic>;
      var highestId = data['id'];

      int nextId;
      if (highestId is String) {
        nextId = int.tryParse(highestId) ?? 0;
      } else if (highestId is int) {
        nextId = highestId;
      } else {
        nextId = 0;
      }

      return (nextId + 1).toString();
    } catch (e) {
      print('Error generating next customer ID: $e');
      // Fallback to timestamp-based ID if we can't determine the next ID
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Add services taken to firestore
  Future<void> addServicesTaken(String customerId) async {
    try {
      // Create a comma-separated list of service names
      String servicesList = selectedServices
          .map((service) => service.name)
          .join(', ');

      print('Adding services taken for customer ID: $customerId');

      // Add record to services_taken collection with the customerId in the 'id' field
      await _firestore.collection('services_taken').add({
        'id': customerId, // This should be the numeric customer ID
        't_cost': totalAmount.value,
        'services': servicesList,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Services taken added successfully for customer: $customerId');
    } catch (e) {
      print('Error adding services taken: $e');
      throw e; // Re-throw to handle in calling function
    }
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
      String customerId;

      // Check if customer exists by phone number
      Customer? existingCustomer = await checkCustomerExists(phoneController.text);

      if (existingCustomer != null) {
        // Customer exists, update their info
        customerId = existingCustomer.id;

        // We need to find the Firestore document ID using the customer ID field
        QuerySnapshot snapshot = await _firestore.collection('customer')
            .where('id', isEqualTo: customerId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          String docId = snapshot.docs.first.id;
          await _firestore.collection('customer').doc(docId).update({
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'address': addressController.text,
            'gender': selectedGender.value,
            'updated_at': FieldValue.serverTimestamp(),
          });
          print('Updated existing customer with ID: $customerId (doc: $docId)');
        } else {
          print('Error: Could not find document for customer ID: $customerId');
        }
      } else {
        // Customer doesn't exist, create new with sequential ID
        String nextId = await getNextCustomerId();
        customerId = nextId;

        await _firestore.collection('customer').add({
          'id': nextId, // Store the sequential numeric ID as a field
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'gender': selectedGender.value,
          'created_at': FieldValue.serverTimestamp(),
        });
        print('Created new customer with ID: $nextId');
      }

      // Add services taken record with the numeric customer ID
      await addServicesTaken(customerId);

      Get.snackbar(
        'Success',
        'Appointment booked successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      resetForm();
    } catch (e) {
      print('Error booking appointment: $e');
      Get.snackbar(
        'Error',
        'Failed to book appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}