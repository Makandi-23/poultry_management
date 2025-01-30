import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poultry_management/screens/Birds_mortality.dart';
import 'package:poultry_management/screens/Birds_purchase.dart';
import 'package:poultry_management/screens/Birds_sales.dart';
import 'package:poultry_management/screens/Eggs_production.dart';
import 'package:poultry_management/screens/Eggs_sales.dart';
import 'package:poultry_management/screens/Feeds_purchase.dart';
import 'package:poultry_management/screens/Orders.dart';
import 'package:poultry_management/screens/medicine.dart';
import 'package:poultry_management/screens/payroll.dart';
import 'package:poultry_management/screens/settings.dart';
import 'package:poultry_management/screens/profile.dart';
import 'package:poultry_management/screens/vaccination.dart';
import 'package:poultry_management/theme/theme.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: DashboardScreen(),
      routes: {
        '/eggsProduction': (context) => EggsProductionScreen(),
        '/eggsSales': (context) => EggsSalesScreen(),
        '/birdsPurchase': (context) => BirdsPurchaseScreen(),
        '/birdsMortality': (context) => BirdsMortalityScreen(),
        '/birdsSales': (context) => BirdsSalesScreen(),
        '/feedPurchase': (context) => FeedsPurchaseScreen(),
        '/medicine': (context) => MedicineScreen(),
        '/vaccination': (context) => VaccinationScreen(),
        '/payroll': (context) => PayrollScreen(),
        '/settings': (context) => SettingsScreen(),
       '/profile': (context) => ProfileScreen(),
        '/orders': (context) => OrdersScreen(),
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
   String? userId;

  String noOfBirds = "-";
  String mortalityRate = "-";
  String noOfEggs = "-";
  String noOfEmployees = "-";
  List<dynamic> recentOrders = [];

  @override
  void initState() {
    super.initState();
    fetchMetrics();
    fetchOrders();
    
  }

  Future<void> fetchMetrics() async {
    const String apiUrl = "https://tujengeane.co.ke/Poultry/metricsdata.php";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          setState(() {
            noOfBirds = data['data']['birds'].toString();
            mortalityRate = "${data['data']['mortality_rate'] ?? "0"}%";
            noOfEggs = data['data']['eggs'].toString();
            noOfEmployees = data['data']['employees'].toString();
          });
        }
      }
    } catch (e) {
      print("Error fetching metrics: $e");
    }
  }

  Future<void> fetchOrders() async {
    const String apiUrl = "https://tujengeane.co.ke/Poultry/getorders.php";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          setState(() {
            recentOrders = data['orders'];
          });
        }
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

 void _onTabTapped(int index) {
  if (index == 1) {
    _showQuickActions();
  } else if (index == 2) {
   
    Navigator.pushNamed(
      context,
      '/profile', 
       
    );
  } else {
    setState(() {
      _currentIndex = index;
    });
  }
}

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildActionCard(Icons.egg, 'Eggs Production'),
                    _buildActionCard(Icons.shopping_cart, 'Eggs Sales'),
                    _buildActionCard(Icons.add_shopping_cart, 'Birds Purchase'),
                    _buildActionCard(Icons.warning, 'Birds Mortality'),
                    _buildActionCard(Icons.sell, 'Birds Sales'),
                    _buildActionCard(Icons.shopping_bag, 'Feed Purchase'),
                   
                    _buildActionCard(Icons.medical_services, 'Medicine'),
                    _buildActionCard(Icons.vaccines, 'Vaccination'),
                    _buildActionCard(Icons.payments, 'Payroll'),
                    _buildActionCard(Icons.settings, 'Settings'),
                    _buildActionCard(Icons.shopping_basket, 'Orders'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home ', 
        style: TextStyle(
         fontWeight: FontWeight.bold, 
      fontSize: 24.0,
      foreground: Paint()..shader = LinearGradient(
              colors: [Color(0xFF6A5FC3), Color(0xFF8E7DE5)],
            ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
        )),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF6A5FC3)),
            onPressed: () {
              fetchMetrics();
              fetchOrders();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                'Welcome to your dashboard',
                style: TextStyle(
                color: Color(0xFF6A5FC3), 
                 ),
              ),

              SizedBox(height: 20),
              _buildStatsRow(),
              SizedBox(height: 20),
              Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              recentOrders.isEmpty
                  ? Center(child: Text('No orders available'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recentOrders.length,
                      itemBuilder: (context, index) {
                        final order = recentOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: _onTabTapped,
        height: 60,
        color: Color(0xFF6A5FC3),
        backgroundColor: Colors.white,
        items: const [
          Icon(Icons.dashboard, size: 30, color: Colors.white),
          Icon(Icons.list, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildStatCard('No. of Birds', noOfBirds, Colors.teal.shade100, Icons.air)),
            SizedBox(width: 10),
            Expanded(child: _buildStatCard('Mortality Rate', mortalityRate, Colors.red.shade100, Icons.warning)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildStatCard('No. of Eggs', noOfEggs, Colors.white,Icons.egg)),
            SizedBox(width: 10),
            Expanded(child: _buildStatCard('No. of Employees', noOfEmployees, Colors.blue.shade100,Icons.person)),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: order['status'] == 'Completed' ? Colors.deepPurple : Colors.deepPurple,
          child: Icon(order['status'] == 'Completed' ? Icons.check : Icons.pending),
        ),
        title: Text(order['order_type'] ?? 'Unknown Item'),
      subtitle: Text(
        'Customer: ${order['customer_name'] ?? 'Anonymous'}\nStatus: ${order['status'] ?? 'Pending'}',
      ),
      trailing: Text('KES ${order['total_price'] ?? 0}'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5.0),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 2),
          blurRadius: 6.0,
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 40.0,
          color: Colors.purple.shade700,
        ),
        const SizedBox(height: 10.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildActionCard(IconData icon, String label) {
    final Map<String, String> routeMap = {
      'Eggs Production': '/eggsProduction',
      'Eggs Sales': '/eggsSales',
      'Birds Purchase': '/birdsPurchase',
      'Birds Mortality': '/birdsMortality',
      'Birds Sales': '/birdsSales',
      'Feed Purchase': '/feedPurchase',
      
      'Medicine': '/medicine',
      'Vaccination': '/vaccination',
      'Payroll': '/payroll',
      'Settings': '/settings',
      'Orders': '/orders',
    };

    return GestureDetector(
      onTap: () {
        if (routeMap.containsKey(label)) {
          Navigator.pushNamed(context, routeMap[label]!);
        }
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Icon(icon, size: 30,color:Colors.deepPurple,),
              SizedBox(height: 5),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}