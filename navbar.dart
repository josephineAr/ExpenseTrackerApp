import 'package:flutter/material.dart';
import 'report.dart';
import 'dashboard.dart';
import 'transactionmodel.dart';
import 'budgets.dart';

class Navbar extends StatefulWidget {
  final int userId; 

  
  const Navbar({super.key, required this.userId});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  final List<Transactionmodel> _transactions = [];

  void _addTransaction(Transactionmodel tx) {
    setState(() {
      _transactions.add(tx);
    });
  }

  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
   
    final List<Widget> pages = [
      Dashboard(
        userId: widget.userId,
        transactions: _transactions,
        onAddTransaction: _addTransaction,
        monthly_budget: 0,
        onSetBudget: (val) {},
      ),
      Budget(
        userId: widget.userId,
        transactions: _transactions,
      ),
      Reports(
        
        userId: widget.userId,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigate,
        selectedItemColor: Colors.purple,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Budgets'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
        ],
      ),
    );
  }
}