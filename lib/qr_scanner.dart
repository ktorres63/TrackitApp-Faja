import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


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
  String _scannedData = '';

  // Función para realizar el PUT request al endpoint
  Future<void> updatePackageStatus(String extractedNumber, int nodeId) async {
    final apiUrl = dotenv.env['API_URL'];
    
    if (apiUrl == null) {
      print('Error: API_URL no está definido en el archivo .env');
      return;
    }
    final url = Uri.parse('$apiUrl/ruta/api/$extractedNumber/$nodeId/');
    
    try {
      print('extracted-> $extractedNumber- nodoId->$nodeId/');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'estado': 1,  // Cambiar estado a 1
        }),
      );

      if (response.statusCode == 200) {
        // Si la solicitud fue exitosa, puedes mostrar un mensaje o hacer algo más
        print('Estado actualizado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Si algo salió mal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la actualización: ${response.statusCode}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        print('Error en la actualización del estado: ${response.statusCode}');
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
                  if (scannedValue != _scannedData) {
                    setState(() {
                      _scannedData = scannedValue;
                    });
                    // Aquí puedes llamar a la función para actualizar el estado
                    if (_scannedData.isNotEmpty) {
                      // Suponiendo que el QR contiene el ID de paquete como 'id-paquete:5'
                      final extractedNumber = _scannedData.split(':').last;  // Extraer el número
                      updatePackageStatus(extractedNumber, widget.nodeId);  // Llamar a la API
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
                        const Text(
                          'Scanned Data:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_scannedData),
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
