import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: SettingsBody(),
    );
  }
}

class SettingsBody extends StatefulWidget {
  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change Password Section
          Text(
            "Change Password",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildTextField(
            controller: _currentPasswordController,
            hint: 'Current Password',
            icon: Icons.lock,
            obscureText: true,
          ),
          SizedBox(height: 10),
          _buildTextField(
            controller: _newPasswordController,
            hint: 'New Password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _updatePassword(),
            icon: Icon(Icons.save),
            label: Text('Update Password'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          // Contact Us Section
          Text(
            "Contact Us",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
         _buildContactRow(FontAwesomeIcons.whatsapp, 'WhatsApp', 'https://wa.me/1234567890'),
_buildContactRow(FontAwesomeIcons.instagram, 'Instagram', 'https://instagram.com/featherhub'),
_buildContactRow(FontAwesomeIcons.twitter, 'Twitter', 'https://twitter.com/featherhub'),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purple),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String name, String url) {
    return GestureDetector(
      onTap: () => _openLink(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple),
            SizedBox(width: 10),
            Text(name, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _openLink(String url) async {
    // Handle link opening (use the url_launcher package for real functionality)
    print("Opening: $url");
  }

  void _updatePassword() async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email'); // Assume email is stored during login

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No email found. Please log in again.')),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://tujengeane.co.ke/Poultry/updatepassword.php?email=$email&current_password=$currentPassword&new_password=$newPassword'));

      final data = json.decode(response.body);

      if (data['success']) {
        // Save new password locally in SharedPreferences
        await prefs.setString('password', newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password')),
      );
    }
  }
}
