class StyledOutfitPiece {
  final String category; // 'Top / Shirt', 'Bottom / Trouser', 'Outerwear / Jacket', 'Footwear', 'Accessories'
  final String itemName;
  final String color;
  final String details;

  const StyledOutfitPiece({
    required this.category,
    required this.itemName,
    required this.color,
    required this.details,
  });

  factory StyledOutfitPiece.fromJson(Map<String, dynamic> json) {
    return StyledOutfitPiece(
      category: json['category'] as String? ?? 'Piece',
      itemName: json['itemName'] as String? ?? 'Garment',
      color: json['color'] as String? ?? 'Classic',
      details: json['details'] as String? ?? 'Tailored finish',
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'itemName': itemName,
    'color': color,
    'details': details,
  };
}

class EventStylingResult {
  final String eventName;
  final String dressCode; // 'Black Tie', 'Cocktail / Semi-Formal', 'Business Professional', 'Smart Casual', 'Casual Chic'
  final String styleHeadline;
  final String colorHarmonyAnalysis;
  final List<StyledOutfitPiece> outfitBreakdown;
  final List<String> accessoriesAndJewelry;
  final String groomingAndFragranceTip;
  final String confidenceAndPostureTip;

  const EventStylingResult({
    required this.eventName,
    required this.dressCode,
    required this.styleHeadline,
    required this.colorHarmonyAnalysis,
    required this.outfitBreakdown,
    required this.accessoriesAndJewelry,
    required this.groomingAndFragranceTip,
    required this.confidenceAndPostureTip,
  });

  factory EventStylingResult.fromJson(Map<String, dynamic> json) {
    final rawPieces = json['outfitBreakdown'] as List<dynamic>? ?? [];
    final rawAcc = json['accessoriesAndJewelry'];
    List<String> accList = [];
    if (rawAcc is List) {
      accList = rawAcc.map((e) => e.toString()).toList();
    }

    return EventStylingResult(
      eventName: json['eventName'] as String? ?? 'Special Occasion',
      dressCode: json['dressCode'] as String? ?? 'Smart Casual',
      styleHeadline: json['styleHeadline'] as String? ?? 'Refined & Effortless Silhouette',
      colorHarmonyAnalysis: json['colorHarmonyAnalysis'] as String? ?? 'Sophisticated tonal contrast.',
      outfitBreakdown: rawPieces.map((p) => StyledOutfitPiece.fromJson(p as Map<String, dynamic>)).toList(),
      accessoriesAndJewelry: accList,
      groomingAndFragranceTip: json['groomingAndFragranceTip'] as String? ?? 'Subtle woody fragrance and clean lines.',
      confidenceAndPostureTip: json['confidenceAndPostureTip'] as String? ?? 'Stand tall with relaxed shoulders.',
    );
  }

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'dressCode': dressCode,
    'styleHeadline': styleHeadline,
    'colorHarmonyAnalysis': colorHarmonyAnalysis,
    'outfitBreakdown': outfitBreakdown.map((p) => p.toJson()).toList(),
    'accessoriesAndJewelry': accessoriesAndJewelry,
    'groomingAndFragranceTip': groomingAndFragranceTip,
    'confidenceAndPostureTip': confidenceAndPostureTip,
  };
}
