import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BirdsPurchaseScreen extends StatefulWidget {
  @override
  _BirdsPurchaseScreenState createState() => _BirdsPurchaseScreenState();
}

class _BirdsPurchaseScreenState extends State<BirdsPurchaseScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _pricePerUnitController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  List<dynamic> _birdsPurchaseList = [];
  String _editingId = '';
  Future<void> _fetchBirdsPurchase() async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=birdspurchase'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _birdsPurchaseList = data['data'];
        });
      } else {
        print('No data available or failed to fetch.');
      }
    } else {
      print('Failed to fetch data.');
    }
  }

  
  Future<void> _saveBirdsPurchase() async {
    if (_dateController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _batchNameController.text.isEmpty ||
        _supplierNameController.text.isEmpty ||
        _pricePerUnitController.text.isEmpty ||
        _totalCostController.text.isEmpty ||
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    String url = '';
    if (_editingId.isEmpty) {
      
      url = 'https://tujengeane.co.ke/Poultry/create.php?module=birdspurchase&date=${_dateController.text}&quantity=${_quantityController.text}&batch_name=${_batchNameController.text}&supplierName=${_supplierNameController.text}&price_per_unit=${_pricePerUnitController.text}&total_cost=${_totalCostController.text}&age=${_ageController.text}';
    } else {
     
      url = 'https://tujengeane.co.ke/Poultry/update.php?module=birdspurchase&id=$_editingId&date=${_dateController.text}&quantity=${_quantityController.text}&batch_name=${_batchNameController.text}&supplierName=${_supplierNameController.text}&price_per_unit=${_pricePerUnitController.text}&total_cost=${_totalCostController.text}&age=${_ageController.text}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Birds Purchase saved/updated successfully!')),
        );
        _fetchBirdsPurchase();
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save/update birds purchase!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

 
  Future<void> _deleteBirdsPurchase(BuildContext context, String id) async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=birdspurchase&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _birdsPurchaseList.removeWhere((item) => item['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Birds Purchase deleted successfully!')),
        );
        _fetchBirdsPurchase();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete birds purchase!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

 
  void _clearFields() {
    _dateController.clear();
    _quantityController.clear();
    _batchNameController.clear();
    _supplierNameController.clear();
    _pricePerUnitController.clear();
    _totalCostController.clear();
    _ageController.clear();
    _editingId = ''; 
  }

 
  void _calculateTotalCost() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final pricePerUnit = double.tryParse(_pricePerUnitController.text) ?? 0;

    final totalCost = quantity * pricePerUnit;

    setState(() {
      _totalCostController.text = totalCost.toStringAsFixed(2);
    });
  }

  @override
  void initState() {
    super.initState();

   
    _quantityController.addListener(_calculateTotalCost);
    _pricePerUnitController.addListener(_calculateTotalCost);
    _fetchBirdsPurchase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Birds Purchase'),
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
                      controller: _batchNameController,
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
                      controller: _supplierNameController,
                      decoration: InputDecoration(
                        labelText: 'Supplier Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _pricePerUnitController,
                      decoration: InputDecoration(
                        labelText: 'Price per Unit',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _totalCostController,
                      decoration: InputDecoration(
                        labelText: 'Total Cost',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      readOnly: true,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.accessibility_new),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveBirdsPurchase,
                      child: Text(_editingId.isEmpty ? 'Save' : 'Update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _birdsPurchaseList.length,
                itemBuilder: (context, index) {
                  final purchase = _birdsPurchaseList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Batch: ${purchase['batch_name']}'),
                      subtitle: Text('Supplier: ${purchase['supplierName']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _editingId = purchase['id'];
                                _dateController.text = purchase['date'];
                                _quantityController.text = purchase['quantity'].toString();
                                _batchNameController.text = purchase['batch_name'];
                                _supplierNameController.text = purchase['supplierName'];
                                _pricePerUnitController.text = purchase['price_per_unit'].toString();
                                _totalCostController.text = purchase['total_cost'].toString();
                                _ageController.text = purchase['age'].toString();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,color: Colors.red),
                            onPressed: () => _deleteBirdsPurchase(context, purchase['id']),
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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = '${selectedDate.toLocal()}'.split(' ')[0];
      });
    }
  }
}
