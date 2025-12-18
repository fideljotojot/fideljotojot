import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

/// Analyzes dominant colors in bill images
class ColorAnalyzer {
  /// Analyze colors from an image file
  static Map<String, dynamic> analyzeImage(File imageFile) {
    try {
      final bytes = imageFile.readAsBytesSync();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return {'error': 'Failed to decode image: ${imageFile.path}'};
      }

      // Sample pixels (every Nth pixel for performance)
      final colorMap = <int, int>{};
      final totalPixels = image.width * image.height;
      final sampleRate = math.max(
        1,
        totalPixels ~/ 10000,
      ); // Sample ~10k pixels
      int sampledPixelCount = 0; // Track actual number of sampled pixels

      for (int y = 0; y < image.height; y += sampleRate) {
        for (int x = 0; x < image.width; x += sampleRate) {
          final pixel = image.getPixelSafe(x, y);
          final r = img.getRed(pixel);
          final g = img.getGreen(pixel);
          final b = img.getBlue(pixel);

          // Quantize colors to reduce noise (group similar colors)
          final quantizedR = (r ~/ 16) * 16;
          final quantizedG = (g ~/ 16) * 16;
          final quantizedB = (b ~/ 16) * 16;
          final colorKey = (quantizedR << 16) | (quantizedG << 8) | quantizedB;

          colorMap[colorKey] = (colorMap[colorKey] ?? 0) + 1;
          sampledPixelCount++; // Count each sampled pixel
        }
      }

      // Get top 10 dominant colors
      final sortedColors = colorMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final dominantColors = sortedColors.take(10).map((entry) {
        final color = entry.key;
        final r = (color >> 16) & 0xFF;
        final g = (color >> 8) & 0xFF;
        final b = color & 0xFF;
        final count = entry.value;
        // Fix: Use actual sampled pixel count instead of incorrect formula
        // When sampling with step size sampleRate in both dimensions,
        // the actual sample count is sampledPixelCount, not (totalPixels ~/ sampleRate)
        final percentage = sampledPixelCount > 0
            ? (count / sampledPixelCount) * 100
            : 0.0;

        return {
          'rgb': [r, g, b],
          'hex':
              '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}',
          'percentage': percentage.toStringAsFixed(2),
          'count': count,
        };
      }).toList();

      // Calculate average color
      int totalR = 0, totalG = 0, totalB = 0;
      int pixelCount = 0;

      for (int y = 0; y < image.height; y += sampleRate) {
        for (int x = 0; x < image.width; x += sampleRate) {
          final pixel = image.getPixelSafe(x, y);
          totalR += img.getRed(pixel);
          totalG += img.getGreen(pixel);
          totalB += img.getBlue(pixel);
          pixelCount++;
        }
      }

      final avgR = (totalR / pixelCount).round();
      final avgG = (totalG / pixelCount).round();
      final avgB = (totalB / pixelCount).round();

      return {
        'filename': imageFile.path.split(Platform.pathSeparator).last,
        'width': image.width,
        'height': image.height,
        'averageColor': {
          'rgb': [avgR, avgG, avgB],
          'hex':
              '#${avgR.toRadixString(16).padLeft(2, '0')}${avgG.toRadixString(16).padLeft(2, '0')}${avgB.toRadixString(16).padLeft(2, '0')}',
        },
        'dominantColors': dominantColors,
      };
    } catch (e) {
      return {'error': 'Error processing ${imageFile.path}: $e'};
    }
  }

  /// Analyze all bill images in the assets/images directory
  static Future<List<Map<String, dynamic>>> analyzeAllBillImages() async {
    final imagesDir = Directory('assets/images');
    if (!await imagesDir.exists()) {
      throw Exception('assets/images directory not found');
    }

    final results = <Map<String, dynamic>>[];
    final files = imagesDir
        .listSync()
        .whereType<File>()
        .where((file) => !file.path.contains('peso_logo.png'))
        .toList();

    for (final file in files) {
      final result = analyzeImage(file);
      results.add(result);
    }

    return results;
  }
}
