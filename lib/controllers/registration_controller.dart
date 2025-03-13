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
  RxBool isSearchPage = false.obs;

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

  var phoneNumber ="".obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();

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
    selectedGender.value = gender;
    updateServicesByGender();
  }

  void updateServicesByGender() {

    filteredServices.clear();
    selectedServices.clear();
    totalAmount.value = 0.0;

    if (selectedGender.value.toLowerCase() == 'male') {
      filteredServices.value = maleServices.map((service) => Service(
        id: service.id,
        name: service.name,
        price: service.price,
        isSelected: false,
      )).toList();

    } else if (selectedGender.value.toLowerCase() == 'female') {
      filteredServices.value = femaleServices.map((service) => Service(
        id: service.id,
        name: service.name,
        price: service.price,
        isSelected: false,
      )).toList();

    }
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    try {
      QuerySnapshot maleSnapshot = await _firestore.collection('services_male').get();
      maleServices.value = maleSnapshot.docs
          .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Service(
          id: doc.id,
          name: data['s_name'] ?? '',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
        );
      })
          .toList();

      QuerySnapshot femaleSnapshot = await _firestore.collection('services_female').get();
      femaleServices.value = femaleSnapshot.docs
          .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Service(
          id: doc.id,
          name: data['s_name'] ?? '',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
        );
      })
          .toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  void toggleService(Service service) {

    int index = filteredServices.indexWhere((s) => s.id == service.id);
    if (index >= 0) {
      filteredServices[index].isSelected = !filteredServices[index].isSelected;

      selectedServices.clear();

      for (var s in filteredServices) {
        if (s.isSelected) {
          selectedServices.add(s);
        }
      }

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

  Future<Customer?> checkCustomerExists(String phone) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('customer')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        var data = doc.data() as Map<String, dynamic>;
        return Customer.fromJson({
          ...data,
          'id': data['id'] ?? ''
        });
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> getNextCustomerId() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('customer')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return '1';
      }

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
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  Future<void> addServicesTaken(String customerId) async {
    try {
      String servicesList = selectedServices
          .map((service) => service.name)
          .join(', ');

      await _firestore.collection('services_taken').add({
        'id': customerId,
        't_cost': totalAmount.value,
        'services': servicesList,
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  Future<void> bookAppointment() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumber.value.isEmpty ||
        addressController.text.isEmpty ||
        selectedGender.value.isEmpty ||
        selectedServices.isEmpty) {

      String errorMessage = 'Please fill all fields and select at least one service: ';
      if (nameController.text.isEmpty) errorMessage += 'Name is empty. ';
      if (emailController.text.isEmpty) errorMessage += 'Email is empty. ';
      if (phoneNumber.value.isEmpty) errorMessage += 'Phone is empty. ';
      if (addressController.text.isEmpty) errorMessage += 'Address is empty. ';
      if (selectedGender.value.isEmpty) errorMessage += 'Gender is not selected. ';
      if (selectedServices.isEmpty) errorMessage += 'No services selected. ';

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFFE91E63),
        colorText: Colors.white
      );
      return;
    }

    isLoading.value = true;

    try {
      String customerId;

      Customer? existingCustomer = await checkCustomerExists(phoneNumber.value);

      if (existingCustomer != null) {
        customerId = existingCustomer.id;

        QuerySnapshot snapshot = await _firestore.collection('customer')
            .where('id', isEqualTo: customerId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          String docId = snapshot.docs.first.id;
          await _firestore.collection('customer').doc(docId).update({
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneNumber.value,
            'address': addressController.text,
            'gender': selectedGender.value,
            'updated_at': FieldValue.serverTimestamp(),
          });
        } else {
        }
      } else {
        String nextId = await getNextCustomerId();
        customerId = nextId;

        await _firestore.collection('customer').add({
          'id': nextId,
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneNumber.value,
          'address': addressController.text,
          'gender': selectedGender.value,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      await addServicesTaken(customerId);

      Get.snackbar(
        'Success',
        'Appointment booked successfully',
         snackPosition: SnackPosition.TOP, backgroundColor: Color(0xFFE91E63),
          colorText: Colors.white


      );

      resetForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to book appointment: $e',
        snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFFE91E63),
          colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }
}