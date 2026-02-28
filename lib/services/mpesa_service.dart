import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MpesaService {
  // Get from environment variables
  static String get consumerKey => dotenv.env['MPESA_CONSUMER_KEY'] ?? '';
  static String get consumerSecret => dotenv.env['MPESA_CONSUMER_SECRET'] ?? '';
  static String get passkey => dotenv.env['MPESA_PASSKEY'] ?? '';
  static String get shortcode => dotenv.env['MPESA_SHORTCODE'] ?? '174379';
  static String get callbackUrl => dotenv.env['MPESA_CALLBACK_URL'] ?? '';

  // Sandbox URLs (change to production for live)
  static const String baseUrl = 'https://sandbox.safaricom.co.ke';
  static const String authUrl = '$baseUrl/oauth/v1/generate?grant_type=client_credentials';
  static const String stkPushUrl = '$baseUrl/mpesa/stkpush/v1/processrequest';
  static const String queryUrl = '$baseUrl/mpesa/stkpushquery/v1/query';

  String? _accessToken;
  DateTime? _tokenExpiry;

  // ============= AUTHENTICATION =============

  Future<String> getAccessToken() async {
    // Return cached token if still valid
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final credentials = base64.encode(
        utf8.encode('$consumerKey:$consumerSecret'),
      );

      final response = await http.get(
        Uri.parse(authUrl),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        // Token expires in 3599 seconds, cache for 3500 to be safe
        _tokenExpiry = DateTime.now().add(const Duration(seconds: 3500));
        
        return _accessToken!;
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting access token: $e');
    }
  }

  // ============= GENERATE PASSWORD =============

  String generatePassword() {
    final timestamp = getTimestamp();
    final data = '$shortcode$passkey$timestamp';
    return base64.encode(utf8.encode(data));
  }

  String getTimestamp() {
    final now = DateTime.now();
    return '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }

  // ============= STK PUSH (LIPA NA M-PESA) =============

  Future<Map<String, dynamic>> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final token = await getAccessToken();
      final password = generatePassword();
      final timestamp = getTimestamp();

      // Format phone number (remove leading 0, add country code)
      String formattedPhone = phoneNumber;
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254${formattedPhone.substring(1)}';
      } else if (!formattedPhone.startsWith('254')) {
        formattedPhone = '254$formattedPhone';
      }

      final body = {
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toInt().toString(),
        'PartyA': formattedPhone,
        'PartyB': shortcode,
        'PhoneNumber': formattedPhone,
        'CallBackURL': callbackUrl,
        'AccountReference': accountReference,
        'TransactionDesc': transactionDesc,
      };

      final response = await http.post(
        Uri.parse(stkPushUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'merchantRequestID': responseData['MerchantRequestID'],
          'checkoutRequestID': responseData['CheckoutRequestID'],
          'responseCode': responseData['ResponseCode'],
          'responseDescription': responseData['ResponseDescription'],
          'customerMessage': responseData['CustomerMessage'],
        };
      } else {
        return {
          'success': false,
          'errorCode': responseData['errorCode'] ?? 'UNKNOWN',
          'errorMessage': responseData['errorMessage'] ?? 'Payment failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Error initiating payment: $e',
      };
    }
  }

  // ============= QUERY TRANSACTION STATUS =============

  Future<Map<String, dynamic>> queryTransaction({
    required String checkoutRequestID,
  }) async {
    try {
      final token = await getAccessToken();
      final password = generatePassword();
      final timestamp = getTimestamp();

      final body = {
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestID,
      };

      final response = await http.post(
        Uri.parse(queryUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'resultCode': responseData['ResultCode'],
          'resultDesc': responseData['ResultDesc'],
        };
      } else {
        return {
          'success': false,
          'errorMessage': responseData['errorMessage'] ?? 'Query failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Error querying transaction: $e',
      };
    }
  }

  // ============= PAYMENT VERIFICATION =============

  Future<bool> verifyPayment(String checkoutRequestID) async {
    // Poll for payment status (max 60 seconds)
    for (int i = 0; i < 12; i++) {
      await Future.delayed(const Duration(seconds: 5));
      
      final result = await queryTransaction(
        checkoutRequestID: checkoutRequestID,
      );

      if (result['success'] == true) {
        final resultCode = result['resultCode'];
        
        // 0 = Success
        if (resultCode == '0') {
          return true;
        }
        
        // 1032 = Cancelled by user
        // 1 = Insufficient balance
        // Other codes = Failed
        if (resultCode != null && resultCode != '0') {
          return false;
        }
      }
    }

    // Timeout
    return false;
  }

  // ============= HELPER METHODS =============

  String getPaymentStatusMessage(String resultCode) {
    switch (resultCode) {
      case '0':
        return 'Malipo yamekamilika';
      case '1':
        return 'Salio haitoshi';
      case '1032':
        return 'Malipo yameghairiwa na mtumiaji';
      case '1037':
        return 'Mtumiaji hakupokea prompt ya M-Pesa';
      case '2001':
        return 'PIN si sahihi';
      default:
        return 'Malipo yameshindikana';
    }
  }

  // Calculate delivery fee with M-Pesa charges
  Map<String, double> calculateTotalAmount(double deliveryFee) {
    // M-Pesa charges (approximate for Tanzania)
    double mpesaCharge = 0;
    
    if (deliveryFee <= 1000) {
      mpesaCharge = 30;
    } else if (deliveryFee <= 2500) {
      mpesaCharge = 50;
    } else if (deliveryFee <= 5000) {
      mpesaCharge = 67;
    } else if (deliveryFee <= 10000) {
      mpesaCharge = 110;
    } else {
      mpesaCharge = 130;
    }

    return {
      'deliveryFee': deliveryFee,
      'mpesaCharge': mpesaCharge,
      'totalAmount': deliveryFee + mpesaCharge,
    };
  }

  // Format phone number for display
  String formatPhoneNumber(String phone) {
    if (phone.startsWith('254')) {
      return '0${phone.substring(3)}';
    }
    return phone;
  }

  // Validate phone number
  bool isValidPhoneNumber(String phone) {
    // Remove spaces and special characters
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Tanzanian mobile number
    if (phone.startsWith('0')) {
      phone = '254${phone.substring(1)}';
    }
    
    // Valid format: 254XXXXXXXXX (12 digits)
    return phone.startsWith('254') && phone.length == 12;
  }
}

// ============= PAYMENT MODELS =============

class PaymentTransaction {
  final String id;
  final String orderId;
  final String customerId;
  final double amount;
  final String phoneNumber;
  final String merchantRequestID;
  final String checkoutRequestID;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? resultCode;
  final String? resultDescription;

  PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.amount,
    required this.phoneNumber,
    required this.merchantRequestID,
    required this.checkoutRequestID,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.resultCode,
    this.resultDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'merchantRequestID': merchantRequestID,
      'checkoutRequestID': checkoutRequestID,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'resultCode': resultCode,
      'resultDescription': resultDescription,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      orderId: json['orderId'],
      customerId: json['customerId'],
      amount: json['amount'].toDouble(),
      phoneNumber: json['phoneNumber'],
      merchantRequestID: json['merchantRequestID'],
      checkoutRequestID: json['checkoutRequestID'],
      status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      resultCode: json['resultCode'],
      resultDescription: json['resultDescription'],
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}
