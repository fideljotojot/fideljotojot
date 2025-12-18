import 'dart:io';
import 'package:peso_bills/ml/bill_classifier.dart';

/// Test script to validate sample images for polymer 100 and polymer 50
/// This helps ensure the model correctly identifies these bill types
Future<void> main() async {
  final classifier = BillClassifier();

  try {
    await classifier.initialize();

    final separator = List.filled(60, '=').join();
    stdout.writeln(separator);
    stdout.writeln('Testing Sample Images for Polymer Bill Accuracy');
    stdout.writeln(separator);
    stdout.writeln('');

    // Test sample (1) - should be polymer 100
    stdout.writeln(
      'Testing sample (1).jpg (Expected: polymer ₱100 peso bill)...',
    );
    final sample1File = File('assets/images/sample (1).jpg');
    if (await sample1File.exists()) {
      final prediction1 = await classifier.classify(sample1File);
      if (prediction1 != null) {
        stdout.writeln('  ✓ Prediction: ${prediction1.displayLabel}');
        stdout.writeln(
          '  ✓ Confidence: ${(prediction1.confidence * 100).toStringAsFixed(2)}%',
        );
        stdout.writeln('  ✓ Material: ${prediction1.materialHint}');
        stdout.writeln('  ✓ Value: ₱${prediction1.valueMatch}');

        // Check if it's correctly identified as polymer 100
        final isPolymer100 =
            prediction1.label.contains('polymer') &&
            prediction1.label.contains('100');
        if (isPolymer100) {
          stdout.writeln('  ✓ CORRECTLY IDENTIFIED as polymer ₱100');
        } else {
          stdout.writeln(
            '  ✗ MISIDENTIFIED - Expected polymer ₱100, got: ${prediction1.label}',
          );
          stdout.writeln('  All scores:');
          prediction1.scores.forEach((label, score) {
            if (score > 0.1) {
              stdout.writeln(
                '    - $label: ${(score * 100).toStringAsFixed(2)}%',
              );
            }
          });
        }
      } else {
        stdout.writeln('  ✗ No prediction returned (confidence too low)');
      }
    } else {
      stdout.writeln('  ✗ File not found: ${sample1File.path}');
    }

    stdout.writeln('');

    // Test sample (2) - should be polymer 50
    stdout.writeln(
      'Testing sample (2).jpg (Expected: polymer ₱50 peso bill)...',
    );
    final sample2File = File('assets/images/sample (2).jpg');
    if (await sample2File.exists()) {
      final prediction2 = await classifier.classify(sample2File);
      if (prediction2 != null) {
        stdout.writeln('  ✓ Prediction: ${prediction2.displayLabel}');
        stdout.writeln(
          '  ✓ Confidence: ${(prediction2.confidence * 100).toStringAsFixed(2)}%',
        );
        stdout.writeln('  ✓ Material: ${prediction2.materialHint}');
        stdout.writeln('  ✓ Value: ₱${prediction2.valueMatch}');

        // Check if it's correctly identified as polymer 50
        final isPolymer50 =
            prediction2.label.contains('polymer') &&
            prediction2.label.contains('50');
        if (isPolymer50) {
          stdout.writeln('  ✓ CORRECTLY IDENTIFIED as polymer ₱50');
        } else {
          stdout.writeln(
            '  ✗ MISIDENTIFIED - Expected polymer ₱50, got: ${prediction2.label}',
          );
          stdout.writeln('  All scores:');
          prediction2.scores.forEach((label, score) {
            if (score > 0.1) {
              stdout.writeln(
                '    - $label: ${(score * 100).toStringAsFixed(2)}%',
              );
            }
          });
        }
      } else {
        stdout.writeln('  ✗ No prediction returned (confidence too low)');
      }
    } else {
      stdout.writeln('  ✗ File not found: ${sample2File.path}');
    }

    stdout.writeln('');
    stdout.writeln(separator);
    stdout.writeln('Test Complete');
    stdout.writeln(separator);
  } catch (e) {
    stderr.writeln('Error: $e');
  } finally {
    classifier.close();
  }
}
