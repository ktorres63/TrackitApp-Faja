import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class QrScannerPage extends StatefulWidget {
  final String nodeName;
  final int nodeId;

  const QrScannerPage({
    super.key,
    required this.nodeName,
    required this.nodeId,
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
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

  String _scannedData = '';
  bool _isProcessing = false;
  String? _finalNodeName;

  // Función para actualizar el estado del paquete
  Future<void> updatePackageStatus(String extractedNumber) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      print('Error: API_URL no está definido en el archivo .env');
      return;
    }

    final url = Uri.parse('$apiUrl/ruta/api/$extractedNumber/${widget.nodeId}/');

    try {
      print('Actualizando: paquete=$extractedNumber nodo=${widget.nodeId}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': 2}),
      );

      if (response.statusCode == 200) {
        print('Estado actualizado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        await fetchFinalNode(extractedNumber);
      } else {
        print('Error en la actualización del estado: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la actualización: ${response.statusCode}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      print('Error de conexión: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _scannedData = '';
        _isProcessing = false;
      });
    }
  }

  // Función para obtener nodo_fin_id y asignar el nombre del nodo final
  Future<void> fetchFinalNode(String extractedNumber) async {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      print('Error: API_URL no está definido en el archivo .env');
      return;
    }

    final url = Uri.parse('$apiUrl/ruta/api/get/$extractedNumber/${widget.nodeId}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final finalNodeId = data['nodo_fin_id'] as int?;
        setState(() {
          _finalNodeName = _nodes.entries
              .firstWhere((entry) => entry.value == finalNodeId, orElse: () => const MapEntry('', 0))
              .key;
        });
      } else {
        print('Error al obtener nodo_fin_id: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de conexión al obtener nodo_fin_id: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nodeName} QR Scanner'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: MobileScanner(
                fit: BoxFit.contain,
                onDetect: (capture) {
                  final scannedValue = capture.barcodes.first.rawValue ?? '';
                  if (!_isProcessing && scannedValue != _scannedData) {
                    setState(() {
                      _scannedData = scannedValue;
                      _isProcessing = true;
                    });
                    if (_scannedData.isNotEmpty) {
                      final extractedNumber = _scannedData.split(':').last;
                      updatePackageStatus(extractedNumber);
                    }
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text(
                        //   'Scanned Data:',
                        //   style: TextStyle(fontWeight: FontWeight.bold),
                        // ),
                        // const SizedBox(height: 8),
                        // Text(_scannedData),
                        // const SizedBox(height: 16),
                        const Text(
                          'Se dirige a:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_finalNodeName ?? 'Esperando datos...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
