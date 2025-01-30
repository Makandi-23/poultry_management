import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BirdsMortalityScreen extends StatefulWidget {
  @override
  _BirdsMortalityScreenState createState() => _BirdsMortalityScreenState();
}

class _BirdsMortalityScreenState extends State<BirdsMortalityScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _batch_nameController = TextEditingController();
  final TextEditingController _causeController = TextEditingController();

  List<dynamic> _birdsMortalityList = [];
  String? _selectedId; 

  
  Future<void> _fetchBirdsMortality() async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=birdsMortality'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _birdsMortalityList = data['data'];
        });
      } else {
        print('No data available or failed to fetch.');
      }
    } else {
      print('Failed to fetch data.');
    }
  }

  
  Future<void> _saveOrUpdateBirdsMortality() async {
    if (_dateController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _batch_nameController.text.isEmpty ||
        _causeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    final endpoint = _selectedId == null
        ? 'create.php'
        : 'update.php'; 
    final url = Uri.parse(
        'https://tujengeane.co.ke/Poultry/$endpoint?module=birdsMortality&id=${_selectedId ?? ''}&date=${_dateController.text}&quantity=${_quantityController.text}&batch_name=${_batch_nameController.text}&cause=${_causeController.text}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedId == null
                ? 'Birds Mortality saved successfully!'
                : 'Birds Mortality updated successfully!'),
          ),
        );
        _fetchBirdsMortality();
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save or update birds mortality!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

  
  Future<void> _deleteBirdsMortality(BuildContext context, String id) async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=birdsMortality&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _birdsMortalityList.removeWhere((item) => item['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Birds Mortality deleted successfully!')),
        );
        _fetchBirdsMortality();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete birds mortality!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

  
  void _populateFields(dynamic item) {
    setState(() {
      _selectedId = item['id'];
      _dateController.text = item['date'];
      _quantityController.text = item['quantity'];
      _batch_nameController.text = item['batch_name'];
      _causeController.text = item['cause'];
    });
  }

 
  void _clearFields() {
    _dateController.clear();
    _quantityController.clear();
    _batch_nameController.clear();
    _causeController.clear();
    setState(() {
      _selectedId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBirdsMortality();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Birds Mortality'),
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
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _batch_nameController,
                      decoration: InputDecoration(
                        labelText: 'Batch Name',
                        prefixIcon: Icon(Icons.text_fields),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _causeController,
                      decoration: InputDecoration(
                        labelText: 'Cause',
                        prefixIcon: Icon(Icons.error_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveOrUpdateBirdsMortality,
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
                itemCount: _birdsMortalityList.length,
                itemBuilder: (context, index) {
                  final item = _birdsMortalityList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Batch: ${item['batch_name']}'),
                      subtitle: Text(
                          'Quantity: ${item['quantity']} - Cause: ${item['cause']} - Date: ${item['date']}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _populateFields(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBirdsMortality(context, item['id']),
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
