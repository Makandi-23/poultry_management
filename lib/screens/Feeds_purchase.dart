import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedsPurchaseScreen extends StatefulWidget {
  @override
  _FeedsPurchaseScreenState createState() => _FeedsPurchaseScreenState();
}

class _FeedsPurchaseScreenState extends State<FeedsPurchaseScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _feedTypeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _pricePerUnitController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  List<dynamic> _feedsPurchaseList = [];
  String? _selectedId;

 
  void _updateTotalCost() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final pricePerUnit = double.tryParse(_pricePerUnitController.text) ?? 0;
    final totalCost = quantity * pricePerUnit;

    setState(() {
      _totalCostController.text = totalCost.toStringAsFixed(2);
    });
  }

  
  Future<void> _fetchFeedsPurchase() async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=feedsPurchase'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _feedsPurchaseList = data['data'];
        });
      } else {
        print('No data available.');
      }
    } else {
      print('Failed to fetch data.');
    }
  }

  
  Future<void> _saveOrUpdateFeedsPurchase() async {
    if (_dateController.text.isEmpty ||
        _feedTypeController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _pricePerUnitController.text.isEmpty ||
        _supplierNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    final endpoint = _selectedId == null ? 'create.php' : 'update.php';
    final url = Uri.parse(
        'https://tujengeane.co.ke/Poultry/$endpoint?module=feedsPurchase&id=${_selectedId ?? ''}'
        '&date=${_dateController.text}&feed_type=${_feedTypeController.text}'
        '&quantity=${_quantityController.text}&price_per_unit=${_pricePerUnitController.text}'
        '&total_cost=${_totalCostController.text}&supplier_name=${_supplierNameController.text}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedId == null
                ? 'Feeds Purchase saved successfully!'
                : 'Feeds Purchase updated successfully!'),
          ),
        );
        _fetchFeedsPurchase();
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save or update feeds purchase!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

  // Delete entry
  Future<void> _deleteFeedsPurchase(BuildContext context, String id) async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=feedsPurchase&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _feedsPurchaseList.removeWhere((item) => item['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feeds Purchase deleted successfully!')),
        );
        _fetchFeedsPurchase();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete feeds purchase!')),
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
      _feedTypeController.text = item['feed_type'];
      _quantityController.text = item['quantity'];
      _pricePerUnitController.text = item['price_per_unit'];
      _supplierNameController.text = item['supplier_name'];
      _totalCostController.text = item['total_cost'];
    });
  }

 
  void _clearFields() {
    _dateController.clear();
    _feedTypeController.clear();
    _quantityController.clear();
    _pricePerUnitController.clear();
    _supplierNameController.clear();
    _totalCostController.clear();
    setState(() {
      _selectedId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFeedsPurchase();
    _quantityController.addListener(_updateTotalCost);
    _pricePerUnitController.addListener(_updateTotalCost);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_updateTotalCost);
    _pricePerUnitController.removeListener(_updateTotalCost);
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeds Purchase'),
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
                      controller: _feedTypeController,
                      decoration: InputDecoration(
                        labelText: 'Feed Type',
                        prefixIcon: Icon(Icons.feed),
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
                      controller: _pricePerUnitController,
                      decoration: InputDecoration(
                        labelText: 'Price per Unit',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _totalCostController,
                      decoration: InputDecoration(
                        labelText: 'Total Cost',
                        prefixIcon: Icon(Icons.calculate),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      readOnly: true,
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
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveOrUpdateFeedsPurchase,
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
                itemCount: _feedsPurchaseList.length,
                itemBuilder: (context, index) {
                  final item = _feedsPurchaseList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Feed Type: ${item['feed_type']}'),
                      subtitle: Text(
                          'Quantity: ${item['quantity']} - Total Cost: ${item['total_cost']} - Date: ${item['date']} - Supplier: ${item['supplier_name']}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _populateFields(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFeedsPurchase(context, item['id']),
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
