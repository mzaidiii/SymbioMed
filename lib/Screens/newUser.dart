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

  // Base API URL
  final String baseUrl = 'https://symbiomed-api.onrender.com';

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<void> _lookupSymptom(String query) async {
    print('Lookup called with query: $query');
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

    final uri = Uri.parse('$baseUrl/lookup').replace(
      queryParameters: {
        'q': query,
        'system': 'http://namaste.gov.in/fhir/CodeSystem/namaste-ayurveda',
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Lookup response status: ${response.statusCode}');
      print('Lookup response body: ${response.body}');

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
            setState(() {
              _lookupResults = [
                {'code': code, 'display': display},
              ];
            });
          } else {
            setState(() {
              _lookupResults = [];
            });
          }
        } else if (results != null &&
            results['resourceType'] == 'OperationOutcome') {
          setState(() {
            _lookupResults = [];
          });
        } else {
          setState(() {
            _lookupResults = [];
          });
        }
      } else if (response.statusCode == 401) {
        _showError('Unauthorized. Please login again.');
      } else {
        _showError('Lookup failed: ${response.statusCode}');
      }
    } catch (e) {
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
    final body = json.encode({
      "code": namasteCode,
      "system": "http://namaste.gov.in/fhir/CodeSystem/namaste-ayurveda",
      "target": "http://id.who.int/icd/release/11/mms",
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['resourceType'] == 'Parameters' && data['parameter'] != null) {
          final matches = data['parameter']
              .where((p) => p['name'] == 'match')
              .toList();

          if (matches.isNotEmpty) {
            final concept = matches[0]['part'].firstWhere(
              (part) => part['name'] == 'concept',
              orElse: () => null,
            );
            if (concept != null && concept['valueCoding'] != null) {
              final tm2Code = concept['valueCoding']['code'] ?? '';
              setState(() {
                _tm2Controller.text = tm2Code;
              });
              return;
            }
          }
        }
        _showError('No translation found');
      } else if (response.statusCode == 401) {
        _showError('Unauthorized. Please login again.');
      } else {
        _showError('Translate failed: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Translate error: $e');
    }
  }

  Future<void> _savePatientDetails() async {
    final fullName = _fullNameController.text.trim();
    final ageStr = _ageController.text.trim();
    final gender = _gender;
    final heightStr = _heightController.text.trim();
    final weightStr = _weightController.text.trim();
    final symptom = _symptomController.text.trim();
    final namasteCode = _namasteController.text.trim();
    final tm2Code = _tm2Controller.text.trim();
    final notes = _notesController.text.trim();

    if (fullName.isEmpty ||
        ageStr.isEmpty ||
        gender == null ||
        namasteCode.isEmpty ||
        tm2Code.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      _showError('Please fill all required fields and select date/time');
      return;
    }

    final age = int.tryParse(ageStr);
    final height = double.tryParse(heightStr);
    final weight = double.tryParse(weightStr);

    if (age == null) {
      _showError('Invalid age');
      return;
    }

    final token = await _getIdToken();
    if (token == null) {
      _showError('User  not authenticated');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final patientId = fullName.toLowerCase().replaceAll(' ', '_') + '_id';

    final bundle = {
      "resourceType": "Bundle",
      "type": "collection",
      "entry": [
        {
          "resource": {
            "resourceType": "Patient",
            "id": patientId,
            "name": [
              {
                "given": [fullName.split(' ').first],
                "family": fullName.split(' ').length > 1
                    ? fullName.split(' ').sublist(1).join(' ')
                    : '',
              },
            ],
            "gender": gender.toLowerCase(),
            "birthDate": _calculateBirthDate(age),
          },
        },
        {
          "resource": {
            "resourceType": "Encounter",
            "id": "enc_${DateTime.now().millisecondsSinceEpoch}",
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
            "id": "cond_${DateTime.now().millisecondsSinceEpoch}",
            "code": {
              "coding": [
                {
                  "system":
                      "http://namaste.gov.in/fhir/CodeSystem/namaste-ayurveda",
                  "code": namasteCode,
                  "display": symptom.isNotEmpty ? symptom : "NAMASTE code",
                },
              ],
            },
            "note": [
              {"text": notes},
            ],
          },
        },
      ],
    };

    final url = Uri.parse('$baseUrl/fhir/Bundle?dryRun=true');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(bundle),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSuccess('Patient details saved successfully (dry run)');
      } else if (response.statusCode == 401) {
        _showError('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        _showError('Bad request. Please check your data.');
      } else {
        _showError('Save failed: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Save error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _calculateBirthDate(int age) {
    final now = DateTime.now();
    final birthYear = now.year - age;
    return DateTime(birthYear, 1, 1).toIso8601String().split('T').first;
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
}
