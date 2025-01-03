import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RazorpayPage extends StatefulWidget {
  const RazorpayPage({super.key});

  @override
  State<RazorpayPage> createState() => _RazorpayPageState();
}

class _RazorpayPageState extends State<RazorpayPage> {
  late Razorpay _razorpay;
  TextEditingController amtController = TextEditingController();

  void openCheckout(int amount) async {
    amount = amount * 100; // Convert to paise
    var options = {
      'key': 'rzp_test_1DP5mn0lfG5ag', // Replace with your Razorpay key
      'amount': amount,
      'name': 'College App',
      'description': 'Payment for the college app',
      'prefill': {'contact': '1234567890', 'email': 'test@gmail.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "Payment successful: ${response.paymentId}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment failed: ${response.message ?? 'Unknown error'}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "External Wallet: ${response.walletName}",
        toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Welcome to College App Payment",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                cursorColor: Colors.white,
                autofocus: false,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Enter amount to be paid',
                  labelStyle: TextStyle(fontSize: 15.0, color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
                controller: amtController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount to be paid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (amtController.text.isNotEmpty) {
                  try {
                    int amount = int.parse(amtController.text);
                    openCheckout(amount);
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg: "Invalid amount entered",
                        toastLength: Toast.LENGTH_SHORT);
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "Please enter an amount",
                      toastLength: Toast.LENGTH_SHORT);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Make Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
