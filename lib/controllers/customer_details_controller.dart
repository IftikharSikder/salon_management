import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:salon_management/models/customer_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var serviceTakenData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchServicesTaken();
  }

  Future<void> fetchServicesTaken() async {
    isLoading.value = true;
    try {
      QuerySnapshot snapshot = await _firestore.collection('services_taken')
          .orderBy('timestamp', descending: true)
          .get();

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
      isLoading.value = false;
    } catch (e) {
      print('Error fetching services taken: $e');
      isLoading.value = false;
    }
  }

  String getFormattedDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(date);
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

  int getTotalVisits(String customerId) {
    return serviceTakenData.where((service) => service['id'] == customerId).length;
  }

  String getLastServiceInfo(String customerId) {
    final customerServices = getCustomerServices(customerId);
    if (customerServices.isEmpty) return 'No services yet';

    final lastService = customerServices.first;
    return '${lastService['services']} on ${getFormattedDate(lastService['timestamp'])}';
  }

  List<Map<String, dynamic>> getCustomerServices(String customerId) {
    return serviceTakenData
        .where((service) => service['id'] == customerId)
        .toList();
  }

  void callCustomer(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone call',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void textCustomer(String phone) async {
    final Uri url = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch messaging app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void emailCustomer(String email) async {
    final Uri url = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch email app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void editCustomer(Customer customer) {
    // Navigate to edit customer screen
    Get.toNamed('/edit_customer', arguments: customer);
  }
}