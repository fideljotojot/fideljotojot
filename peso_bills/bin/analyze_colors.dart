import 'dart:io';
import 'dart:math' as math;
import 'package:peso_bills/utils/color_analyzer.dart';

void main() async {
  stdout.writeln('Analyzing colors in bill images...\n');

  try {
    final results = await ColorAnalyzer.analyzeAllBillImages();

    for (final result in results) {
      if (result.containsKey('error')) {
        stdout.writeln('❌ ${result['error']}\n');
        continue;
      }

      stdout.writeln('📄 ${result['filename']}');
      stdout.writeln('   Size: ${result['width']}x${result['height']}');
      stdout.writeln(
        '   Average Color: ${result['averageColor']['hex']} (RGB: ${result['averageColor']['rgb']})',
      );
      stdout.writeln('   Dominant Colors:');

      final dominantColors = result['dominantColors'] as List;
      for (int i = 0; i < math.min(5, dominantColors.length); i++) {
        final color = dominantColors[i];
        stdout.writeln(
          '     ${i + 1}. ${color['hex']} (RGB: ${color['rgb']}) - ${color['percentage']}%',
        );
      }
      stdout.writeln('');
    }

    // Summary of all colors
    stdout.writeln('\n=== COLOR SUMMARY ===\n');
    final allColors = <String, int>{};

    for (final result in results) {
      if (result.containsKey('error')) continue;

      final dominantColors = result['dominantColors'] as List;
      for (final color in dominantColors.take(3)) {
        final hex = color['hex'] as String;
        allColors[hex] = (allColors[hex] ?? 0) + 1;
      }
    }

    final sortedColors = allColors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    stdout.writeln('Most common colors across all bills:');
    for (final entry in sortedColors.take(10)) {
      stdout.writeln('  ${entry.key}: appears in ${entry.value} image(s)');
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
