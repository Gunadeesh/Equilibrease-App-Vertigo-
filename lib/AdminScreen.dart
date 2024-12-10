import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'config.dart'; // Import the config file

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController doctorIDController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isDinesh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showAccessAlert());
  }

  Future<void> _showAccessAlert() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing without action
      builder: (context) => AlertDialog(
        title: const Text('Access Restricted'),
        content: const Text(
            'Only Doctor Dinesh has access and authority to add other doctors. Please consult Dr. Dinesh Ram.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isDinesh = true; // Grant access if they confirm
              });
              Navigator.pop(context);
            },
            child: const Text('I am Dr. Dinesh'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Navigate back if not authorized
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> handleAddDoctor() async {
    final String doctorID = doctorIDController.text;
    final String name = nameController.text;
    final String password = passwordController.text;

    if (doctorID.isNotEmpty && name.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(Config.adminAddDoctor),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'doctor_ID': doctorID,
            'name': name,
            'password': password,
          },
        );

        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          _showAlert('Success', 'Doctor added successfully!', shouldPop: true);
        } else {
          _showAlert('Error', responseData['error'] ?? 'Failed !.Please use Special Key in DoctorId for successful creation.');
        }
      } catch (error) {
        print('Error during adding doctor: $error');
        _showAlert('Error', 'An error occurred. Please try again later.');
      }
    } else {
      _showAlert('Warning', 'Please fill all fields.');
    }
  }

  void _showAlert(String title, String message, {bool shouldPop = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close alert dialog
              if (shouldPop) Navigator.pop(context); // Navigate back if required
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5EDFE),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Arrow
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.asset(
                    'assets/backarrow.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Add Doctor Title Container
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Add Doctor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_isDinesh)
              // Form Container
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: doctorIDController,
                        decoration: const InputDecoration(
                          labelText: 'Doctor ID *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: handleAddDoctor,
                        child: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
