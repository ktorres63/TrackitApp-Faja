import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import './qr_scanner.dart'; 

class SelectNodePage extends StatefulWidget {
  const SelectNodePage({super.key});

  @override
  State<SelectNodePage> createState() => _SelectNodePageState();
}

class _SelectNodePageState extends State<SelectNodePage> {
  String? _selectedNode;
  int? _selectedNodeId;
  final Map<String, int> _nodes = {
    'Tacna': 1,
    'Arequipa': 2,
    'Madre de Dios': 3,
    'Ayacucho': 4,
    'Ucayali': 5,
    'Lima': 6,
    'San Martin': 7,
    'Tumbes': 8,
    'Loreto': 9,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacen'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Seleccione un nodo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedNode,
                hint: const Text('Seleccione un nodo'),
                items: _nodes.keys.map((node) {
                  return DropdownMenuItem<String>(
                    value: node,
                    child: Text(node),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedNode = newValue;
                    _selectedNodeId = _nodes[newValue];  // Obtener el ID correspondiente
                  });
                  // Aquí puedes usar el nodo seleccionado para otra funcionalidad
                  print("Nodo seleccionado: $_selectedNode, ID: $_selectedNodeId");
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_selectedNodeId != null) {
                    // Navegar a la página de escáner y pasar tanto el nombre del nodo como el ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrScannerPage(
                          nodeName: _selectedNode!,  // Pasar el nombre del nodo
                          nodeId: _selectedNodeId!,  // Pasar el ID del nodo
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Confirmar selección'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
