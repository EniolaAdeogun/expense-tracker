import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  const MyListTile({super.key, required this.title , required this.trailing ,  required this.onEditPressed , required this.onDeletePressed});
  final void Function (BuildContext)? onEditPressed;
  final void Function (BuildContext)? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Slidable (
      endActionPane: ActionPane(motion: const StretchMotion(),
       children:[ SlidableAction(onPressed: onEditPressed, icon: Icons.settings, backgroundColor: Colors.grey, foregroundColor: Colors.white, borderRadius: BorderRadius.circular(4), ),
       SlidableAction(onPressed: onDeletePressed  ,icon:  Icons.delete , backgroundColor: Colors.red, foregroundColor: Colors.white, borderRadius: BorderRadius.circular(14),),
       
       ]
       ),

      child: ListTile(
      
              title: Text(title),
              trailing: Text(trailing),
            ),
    );
  }
} 