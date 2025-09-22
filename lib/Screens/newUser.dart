import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class Newuser extends StatefulWidget {
  @override
  State<Newuser> createState() {
    return _NewuserState();
  }
}

class _NewuserState extends State<Newuser> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _gender;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _namasteController = TextEditingController();
  final TextEditingController _tm2Controller = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;
  List<Map<String, dynamic>> _lookupResults = [];
  final String baseUrl = 'https://symbiomed-api.onrender.com';

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<void> _lookupSymptom(String query) async {
    print('Lookup called with query: "$query"');
    if (query.trim().isEmpty) {
      setState(() {
        _lookupResults = [];
      });
      return;
    }

    final token = await _getIdToken();
    if (token == null) {
      _showError('User  not authenticated');
      return;
    }

    final systems = [
      'http://namaste.gov.in/fhir/CodeSystem/namaste-ayurveda',
      'http://namaste.gov.in/fhir/CodeSystem/namaste-siddha',
      'http://namaste.gov.in/fhir/CodeSystem/namaste-unani',
    ];

    List<Map<String, dynamic>> allResults = [];

    try {
      for (var system in systems) {
        final uri = Uri.parse(
          '$baseUrl/lookup',
        ).replace(queryParameters: {'q': query, 'system': system});

        print('Sending GET request to: $uri');
        final response = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'];

          if (results != null &&
              results['resourceType'] == 'Parameters' &&
              results['parameter'] != null) {
            final parameters = results['parameter'] as List<dynamic>;

            String? code;
            String? display;

            for (final param in parameters) {
              if (param['name'] == 'code') {
                code = param['valueCode'];
              } else if (param['name'] == 'display') {
                display = param['valueString'];
              }
            }

            if (code != null && display != null) {
              allResults.add({'code': code, 'display': display});
            }
          } else {
            print('No valid parameters found in response for system $system');
          }
        } else if (response.statusCode == 401) {
          _showError('Unauthorized. Please login again.');
          return;
        } else {
          print('Lookup failed with status: ${response.statusCode}');
        }
      }

      setState(() {
        _lookupResults = allResults;
      });

      if (allResults.isEmpty) {
        print('No results found for query "$query" in any system.');
      }
    } catch (e, stacktrace) {
      print('Exception during lookup: $e');
      print(stacktrace);
      _showError('Lookup error: $e');
    }
  }

  Future<void> _translateNamasteToTm2() async {
    final namasteCode = _namasteController.text.trim();
    if (namasteCode.isEmpty) {
      _showError('Please select a NAMASTE code first');
      return;
    }

    final token = await _getIdToken();
    if (token == null) {
      _showError('User  not authenticated');
      return;
    }

    final url = Uri.parse('$baseUrl/translate');
    final systems = [
      'http://namaste.gov.in/fhir/CodeSystem/namaste-ayurveda',
      'http://namaste.gov.in/fhir/CodeSystem/namaste-siddha',
      'http://namaste.gov.in/fhir/CodeSystem/namaste-unani',
    ];

    List<String> tm2Codes = [];

    for (var system in systems) {
      final body = json.encode({
        "code": namasteCode,
        "system": system,
        "target": "http://id.who.int/icd/release/11/mms",
      });

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('Translate POST request to: $url');
      print('Request headers: $headers');
      print('Request body: $body');

      try {
        final response = await http.post(url, headers: headers, body: body);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final result = data['result'];

          if (result == null) {
            if (data['result'] != null &&
                data['result']['resourceType'] == 'OperationOutcome') {
              continue;
            } else {
              _showError('Unexpected response format from server.');
              return;
            }
          }

          if (result['resourceType'] == 'Parameters' &&
              result['parameter'] != null) {
            final parameters = result['parameter'] as List<dynamic>;

            for (var param in parameters) {
              if (param['name'] == 'match' && param['part'] != null) {
                final parts = param['part'] as List<dynamic>;
                final concept = parts.firstWhere(
                  (p) => p['name'] == 'concept' && p['valueCoding'] != null,
                  orElse: () => null,
                );
                if (concept != null) {
                  final code = concept['valueCoding']['code']?.toString() ?? '';
                  if (code.isNotEmpty) {
                    tm2Codes.add(code);
                  }
                }
              }
            }

            if (tm2Codes.isNotEmpty) {
              setState(() {
                _tm2Controller.text = tm2Codes.join('\n');
              });
              return;
            }
          }
        } else if (response.statusCode == 401) {
          _showError('Unauthorized. Please login again.');
          return;
        } else {
          print('Translate failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Translate error: $e');
      }
    }
    if (tm2Codes.isEmpty) {
      _showError('No translation found for code "$namasteCode" in any system.');
    }
  }

  Future<void> _savePatientDetails() async {
    if (_fullNameController.text.trim().isEmpty) {
      _showError('Full Name is required');
      return;
    }
    if (_ageController.text.trim().isEmpty) {
      _showError('Age is required');
      return;
    }
    if (_gender == null) {
      _showError('Please select a gender');
      return;
    }
    if (_namasteController.text.trim().isEmpty) {
      _showError('Please select a NAMASTE code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final token = await _getIdToken();
    if (token == null) {
      _showError('User not authenticated');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$baseUrl/fhir/Bundle');

    // --- build FHIR bundle ---
    final body = jsonEncode({
      "resourceType": "Bundle",
      "type": "collection",
      "entry": [
        {
          "resource": {
            "resourceType": "Patient",
            "id": "pat-${DateTime.now().millisecondsSinceEpoch}",
            "name": [
              {
                "given": [_fullNameController.text.trim()],
                "family": "", // optional: split last name if you want
              },
            ],
            "gender": _gender,
            "birthDate": _selectedDate?.toIso8601String().split("T").first,
          },
        },
        {
          "resource": {
            "resourceType": "Encounter",
            "id": "enc-${DateTime.now().millisecondsSinceEpoch}",
            "status": "finished",
            "class": {
              "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
              "code": "AMB",
              "display": "ambulatory",
            },
          },
        },
        {
          "resource": {
            "resourceType": "Condition",
            "id": "cond-${DateTime.now().millisecondsSinceEpoch}",
            "code": {
              "coding": [
                {
                  "system":
                      "http://namaste.gov.in/fhir/CodeSystem/namaste-ayurveda",
                  "code": _namasteController.text.trim(),
                  "display": _symptomController.text.trim(),
                },
              ],
            },
          },
        },
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Patient details saved successfully');
      } else if (response.statusCode == 401) {
        _showError('Unauthorized. Please login again.');
      } else {
        _showError(
          'Failed to save patient details: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      _showError('Error saving patient details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _symptomController.dispose();
    _namasteController.dispose();
    _tm2Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('New User Registration', style: GoogleFonts.robotoSlab()),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic Information',
                          style: GoogleFonts.robotoSlab(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Age',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder(),
                                ),
                                items: ['Male', 'Female', 'Other']
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _gender = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Height (cm)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical Information',
                          style: GoogleFonts.robotoSlab(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _symptomController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Symptoms/Disease Search',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            _lookupSymptom(val);
                          },
                        ),
                        const SizedBox(height: 15),
                        if (_lookupResults.isNotEmpty)
                          Container(
                            height: 100,
                            child: ListView.builder(
                              itemCount: _lookupResults.length,
                              itemBuilder: (context, index) {
                                final item = _lookupResults[index];
                                return ListTile(
                                  title: Text(item['display'] ?? ''),
                                  subtitle: Text(item['code'] ?? ''),
                                  onTap: () {
                                    setState(() {
                                      _namasteController.text =
                                          item['code'] ?? '';
                                      _symptomController.text =
                                          item['display'] ?? '';
                                      _lookupResults = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _namasteController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'NAMASTE Code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _translateNamasteToTm2,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text("Translate to TM2"),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _tm2Controller,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'TM2 Code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                onTap: () => _pickDate(context),
                                decoration: InputDecoration(
                                  labelText: _selectedDate == null
                                      ? "Date"
                                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                onTap: () => _pickTime(context),
                                decoration: InputDecoration(
                                  labelText: _selectedTime == null
                                      ? "Time"
                                      : _selectedTime!.format(context),
                                  prefixIcon: Icon(Icons.access_time),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Additional Notes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _savePatientDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Save Patient Details",
                        style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
