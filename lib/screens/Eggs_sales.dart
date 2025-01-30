import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EggsSalesScreen extends StatefulWidget {
  @override
  _EggsSalesScreenState createState() => _EggsSalesScreenState();
}

class _EggsSalesScreenState extends State<EggsSalesScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();

  List<dynamic> salesData = [];
  String? editId;

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      final response = await http.get(
        Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=eggssales'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          setState(() {
            salesData = data['data'];
          });
        } else {
          showSnackBar(data['message']);
        }
      } else {
        showSnackBar("Failed to load data. Server error.");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }
  }

  Future<void> deleteSales(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=eggssales&id=$id'),
      );
      final data = json.decode(response.body);
      if (data['success'] == 1) {
        fetchSalesData(); 
        showSnackBar("Sales entry deleted successfully.");
      } else {
        showSnackBar(data['message']);
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }
  }

  Future<void> saveSales() async {
    final date = dateController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim());
    final pricePerUnit = double.tryParse(pricePerUnitController.text.trim());
    final totalAmount = double.tryParse(totalAmountController.text.trim());
    final customerName = customerNameController.text.trim();

    if (date.isEmpty || quantity == null || pricePerUnit == null || totalAmount == null || customerName.isEmpty) {
      showSnackBar("Please fill in all fields with valid data.");
      return;
    }

    try {
      final queryParameters = {
        'module': 'eggssales',
        'date': date,
        'quantity': quantity.toString(),
        'price_per_unit': pricePerUnit.toString(),
        'totalAmount': totalAmount.toString(),
        'customerName': customerName,
        if (editId != null) 'id': editId!
      };

      final uri = Uri.https(
        'tujengeane.co.ke',
        editId == null ? '/Poultry/create.php' : '/Poultry/update.php',
        queryParameters,
      );

      final response = await http.get(uri);
      final data = json.decode(response.body);

      if (data['success'] == 1) {
        fetchSalesData();
        clearInputFields();
        setState(() {
          editId = null;
        });
        showSnackBar(editId == null ? "Sales entry added successfully." : "Sales entry updated successfully.");
      } else {
        showSnackBar(data['message']);
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  void clearInputFields() {
    dateController.clear();
    quantityController.clear();
    pricePerUnitController.clear();
    totalAmountController.clear();
    customerNameController.clear();
  }

  void calculateTotalAmount() {
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final pricePerUnit = double.tryParse(pricePerUnitController.text) ?? 0.0;
    final totalAmount = quantity * pricePerUnit;

    totalAmountController.text = totalAmount.toStringAsFixed(2);
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Eggs Sales',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(  
                child: TextField(
                  controller: dateController,
                  decoration: buildInputDecoration('Date', Icons.calendar_today),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: quantityController,
              decoration: buildInputDecoration('Quantity', Icons.production_quantity_limits),
              keyboardType: TextInputType.number,
              onChanged: (_) => calculateTotalAmount(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: pricePerUnitController,
              decoration: buildInputDecoration('Price per Unit', Icons.attach_money),
              keyboardType: TextInputType.number,
              onChanged: (_) => calculateTotalAmount(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: totalAmountController,
              decoration: buildInputDecoration('Total Amount', Icons.calculate),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: customerNameController,
              decoration: buildInputDecoration('Customer Name', Icons.person),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: saveSales,
              child: Text(editId == null ? "Add Sales" : "Update Sales"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: salesData.length,
                itemBuilder: (context, index) {
                  final sale = salesData[index];
                  return Card(
                    child: ListTile(
                      title: Text("Customer: ${sale['customerName']}"),
                      subtitle: Text("Quantity: ${sale['quantity']} - Date: ${sale['date']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.purple),
                            onPressed: () {
                              setState(() {
                                editId = sale['id'];
                              });
                              dateController.text = sale['date'];
                              quantityController.text = sale['quantity'].toString();
                              pricePerUnitController.text = sale['price_per_unit'].toString();
                              totalAmountController.text = sale['totalAmount'].toString();
                              customerNameController.text = sale['customerName'];
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteSales(sale['id']),
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
        dateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }
}
