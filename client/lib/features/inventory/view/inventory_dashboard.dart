import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("This is Inventory Management Page!"),
        leading: ElevatedButton(onPressed: ()=> context.go("/login"), child: null),
      ),
    );
  }
}