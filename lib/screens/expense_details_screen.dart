import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  ExpenseDetailsScreen({required this.book});

  @override
  _ExpenseDetailsScreenState createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  int totalIn = 0;
  int totalOut = 0;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  String searchQuery = '';
  String sortBy = 'Date'; // Default sorting by date
  bool ascending = true; // Default sort order

  @override
  void initState() {
    super.initState();
    transactions = List<Map<String, dynamic>>.from(widget.book['transactions'] ?? []);
    filteredTransactions = List<Map<String, dynamic>>.from(transactions);
    _calculateTotals();
  }

  void _calculateTotals() {
    totalIn = 0;
    totalOut = 0;
    for (var transaction in filteredTransactions) {
      if (transaction['type'] == 'in') {
        totalIn += (transaction['amount'] as num).toInt();
      } else {
        totalOut += (transaction['amount'] as num).toInt();
      }
    }
  }

  // Validation: Check if the transaction name contains only letters and spaces
  bool _isValidName(String name) {
    final RegExp nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    return nameRegex.hasMatch(name);
  }

  void _showTransactionDialog(String type) {
    final _amountController = TextEditingController();
    final _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'in' ? 'Cash In' : 'Cash Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Transaction Name'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              final amount = int.tryParse(_amountController.text.trim()) ?? 0;

              // Validation: Ensure name is not empty and contains only letters
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transaction name cannot be empty')),
                );
                return;
              }

              if (!_isValidName(name)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transaction name can only contain letters and spaces')),
                );
                return;
              }

              // Validation: Ensure amount is positive
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Amount must be greater than 0')),
                );
                return;
              }

              // Add the transaction
              setState(() {
                transactions.add({
                  'id': DateTime.now().millisecondsSinceEpoch, // Unique ID for each transaction
                  'name': name,
                  'amount': amount,
                  'date': DateTime.now().toString().split(' ')[0],
                  'type': type,
                  'archived': false, // Mark transaction as not archived by default
                });
                filteredTransactions = List<Map<String, dynamic>>.from(transactions);
                _calculateTotals();
                widget.book['transactions'] = transactions;
              });

              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  int getCurrentBalance() => totalIn - totalOut;

  void _searchTransactions(String query) {
    setState(() {
      searchQuery = query;
      filteredTransactions = transactions
          .where((transaction) => transaction['name']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
      _calculateTotals();
    });
  }

  void _sortTransactions(String sortBy) {
    setState(() {
      if (sortBy == 'Date') {
        filteredTransactions.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']);
          DateTime dateB = DateTime.parse(b['date']);
          return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
      } else if (sortBy == 'Amount') {
        filteredTransactions.sort((a, b) {
          int amountA = a['amount'];
          int amountB = b['amount'];
          return ascending ? amountA.compareTo(amountB) : amountB.compareTo(amountA);
        });
      }
      _calculateTotals();
    });
  }

  void _archiveTransaction(int index) {
    setState(() {
      // Archive the transaction by marking it
      transactions[index]['archived'] = true;
      filteredTransactions = List<Map<String, dynamic>>.from(transactions);
      _calculateTotals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title']),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SummaryCard(
                  title: 'Total In',
                  amount: totalIn,
                  color: Colors.blue, // Solid blue
                ),
                SummaryCard(
                  title: 'Total Out',
                  amount: -totalOut, // Show as negative
                  color: Colors.red, // Solid red
                ),
                SummaryCard(
                  title: 'Balance',
                  amount: getCurrentBalance(),
                  color: Colors.green, // Solid green
                ),
              ],
            ),
          ),
          
          // Search and Sort section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: _searchTransactions,
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.blue),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                    filteredTransactions = List<Map<String, dynamic>>.from(transactions);
                                    _calculateTotals();
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: sortBy,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          sortBy = value;
                        });
                        _sortTransactions(sortBy);
                      }
                    },
                    items: <String>['Date', 'Amount']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    icon: Icon(Icons.sort, color: Colors.blue),
                    iconSize: 20,
                    style: TextStyle(color: Colors.blue),
                    underline: SizedBox(),
                  ),
                ),
                const SizedBox(width: 16),

                // Sort Order Toggle Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                    });
                    _sortTransactions(sortBy);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: CircleBorder(),
                    padding: const EdgeInsets.all(10.0),
                  ),
                  child: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          
          // Transaction List with Dismissible
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    for (var index = 0; index < filteredTransactions.length; index++)
                      if (!filteredTransactions[index]['archived']) // Only show non-archived
                        Dismissible(
                          key: Key(filteredTransactions[index]['id'].toString()), // Unique key using transaction ID
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _archiveTransaction(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Transaction archived')),
                            );
                          },
                          background: Container(
                            color: Colors.grey,
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.archive, color: Colors.white),
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(filteredTransactions[index]['name']),
                              subtitle: Text(filteredTransactions[index]['date']),
                              trailing: Text(
                                'Rwf ${filteredTransactions[index]['amount']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: filteredTransactions[index]['type'] == 'in'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showTransactionDialog('in'),
              icon: Icon(Icons.arrow_upward, color: Colors.white),
              label: Text('Cash In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showTransactionDialog('out'),
              icon: Icon(Icons.arrow_downward, color: Colors.white),
              label: Text('Cash Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color color;

  const SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 1,
            ),
            SizedBox(height: 8),
            AutoSizeText(
              'Rwf $amount',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}