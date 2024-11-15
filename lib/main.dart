import 'package:flutter/material.dart';
import 'select_node.dart'; // Asegúrate de tener el import correcto de la página SelectNodePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Almacen-App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SelectNodePage(),  // Directamente inicializamos SelectNodePage
    );
  }
}
