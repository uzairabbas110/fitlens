class CapsuleItem {
  final String id;
  final String name;
  final String category; // 'Top', 'Bottom', 'Layer', 'Shoe', 'Accessory'
  final String color;
  final String styleTip;
  final String? imageUrl;

  const CapsuleItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.styleTip,
    this.imageUrl,
  });

  factory CapsuleItem.fromJson(Map<String, dynamic> json) {
    return CapsuleItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Core Staple',
      category: json['category'] as String? ?? 'Top',
      color: json['color'] as String? ?? 'Neutral',
      styleTip: json['styleTip'] as String? ?? 'Versatile layer',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'color': color,
    'styleTip': styleTip,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}

class CapsuleOutfit {
  final int outfitNumber;
  final String title;
  final String occasion; // 'Work / Business Casual', 'Everyday Casual', 'Evening / Date Night'
  final List<String> itemNames;
  final String whyItWorks;
  final String stylingTip;

  const CapsuleOutfit({
    required this.outfitNumber,
    required this.title,
    required this.occasion,
    required this.itemNames,
    required this.whyItWorks,
    required this.stylingTip,
  });

  factory CapsuleOutfit.fromJson(Map<String, dynamic> json) {
    final rawItems = json['itemNames'];
    List<String> items = [];
    if (rawItems is List) {
      items = rawItems.map((e) => e.toString()).toList();
    }

    return CapsuleOutfit(
      outfitNumber: (json['outfitNumber'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Capsule Look',
      occasion: json['occasion'] as String? ?? 'Everyday Casual',
      itemNames: items,
      whyItWorks: json['whyItWorks'] as String? ?? 'Balanced proportions and neutral harmony.',
      stylingTip: json['stylingTip'] as String? ?? 'Pair with minimal jewelry.',
    );
  }

  Map<String, dynamic> toJson() => {
    'outfitNumber': outfitNumber,
    'title': title,
    'occasion': occasion,
    'itemNames': itemNames,
    'whyItWorks': whyItWorks,
    'stylingTip': stylingTip,
  };
}

class CapsuleWardrobe {
  final String season;
  final String vibe;
  final String colorPaletteSummary;
  final List<CapsuleItem> corePieces; // Exactly 10 pieces
  final List<CapsuleOutfit> outfitFormulas; // Up to 30 outfits

  const CapsuleWardrobe({
    required this.season,
    required this.vibe,
    required this.colorPaletteSummary,
    required this.corePieces,
    required this.outfitFormulas,
  });

  factory CapsuleWardrobe.fromJson(Map<String, dynamic> json) {
    final rawPieces = json['corePieces'] as List<dynamic>? ?? [];
    final rawOutfits = json['outfitFormulas'] as List<dynamic>? ?? [];

    return CapsuleWardrobe(
      season: json['season'] as String? ?? 'All Season',
      vibe: json['vibe'] as String? ?? 'Modern Minimalist',
      colorPaletteSummary: json['colorPaletteSummary'] as String? ?? 'Neutrals, Beige, Navy & White',
      corePieces: rawPieces.map((p) => CapsuleItem.fromJson(p as Map<String, dynamic>)).toList(),
      outfitFormulas: rawOutfits.map((o) => CapsuleOutfit.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'season': season,
    'vibe': vibe,
    'colorPaletteSummary': colorPaletteSummary,
    'corePieces': corePieces.map((p) => p.toJson()).toList(),
    'outfitFormulas': outfitFormulas.map((o) => o.toJson()).toList(),
  };
}
