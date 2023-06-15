import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(home: MyQR()));

Future<void> getNewInsignia(BuildContext context, String? idChallenge) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? idUser = prefs.getString("idUser");
  final String token = prefs.getString('token') ?? "";
  String path =
      'http://${dotenv.env['API_URL']}/user/challenges/addinsignia/$idUser/$idChallenge';
  var response = await Dio().get(path,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }));
  // if (response.statusCode == 200) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Nueva insignia desbloqueada")));
  // } else {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Error al obtener nueva insignia")));
  // }
}

class MyQR extends StatelessWidget {
  const MyQR({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const Center(
              child: QRViewExample(),
            ),
            Positioned(
              top: 25,
              left: 25,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/navbar');
                },
                backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: const Color.fromARGB(255, 222, 66, 66),
              borderRadius: 20,
              borderLength: 35,
              borderWidth: 13,
              cutOutSize: scanArea + 20),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (result != null)
                    FutureBuilder<void>(
                      future: getNewInsignia(context, result!.code),
                      builder:
                          (BuildContext context, AsyncSnapshot<void> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          // La llamada a getNewInsignia ha finalizado
                          return Container(); // Puedes retornar cualquier Widget aquí
                        } else {
                          // La llamada a getNewInsignia aún no ha finalizado
                          return CircularProgressIndicator(); // Muestra un indicador de progreso o cualquier otro Widget mientras se espera
                        }
                      },
                    )
                  // getNewInsignia(context, result!.code)
                  // Text(
                  //     'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.fromLTRB(8, 8, 30, 8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 222, 66, 66),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                              backgroundColor:
                                  const Color.fromARGB(255, 222, 66, 66),
                              foregroundColor: Colors.white,
                            ),
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Icon(
                                    snapshot.data == true
                                        ? Icons.flash_on
                                        : Icons.flash_off,
                                    size: 24,
                                  );
                                } else {
                                  return const Icon(
                                    Icons.access_time_filled,
                                    size: 24,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 222, 66, 66),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                              backgroundColor:
                                  const Color.fromARGB(255, 222, 66, 66),
                              foregroundColor: Colors.white,
                            ),
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return const Icon(
                                    Icons.sync_rounded,
                                    size: 24,
                                  );
                                } else {
                                  return const Icon(
                                    Icons.access_time_filled,
                                    size: 24,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                ]))
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
