import '../../data/brand_size_charts.dart';

class SizeCalculatorService {
  static List<String> getRecommendations(double? chestInches, double? waistInches) {
    if (chestInches == null && waistInches == null) {
      return ["Unable to determine size without measurements."];
    }

    final recommendations = <String>[];

    for (final brandEntry in BrandSizeCharts.brands.entries) {
      final brandName = brandEntry.key;
      final sizeChart = brandEntry.value;

      String? matchedSize;
      
      for (final sizeRule in sizeChart) {
        final minChest = sizeRule['min_chest'] as double;
        final maxChest = sizeRule['max_chest'] as double;
        final minWaist = sizeRule['min_waist'] as double;
        final maxWaist = sizeRule['max_waist'] as double;

        bool chestMatches = chestInches != null && (chestInches >= minChest && chestInches < maxChest);
        bool waistMatches = waistInches != null && (waistInches >= minWaist && waistInches < maxWaist);

        // If both are provided, both should ideally match, or at least one is strongly matched.
        // For simplicity, we prioritize chest for tops/overall, but if chest is null we use waist.
        if (chestInches != null && chestMatches) {
          matchedSize = sizeRule['size'];
          break;
        } else if (chestInches == null && waistInches != null && waistMatches) {
          matchedSize = sizeRule['size'];
          break;
        }
      }

      if (matchedSize != null) {
        recommendations.add("$brandName: Size $matchedSize");
      } else {
        // Find nearest size if out of bounds
        recommendations.add("$brandName: Custom/Check Chart");
      }
    }

    return recommendations;
  }
}
