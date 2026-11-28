import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isLoading = true;
  bool isTakingPhoto = false;
  String? error;

  @override
  void initState() {
    super.initState();
    startCamera();
  }

  Future<void> startCamera() async {
    try {
      final cameras = await availableCameras();

      if (!mounted) return;

      if (cameras.isEmpty) {
        throw Exception('Камера табылмады');
      }

      controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
    } catch (e) {
      error = 'Камераны ашу мүмкін болмады: $e';
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> takePhoto() async {
    final camera = controller;

    if (camera == null ||
        !camera.value.isInitialized ||
        isTakingPhoto) {
      return;
    }

    setState(() {
      isTakingPhoto = true;
    });

    try {
      final photo = await camera.takePicture();

      if (!mounted) return;

      Navigator.pop(context, photo);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото түсіру мүмкін болмады'),
        ),
      );

      setState(() {
        isTakingPhoto = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Камера'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : error != null
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                : CameraPreview(controller!),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(0, 55),
            ),
            onPressed: isLoading ||
                    error != null ||
                    isTakingPhoto
                ? null
                : takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Фото түсіру'),
          ),
        ),
      ),
    );
  }
}