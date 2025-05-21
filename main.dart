import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseData(),
      builder: (context, child) => ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '8-bit Ledger',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.pressStart2p(color: Colors.white),
          bodyMedium: GoogleFonts.pressStart2p(color: Colors.white),
        ),
      ),
      home: ExpenseTrackerScreen(),
    );
  }
}

class ExpenseData extends ChangeNotifier {
  final List<Map<String, dynamic>> _expenses = [];

  List<Map<String, dynamic>> get expenses => _expenses;

  void addExpense(String name, double amount) {
    _expenses.add({
      'name': name,
      'amount': amount,
      'date': DateTime.now(),
    });
    notifyListeners();
  }

  List<Map<String, dynamic>> getExpensesForMonth(int targetMonth) {
    return _expenses.where((expense) => (expense['date'] as DateTime).month == targetMonth).toList();
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return RadialGradient(
              center: Alignment.topLeft,
              radius: 2,
              colors: <Color>[Colors.greenAccent, Colors.blue],
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Text(
            '8-bit Ledger',
            style: GoogleFonts.pressStart2p(
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.green,
                  offset: Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 0.0,
                  color: Colors.black,
                  offset: Offset(2, 2),
                ),
                Shadow(
                  blurRadius: 0.0,
                  color: Colors.black,
                  offset: Offset(-2, -2),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 80,
        titleTextStyle: GoogleFonts.pressStart2p(
          color: Colors.yellow,
          fontSize: 20,
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.pressStart2p(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                      hintStyle: GoogleFonts.pressStart2p(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _expenseController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.pressStart2p(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter expense (₱)',
                      hintStyle: GoogleFonts.pressStart2p(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text;
                    final amount = double.tryParse(_expenseController.text) ?? 0.0;
                    if (name.isNotEmpty) {
                      Provider.of<ExpenseData>(context, listen: false).addExpense(name, amount);
                      _expenseController.clear();
                      _nameController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: Text(
                    'ADD',
                    style: GoogleFonts.pressStart2p(color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Consumer<ExpenseData>(
                builder: (context, expenseData, child) {
                  return ListView.builder(
                    itemCount: expenseData.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenseData.expenses[index];
                      return ListTile(
                        title: Text(
                          '${expense['name']} - ₱${expense['amount'].toStringAsFixed(2)}',
                          style: GoogleFonts.pressStart2p(color: Colors.yellow),
                        ),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(expense['date']),
                          style: GoogleFonts.pressStart2p(color: Colors.blue),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MonthlySummaryScreen(),
            ),
          );
        },
        backgroundColor: Colors.black,
        shape: CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            'https://static.vecteezy.com/system/resources/thumbnails/027/517/677/small/pixel-art-red-chinese-gold-coin-png.png',
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _expenseController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  _MonthlySummaryScreenState createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  int _selectedMonth = DateTime.now().month;

  List<List<Map<String, dynamic>>> groupExpensesByWeek(List<Map<String, dynamic>> expenses) {
    List<List<Map<String, dynamic>>> weeklyExpenses = [];
    List<Map<String, dynamic>> currentWeek = [];
    DateTime? currentWeekStart;

    for (var expense in expenses) {
      DateTime expenseDate = expense['date'];

      currentWeekStart ??= expenseDate.subtract(Duration(days: expenseDate.weekday - 1));

      if (expenseDate.isBefore(currentWeekStart.add(Duration(days: 7)))) {
        // Expense falls within the current week.
        currentWeek.add(expense);
      } else {
        // Expense falls in a new week, so save the current week and start a new one.
        weeklyExpenses.add(currentWeek);
        currentWeek = [expense];
        currentWeekStart = expenseDate.subtract(Duration(days: expenseDate.weekday - 1));
      }
    }

    // Add the last week if it's not empty.
    if (currentWeek.isNotEmpty) {
      weeklyExpenses.add(currentWeek);
    }

    return weeklyExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monthly Summary',
          style: GoogleFonts.pressStart2p(
            color: Colors.greenAccent,
            fontSize: 20,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.green,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Consumer<ExpenseData>(
        builder: (context, expenseData, child) {
          final monthlyExpenses = expenseData.getExpensesForMonth(_selectedMonth);
          final weeklyExpenses = groupExpensesByWeek(monthlyExpenses);

          double totalAmount = 0;
          for (var expense in monthlyExpenses) {
            totalAmount += expense['amount'];
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = _selectedMonth > 1 ? _selectedMonth - 1 : 12;
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM').format(DateTime(0, _selectedMonth)),
                      style: GoogleFonts.pressStart2p(
                        color: Colors.greenAccent,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = _selectedMonth < 12 ? _selectedMonth + 1 : 1;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Weekly Expense Entries:',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.yellow,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: weeklyExpenses.length,
                    itemBuilder: (context, index) {
                      final week = weeklyExpenses[index];
                      return ExpansionTile(
                        leading: Icon(Icons.crop_square, color: Colors.white),
                        title: Text(
                          'Week ${index + 1}: ${week.length} entries',
                          style: GoogleFonts.pressStart2p(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                        children: week.map<Widget>((expense) {
                          return ListTile(
                            title: Text(
                              '${expense['name']} - ₱${expense['amount'].toStringAsFixed(2)}',
                              style: GoogleFonts.pressStart2p(color: Colors.yellow, fontSize: 10),
                            ),
                            subtitle: Text(
                              DateFormat('yyyy-MM-dd').format(expense['date']),
                              style: GoogleFonts.pressStart2p(color: Colors.blue, fontSize: 8),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Total Amount: ₱${totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.greenAccent,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
