import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chợ & Khu vực'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () {},
            tooltip: 'Thêm chợ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(),
            const SizedBox(height: 20),
            Text(
              'Chợ gần đây',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _EmptyMarketCard(),
            const SizedBox(height: 20),
            Text(
              'Khu vực trong chợ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _ZoneChips(),
            const SizedBox(height: 12),
            _EmptyZoneCard(),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm chợ, siêu thị...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
        suffixIcon: const Icon(Icons.tune, color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyMarketCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có chợ nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Thêm chợ để theo dõi giá cả',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ZoneChips extends StatelessWidget {
  final _zones = const [
    ('🥩 Khu thịt', false),
    ('🥦 Khu rau', false),
    ('🌸 Khu hoa', false),
    ('🍬 Bánh kẹo', false),
    ('🎁 Quà Tết', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _zones
          .map((z) => Chip(
                label: Text(z.$1),
                backgroundColor: z.$2
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceVariant,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color:
                      z.$2 ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      z.$2 ? FontWeight.w600 : FontWeight.normal,
                ),
              ))
          .toList(),
    );
  }
}

class _EmptyZoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'Chọn chợ để xem khu vực',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
