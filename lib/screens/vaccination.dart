import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VaccinationScreen extends StatefulWidget {
  @override
  _VaccinationScreenState createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _administeredByController = TextEditingController();

  List<dynamic> _vaccinationList = [];
  String? _selectedId; // To track the currently selected record for editing

  // Fetch data from the server
  Future<void> _fetchVaccinationData() async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=vaccination'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _vaccinationList = data['data'];
        });
      } else {
        print('No data available.');
      }
    } else {
      print('Failed to fetch data.');
    }
  }

  // Save or update vaccination data
  Future<void> _saveOrUpdateVaccination() async {
    if (_dateController.text.isEmpty ||
        _vaccineNameController.text.isEmpty ||
        _batchNameController.text.isEmpty ||
        _costController.text.isEmpty ||
        _administeredByController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    final endpoint = _selectedId == null ? 'create.php' : 'update.php';
    final url = Uri.parse(
      'https://tujengeane.co.ke/Poultry/$endpoint?module=vaccination&id=${_selectedId ?? ''}&date=${_dateController.text}&vaccine_name=${_vaccineNameController.text}&batch_name=${_batchNameController.text}&cost=${_costController.text}&administered_by=${_administeredByController.text}'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedId == null
                ? 'Vaccination record saved successfully!'
                : 'Vaccination record updated successfully!'),
          ),
        );
        _fetchVaccinationData();
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save or update the record!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

  // Delete vaccination entry
  Future<void> _deleteVaccination(BuildContext context, String id) async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=vaccination&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _vaccinationList.removeWhere((item) => item['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vaccination record deleted successfully!')),
        );
        _fetchVaccinationData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete the record!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

  // Populate fields for editing
  void _populateFields(dynamic item) {
    setState(() {
      _selectedId = item['id'];
      _dateController.text = item['date'];
      _vaccineNameController.text = item['vaccine_name'];
      _batchNameController.text = item['batch_name'];
      _costController.text = item['cost'];
      _administeredByController.text = item['administered_by'];
    });
  }

  // Clear input fields
  void _clearFields() {
    _dateController.clear();
    _vaccineNameController.clear();
    _batchNameController.clear();
    _costController.clear();
    _administeredByController.clear();
    setState(() {
      _selectedId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchVaccinationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vaccination Records'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _vaccineNameController,
                      decoration: InputDecoration(
                        labelText: 'Vaccine Name',
                        prefixIcon: Icon(Icons.local_hospital),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _batchNameController,
                      decoration: InputDecoration(
                        labelText: 'Batch Name',
                        prefixIcon: Icon(Icons.batch_prediction),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: 'Cost',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _administeredByController,
                      decoration: InputDecoration(
                        labelText: 'Administered By',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveOrUpdateVaccination,
                      icon: Icon(Icons.save),
                      label: Text(_selectedId == null ? 'Save' : 'Update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _vaccinationList.length,
                itemBuilder: (context, index) {
                  final item = _vaccinationList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Vaccine: ${item['vaccine_name']}'),
                      subtitle: Text(
                          'Batch: ${item['batch_name']} - Cost: ${item['cost']} - Date: ${item['date']}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.purple),
                            onPressed: () => _populateFields(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteVaccination(context, item['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }
}
