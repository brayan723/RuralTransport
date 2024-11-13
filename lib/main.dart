import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Paquete para la conectividad
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login.dart'; // Asegúrate de tener la página de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App de GPS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 58, 116, 183),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// SplashScreen: pantalla inicial que muestra el logo o un mensaje breve
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity(); // Verifica la conectividad al iniciar
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  // Función para verificar la conexión a Internet
  void _checkConnectivity() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
  }

  // Función que se llama cuando la conectividad cambia
  void _onConnectivityChanged(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      // Si vuelve la conexión, puedes hacer algo aquí, por ejemplo, eliminar el mensaje
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // Mostrar un diálogo de alerta si no hay conexión a Internet
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin Conexión a Internet'),
          content: const Text(
              'Por favor, revisa tu conexión a Internet y vuelve a intentarlo.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Después de cerrar el diálogo, intentamos de nuevo conectar
                Future.delayed(const Duration(seconds: 2), () {
                  _checkConnectivity(); // Volver a verificar la conectividad
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription
        ?.cancel(); // Cancelar la suscripción cuando ya no sea necesario
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 58, 116, 183),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(
              Icons.location_on,
              color: Colors.white,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Mi App de GPS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
