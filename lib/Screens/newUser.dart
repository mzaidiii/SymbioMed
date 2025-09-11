import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Newuser extends StatefulWidget {
  @override
  State<Newuser> createState() {
    return _NewuserState();
  }
}

class _NewuserState extends State<Newuser> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _namasteController = TextEditingController();
  final TextEditingController _tm2Controller = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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
                                decoration: InputDecoration(
                                  labelText: 'Age',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
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
                                onChanged: (val) {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Height (cm)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
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
                            onPressed: () {
                              setState(() {
                                _tm2Controller.text = "TM2-XXXX";
                              });
                            },
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
              ElevatedButton(
                onPressed: () {
                  // later: save data to backend
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
