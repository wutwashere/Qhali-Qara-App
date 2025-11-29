import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:qhaliqara_app/data/notifiers.dart';
import 'package:qhaliqara_app/models/historyrecord.dart';

// para MobileNetV2
const int MOBILENET_INPUT_SIZE = 224;
const List<double> IMAGENET_MEAN = [0.485, 0.456, 0.406];
const List<double> IMAGENET_STD = [0.229, 0.224, 0.225];

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

  int _environmentFrameCount = 0;
  int _skinFrameCount = 0;
  final int _minFramesForDetection = 3;
  double _confidenceThreshold = 0.01;

  final List<String> classes = [
    'Benign',
    'Squamous_Cell_Carcinoma',
    'Basal_Cell_Carcinoma',
    'Melanoma'
  ];

  bool _isShowingEnvironment = false;
  bool _debugMode = true;

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
        options: InterpreterOptions()..threads = 4,
      );
      setState(() {
        _isModelLoaded = true;
      });
      print('Modelo MobileNetV2 cargado exitosamente');
      _verifyMobileNetInput();
    } catch (e) {
      print('Error al cargar el modelo: $e');
    }
  }

  Future<void> _verifyMobileNetInput() async {
    try {
      final inputTensors = _interpreter.getInputTensors();
      final outputTensors = _interpreter.getOutputTensors();

      print('MobileNetV2 - Especificaciones:');

      for (var tensor in inputTensors) {
        print('Input: Shape=${tensor.shape}, Type=${tensor.type}');
      }

      for (var tensor in outputTensors) {
        print('Output: Shape=${tensor.shape}, Type=${tensor.type}');
      }

    } catch (e) {
      print('Error verificando MobileNet: $e');
    }
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (mounted) {
          _startRealtimeDetection();
        }
      });

      setState(() {});
    } catch (e) {
      print('Error al configurar cámara: $e');
    }
  }

  void _startRealtimeDetection() {
    _controller!.startImageStream((CameraImage image) {
      if (_isModelLoaded && mounted) {
        _frameCount++;
        if (_frameCount % 15 == 0) {
          _processFrame(image);
        }
      }
    });
  }

  void _processFrame(CameraImage image) {
    try {
      if (_debugMode && _frameCount % 30 == 0) {
        print('Procesando frame ${_frameCount} para MobileNetV2...');
      }

      var inputTensor = _convertCameraImageToTensor(image);

      if (_debugMode && _frameCount % 30 == 0) {
        _debugMobileNetInput(inputTensor);
      }

      var input = [inputTensor];
      var output = List.filled(1 * 4, 0.0).reshape([1, 4]);

      _interpreter.run(input, output);

      var prediction = _processMobileNetOutput(output[0]);

      if (_debugMode && _frameCount % 30 == 0) {
        print('MobileNet Prediction:');
        print('Class: ${prediction['class']}');
        print('Confidence: ${prediction['confidence_percent']}');
        print('All: ${prediction['all_predictions']}');
      }

      final isEnvironment = _isLikelyEnvironment(prediction);

      if (isEnvironment) {
        _environmentFrameCount++;
        _skinFrameCount = 0;
      } else {
        _skinFrameCount++;
        _environmentFrameCount = 0;
      }

      if (mounted) {
        setState(() {
          if (_skinFrameCount >= _minFramesForDetection) {
            _isShowingEnvironment = false;
            _currentPrediction = prediction;
          } else if (_environmentFrameCount >= _minFramesForDetection) {
            _isShowingEnvironment = true;
            _currentPrediction = null;
          }
        });
      }
    } catch (e) {
      if (_debugMode) {
        print('Error en MobileNet inference: $e');
      }
    }
  }

  List<List<List<double>>> _convertCameraImageToTensor(CameraImage image) {
    var tensor = List.generate(
      MOBILENET_INPUT_SIZE,
          (y) => List.generate(
        MOBILENET_INPUT_SIZE,
            (x) => List.filled(3, 0.0),
      ),
    );

    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        _convertYUV420ForMobileNet(image, tensor);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        _convertBGRAForMobileNet(image, tensor);
      } else {
        _convertDefaultForMobileNet(image, tensor);
      }

      _applyMobileNetPreprocessing(tensor);

    } catch (e) {
      print('Error en conversión: $e');
      _fillWithMobileNetTestPattern(tensor);
    }

    return tensor;
  }

  void _convertYUV420ForMobileNet(CameraImage image, List<List<List<double>>> tensor) {
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final yStride = image.planes[0].bytesPerRow;
    final uvStride = image.planes[1].bytesPerRow;

    final width = image.width;
    final height = image.height;

    for (int y = 0; y < MOBILENET_INPUT_SIZE; y++) {
      for (int x = 0; x < MOBILENET_INPUT_SIZE; x++) {
        final srcX = (x * width / MOBILENET_INPUT_SIZE).toInt().clamp(0, width - 1);
        final srcY = (y * height / MOBILENET_INPUT_SIZE).toInt().clamp(0, height - 1);

        final yIndex = srcY * yStride + srcX;
        final uvIndex = (srcY ~/ 2) * uvStride + (srcX & ~1);

        if (yIndex < yPlane.length && uvIndex + 1 < uPlane.length) {
          final yValue = yPlane[yIndex].toDouble();
          final uValue = uPlane[uvIndex].toDouble();
          final vValue = vPlane[uvIndex + 1].toDouble();

          // Conversión YUV to RGB
          final r = yValue + 1.402 * (vValue - 128.0);
          final g = yValue - 0.344136 * (uValue - 128.0) - 0.714136 * (vValue - 128.0);
          final b = yValue + 1.772 * (uValue - 128.0);

          tensor[y][x] = [
            r.clamp(0.0, 255.0),
            g.clamp(0.0, 255.0),
            b.clamp(0.0, 255.0)
          ];
        }
      }
    }
  }

  void _convertBGRAForMobileNet(CameraImage image, List<List<List<double>>> tensor) {
    final bytes = image.planes[0].bytes;
    final stride = image.planes[0].bytesPerRow;
    final width = image.width;
    final height = image.height;

    for (int y = 0; y < MOBILENET_INPUT_SIZE; y++) {
      for (int x = 0; x < MOBILENET_INPUT_SIZE; x++) {
        final srcX = (x * width / MOBILENET_INPUT_SIZE).toInt().clamp(0, width - 1);
        final srcY = (y * height / MOBILENET_INPUT_SIZE).toInt().clamp(0, height - 1);

        final pixelIndex = srcY * stride + srcX * 4;

        if (pixelIndex + 2 < bytes.length) {
          final b = bytes[pixelIndex].toDouble();
          final g = bytes[pixelIndex + 1].toDouble();
          final r = bytes[pixelIndex + 2].toDouble();

          tensor[y][x] = [r, g, b];
        }
      }
    }
  }

  void _convertDefaultForMobileNet(CameraImage image, List<List<List<double>>> tensor) {
    final width = image.width;
    final height = image.height;

    for (int y = 0; y < MOBILENET_INPUT_SIZE; y++) {
      for (int x = 0; x < MOBILENET_INPUT_SIZE; x++) {
        final srcX = (x * width / MOBILENET_INPUT_SIZE).round();
        final srcY = (y * height / MOBILENET_INPUT_SIZE).round();

        // Crear un patrón simple de colores
        final r = (srcX / width * 255.0).clamp(0.0, 255.0);
        final g = (srcY / height * 255.0).clamp(0.0, 255.0);
        final b = 128.0;

        tensor[y][x] = [r, g, b];
      }
    }
  }

  void _applyMobileNetPreprocessing(List<List<List<double>>> tensor) {
    for (int y = 0; y < MOBILENET_INPUT_SIZE; y++) {
      for (int x = 0; x < MOBILENET_INPUT_SIZE; x++) {
        for (int c = 0; c < 3; c++) {
          // 1. Normalizar a [0, 1]
          double normalized = tensor[y][x][c] / 255.0;

          // 2. Aplicar mean y std de ImageNet
          normalized = (normalized - IMAGENET_MEAN[c]) / IMAGENET_STD[c];

          tensor[y][x][c] = normalized;
        }
      }
    }
  }

  void _fillWithMobileNetTestPattern(List<List<List<double>>> tensor) {
    print('Usando patrón de prueba MobileNet-compatible');
    for (int y = 0; y < MOBILENET_INPUT_SIZE; y++) {
      for (int x = 0; x < MOBILENET_INPUT_SIZE; x++) {
        final r = ((x / MOBILENET_INPUT_SIZE) * 255.0).clamp(0.0, 255.0);
        final g = ((y / MOBILENET_INPUT_SIZE) * 255.0).clamp(0.0, 255.0);
        final b = 128.0;

        tensor[y][x] = [
          (r / 255.0 - IMAGENET_MEAN[0]) / IMAGENET_STD[0],
          (g / 255.0 - IMAGENET_MEAN[1]) / IMAGENET_STD[1],
          (b / 255.0 - IMAGENET_MEAN[2]) / IMAGENET_STD[2],
        ];
      }
    }
  }

  void _debugMobileNetInput(List<List<List<double>>> tensor) {
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;
    List<double> channelSums = [0, 0, 0];
    int pixelCount = MOBILENET_INPUT_SIZE * MOBILENET_INPUT_SIZE;

    for (int y = 0; y < MOBILENET_INPUT_SIZE; y++) {
      for (int x = 0; x < MOBILENET_INPUT_SIZE; x++) {
        for (int c = 0; c < 3; c++) {
          double val = tensor[y][x][c];
          minVal = min(minVal, val);
          maxVal = max(maxVal, val);
          channelSums[c] += val;
        }
      }
    }

    print('MobileNet Input Range:');
    print('Min: ${minVal.toStringAsFixed(3)}');
    print('Max: ${maxVal.toStringAsFixed(3)}');
    print('Channel Means: R=${(channelSums[0]/pixelCount).toStringAsFixed(3)}, '
        'G=${(channelSums[1]/pixelCount).toStringAsFixed(3)}, '
        'B=${(channelSums[2]/pixelCount).toStringAsFixed(3)}');
  }

  Map<String, dynamic> _processMobileNetOutput(List<double> predictions) {
    // Aplicar softmax para convertir logits en probabilidades
    final softmaxPredictions = _applySoftmax(predictions);

    double maxConfidence = 0.0;
    int predictedClass = 0;

    for (int i = 0; i < softmaxPredictions.length; i++) {
      if (softmaxPredictions[i] > maxConfidence) {
        maxConfidence = softmaxPredictions[i];
        predictedClass = i;
      }
    }

    return {
      'class': classes[predictedClass],
      'confidence': maxConfidence * 100,
      'confidence_percent': '${(maxConfidence * 100).toStringAsFixed(1)}%',
      'class_index': predictedClass,
      'all_predictions': softmaxPredictions,
    };
  }

  List<double> _applySoftmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final expLogits = logits.map((x) => exp(x - maxLogit)).toList();
    final sumExp = expLogits.reduce((a, b) => a + b);

    return expLogits.map((x) => x / sumExp).toList();
  }

  bool _isLikelyEnvironment(Map<String, dynamic> prediction) {
    final confidence = prediction['confidence'] / 100.0;
    final allPredictions = prediction['all_predictions'] as List<double>;

    if (_debugMode && _frameCount % 30 == 0) {
      print('Análisis de entorno:');
      print('Confianza máxima: ${confidence.toStringAsFixed(3)}');
      print('Todas las predicciones: $allPredictions');
    }

    // 1. Si la confianza es muy baja
    if (confidence < _confidenceThreshold) {
      if (_debugMode && _frameCount % 30 == 0) print('Confianza muy baja');
      return true;
    }

    // 2. Si las predicciones están muy balanceadas
    final maxProb = allPredictions.reduce((a, b) => a > b ? a : b);
    final secondMax = allPredictions.where((p) => p != maxProb).reduce((a, b) => a > b ? a : b);
    final difference = maxProb - secondMax;

    if (difference < 0.2) {
      if (_debugMode && _frameCount % 30 == 0) print('Predicciones balanceadas, diferencia: ${difference.toStringAsFixed(3)}');
      return true;
    }

    // 3. Verificar que las probabilidades sumen ~1.0
    final sum = allPredictions.reduce((a, b) => a + b);
    if (sum < 0.9 || sum > 1.1) {
      if (_debugMode && _frameCount % 30 == 0) print('Suma de probabilidades anómala: ${sum.toStringAsFixed(3)}');
      return true;
    }

    if (_debugMode && _frameCount % 30 == 0) print('Parece una detección válida');
    return false;
  }

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

  void _saveToHistory(HistoryRecord record) {
    addHistoryRecord(record);
    _showSaveSuccess();
  }

  void _showSaveSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Análisis guardado en historial'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
                _buildUserGuidance(),
                if (_currentPrediction != null)
                  _buildPredictionOverlay(),
                _buildCaptureButton(),
              ],
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Iniciando cámara para MobileNetV2...',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            );
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
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
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
            ..._buildAllProbabilities(prediction),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAllProbabilities(Map<String, dynamic> prediction) {
    final allPredictions = prediction['all_predictions'] as List<double>;
    return [
      SizedBox(height: 8),
      Text(
        'Todas las probabilidades:',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      ...classes.asMap().entries.map((entry) {
        final index = entry.key;
        final className = entry.value;
        final prob = allPredictions[index];
        return Text(
          '${className}: ${(prob * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        );
      }),
    ];
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            if (_currentPrediction != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lesión detectada - Listo para capturar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 16),
            FloatingActionButton(
              backgroundColor: _currentPrediction != null ? Colors.amber : Colors.grey,
              onPressed: _currentPrediction != null ? _takePicture : null,
              child: Icon(Icons.camera_alt, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGuidance() {
    return Stack(
      children: [
        if (_isShowingEnvironment)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Buscando lesión en la piel...\nApunta directamente a la lesión con buena luz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 120,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Cómo usar:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '- Buena iluminación natural\n'
                      '- Enfoca directamente la lesión\n'
                      '- Mantén estable la cámara\n'
                      '- Acércate a ~15cm de distancia\n'
                      '- Espera el indicador',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _takePicture() async {
    if (_currentPrediction == null) return;

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      final historyRecord = HistoryRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        diagnosis: _currentPrediction!['class'],
        confidence: _currentPrediction!['confidence'] / 100.0,
        dateTime: DateTime.now(),
        imagePath: image.path,
        allPredictions: List<double>.from(_currentPrediction!['all_predictions']),
      );

      _saveToHistory(historyRecord);
      _showDetailedResults(historyRecord);

    } catch (e) {
      print('Error al tomar foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al capturar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDetailedResults(HistoryRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultados del Análisis - MobileNetV2'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (record.imagePath != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(File(record.imagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorByClass(record.diagnosis).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getColorByClass(record.diagnosis)),
                ),
                child: Row(
                  children: [
                    Icon(_getIconByClass(record.diagnosis),
                        color: _getColorByClass(record.diagnosis)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.diagnosis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getColorByClass(record.diagnosis),
                            ),
                          ),
                          Text(
                            'Confianza: ${(record.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              if (record.allPredictions != null) ...[
                Text('Todas las probabilidades:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ..._buildAllProbabilitiesFromRecord(record),
                SizedBox(height: 8),
              ],

              Text('${_formatDate(record.dateTime)} ${_formatTime(record.dateTime)}',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHistoryScreen();
            },
            child: Text('Ver Historial'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllProbabilitiesFromRecord(HistoryRecord record) {
    if (record.allPredictions == null) return [];

    return classes.asMap().entries.map((entry) {
      final index = entry.key;
      final className = entry.value;
      final prob = record.allPredictions![index] * 100;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(className)),
            Text('${prob.toStringAsFixed(1)}%'),
          ],
        ),
      );
    }).toList();
  }

  void _navigateToHistoryScreen() {
    selectedScreenNotifier.value = 1;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}