import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayrollScreen extends StatefulWidget {
  @override
  _PayrollScreenState createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  List<dynamic> _payrollList = [];
  String? _selectedId; // To track the currently selected record for editing

  // Fetch payroll data from the server
  Future<void> _fetchPayrollData() async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/get_data.php?module=payroll'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _payrollList = data['data'];
        });
      } else {
        print('No data available.');
      }
    } else {
      print('Failed to fetch data.');
    }
  }

  // Save or update payroll data
  Future<void> _saveOrUpdatePayroll() async {
    if (_dateController.text.isEmpty ||
        _employeeNameController.text.isEmpty ||
        _positionController.text.isEmpty ||
        _salaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    final endpoint = _selectedId == null ? 'create.php' : 'update.php';
    final url = Uri.parse(
        'https://tujengeane.co.ke/Poultry/$endpoint?module=payroll&id=${_selectedId ?? ''}&date_paid=${_dateController.text}&employee_name=${_employeeNameController.text}&position=${_positionController.text}&salary=${_salaryController.text}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedId == null
                ? 'Payroll record saved successfully!'
                : 'Payroll record updated successfully!'),
          ),
        );
        _fetchPayrollData();
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

  // Delete payroll entry
  Future<void> _deletePayroll(BuildContext context, String id) async {
    final response = await http.get(
      Uri.parse('https://tujengeane.co.ke/Poultry/delete.php?module=payroll&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        setState(() {
          _payrollList.removeWhere((item) => item['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payroll record deleted successfully!')),
        );
        _fetchPayrollData();
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
      _dateController.text = item['date_paid'];
      _employeeNameController.text = item['employee_name'];
      _positionController.text = item['position'];
      _salaryController.text = item['salary'];
    });
  }

  // Clear input fields
  void _clearFields() {
    _dateController.clear();
    _employeeNameController.clear();
    _positionController.clear();
    _salaryController.clear();
    setState(() {
      _selectedId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPayrollData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payroll Records'),
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
                            labelText: 'Date Paid',
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
                      controller: _employeeNameController,
                      decoration: InputDecoration(
                        labelText: 'Employee Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _positionController,
                      decoration: InputDecoration(
                        labelText: 'Position',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _salaryController,
                      decoration: InputDecoration(
                        labelText: 'Salary',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveOrUpdatePayroll,
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
                itemCount: _payrollList.length,
                itemBuilder: (context, index) {
                  final item = _payrollList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Employee: ${item['employee_name']}'),
                      subtitle: Text(
                          'Position: ${item['position']} - Salary: ${item['salary']} - Date Paid: ${item['date_paid']}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _populateFields(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePayroll(context, item['id']),
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
