import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jxp_app/widgets/main_app_bar.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/blur_loader.dart';
import '../widgets/bottom_nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _showOtpField = false;
  bool _isLoading = false;
  bool isCaptchaValid = true;
  String generatedCaptcha = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generateCaptcha();
  }

  // Function to generate a random Captcha
  void generateCaptcha() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    setState(() {
      generatedCaptcha = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    });
  }

  String? emailErrorText;

  @override
  void dispose() {
    // TODO: implement dispose
  _emailController.dispose();
  _captchaController.dispose();
  _otpController.dispose();
    super.dispose();
  }

  void _getOtp() async {
    if (_emailController.text.isEmpty || _captchaController.text.isEmpty) {
      _showMessage("Please enter Email and Captcha");
      return;
    }

    if (_captchaController.text != generatedCaptcha) {
      setState(() => isCaptchaValid = false);
      return;
    }else{
      setState(() => isCaptchaValid = true);
    }

    setState(() {
      isCaptchaValid = true;
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).getOtp(_emailController.text);
      var otpResponse = Provider.of<AuthProvider>(context, listen: false).otpResponse;
      setState(() {
        _showOtpField = !(otpResponse?.status == 'error');
        _showMessage(otpResponse!.message);
      });
    } catch (e) {
      _showMessage("Failed to send OTP. Try again. Error: $e");
    }

    setState(() => _isLoading = false);

  }


  void _resendOtp() async {
    if (_emailController.text.isNotEmpty && _captchaController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthProvider>(context, listen: false).getOtp(_emailController.text);

        var otpResponse = Provider.of<AuthProvider>(context, listen: false).otpResponse;

        setState(() {
          _showMessage(otpResponse!.message);
        });
      } catch (e) {
        _showMessage("Failed to send OTP. Try again. Error: $e");
      }
      setState(() => _isLoading = false);
    } else {
      _showMessage("Please enter Email and Captcha");
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthProvider>(context, listen: false).verifyOtp(
            _emailController.text, _otpController.text);

        final verifyResponse =  Provider.of<AuthProvider>(context, listen: false).verifyResponse;
        if (verifyResponse?.status == 'error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(verifyResponse?.message ?? "1")),
          );
        } else {
          print('verifyResponse: ${verifyResponse?.id}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(verifyResponse?.message ?? "2")),  // problem
          );

          Provider.of<AuthProvider>(context, listen: false).notify2Listeners();
          Navigator.of(context).pushAndRemoveUntil(  MaterialPageRoute(builder: (context) => const BottomNavBar()),      (route) => false,);
        }

      } catch (e) {
        _showMessage("$e");
      }
      setState(() => _isLoading = false);
    } else {
      _showMessage("Enter OTP");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      backgroundColor: appBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/login_cover.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text(
                  'JOURNEYXPRO\nby OCS Services',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    elevation: 6,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Log into your Account',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Email', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                labelText: 'Enter your email',
                                border: const OutlineInputBorder(),
                                errorText: emailErrorText
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            onChanged: (value) {
                              setState(() {
                                emailErrorText = _isValidEmail(value) ? null : "Enter a valid email";
                              });
                            },
                          ),
                          if (!_showOtpField) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text('Captcha', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      generatedCaptcha,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(icon: const Icon(Icons.refresh), onPressed: generateCaptcha),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _captchaController,
                              decoration: InputDecoration(labelText: 'Enter Captcha', border: OutlineInputBorder(), errorText: isCaptchaValid ? null : 'Incorrect Captcha!'),
                            ),
                          ],
                          const SizedBox(height: 20),
                          if (!_showOtpField)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _getOtp,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                ).copyWith(
                                  backgroundColor: WidgetStateProperty.resolveWith((states) => null),
                                  foregroundColor: WidgetStateProperty.all(Colors.white),
                                  overlayColor: WidgetStateProperty.all(Colors.white10),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4D9BC6), Color(0xFF111C68)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    child: const Text(
                                      'Get OTP',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_showOtpField) ...[
                            const SizedBox(height: 20),
                            const Text('Enter OTP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
                            const SizedBox(height: 5),
                            TextField(
                              controller: _otpController,
                              decoration: const InputDecoration(labelText: 'Enter OTP', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _verifyOtp,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty.resolveWith((states) => null),
                                      foregroundColor: WidgetStateProperty.all(Colors.white),
                                      overlayColor: WidgetStateProperty.all(Colors.white10),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF4D9BC6), Color(0xFF111C68)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        child: const Text(
                                          'Submit',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _resendOtp,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty.resolveWith((states) => null),
                                      foregroundColor: WidgetStateProperty.all(Colors.white),
                                      overlayColor: WidgetStateProperty.all(Colors.white10),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF4D9BC6), Color(0xFF111C68)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        child: const Text(
                                          'Resend OTP',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    BlurLoader(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}