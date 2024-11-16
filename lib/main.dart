import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'select_node.dart';


Future<void> main() async {
  // Asegúrate de cargar las variables de entorno antes de ejecutar la app
  await dotenv.load(fileName: ".env");
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
