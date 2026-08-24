import 'package:flutter/material.dart';

import '../../domain/entities/history_entity.dart';

class HistoryCard extends StatelessWidget {
  final HistoryEntity history;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.history,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color getAdviceColor() {
      final lowercase = history.buyAdvice.toLowerCase();
      if (lowercase.contains('highly')) return const Color(0xFF2E7D32);
      if (lowercase.contains('recommend')) return const Color(0xFF43A047);
      if (lowercase.contains('consider')) return const Color(0xFFFB8C00);
      return const Color(0xFFE53935);
    }

    final adviceColor = getAdviceColor();
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              adviceColor.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, adviceColor),
              const SizedBox(height: 16),
              _buildScoresRow(context),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildDetailsSection(context),
              const SizedBox(height: 16),
              _buildReasoning(context),
              const SizedBox(height: 16),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color adviceColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getFeatureIcon(history.feature),
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatFeatureName(history.feature),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: adviceColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: adviceColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  history.buyAdvice.toUpperCase(),
                  style: TextStyle(
                    color: adviceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
          tooltip: 'Delete',
          onPressed: onDelete,
        ),
      ],
    );
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature) {
      case 'skin_tone': return Icons.face;
      case 'size': return Icons.straighten;
      case 'quality': return Icons.texture;
      case 'buy': return Icons.shopping_bag_outlined;
      default: return Icons.auto_awesome;
    }
  }

  Widget _buildScoresRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: 'Size Match',
            score: history.sizeMatchScore,
            icon: Icons.straighten,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: 'Color Match',
            score: history.colorMatchScore,
            icon: Icons.palette_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: 'Quality',
            score: history.qualityScore,
            icon: Icons.high_quality_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreIndicator(
    BuildContext context, {
    required String label,
    required int score,
    required IconData icon,
  }) {
    final Color scoreColor;
    if (score >= 80) {
      scoreColor = const Color(0xFF2E7D32);
    } else if (score >= 60) {
      scoreColor = const Color(0xFFFB8C00);
    } else {
      scoreColor = const Color(0xFFE53935);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scoreColor),
          const SizedBox(height: 6),
          Text(
            '$score%',
            style: TextStyle(
              color: scoreColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(icon: Icons.face, label: 'Skin Tone', value: history.skinTone),
        _InfoRow(icon: Icons.person_outline, label: 'Estimated Size', value: history.estimatedSize),
        _InfoRow(icon: Icons.checkroom, label: 'Rec. Size', value: history.recommendedSize),
        _InfoRow(icon: Icons.texture, label: 'Texture', value: history.clothingTexture),
        _InfoRow(icon: Icons.high_quality, label: 'Quality Note', value: history.clothingQuality),
      ],
    );
  }

  Widget _buildReasoning(BuildContext context) {
    if (history.reasoning.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'AI Reasoning',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            history.reasoning,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              _formatDateTime(history.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          'FitLens Verified',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatFeatureName(String feature) {
    switch (feature) {
      case 'skin_tone': return 'Skin Tone Analysis';
      case 'size': return 'Size Recommendation';
      case 'quality': return 'Quality Analysis';
      case 'buy': return 'Outfit Fit Analysis';
      case 'all': return 'Complete Fit Analysis';
      default: return feature.toUpperCase();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label, 
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}