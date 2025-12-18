import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class BillClassifier {
  static const _modelAssetPath = 'assets/models/model_unquant.tflite';
  static const _labelsAssetPath = 'assets/models/labels.txt';
  static const _inputSize = 224;

  /// Minimum confidence threshold (0.0-1.0). Predictions below this will be rejected.
  /// Set to null to disable threshold filtering.
  double? minConfidenceThreshold = 0.5;

  /// Enable test-time augmentation (averaging predictions from multiple augmented images).
  /// This improves accuracy but increases processing time.
  bool enableTestTimeAugmentation = true;

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> initialize() async {
    if (_interpreter != null && _labels != null) {
      return;
    }

    try {
      _interpreter = await Interpreter.fromAsset(_modelAssetPath);
      final rawLabels = await rootBundle.loadString(_labelsAssetPath);
      _labels = rawLabels
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (error) {
      throw BillClassifierException(
        'Failed to load Teachable Machine assets. '
        'Ensure peso_bills.tflite and labels.txt are placed under assets/models.\n$error',
      );
    }
  }

  Future<BillPrediction?> classify(File imageFile) async {
    await initialize();

    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw BillClassifierException('Unable to decode the captured image.');
    }

    // Apply image enhancement for better accuracy
    final enhancedImage = _enhanceImage(decodedImage);

    List<double> averagedPredictions;

    if (enableTestTimeAugmentation) {
      // Test-time augmentation: average predictions from multiple augmented versions
      averagedPredictions = _classifyWithAugmentation(enhancedImage);
    } else {
      // Single prediction
      averagedPredictions = _runInference(enhancedImage);
    }

    if (averagedPredictions.isEmpty) {
      debugPrint('BillClassifier: No predictions returned from model');
      return null;
    }

    // Find best prediction
    int bestIndex = 0;
    double bestConfidence = averagedPredictions[0];
    for (int i = 1; i < averagedPredictions.length; i++) {
      if (averagedPredictions[i] > bestConfidence) {
        bestConfidence = averagedPredictions[i];
        bestIndex = i;
      }
    }

    debugPrint(
      'BillClassifier: Best confidence: ${(bestConfidence * 100).toStringAsFixed(1)}%',
    );

    // Apply confidence threshold if set
    if (minConfidenceThreshold != null &&
        bestConfidence < minConfidenceThreshold!) {
      debugPrint(
        'BillClassifier: Confidence ${(bestConfidence * 100).toStringAsFixed(1)}% '
        'below threshold ${(minConfidenceThreshold! * 100).toStringAsFixed(1)}%',
      );
      return null;
    }

    // Safety checks
    if (_labels == null || _labels!.isEmpty) {
      throw BillClassifierException('Labels not loaded');
    }

    if (bestIndex >= _labels!.length) {
      throw BillClassifierException('Best index out of bounds');
    }

    if (averagedPredictions.length != _labels!.length) {
      throw BillClassifierException(
        'Prediction length (${averagedPredictions.length}) does not match labels length (${_labels!.length})',
      );
    }

    // Build a map of all class scores so the UI can display full confidence
    // statistics for every label.
    final allScores = <String, double>{};
    for (
      int i = 0;
      i < averagedPredictions.length && i < _labels!.length;
      i++
    ) {
      final rawLabel = _labels![i];
      final cleanedLabel = rawLabel.replaceFirst(RegExp(r'^\d+\s*'), '');
      allScores[cleanedLabel] = averagedPredictions[i];
    }

    return BillPrediction(
      label: _labels![bestIndex],
      confidence: bestConfidence,
      scores: allScores,
    );
  }

  /// Run inference on a single image and return raw predictions
  List<double> _runInference(img.Image image) {
    if (_interpreter == null) {
      throw BillClassifierException('Interpreter not initialized');
    }

    try {
      final processedImageData = _processImage(image);
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;

      if (outputShape.length < 2) {
        throw BillClassifierException('Invalid output tensor shape');
      }

      final outputBuffer = List<List<double>>.generate(
        outputShape[0],
        (_) => List<double>.filled(outputShape[1], 0),
      );

      _interpreter!.runForMultipleInputs(
        [processedImageData],
        {0: outputBuffer},
      );

      if (outputBuffer.isEmpty || outputBuffer[0].isEmpty) {
        return [];
      }

      final rawOutput = outputBuffer[0];
      return rawOutput;
    } catch (e) {
      throw BillClassifierException('Inference failed: $e');
    }
  }

  /// Classify with test-time augmentation by averaging predictions from multiple augmented images
  List<double> _classifyWithAugmentation(img.Image image) {
    final predictions = <List<double>>[];

    try {
      // Original image
      predictions.add(_runInference(image));

      // Brightness variations
      try {
        final brighter = img.adjustColor(image, brightness: 1.1);
        predictions.add(_runInference(brighter));
      } catch (_) {
        // If augmentation fails, skip it
      }

      try {
        final darker = img.adjustColor(image, brightness: 0.9);
        predictions.add(_runInference(darker));
      } catch (_) {
        // If augmentation fails, skip it
      }

      // Contrast variations
      try {
        final higherContrast = img.adjustColor(image, contrast: 1.1);
        predictions.add(_runInference(higherContrast));
      } catch (_) {
        // If augmentation fails, skip it
      }

      try {
        final lowerContrast = img.adjustColor(image, contrast: 0.9);
        predictions.add(_runInference(lowerContrast));
      } catch (_) {
        // If augmentation fails, skip it
      }

      // Gamma correction variations (helps with different lighting conditions)
      try {
        final higherGamma = img.adjustColor(image, gamma: 1.15);
        predictions.add(_runInference(higherGamma));
      } catch (_) {
        // If augmentation fails, skip it
      }

      try {
        final lowerGamma = img.adjustColor(image, gamma: 0.9);
        predictions.add(_runInference(lowerGamma));
      } catch (_) {
        // If augmentation fails, skip it
      }
    } catch (e) {
      // If all augmentations fail, return empty list
      return [];
    }

    // Safety check: ensure we have at least one prediction
    if (predictions.isEmpty) {
      return [];
    }

    // Average all predictions
    final numClasses = predictions[0].length;
    final averaged = List<double>.filled(numClasses, 0.0);
    int validPredictionCount = 0; // Track count of actually-used predictions

    for (final pred in predictions) {
      // Safety check: ensure prediction has correct length
      if (pred.length != numClasses) continue;
      // Only count and use predictions with correct length
      validPredictionCount++;
      for (int i = 0; i < numClasses; i++) {
        averaged[i] += pred[i];
      }
    }

    // Normalize by number of valid augmentations actually used
    // Use validPredictionCount instead of predictions.length to account for skipped predictions
    if (validPredictionCount > 0) {
      for (int i = 0; i < numClasses; i++) {
        averaged[i] /= validPredictionCount;
      }
    }

    return averaged;
  }

  /// Enhance image quality for better classification accuracy
  /// Optimized for polymer bills (especially polymer 50 and 100) based on sample images
  img.Image _enhanceImage(img.Image image) {
    // Analyze image characteristics to determine optimal enhancement
    final imageStats = _analyzeImageCharacteristics(image);

    // Apply adaptive enhancement based on image characteristics
    // Polymer bills typically have lighter, more neutral tones and need
    // different enhancement than paper bills
    var enhanced = image;

    // Enhanced preprocessing optimized for polymer bills (50 and 100)
    // Based on analysis of sample (1) for polymer 100 and sample (2) for polymer 50
    if (_isLikelyPolymerBill(imageStats)) {
      // Polymer bills benefit from stronger contrast and brightness adjustments
      // to enhance the subtle features and security elements
      enhanced = img.adjustColor(
        enhanced,
        contrast: 1.12, // Stronger contrast for polymer bill features
        brightness:
            1.05, // Slightly higher brightness for polymer's lighter tones
        saturation: 0.95, // Slightly desaturate to emphasize neutral tones
        gamma: 1.08, // Higher gamma for better mid-tone detail in polymer bills
      );
    } else {
      // Standard enhancement for paper bills
      enhanced = img.adjustColor(
        enhanced,
        contrast:
            1.08, // Increased contrast boost for better feature visibility
        brightness: 1.03, // Slight brightness boost
        saturation: 1.0, // Keep saturation neutral
        gamma: 1.05, // Slight gamma adjustment for better mid-tone detail
      );
    }

    return enhanced;
  }

  /// Analyze image characteristics to help determine optimal preprocessing
  _ImageStats _analyzeImageCharacteristics(img.Image image) {
    if (image.width <= 0 || image.height <= 0) {
      return _ImageStats(0, 0, 0);
    }

    // Sample pixels for performance (every 10th pixel)
    int totalPixels = 0;
    double totalBrightness = 0;
    double totalSaturation = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixelSafe(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        // Calculate brightness (luminance)
        final brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;

        // Calculate saturation
        final max = math.max(math.max(r, g), b) / 255.0;
        final min = math.min(math.min(r, g), b) / 255.0;
        final saturation = max == 0 ? 0 : (max - min) / max;

        totalBrightness += brightness;
        totalSaturation += saturation;
        totalPixels++;
      }
    }

    if (totalPixels == 0) {
      return _ImageStats(0, 0, 0);
    }

    return _ImageStats(
      totalBrightness / totalPixels,
      totalSaturation / totalPixels,
      totalPixels,
    );
  }

  /// Determine if image is likely a polymer bill based on characteristics
  /// Polymer bills typically have:
  /// - Higher average brightness (lighter tones)
  /// - Lower saturation (more neutral colors)
  /// - Cream/off-white backgrounds
  bool _isLikelyPolymerBill(_ImageStats stats) {
    // Thresholds based on analysis of sample (1) and sample (2)
    // Polymer bills tend to be brighter and less saturated
    return stats.averageBrightness > 0.55 && stats.averageSaturation < 0.25;
  }

  List<List<List<List<double>>>> _processImage(img.Image image) {
    // Safety checks
    if (image.width <= 0 || image.height <= 0) {
      throw BillClassifierException(
        'Invalid image dimensions: ${image.width}x${image.height}',
      );
    }

    // 1. Center crop to square
    final shortestSide = math.min(image.width, image.height);
    if (shortestSide <= 0) {
      throw BillClassifierException('Image too small to process');
    }

    final offsetX = (image.width - shortestSide) ~/ 2;
    final offsetY = (image.height - shortestSide) ~/ 2;

    final cropped = img.copyCrop(
      image,
      offsetX,
      offsetY,
      shortestSide,
      shortestSide,
    );

    if (cropped.width <= 0 || cropped.height <= 0) {
      throw BillClassifierException('Failed to crop image');
    }

    // 2. Resize to model input size using cubic interpolation for better quality
    final resizedImage = img.copyResize(
      cropped,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.cubic, // Better quality than linear
    );

    // 3. Build input tensor [1, height, width, 3], normalized to 0-1
    final imageData = List<List<List<List<double>>>>.generate(
      1,
      (_) => List<List<List<double>>>.generate(
        _inputSize,
        (_) => List<List<double>>.generate(
          _inputSize,
          (_) => List<double>.filled(3, 0),
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resizedImage.getPixelSafe(x, y);
        final r = img.getRed(pixel).toDouble();
        final g = img.getGreen(pixel).toDouble();
        final b = img.getBlue(pixel).toDouble();

        // Normalize from [0,255] to [0,1] which matches Teachable Machine
        // float image models (MobileNet/EfficientNet based).
        imageData[0][y][x][0] = r / 255.0;
        imageData[0][y][x][1] = g / 255.0;
        imageData[0][y][x][2] = b / 255.0;
      }
    }

    return imageData;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}

class BillPrediction {
  BillPrediction({
    required this.label,
    required this.confidence,
    Map<String, double>? scores,
  }) : scores = scores ?? const {};

  final String label;
  final double confidence;

  /// Map of all labels to their raw confidence scores (0–1) from the model.
  /// Keys are cleaned labels without the leading class index.
  final Map<String, double> scores;

  /// Label without the leading class index from Teachable Machine, e.g.
  /// "0 20 peso bill" -> "20 peso bill".
  String get displayLabel => label.replaceFirst(RegExp(r'^\d+\s*'), '');

  /// A human-friendly material hint derived from the label text.
  /// Returns "polymer", "paper", or "unknown".
  String get materialHint {
    if (indicatesPolymer) return 'polymer (plastic)';
    if (indicatesPaper) return 'paper';
    return 'unknown';
  }

  int? get valueMatch {
    // Skip the first digit (class index) and find the actual denomination
    final matches = RegExp(r'\d+').allMatches(label);
    if (matches.length < 2) return null;
    // Get the second number which is the denomination (20, 50, 100, 500, 1000)
    return int.tryParse(matches.elementAt(1).group(0)!);
  }

  bool get indicatesPolymer {
    final normalized = label.toLowerCase();
    return normalized.contains('polymer') ||
        normalized.contains('plastic') ||
        normalized.contains('new');
  }

  bool get indicatesPaper {
    final normalized = label.toLowerCase();

    // Explicitly check for paper/cotton keywords
    if (normalized.contains('paper') || normalized.contains('cotton')) {
      return true;
    }

    // With the current label format in labels.txt:
    // - Regular bills: "₱20 peso bill", "₱50 peso bill", "₱100 peso bill", etc.
    //   These do NOT contain "polymer", "plastic", or "new" keywords
    // - Polymer bills: "polymer ₱50 peso bill", "polymer ₱100 peso bill", etc.
    //   These explicitly contain "polymer" keyword

    // Check explicitly for polymer indicators
    final hasPolymerKeyword =
        normalized.contains('polymer') ||
        normalized.contains('plastic') ||
        normalized.contains('new');

    // If it doesn't have polymer keywords, it's a paper bill
    // This matches the label format where regular bills (without "polymer" prefix) are paper
    return !hasPolymerKeyword;
  }
}

class BillClassifierException implements Exception {
  BillClassifierException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Internal class to store image statistics for adaptive preprocessing
class _ImageStats {
  _ImageStats(this.averageBrightness, this.averageSaturation, this.sampleCount);

  final double averageBrightness;
  final double averageSaturation;
  final int sampleCount;
}
