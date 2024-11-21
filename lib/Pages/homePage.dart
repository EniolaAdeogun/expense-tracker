import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';

import 'package:expense_tracker/bar_graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_dartbase.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();


Future <Map<int , double >>? _monthlyTotalsFuture;
Future<double>? _calculateCurrentMonthTotal; 
@override
  void initState() {
    Provider.of<ExpenseDataBase>(context , listen: false).readExpenses();

    refreshData();

    super.initState();
  }


void refreshData(){
  _monthlyTotalsFuture = Provider.of<ExpenseDataBase> (context , listen: false)

  .calculateMonthlyTotals();

  _calculateCurrentMonthTotal = 
  Provider.of<ExpenseDataBase>(context , listen : false)
  .calculateCurrentMonthTotal();
}

  void openNewExpenseBox(){
showDialog(
  context: context, builder: (context) => AlertDialog(
    title: Text('New Expense'),
    content: Column(
mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'name'),
        ),
        TextField(
          controller: amountController,
          decoration: const InputDecoration(hintText: 'Amount')
        )
      ],
    ),
    actions: [
       _cancelButton(),

       _createNewExpenseButton()
    ],
  )
  
  );

  }

  void openEditBox( Expense expense){

    

    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
showDialog(
  context: context, builder: (context) => AlertDialog(
    title: Text('Edit Expense'),
    content: Column(
mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration:  InputDecoration(hintText: existingName),
        ),
        TextField(
          controller: amountController,
          decoration:  InputDecoration(hintText: existingAmount)
        )
      ],
    ),
    actions: [
       _cancelButton(),

       _editExpenseButton(expense)
    ],
  )
  
  );

  }


  void  openDeleteBox(Expense expense){
    showDialog(
  context: context, builder: (context) => AlertDialog(
    title: Text('Delete Expense?'),
   
    actions: [
       _cancelButton(),

       _deleteExpenseButton(expense.id)
    ],
  )
  
  );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDataBase>(
      builder: (context , value, child) {

        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth); 

        List<Expense> currentMonthExpense = value.allExpense.where((expense) {
return expense.date.year == currentYear && 
expense.date.month == currentMonth ; 
        }
        
        ).toList();

     return   Scaffold(
backgroundColor: Colors.grey.shade300,
      floatingActionButton: FloatingActionButton(
        
        onPressed: openNewExpenseBox,
        child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: FutureBuilder<double>(
future:  _calculateCurrentMonthTotal,
builder: (context , snapshot){
if (snapshot.connectionState == ConnectionState.done){

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween ,
    children: [
      Text('\$' + snapshot.data!.toStringAsFixed(2)),

      Text(getCurrentMonthName()),
    ],
  ); 
}

else {

  return Text(' Loading');
}

},


          ),
        ),
       body: Column(
        children: [
// GRAPH UI 
SafeArea(
  child: SizedBox(
    height: 250,
    child: FutureBuilder(future: _monthlyTotalsFuture, builder: (context , snapshot){
    if (snapshot.connectionState == ConnectionState.done){
      final monthlyTotals = snapshot.data ?? {}; 
    
    
      List<double> monthlySummary = 
      List.generate(monthCount, (index)=> monthlyTotals[startMonth + index]??0.0);
    
      return MyBarGraph(monthlySummary: monthlySummary, startMonth: startMonth);
     
      }
    
      else{
        return const Center(
          child: Text('Loading...'),
        );
      }
    
    }),
  ),
),

          Expanded(
            child: ListView.builder(
                    itemCount: currentMonthExpense.length,
                    itemBuilder: (context,index) {

                      int reversedIndex = currentMonthExpense.length - 1 - index ; 
            Expense individualExpense = currentMonthExpense[index];
            return MyListTile(title:  individualExpense.name, trailing: formatAmount(individualExpense.amount), onEditPressed: (context)=> openEditBox(individualExpense), onDeletePressed: (context)=> openDeleteBox(individualExpense),); 
                    }
                    ),
          ),
        ],
       )
    );
      }
    ); 
  }


  Widget _cancelButton (){
    return MaterialButton(onPressed: (){
Navigator.pop(context);
nameController.clear();
amountController.clear();

    },
    child: const Text('Cancel '),
    
    );
  }

  Widget _createNewExpenseButton (){
    return MaterialButton(onPressed: () async{
if (
  nameController.text.isNotEmpty && amountController.text.isNotEmpty){
Navigator.pop(context);

Expense newExpense = Expense(
  name: nameController.text,
   amount: convertStringToDouble(amountController.text), 
   date: DateTime.now()
   );

   await context.read<ExpenseDataBase>().createNewExpense(newExpense);

   refreshData();

   nameController.clear();
   amountController.clear();
}
    },
    child: const Text('Save'),
    ); 
  }

  Widget _editExpenseButton( Expense expense){

    return MaterialButton(
      onPressed: ()async {
          if (
            nameController.text.isNotEmpty || amountController.text.isNotEmpty
          ) {
Navigator.pop(context);

Expense updatedExpense= Expense(
  name: nameController.text.isNotEmpty
  ? nameController.text
  : expense.name,
 amount: amountController.text.isNotEmpty ? convertStringToDouble(amountController.text)
 : expense.amount,
  date: DateTime.now(),
  
  );

  int existingID = expense.id;

  await context.read<ExpenseDataBase>().updateExpense(existingID, updatedExpense);

  refreshData();

          } 
      },
      child: const Text('Save'),
    );
  }


  Widget _deleteExpenseButton(int id) {
return MaterialButton(onPressed: () async{
 
 Navigator.pop(context);

 await context.read<ExpenseDataBase>().deleteExpense(id);

 refreshData();

},
child: const Text('Delete'),
);

  }
}