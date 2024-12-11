import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'VideoScreen.dart';

import 'payment_configurations.dart' as payment_configurations;

const _paymentItems = [
  PaymentItem(
    label: 'Total',
    amount: '6.00',
    status: PaymentItemStatus.final_price,
  )
];

class PaySampleApp extends StatefulWidget {
  final String name, mediaUrl;
  final dynamic sess;
  PaySampleApp({required this.name, required this.mediaUrl, required this.sess, Key? key})
      : super(key: key);

  @override
  _PaySampleAppState createState() => _PaySampleAppState();
}

class _PaySampleAppState extends State<PaySampleApp> {
  late final Future<PaymentConfiguration> _googlePayConfigFuture;

  @override
  void initState() {
    super.initState();
    _googlePayConfigFuture =
        PaymentConfiguration.fromAsset('default_google_pay_config.json');
  }

  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) =>
          VideoScreen(name: widget.name, mediaUrl: widget.mediaUrl, sess: widget.sess),
    ));
  }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) =>
          VideoScreen(name: widget.name, mediaUrl: widget.mediaUrl, sess: widget.sess),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement annuel'),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const Image(
              image: AssetImage('assets/images/logo.png'),
              height: 350,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Abonnement annuel pour A Vous De Jouer',
            style: TextStyle(
              color: Color(0xff777777),
              fontSize: 15,
            ),
          ),
          // Example pay button configured using an asset
         GooglePayButton(
                paymentConfiguration: PaymentConfiguration.fromJsonString(
                    payment_configurations.defaultGooglePay),
                paymentItems: _paymentItems,
                type: GooglePayButtonType.buy,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: onGooglePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          // Example pay button configured using a string
          ApplePayButton(
            paymentConfiguration: PaymentConfiguration.fromJsonString(
                payment_configurations.defaultApplePay),
            paymentItems: _paymentItems,
            style: ApplePayButtonStyle.black,
            type: ApplePayButtonType.buy,
            margin: const EdgeInsets.only(top: 15.0),
            onPaymentResult: onApplePayResult,
            loadingIndicator: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}