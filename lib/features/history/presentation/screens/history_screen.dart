import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/floating_fashion_background.dart';
import '../../domain/entities/history_entity.dart';
import '../providers/history_provider.dart';
import '../widgets/history_card.dart';

/// Screen that displays the current user's saved analysis and
/// recommendation history.
///
/// Reads state from [historyNotifierProvider] and renders loading,
/// error, empty, or success UI accordingly. Delete and clear actions
/// require confirmation before delegating to the notifier — no
/// Firestore or business logic lives in this widget.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider);
    final notifier = ref.read(historyNotifierProvider.notifier);

    final hasHistory = historyState.value?.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'History',
          style: Theme.of(context).appBarTheme.titleTextStyle ??
              TextStyle(
                fontFamily: 'MontserratAlternates',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -0.5,
              ),
        ),
        centerTitle: true,
        actions: [
          if (hasHistory)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear History',
              onPressed: () => _confirmClearHistory(context, notifier),
            ),
        ],
      ),
      body: FloatingFashionBackground(
        child: historyState.when(
          loading: () => _buildLoading(context),
          error: (error, stackTrace) => _buildError(context, error, notifier),
          data: (history) {
            if (history.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildHistoryList(context, history, notifier);
          },
        ),
      ),
    );
  }

  /// Renders the loading state: a spinner with a status message.
  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading history...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Renders the error state: an error icon, message, and retry button.
  Widget _buildError(BuildContext context, Object error, HistoryNotifier notifier) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: notifier.refreshHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders the empty state: an icon and explanatory text shown when
  /// no history records exist yet.
  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No history yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your analyzed outfits will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the success state: a pull-to-refresh list of [HistoryCard]
  /// widgets, one per history record.
  Widget _buildHistoryList(
      BuildContext context,
      List<HistoryEntity> history,
      HistoryNotifier notifier,
      ) {
    return RefreshIndicator(
      onRefresh: notifier.refreshHistory,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final record = history[index];
          return HistoryCard(
            history: record,
            onDelete: () => _confirmDeleteHistory(context, notifier, record),
          );
        },
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a single history
  /// record, only proceeding if the user confirms.
  Future<void> _confirmDeleteHistory(
      BuildContext context,
      HistoryNotifier notifier,
      HistoryEntity history,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: const Text(
          'Are you sure you want to delete this history record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.deleteHistory(history.id);
    }
  }

  /// Shows a confirmation dialog before clearing all history records,
  /// only proceeding if the user confirms.
  Future<void> _confirmClearHistory(
      BuildContext context,
      HistoryNotifier notifier,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all saved history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.clearHistory();
    }
  }
}