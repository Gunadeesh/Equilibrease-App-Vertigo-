import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'config.dart'; // Importing config.dart

class PatientLogin extends StatefulWidget {
  @override
  _PatientLoginState createState() => _PatientLoginState();
}

class _PatientLoginState extends State<PatientLogin> {
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio dio = Dio();

  bool _passwordVisible = false;

  void _handleLogin() async {
    String patientId = _patientIdController.text.trim();
    String password = _passwordController.text.trim();

    if (patientId.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await dio.get(Config.login, queryParameters: {
          'patientId': patientId,
          'password': password,
        });

        if (response.data['success'] == true) {
          print('Login successful, navigating to PatientDrawer');
          Get.toNamed('/PatientDrawer', arguments: {'patientId': patientId});
        } else {
          _showAlert(response.data['error'] ?? 'Invalid Patient ID or Password. Please try again.');
        }
      } catch (e) {
        print('Error during patient login: $e');
        _showAlert('Invalid Patient ID or Password. Please try again.');
      }
    } else {
      _showAlert('Please enter both Patient ID and Password.');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double windowWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFC5EDFE),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Image.asset('assets/backarrow.png'),
                iconSize: 40,
                onPressed: () {
                  Navigator.pushNamed(context, '/DoctorPatient');
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: windowWidth * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5EDFE),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "PATIENT'S LOGIN",
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/patient.png',
                        width: windowWidth * 0.5,
                        height: windowWidth * 0.5,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _patientIdController,
                        decoration: const InputDecoration(
                          hintText: 'Patient ID *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password *',
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: _handleLogin,
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: () {
                          Get.toNamed('/PatientDrawer', arguments: {'patientId': 'guest'});
                        },
                        child: const Text(
                          'Guest',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
