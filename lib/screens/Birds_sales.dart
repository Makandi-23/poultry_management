import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BirdsSalesScreen extends StatefulWidget {
  @override
  _BirdsSalesScreenState createState() => _BirdsSalesScreenState();
}

class _BirdsSalesScreenState extends State<BirdsSalesScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _pricePerBirdController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  List<dynamic> _birdsSalesList = [];
  String? _selectedid;

  @override
  void initState() {
    super.initState();
    _fetchBirdsSales();
  }

  // Fetch birds sales data from the server
  Future<void> _fetchBirdsSales() async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=birdsSale'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _birdsSalesList = data['data'];
        });
      } else {
        print('No data available.');
      }
    } else {
      print('Failed to fetch data.');
    }
  }

 
  Future<void> _saveOrUpdateBirdsSales() async {
    if (_dateController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _pricePerBirdController.text.isEmpty ||
        _customerNameController.text.isEmpty ||
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    final totalCost =
        int.parse(_quantityController.text) * double.parse(_pricePerBirdController.text);

    final endpoint = _selectedid == null ? 'create.php' : 'update.php';
    final url = Uri.parse(
        'https://tujengeane.co.ke/Poultry/$endpoint?module=birdsSale&id=${_selectedid ?? ''}&date=${_dateController.text}&quantity=${_quantityController.text}&price_per_bird=${_pricePerBirdController.text}&total_cost=$totalCost&customer_name=${_customerNameController.text}&age=${_ageController.text}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedid == null
                ? 'Birds Sale saved successfully!'
                : 'Birds Sale updated successfully!'),
          ),
        );
        _fetchBirdsSales();
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save or update birds sale!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

  // Delete a sale
  Future<void> _deleteBirdsSales(BuildContext context, String id) async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=birdsSale&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _birdsSalesList.removeWhere((item) => item['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Birds Sale deleted successfully!')),
        );
        _fetchBirdsSales();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete birds sale!')),
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
      _selectedid = item['id'];
      _dateController.text = item['date'];
      _quantityController.text = item['quantity'];
      _pricePerBirdController.text = item['price_per_bird'];
      _totalCostController.text = item['total_cost'];
      _customerNameController.text = item['customer_name'];
      _ageController.text = item['age'];
    });
  }

  void _clearFields() {
    _dateController.clear();
    _quantityController.clear();
    _pricePerBirdController.clear();
    _totalCostController.clear();
    _customerNameController.clear();
    _ageController.clear();
    setState(() {
      _selectedid = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Birds Sales'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
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
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity of birds',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _pricePerBirdController,
                      decoration: InputDecoration(
                        labelText: 'Price per Bird',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (_quantityController.text.isNotEmpty) {
                          final total = int.parse(_quantityController.text) *
                              double.parse(_pricePerBirdController.text);
                          _totalCostController.text = total.toStringAsFixed(2);
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _totalCostController,
                      decoration: InputDecoration(
                        labelText: 'Total Cost',
                        prefixIcon: Icon(Icons.calculate),
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.timeline),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveOrUpdateBirdsSales,
                      icon: Icon(Icons.save),
                      label: Text(_selectedid == null ? 'Save' : 'Update'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _birdsSalesList.length,
                itemBuilder: (context, index) {
                  final item = _birdsSalesList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Customer: ${item['customer_name']}'),
                      subtitle: Text(
                          'Quantity: ${item['quantity']} - Total Cost: ${item['total_cost']} - Date: ${item['date']}'),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _populateFields(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBirdsSales(context, item['id']),
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
        _dateController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }
}
