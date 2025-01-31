import 'package:flutter/material.dart';
import 'expense_details_screen.dart';
import 'custom_bottom_nav_bar.dart';
import 'package:intl/intl.dart'; // For date formatting

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final List<Map<String, dynamic>> books = [
    {
      'title': 'January expenses',
      'updated': 'Jan 21 2024',
      'transactions': [],
    },
    {
      'title': 'Groceries',
      'updated': 'Mar 31 2024',
      'transactions': [],
    },
  ];

  List<Map<String, dynamic>> filteredBooks = [];
  int _selectedIndex = 0;
  String searchQuery = '';
  String sortBy = 'Title'; // Default sorting by title
  bool ascending = true; // Default sort order
  bool isLoading = false; // Loading state for filtering/sorting

  @override
  void initState() {
    super.initState();
    filteredBooks = List<Map<String, dynamic>>.from(books);
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      isLoading = true; // Show loading indicator
    });

    // Simulate a delay for filtering
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        filteredBooks = books
            .where((book) =>
                book['title'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        _sortBooks(sortBy); // Re-sort after filtering
        isLoading = false; // Hide loading indicator
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddBookDialog() {
    final TextEditingController titleController = TextEditingController();
    final String currentDate = DateFormat('MMM dd yyyy').format(DateTime.now());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter book title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Updated Date',
                  hintText: currentDate,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }

                setState(() {
                  books.add({
                    'title': title,
                    'updated': currentDate,
                    'transactions': [],
                  });
                  filteredBooks = List<Map<String, dynamic>>.from(books);
                  _sortBooks(sortBy); // Re-sort after adding
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editBook(int index) {
    final TextEditingController titleController =
        TextEditingController(text: books[index]['title']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter book title',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }

                setState(() {
                  books[index]['title'] = title;
                  filteredBooks = List<Map<String, dynamic>>.from(books);
                  _sortBooks(sortBy); // Re-sort after editing
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(int index) {
    setState(() {
      books.removeAt(index);
      filteredBooks = List<Map<String, dynamic>>.from(books);
      _sortBooks(sortBy); // Re-sort after deleting
    });
  }

  void _sortBooks(String sortBy) {
    setState(() {
      if (sortBy == 'Title') {
        filteredBooks.sort((a, b) {
          return ascending
              ? a['title'].compareTo(b['title'])
              : b['title'].compareTo(a['title']);
        });
      } else if (sortBy == 'Date') {
        filteredBooks.sort((a, b) {
          DateTime dateA = DateFormat('MMM dd yyyy').parse(a['updated']);
          DateTime dateB = DateFormat('MMM dd yyyy').parse(b['updated']);
          return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 188, 83, 83)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Sort section
            SearchAndSortBar(
              onSearchChanged: _onSearchChanged,
              sortBy: sortBy,
              onSortChanged: (value) {
                if (value != null) {
                  setState(() {
                    sortBy = value;
                  });
                  _sortBooks(sortBy);
                }
              },
              ascending: ascending,
              onSortOrderChanged: () {
                setState(() {
                  ascending = !ascending;
                });
                _sortBooks(sortBy);
              },
            ),
            const SizedBox(height: 20),

            // Books Title and Add New Book Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Books',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddBookDialog,
                  icon: Icon(Icons.add, size: 16, color: Colors.white),
                  label: Text(
                    'Add New Book',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Books List
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return BookItem(
                          book: book,
                          onEdit: () => _editBook(index),
                          onDelete: () => _deleteBook(index),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExpenseDetailsScreen(book: book),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Reusable Widget: Search and Sort Bar
class SearchAndSortBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final String sortBy;
  final Function(String?) onSortChanged;
  final bool ascending;
  final Function() onSortOrderChanged;

  const SearchAndSortBar({
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortChanged,
    required this.ascending,
    required this.onSortOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search books...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
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
            onChanged: onSortChanged,
            items: <String>['Title', 'Date']
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
          onPressed: onSortOrderChanged,
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
    );
  }
}

// Reusable Widget: Book Item
class BookItem extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const BookItem({
    required this.book,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Updated on ${book['updated']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}