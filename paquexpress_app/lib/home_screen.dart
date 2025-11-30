import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Listas separadas
  List<dynamic> pendientes = [];
  List<dynamic> historial = [];
  bool _isLoading = true;
  
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://192.168.100.34:8000";

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  // Función maestra para cargar ambas listas
  Future<void> _cargarTodo() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    // 1. Cargar Pendientes
    try {
      final resPendientes = await http.get(
        Uri.parse("$baseUrl/mis-paquetes"),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      // 2. Cargar Historial (NUEVO)
      final resHistorial = await http.get(
        Uri.parse("$baseUrl/mi-historial"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resPendientes.statusCode == 200 && resHistorial.statusCode == 200) {
        setState(() {
          pendientes = json.decode(resPendientes.body);
          historial = json.decode(resHistorial.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error cargando datos: $e");
      setState(() => _isLoading = false);
    }
  }

  // ... (Funciones _abrirMapa y _entregarPaquete IGUAL que antes, pégalas aquí si se borraron, 
  // o usa el código anterior para rellenar esta parte. 
  // Solo asegúrate de llamar a _cargarTodo() al final de _entregarPaquete) ...
  
  void _abrirMapa(double lat, double lng) async {
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        print('No se pudo abrir el mapa');
      }
  }

  Future<void> _entregarPaquete(int id) async {
    // ... COPIA AQUÍ TU LÓGICA DE ENTREGA ANTERIOR ...
    // ... PERO AL FINAL LLAMA A: _cargarTodo();
    
    // Si quieres pego la lógica completa aquí abajo para que no batalles:
    final ImagePicker picker = ImagePicker();
    final source = kIsWeb ? ImageSource.gallery : ImageSource.camera;
    final XFile? foto = await picker.pickImage(source: source);
    if (foto == null) return;
    setState(() => _isLoading = true);
    
    double lat = 0.0, lng = 0.0;
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      lat = position.latitude;
      lng = position.longitude;
    } catch (e) { print(e); }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/paquetes/$id/entregar"));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['latitud'] = lat.toString();
    request.fields['longitud'] = lng.toString();
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes('file', await foto.readAsBytes(), filename: 'evidencia.jpg'));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', foto.path));
    }
    var response = await request.send();
    if (response.statusCode == 200) {
       _cargarTodo(); // <--- ACTUALIZA AMBAS LISTAS
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Entregado"), backgroundColor: Colors.green));
    } else {
       setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController( // <--- CONTROLADOR DE PESTAÑAS
      length: 2, 
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("Paquexpress", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.indigo[800],
          foregroundColor: Colors.white,
          bottom: TabBar( // <--- BARRA DE PESTAÑAS
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.local_shipping), text: "EN RUTA"),
              Tab(icon: Icon(Icons.history), text: "HISTORIAL"),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout), 
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pop(context);
              }
            ),
          ],
        ),
        body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : TabBarView( // <--- VISTAS DE LAS PESTAÑAS
              children: [
                // PESTAÑA 1: PENDIENTES
                _buildLista(pendientes, esHistorial: false),
                
                // PESTAÑA 2: HISTORIAL
                _buildLista(historial, esHistorial: true),
              ],
            ),
      ),
    );
  }

  // Widget reutilizable para las listas
  Widget _buildLista(List<dynamic> lista, {required bool esHistorial}) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(esHistorial ? Icons.history_toggle_off : Icons.inbox, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(esHistorial ? "No hay historial aún" : "Todo entregado 🎉", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final p = lista[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(15),
            leading: CircleAvatar(
              backgroundColor: esHistorial ? Colors.green[100] : Colors.orange[100],
              child: Icon(
                esHistorial ? Icons.check : Icons.local_shipping, 
                color: esHistorial ? Colors.green : Colors.orange
              ),
            ),
            title: Text(p['direccion_destino'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(esHistorial ? "Entregado exitosamente" : "ID: #${p['id']} - Pendiente"),
            trailing: esHistorial 
              ? Icon(Icons.check_circle, color: Colors.green) // Solo icono si ya se entregó
              : Row( // Botones de acción si está pendiente
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.map, color: Colors.blue),
                      onPressed: () => _abrirMapa(p['latitud_destino'], p['longitud_destino']),
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.red),
                      onPressed: () => _entregarPaquete(p['id']),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }
}