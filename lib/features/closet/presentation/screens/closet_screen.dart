import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../../core/widgets/fitlens_logo.dart';
import '../providers/closet_provider.dart';
import '../../domain/entities/closet_item_entity.dart';

class ClosetScreen extends ConsumerWidget {
  const ClosetScreen({super.key});

  Future<void> _pickImage(WidgetRef ref, BuildContext context, {String? overrideCategory, String? overrideSeason}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (image != null) {
      ref.read(isUploadingProvider.notifier).set(true);
      try {
        final bytes = await image.readAsBytes();
        await ref.read(closetProvider.notifier).addClosetItem(bytes, overrideCategory: overrideCategory, overrideSeason: overrideSeason);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorHandler.getMessage(e, 'Unable to add wardrobe item. Please try again.'))),
          );
        }
      } finally {
        ref.read(isUploadingProvider.notifier).set(false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closetState = ref.watch(filteredClosetProvider);
    final isUploading = ref.watch(isUploadingProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final selectedSeason = ref.watch(selectedSeasonProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FloatingFashionBackground(
        child: Stack(
          children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                elevation: 0,
                pinned: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: const FitLensLogo(fontSize: 24),
                actions: [
                  IconButton(
                    icon: Icon(Icons.auto_awesome, color: colorScheme.primary),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search your wardrobe...',
                            hintStyle: TextStyle(color: colorScheme.outline, fontWeight: FontWeight.w500),
                            prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Categories Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: ['All', 'Tops', 'Bottoms', 'Dresses', 'Shoes', 'Accessories'].map((category) {
                            final isSelected = selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () => ref.read(selectedCategoryProvider.notifier).update(category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: const Color(0xFF3D2930).withValues(alpha: 0.08),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ] : null,
                                  ),
                                  child: Text(
                                    category,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Seasons Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: ['All', 'Spring', 'Summer', 'Autumn', 'Winter'].map((season) {
                            final isSelected = selectedSeason == season;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () => ref.read(selectedSeasonProvider.notifier).update(season),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(
                                    season,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 10x30 Capsule VIP Wardrobe Banner
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.capsule),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3D2930), Color(0xFF7E3B50)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7E3B50).withValues(alpha: 0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.auto_awesome_mosaic, color: Color(0xFFC5A267), size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '10x30 Capsule Generator',
                                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'VIP',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFC5A267)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Turn 10 closet items into 30 distinct looks',
                                      style: TextStyle(fontSize: 11.5, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              closetState.when(
                data: (items) {
                  if (items.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checkroom, size: 80, color: colorScheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text(
                              'Your closet is empty',
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: isUploading ? null : () => _pickImage(
                                ref, 
                                context,
                                overrideCategory: selectedCategory != 'All' ? selectedCategory : null,
                                overrideSeason: selectedSeason != 'All' ? selectedSeason : null,
                              ),
                              icon: const Icon(Icons.add_a_photo),
                              label: Text(selectedCategory != 'All' ? 'Add $selectedCategory' : 'Add Item'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 100),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return InkWell(
                              onTap: isUploading ? null : () => _pickImage(
                                ref, 
                                context,
                                overrideCategory: selectedCategory != 'All' ? selectedCategory : null,
                                overrideSeason: selectedSeason != 'All' ? selectedSeason : null,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: colorScheme.outlineVariant, width: 2, style: BorderStyle.solid),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 40, color: colorScheme.primary),
                                      const SizedBox(height: 8),
                                      Text(
                                        selectedCategory != 'All' ? 'Add $selectedCategory' : 'Add Item',
                                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return ClosetItemCard(item: items[index - 1]);
                        },
                        childCount: items.length + 1,
                      ),
                    ),
                  );
                },
                loading: () => SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                ),
                error: (error, _) => const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Unable to load wardrobe items. Please pull to refresh.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(
                          'Analyzing & Uploading...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      )),
    );
  }
}

class ClosetItemCard extends ConsumerWidget {
  final ClosetItemEntity item;

  const ClosetItemCard({super.key, required this.item});

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Delete Item?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this ${item.category} (${item.color}) from your wardrobe?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(closetProvider.notifier).deleteClosetItem(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wardrobe item deleted successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ErrorHandler.getMessage(e, 'Unable to delete wardrobe item. Please try again.')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D2930).withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: colorScheme.surfaceContainerLow,
                      child: AppImage(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          color: colorScheme.outlineVariant,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Delete Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showDeleteDialog(context, ref),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} • ${item.color} • ${item.season}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

