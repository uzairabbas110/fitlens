class PackingItem {
  final String id;
  final String name;
  final String category; // 'Tops', 'Bottoms', 'Outerwear', 'Shoes', 'Accessories', 'Essentials'
  final int quantity;
  final bool isChecked;

  const PackingItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isChecked = false,
  });

  PackingItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    bool? isChecked,
  }) {
    return PackingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Packing Item',
      category: json['category'] as String? ?? 'Clothing',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isChecked: json['isChecked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'isChecked': isChecked,
  };
}

class DayOutfitPlan {
  final int dayNumber;
  final String dayTitle; // e.g. "Day 1: Arrival & Exploring Old Town"
  final String activity; // e.g. "Walking & Casual Dinner"
  final String temperatureExpected; // e.g. "24°C / 75°F Sunny"
  final List<String> outfitPieces; // e.g. ["Linen Short Sleeve Shirt", "Khaki Chino Shorts", "Canvas Low Sneakers"]
  final String eveningLayerTip; // e.g. "Bring lightweight denim jacket for coastal breeze"

  const DayOutfitPlan({
    required this.dayNumber,
    required this.dayTitle,
    required this.activity,
    required this.temperatureExpected,
    required this.outfitPieces,
    required this.eveningLayerTip,
  });

  factory DayOutfitPlan.fromJson(Map<String, dynamic> json) {
    final rawPieces = json['outfitPieces'];
    List<String> pieces = [];
    if (rawPieces is List) {
      pieces = rawPieces.map((e) => e.toString()).toList();
    }

    return DayOutfitPlan(
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
      dayTitle: json['dayTitle'] as String? ?? 'Day 1 Itinerary',
      activity: json['activity'] as String? ?? 'Sightseeing & Casual Dinner',
      temperatureExpected: json['temperatureExpected'] as String? ?? 'Moderate',
      outfitPieces: pieces,
      eveningLayerTip: json['eveningLayerTip'] as String? ?? 'Pack an easy light layer.',
    );
  }

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'dayTitle': dayTitle,
    'activity': activity,
    'temperatureExpected': temperatureExpected,
    'outfitPieces': outfitPieces,
    'eveningLayerTip': eveningLayerTip,
  };
}

class TravelTripPlan {
  final String destination;
  final int durationDays;
  final String tripType; // 'Beach & Resort', 'City & Culture', 'Business & Formal', 'Adventure & Mountains'
  final String? genderPreference; // 'Women', 'Men', 'Unisex'
  final String climateSummary;
  final String luggageAdvice;
  final List<PackingItem> checklist;
  final List<DayOutfitPlan> dayByDayOutfits;

  const TravelTripPlan({
    required this.destination,
    required this.durationDays,
    required this.tripType,
    this.genderPreference,
    required this.climateSummary,
    required this.luggageAdvice,
    required this.checklist,
    required this.dayByDayOutfits,
  });

  factory TravelTripPlan.fromJson(Map<String, dynamic> json) {
    final rawChecklist = json['checklist'] as List<dynamic>? ?? [];
    final rawOutfits = json['dayByDayOutfits'] as List<dynamic>? ?? [];

    return TravelTripPlan(
      destination: json['destination'] as String? ?? 'Destination',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 3,
      tripType: json['tripType'] as String? ?? 'Vacation',
      genderPreference: json['genderPreference'] as String? ?? 'Women',
      climateSummary: json['climateSummary'] as String? ?? 'Sunny & Mild',
      luggageAdvice: json['luggageAdvice'] as String? ?? 'Carry-on approved capsule packing list.',
      checklist: rawChecklist.map((c) => PackingItem.fromJson(c as Map<String, dynamic>)).toList(),
      dayByDayOutfits: rawOutfits.map((o) => DayOutfitPlan.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }

  TravelTripPlan copyWith({
    String? destination,
    int? durationDays,
    String? tripType,
    String? genderPreference,
    String? climateSummary,
    String? luggageAdvice,
    List<PackingItem>? checklist,
    List<DayOutfitPlan>? dayByDayOutfits,
  }) {
    return TravelTripPlan(
      destination: destination ?? this.destination,
      durationDays: durationDays ?? this.durationDays,
      tripType: tripType ?? this.tripType,
      genderPreference: genderPreference ?? this.genderPreference,
      climateSummary: climateSummary ?? this.climateSummary,
      luggageAdvice: luggageAdvice ?? this.luggageAdvice,
      checklist: checklist ?? this.checklist,
      dayByDayOutfits: dayByDayOutfits ?? this.dayByDayOutfits,
    );
  }

  Map<String, dynamic> toJson() => {
    'destination': destination,
    'durationDays': durationDays,
    'tripType': tripType,
    'genderPreference': genderPreference,
    'climateSummary': climateSummary,
    'luggageAdvice': luggageAdvice,
    'checklist': checklist.map((c) => c.toJson()).toList(),
    'dayByDayOutfits': dayByDayOutfits.map((o) => o.toJson()).toList(),
  };
}
