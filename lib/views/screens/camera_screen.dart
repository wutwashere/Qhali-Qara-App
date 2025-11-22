import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  Map<String, dynamic>? _currentPrediction;
  int _frameCount = 0;

  final List<String> classes = [
    'Benign',
    'Squamous_Cell_Carcinoma',
    'Basal_Cell_Carcinoma',
    'Melanoma'
  ];

  bool _isShowingEnvironment = true;

  @override
  void initState() {
    super.initState();
    _setupCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/cancer_classifier.tflite',
        options: InterpreterOptions()..threads = 2,
      );
      setState(() {
        _isModelLoaded = true;
      });
      print('Modelo cargado');
    } catch (e) {
      print('Error al cargar el modelo: $e');
    }
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) {
      _startRealtimeDetection();
    });
    setState(() {

    });
  }

  //deteccion aqui esta
  void _startRealtimeDetection() {
    _controller!.startImageStream((CameraImage image) {
      if (_isModelLoaded) {
        _frameCount++;
        if (_frameCount % 5 == 0) {
          _processFrame(image);
        }
      }
    });
  }

  void _processFrame(CameraImage image) {
    try {
      var inputTensor = _convertCameraImageToTensor(image);
      var input = [inputTensor];
      var output = List.filled(1 * 4, 0.0).reshape([1, 4]);

      _interpreter.run(input, output);

      var prediction = _processOutput(output[0]);
      final isEnvironment = _isLikelyEnvironment(prediction);

      //confirmacion
      if (isEnvironment) {
        _environmentFrameCount++;
        _skinFrameCount = 0;
      } else {
        _skinFrameCount++;
        _environmentFrameCount = 0;
      }

      setState(() {
        //confirmar si hay prediccion
        if (_skinFrameCount >= _minFramesForDetection) {
          _isShowingEnvironment = false;
          _currentPrediction = prediction;
        } else if (_environmentFrameCount >= _minFramesForDetection) {
          _isShowingEnvironment = true;
          _currentPrediction = null;
        }
      });
    } catch (e) {
      print('Error al procesar el fotograma: $e');
    }
  }

  //convertir imagen a tensor
  List<List<List<double>>> _convertCameraImageToTensor(CameraImage image) {
    const targetSize = 160;

    var tensor = List.generate(
      targetSize,
      (y) => List.generate(
        targetSize,
        (x) => List.filled(3, 0.0)
        ),
    );

    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        _convertYUV420(image, tensor, targetSize);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        _convertBRGA(image, tensor, targetSize);
      } else {
        _convertDefault(image, tensor, targetSize);
      }
    } catch (e) {
      print('Error en conversión: $e');
      _fillWithDefaultValues(tensor, targetSize);
    }

    return tensor;
  }

  void _convertYUV420(CameraImage image, List<List<List<double>>> tensor, int targetSize) {
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final yStride = image.planes[0].bytesPerRow;
    final uvStride = image.planes[1].bytesPerRow;

    final width = image.width;
    final height = image.height;
    final scaleX = width / targetSize;
    final scaleY = height / targetSize;

    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        final srcX = (x * scaleX).toInt();
        final srcY = (y * scaleY).toInt();

        final yIndex = srcY * yStride + srcX;
        final uvIndex = (srcY ~/ 2) * uvStride + (srcX ~/ 2) * 2;

        final yValue = yPlane[yIndex].toDouble();
        final uValue = uPlane[uvIndex].toDouble();
        final vValue = vPlane[uvIndex + 1].toDouble();

        final r = (yValue + 1.402 * (vValue - 128)).clamp(0.0, 255.0) / 255.0;
        final g = (yValue - 0.34414 * (uValue - 128) - 0.71414 * (vValue - 128)).clamp(0.0, 255.0) / 255.0;
        final b = (yValue + 1.772 * (uValue - 128)).clamp(0.0, 255.0) / 255.0;

        tensor[y][x] = [r, g, b];
      }
    }
  }

  void _convertBRGA(CameraImage image, List<List<List<double>>> tensor, int targetSize) {
    final bytes = image.planes[0].bytes;
    final stride = image.planes[0].bytesPerRow;

    final width = image.width;
    final height = image.height;
    final scaleX = width / targetSize;
    final scaleY = height / targetSize;

    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        final srcX = (x * scaleX).toInt();
        final srcY = (y * scaleY).toInt();

        final pixelIndex = srcY * stride + srcX * 4;

        final b = bytes[pixelIndex].toDouble() / 255.0;
        final g = bytes[pixelIndex + 1].toDouble() / 255.0;
        final r = bytes[pixelIndex + 2].toDouble() / 255.0;

        tensor[y][x] = [r, g, b];
      }
    }
  }

  void _convertDefault(CameraImage image, List<List<List<double>>> tensor, int targetSize) {
    final int width = image.width;
    final int height = image.height;
    final scaleX = width / targetSize;
    final scaleY = height / targetSize;

    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        final srcX = (x * scaleX).round();
        final srcY = (y * scaleY).round();

        tensor[y][x] = [
          (srcX / width),
          (srcY / height),
          0.5,
        ];
      }
    }
  }

  void _fillWithDefaultValues(List<List<List<double>>> tensor, int targetSize) {
    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        tensor[y][x] = [
          (x / targetSize),
          (y / targetSize),
          0.5,
        ];
      }
    }
  }

  // resultados
  Map<String, dynamic> _processOutput(List<double> predictions) {
    double maxConfidence = 0.0;
    int predictedClass = 0;

    for (int i = 0; i < predictions.length; i++) {
      if (predictions[i] > maxConfidence) {
        maxConfidence = predictions[i];
        predictedClass = i;
      }
    }

    return {
      'class': classes[predictedClass],
      'confidence': maxConfidence * 100,
      'confidence_percent': '${(maxConfidence * 100).toStringAsFixed(1)}%',
      'class_index': predictedClass,
    };
  }

  //color por clase
  Color _getColorByClass(String className) {
    switch (className) {
      case 'Melanoma':
        return Colors.red;
      case 'Squamous_Cell_Carcinoma':
        return Colors.orange;
      case 'Basal_Cell_Carcinoma':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  //icono por clase
  IconData _getIconByClass(String className) {
    switch (className) {
      case 'Melanoma':
        return Icons.warning;
      case 'Squamous_Cell_Carcinoma':
        return Icons.error_outline;
      case 'Basal_Cell_Carcinoma':
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller!),

                //guia
                _buildUserGuidance(),

                //resultados si no es entorno
                if (!_isShowingEnvironment && _currentPrediction != null)
                  _buildPredictionOverlay(),

                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: _takePicture,
                      child: const Icon(Icons.camera_alt, color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPredictionOverlay() {
    final prediction = _currentPrediction!;
    final color = _getColorByClass(prediction['class']);
    final icon = _getIconByClass(prediction['class']);

    return Positioned(
      top: 50,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  prediction['class'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Confianza: ${prediction['confidence_percent']}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),

            ),
          ],
        ),
      ),
    );
  }


  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto guardada: ${image.path}'),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () {},
          ),
        ),
      );
      print('Imagen capturada');
      //proceso foto detalle
      _processCapturedImage(image.path);

    } catch (e) {
      print('Error al tomar foto: $e');
    }
  }

  void _processCapturedImage(String imagePath) {
    print('Procesando imagen: $imagePath');

    if (_currentPrediction != null) {
      _showDetailedResults();
    }
  }

  void _showDetailedResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultados del análisis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clase: ${_currentPrediction!['class']}'),
            Text('Confianza: ${_currentPrediction!['confidence_percent']}'),
            SizedBox(height: 16),
            Text('Todas las probabilidades: '),
            for (int i = 0; i < classes.length; i++)
              Text('${classes[i]}: ${(_currentPrediction!['all_predictions']?[i] ?? 0 * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  double _confidenceThreshold = 0.65;
  int _environmentFrameCount = 0;
  int _skinFrameCount = 0;
  final int _minFramesForDetection = 5;

  bool _isLikelyEnvironment(Map<String, dynamic> prediction) {
    final confidence = prediction['confidence'] / 100.0;
    final allPredictions = prediction['all_predictions'] as List<double>;

    //baja confianza
    if (confidence < _confidenceThreshold) {
      return true;
    }

    //predicciones dispersas
    final sortedPredictions = List<double>.from(allPredictions)..sort();
    final variance = sortedPredictions.last - sortedPredictions.first;
    if (variance < 0.4) {
      return true;
    }

    //verificar benigno
    final benignProb = allPredictions[0];
    if (benignProb < 0.1) {
      return true;
    }

    return false;
  }

  Widget _buildUserGuidance() {
    return Column(
      children: [
        if (_isShowingEnvironment)
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Buscando lesión en la piel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Como usar: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Enfoca directamente la lesión de piel\n'
                      '2. Mantén estable la cámara\n'
                      '3. Acércate para mejor detección',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}