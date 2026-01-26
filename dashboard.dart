import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'transactionmodel.dart';
import 'transaction.dart';
import 'debt.dart'; 
import 'dart:async';

class Dashboard extends StatefulWidget {
  final List<Transactionmodel> transactions;
  final Function(Transactionmodel) onAddTransaction;
  final double monthly_budget;
  final void Function(double) onSetBudget;
  final int userId;

  const Dashboard({
    super.key, 
    required this.transactions,
    required this.onSetBudget,
    required this.onAddTransaction,
    required this.monthly_budget,
    required this.userId
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double totalIncome = 0;
  double totalExpense = 0;
  bool isLoading = true;
  
 // Variables for storing user profile info
  String userName = "Loading...";
  String userEmail = "...";

  int currentQuoteIndex = 0;
  double _opacity = 1.0;
  final List<String> quotes = [
    "Do not save what is left after spending; spend what is left after saving",
    "Small Savings today, lead to Big Gains tomorrow",
    "A budget tells your money where to go instead of wondering where it went"
  ];

  @override
  void initState() {
    super.initState();
    fetchDashboardTotals();
    fetchUserProfile(); 
    
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() => _opacity = 0.0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
          _opacity = 1.0;
        });
      });
    });
  }

  //fetching user information
 Future<void> fetchUserProfile() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.103.198.103:3000/users/${widget.userId}'),
    );
   
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("User Data Received: $data"); 
      
      setState(() {
       
        userName = data['username'] ?? "User"; 
        userEmail = data['email'] ?? "No Email";
      });
    } else {
      setState(() {
        userName = "Guest User";
        userEmail = "Login to sync";
      });
    }
  } catch (e) {
    debugPrint("Error fetching profile: $e");
    setState(() => userName = "Error Loading");
  }
}

  Future<void> fetchDashboardTotals() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.103.198.103:3000/transactions/totals/${widget.userId}'),
      );
     
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            totalIncome = double.tryParse(data['total_income'].toString()) ?? 0;
            totalExpense = double.tryParse(data['total_expense'].toString()) ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching totals: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  double get balance => totalIncome - totalExpense;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: const Text("T R A C K F U N D S", 
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        color: Colors.purple,
        onRefresh: () async {
          await fetchDashboardTotals();
          await fetchUserProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.purple,
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/images/logo.jpeg"),
                ),
              ),
              const SizedBox(height: 15),
              _buildBalanceCard(),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildStatTile("Income", totalIncome, Colors.green),
                  const SizedBox(width: 12),
                  _buildStatTile("Expenses", totalExpense, Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              _buildQuoteSection(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => AddTransaction(userId: widget.userId))
                    );
                    if (result == true) fetchDashboardTotals(); 
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text("ADD TRANSACTION", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    elevation: 5,
                    shadowColor: Colors.purple.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
         UserAccountsDrawerHeader(
  decoration: const BoxDecoration(color: Colors.purple),
  currentAccountPicture: const CircleAvatar(
    backgroundColor: Colors.white,
    child: Padding(
      padding: EdgeInsets.all(2.0),
      child: CircleAvatar(backgroundImage: AssetImage('assets/images/logo.jpeg')),
    ),
  ),
  // Use the state variables directly
  accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
  accountEmail: Text(userEmail),
),
          _drawerItem(Icons.money_off, "My Debts", '/debt'),
          _drawerItem(Icons.settings, "Settings", '/settings'),
          _drawerItem(Icons.info_outline, "About", '/about'),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); 
        if (route == '/debt') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Debt(userId: widget.userId)),
          ).then((_) => fetchDashboardTotals()); 
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Widget _buildQuoteSection() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:Colors.purple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.format_quote, color: Colors.white70, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(quotes[currentQuoteIndex], 
                style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.purple.shade100, width: 1),
      ),
      child: Column(
        children: [
          const Text("Current Balance", style: TextStyle(color: Colors.purple, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple)) 
            : Text("UGX ${balance.toStringAsFixed(0)}", 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(label == "Income" ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: color),
                ),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text("UGX ${amount.toStringAsFixed(0)}", 
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}