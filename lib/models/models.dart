class MaterialItem {
  final String name;
  final double quantityTechnical; // Uso real
  final double quantityPurchase; // Arredondado para compra
  final String unit;

  MaterialItem({
    required this.name,
    required this.quantityTechnical,
    required this.quantityPurchase,
    required this.unit,
  });

  double get stockLeftover => quantityPurchase - quantityTechnical;

  String get formattedQuantity {
    // Se for inteiro (ex: 14.0), mostra 14. Se for decimal (ex: 1.5), mostra 1.5
    if (quantityPurchase % 1 == 0) {
      return quantityPurchase.toStringAsFixed(0);
    }
    return quantityPurchase.toStringAsFixed(2);
  }

  @override
  String toString() {
    return '$name: $formattedQuantity $unit (Técnico: ${quantityTechnical.toStringAsFixed(2)})';
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantityTechnical': quantityTechnical,
    'quantityPurchase': quantityPurchase,
    'unit': unit,
  };

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      name: json['name'],
      quantityTechnical: json['quantityTechnical'],
      quantityPurchase: json['quantityPurchase'],
      unit: json['unit'],
    );
  }
}

class CalculationResult {
  final List<MaterialItem> materials;
  final double area;
  final String moduleName;

  CalculationResult({
    required this.materials,
    required this.area,
    required this.moduleName,
  });

  Map<String, dynamic> toJson() => {
    'materials': materials.map((m) => m.toJson()).toList(),
    'area': area,
    'moduleName': moduleName,
  };

  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      materials: (json['materials'] as List).map((i) => MaterialItem.fromJson(i)).toList(),
      area: json['area'],
      moduleName: json['moduleName'],
    );
  }
}

class SavedQuote {
  final int? id;
  final String clientName;
  final double totalValue;
  final String date;
  final CalculationResult result;

  SavedQuote({
    this.id,
    required this.clientName,
    required this.totalValue,
    required this.date,
    required this.result,
  });

  Map<String, dynamic> toMap() {
    // In a real app we'd serialize 'result' to JSON string
    return {
      'id': id,
      'client_name': clientName,
      'total_value': totalValue,
      'date': date,
      // We will store the full object calculation as a JSON string for simplicity
      // Or you could normalize. For MVP CRM, storing JSON string is fine.
    };
  }
}

class ProfessionalProfile {
  final String companyName;
  final String phone;
  final String pixKey;
  // In a real app, this might be a path or bytes. For PDF we often use MemoryImage or similar.
  // We'll keep it simple for the model.
  final String? logoPath;

  ProfessionalProfile({
    required this.companyName,
    required this.phone,
    required this.pixKey,
    this.logoPath,
  });
}
