import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EggsProductionScreen extends StatefulWidget {
  @override
  _EggsProductionScreenState createState() => _EggsProductionScreenState();
}

class _EggsProductionScreenState extends State<EggsProductionScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController eggCountController = TextEditingController();
  final TextEditingController batchNameController = TextEditingController();

  List<dynamic> productionData = [];
  String? editId; 

  @override
  void initState() {
    super.initState();
    fetchProductionData(); 
  }

 
  Future<void> fetchProductionData() async {
    try {
      final response = await http.get(
        Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=eggsproduction'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          setState(() {
            productionData = data['data'];
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

  
  Future<void> saveProductionData() async {
  final date = dateController.text.trim();
  final eggCount = int.tryParse(eggCountController.text.trim());
  final batchName = batchNameController.text.trim();

  if (date.isEmpty || eggCount == null || batchName.isEmpty) {
    showSnackBar("Please fill in all fields with valid data.");
    return;
  }

  print("Saving production data with parameters: ");
  print("Date: $date, Egg Count: $eggCount, Batch Name: $batchName, Edit ID: $editId");

  try {
    final queryParameters = {
      'module': 'eggsproduction',
      'date': date,
      'egg_count': eggCount.toString(),
      'batch_name': batchName,
      if (editId != null) 'id': editId!, 
    };

    final uri = Uri.https(
      'tujengeane.co.ke',
      editId == null ? '/Poultry/create.php' : '/Poultry/update.php',
      queryParameters,
    );

    final response = await http.get(uri);
    final data = json.decode(response.body);

    print("Server response: $data"); 

    if (data['success'] == 1) {
      fetchProductionData(); 
      clearInputFields(); 
      setState(() {
        editId = null; 
      });
      showSnackBar(editId == null ? "Production entry added successfully." : "Production entry updated successfully.");
    } else {
      showSnackBar(data['message']);
    }
  } catch (e) {
    showSnackBar("Error: $e");
  }
}

  Future<void> deleteProductionData(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=eggsproduction&id=$id'),
      );
      final data = json.decode(response.body);
      if (data['success'] == 1) {
        fetchProductionData(); // Refresh data
        showSnackBar("Production entry deleted successfully.");
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
    eggCountController.clear();
    batchNameController.clear();
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

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        dateController.text = '${selectedDate.toLocal()}'.split(' ')[0]; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eggs Production'),
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
              controller: eggCountController,
              decoration: buildInputDecoration('Egg Count', Icons.egg),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: batchNameController,
              decoration: buildInputDecoration('Batch Name', Icons.text_fields),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: saveProductionData,
              child: Text(editId == null ? "Add Production" : "Update Production"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: productionData.length,
                itemBuilder: (context, index) {
                  final production = productionData[index];
                  return Card(
                    child: ListTile(
                      title: Text("Batch: ${production['batch_name']}"),
                      subtitle: Text("Egg Count: ${production['egg_count']} - Date: ${production['date']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.purple),
                            onPressed: () {
                              setState(() {
                                editId = production['id'];
                              });
                              dateController.text = production['date']; 
                              eggCountController.text = production['egg_count'].toString();
                              batchNameController.text = production['batch_name'];
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteProductionData(production['id']),
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
}
