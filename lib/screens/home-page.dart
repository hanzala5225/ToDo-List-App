import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/utils/app_constant.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Todo> todoBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<Todo>("todo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.appMainColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(AppConstant.appMainName,
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box<Todo> box, _){
          return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index){
                Todo todo = box.getAt(index)!;
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: todo.isCompleted ? Colors.white38 : Colors.white38,
                      borderRadius: BorderRadius.circular(10)
                  ),


                  child: Dismissible(
                    key: Key(todo.dateTime.toString(),),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction){
                      setState(() {
                        todo.delete();
                      });
                    },
                    child: ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.description),
                      trailing: Text(
                        DateFormat.yMMMd().format(todo.dateTime),
                      ),
                      leading: Checkbox(
                        value: todo.isCompleted,

                        onChanged: (value)
                        {
                          setState(() {
                            todo.isCompleted = value!;
                            todo.save();
                          });
                        },
                      ),
                    ),
                  ),
                );
              }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()
        {
          _addTodoDialog(context);
        },
        child: Icon(Icons.add_sharp),
      ),
    );
  }

  Future<void> _addTodo(String title, String description) async {
    if (title.isNotEmpty) {
      final todoBox = Hive.box<Todo>("todo");
      await todoBox.add(
        Todo(
          title: title,
          description: description,
          dateTime: DateTime.now(),
        ),
      );
    } else {
      throw Exception('Title cannot be empty');
    }
  }

  void _addTodoDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Task",
            style: TextStyle(fontWeight: FontWeight.bold),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel",
              style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () async {
                String title = _titleController.text.trim();
                String description = _descriptionController.text.trim();
                if (title.isNotEmpty) {
                  try {
                    await _addTodo(title, description);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task added successfully'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust width here
                      ),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add task: $error'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust width here
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Title cannot be empty'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust width here
                    ),
                  );
                }
              },
              child: Text("Add",
              style: TextStyle(color: Colors.green),),
            )
          ],
        );
      },
    );
  }
}