import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> _cameraAvailable;
CameraController _cameraController = CameraController(
  CameraDescription(
    name: "test",
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 1,
  ),
  ResolutionPreset.max,
);

Future<void> initializeController = Future.value((){});
XFile? _imageFile;
String? _errorMessage;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  _initializeCamera() async {
    _cameraAvailable = await availableCameras();

    print("Camera is not empty ${_cameraAvailable.isNotEmpty}");

    if (_cameraAvailable.isEmpty) {
      _errorMessage = "No camera available";
      setState(() {});
      return;
    }

    _cameraController = CameraController(
      _cameraAvailable[0],
      ResolutionPreset.max,
    );
    initializeController = _cameraController.initialize();

    setState(() {});
  }
  
  
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    //_cameraController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _errorMessage != null
            ? Text(_errorMessage!)
            : Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: FutureBuilder<void>(
                  future: initializeController,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_cameraController);
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
      ),

      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(10)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(15),
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(Colors.black),
        ),
        onPressed: _captureImage,
        child: Icon(Icons.camera, color: Colors.white),
      ),
    );
    
  }

  Future<void> _captureImage() async {
    try {
      await initializeController;
      final img = await _cameraController.takePicture();
      setState(() {
        _imageFile = img;
      });

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = File(
        "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      print("${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await _imageFile!.saveTo(imagePath.path);

      if (context.mounted) {
        var snackBar =
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Image saved")));

        Future.delayed(Duration(seconds: 2), ()=>
          snackBar.close()
        );
      }

      showDialog(
        context: context,
        builder: (context) {
          return Center(child: Image.file(File(img.path)));
        },
      );
    } catch (e) {}
  }

  
}