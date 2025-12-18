import 'package:flutter/material.dart';

class Denomination {
  const Denomination({
    required this.value,
    required this.color,
    required this.material,
    required this.securityFeatures,
  });

  final int value;
  final Color color;
  final BillMaterial material;
  final List<String> securityFeatures;
}

enum BillMaterial { paper, polymer }

extension BillMaterialLabel on BillMaterial {
  String get label {
    switch (this) {
      case BillMaterial.paper:
        return 'Paper';
      case BillMaterial.polymer:
        return 'Polymer series (2022+)';
    }
  }
}
