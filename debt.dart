import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Debt extends StatefulWidget {
  final int userId; 
  const Debt({super.key, required this.userId});

  @override
  State<Debt> createState() => _DebtState();
}

class _DebtState extends State<Debt> {
  final String baseUrl = 'http://10.103.198.103:3000';
  List<String> DebtOption = ["Debtor", "Creditor"];
  bool showForm = false;
  String? selectedOption;
  
  TextEditingController namecontroller = TextEditingController();
  TextEditingController debtamountcontroller = TextEditingController();
  TextEditingController infocontroller = TextEditingController();

  Future<List<dynamic>> fetchDebts() async {
    final response = await http.get(Uri.parse('$baseUrl/debts/${widget.userId}'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load debts");
  }

  Future<void> saveDebt() async {
    if (namecontroller.text.isEmpty || debtamountcontroller.text.isEmpty || selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/debts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": widget.userId,
          "name": namecontroller.text,
          "amount": double.parse(debtamountcontroller.text),
          "type": selectedOption,
          "info": infocontroller.text
        }),
      );

      if (response.statusCode == 201) {
        setState(() => showForm = false);
        namecontroller.clear();
        debtamountcontroller.clear();
        infocontroller.clear();
        selectedOption = null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> togglePaid(int debtId, bool currentStatus) async {
    await http.patch(
      Uri.parse('$baseUrl/debts/toggle-paid/$debtId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"is_paid": !currentStatus}),
    );
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          elevation: 0,
          leading: showForm ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => showForm = false)) : null,
          title: Text(showForm ? "Add New Debt" : "My Debts", style: const TextStyle(color: Colors.white))),
      body: showForm ? buildDebtForm() : FutureBuilder<List<dynamic>>(
        future: fetchDebts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text("No debts yet", style: TextStyle(fontStyle: FontStyle.italic)));
          }

          final debts = snapshot.data!;
          return ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              bool isPaid = debt['is_paid'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  leading: Checkbox(
                    value: isPaid,
                    onChanged: (val) => togglePaid(debt['id'], isPaid),
                    activeColor: Colors.purple,
                  ),
                  title: Text(
                    "${debt['name']} - UGX ${debt['amount']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                      color: isPaid ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Text("${debt['type']} • ${debt['info']}"),
                  trailing: Icon(
                    debt['type'] == "Debtor" ? Icons.arrow_downward : Icons.arrow_upward,
                    color: debt['type'] == "Debtor" ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: showForm ? null : FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => setState(() => showForm = true),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildDebtForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.handshake_outlined, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedOption,
              hint: const Text("Select Debt Type"),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Type"),
              items: DebtOption.map((String option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
              onChanged: (value) => setState(() => selectedOption = value),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: namecontroller,
              decoration: const InputDecoration(labelText: "Person Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: debtamountcontroller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount", prefixText: "UGX ", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: infocontroller,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Additional Info", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: saveDebt, 
                child: const Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}