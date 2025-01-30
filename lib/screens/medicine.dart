import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicineScreen extends StatefulWidget {
  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _batchNameController = TextEditingController();

  List<dynamic> _medicineList = [];
  String? _selectedId; 

  
  Future<void> _fetchMedicineData() async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=medicine'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _medicineList = data['data'];
        });
      } else {
        print('No data available .');
      }
    } else {
      print('Failed to fetch data.');
    }
  }

  Future<void> _saveOrUpdateMedicine() async {
    if (_dateController.text.isEmpty ||
        _medicineNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _batchNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    final endpoint = _selectedId == null ? 'create.php' : 'update.php';
    final url = Uri.parse(
        'https://tujengeane.co.ke/Poultry/$endpoint?module=medicine&id=${_selectedId ?? ''}&date=${_dateController.text}&medicine_name=${_medicineNameController.text}&quantity=${_quantityController.text}&amount=${_amountController.text}&batch_name=${_batchNameController.text}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedId == null
                ? 'Medicine record saved successfully!'
                : 'Medicine record updated successfully!'),
          ),
        );
        _fetchMedicineData();
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

  // Delete medicine entry
  Future<void> _deleteMedicine(BuildContext context, String id) async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=medicine&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _medicineList.removeWhere((item) => item['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medicine record deleted successfully!')),
        );
        _fetchMedicineData();
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

  void _populateFields(dynamic item) {
    setState(() {
      _selectedId = item['id'];
      _dateController.text = item['date'];
      _medicineNameController.text = item['medicine_name'];
      _quantityController.text = item['quantity'];
      _amountController.text = item['amount'];
      _batchNameController.text = item['batch_name'];
    });
  }


  void _clearFields() {
    _dateController.clear();
    _medicineNameController.clear();
    _quantityController.clear();
    _amountController.clear();
    _batchNameController.clear();
    setState(() {
      _selectedId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMedicineData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Records'),
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
                      controller: _medicineNameController,
                      decoration: InputDecoration(
                        labelText: 'Medicine Name',
                        prefixIcon: Icon(Icons.medical_services),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _batchNameController,
                      decoration: InputDecoration(
                        labelText: 'Batch Name',
                        prefixIcon: Icon(Icons.text_fields),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveOrUpdateMedicine,
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
                itemCount: _medicineList.length,
                itemBuilder: (context, index) {
                  final item = _medicineList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Medicine: ${item['medicine_name']}'),
                      subtitle: Text(
                          'Quantity: ${item['quantity']} - Amount: ${item['amount']} - Date: ${item['date']}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _populateFields(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMedicine(context, item['id']),
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
