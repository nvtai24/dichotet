import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';
import '../shopping_list/item_detail_screen.dart';

// ─── Data models ───────────────────────────────────────────────────────────

class _ItemAtStore {
  final ShoppingItem item;
  final int purchasedHere;
  final int totalPurchased;
  final int required;

  const _ItemAtStore({
    required this.item,
    required this.purchasedHere,
    required this.totalPurchased,
    required this.required,
  });

  bool get isDoneOverall => totalPurchased >= required;
  bool get hasPurchasedHere => purchasedHere > 0;
  bool get hasPurchasedElsewhere => !hasPurchasedHere && totalPurchased > 0;
}

class _StoreEntry {
  final String name;
  final List<_ItemAtStore> items;
  final double? distanceMeters;
  final double? lat;
  final double? lon;

  const _StoreEntry({required this.name, required this.items, this.distanceMeters, this.lat, this.lon});

  int get pendingCount => items.where((i) => !i.isDoneOverall).length;
  int get doneCount => items.where((i) => i.isDoneOverall).length;
  int get totalCount => items.length;
  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;
  bool get allDone => pendingCount == 0;
}

double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
      sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

String _fmtDistance(double m) =>
    m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(1)} km';

// ─── Build entries ─────────────────────────────────────────────────────────

List<_StoreEntry> _buildStoreEntries(
  List<ShoppingItem> allItems, {
  Position? userPos,
  List<StorePrice>? storeDetails,
}) {
  final Map<String, Set<int>> storeItemIds = {};

  for (final item in allItems) {
    for (final sp in item.storePrices) {
      storeItemIds.putIfAbsent(sp.storeName.trim(), () => {}).add(item.id!);
    }
    for (final p in item.purchases) {
      final loc = p.locationName?.trim();
      if (loc != null && loc.isNotEmpty) {
        storeItemIds.putIfAbsent(loc, () => {}).add(item.id!);
      }
    }
  }

  final itemById = {for (final i in allItems) i.id: i};
  final entries = <_StoreEntry>[];

  for (final entry in storeItemIds.entries) {
    final storeName = entry.key;
    final items = <_ItemAtStore>[];

    for (final id in entry.value) {
      final item = itemById[id];
      if (item == null) continue;
      final purchasedHere = item.purchases
          .where((p) => p.locationName?.trim() == storeName)
          .fold(0, (s, p) => s + p.quantity);
      final totalPurchased = item.purchases.fold(0, (s, p) => s + p.quantity);
      items.add(_ItemAtStore(
        item: item,
        purchasedHere: purchasedHere,
        totalPurchased: totalPurchased,
        required: item.quantity,
      ));
    }

    // Chỉ giữ item chưa mua đủ
    final pending = items.where((i) => !i.isDoneOverall).toList();
    if (pending.isEmpty) continue;

    pending.sort((a, b) {
      int rank(_ItemAtStore x) => x.hasPurchasedHere ? 0 : 1;
      return rank(a).compareTo(rank(b));
    });

    // Tìm tọa độ cửa hàng
    bool valid(double? v) => v != null && v != -1.0;
    StorePrice? coord;
    for (final i in allItems) {
      coord = i.storePrices
          .where((s) => s.storeName.trim() == storeName && valid(s.lat) && valid(s.lon))
          .firstOrNull;
      if (coord != null) break;
    }
    coord ??= storeDetails
        ?.where((s) => s.storeName.trim() == storeName && valid(s.lat) && valid(s.lon))
        .firstOrNull;

    // Tính khoảng cách nếu có GPS
    double? dist;
    if (userPos != null && coord != null) {
      dist = _haversine(userPos.latitude, userPos.longitude, coord.lat!, coord.lon!);
    }

    entries.add(_StoreEntry(
      name: storeName,
      items: pending,
      distanceMeters: dist,
      lat: coord?.lat,
      lon: coord?.lon,
    ));
  }

  // Sort: có khoảng cách thì sort theo gần nhất, không thì theo số item chưa mua
  entries.sort((a, b) {
    if (a.distanceMeters != null && b.distanceMeters != null) {
      return a.distanceMeters!.compareTo(b.distanceMeters!);
    }
    if (a.distanceMeters != null) return -1;
    if (b.distanceMeters != null) return 1;
    return b.pendingCount.compareTo(a.pendingCount);
  });
  return entries;
}

// ─── Screen ────────────────────────────────────────────────────────────────

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

enum _SortMode { distance, itemCount, name }

class _AllStoresScreenState extends State<AllStoresScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  Position? _userPos;
  _SortMode _sortMode = _SortMode.distance;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  PopupMenuItem<_SortMode> _sortItem(_SortMode mode, IconData icon, String label, _SortMode current) {
    final selected = mode == current;
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 18, color: selected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          if (selected) ...[const Spacer(), const Icon(Icons.check_rounded, size: 16, color: AppColors.primary)],
        ],
      ),
    );
  }

  Future<void> _fetchLocation() async {
    try {
      final svc = await Geolocator.isLocationServiceEnabled();
      if (!svc) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      if (mounted) setState(() => _userPos = pos);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShoppingListViewModel>();
    final all = _buildStoreEntries(
      vm.allItems,
      userPos: _userPos,
      storeDetails: vm.storeDetails,
    );

    var entries = _query.isEmpty
        ? List<_StoreEntry>.from(all)
        : all.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();

    // Sort theo mode
    switch (_sortMode) {
      case _SortMode.distance:
        entries.sort((a, b) {
          if (a.distanceMeters != null && b.distanceMeters != null) return a.distanceMeters!.compareTo(b.distanceMeters!);
          if (a.distanceMeters != null) return -1;
          if (b.distanceMeters != null) return 1;
          return b.pendingCount.compareTo(a.pendingCount);
        });
      case _SortMode.itemCount:
        entries.sort((a, b) => b.pendingCount.compareTo(a.pendingCount));
      case _SortMode.name:
        entries.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Điểm mua sắm', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (all.isNotEmpty)
            PopupMenuButton<_SortMode>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sắp xếp',
              initialValue: _sortMode,
              onSelected: (mode) => setState(() => _sortMode = mode),
              itemBuilder: (_) => [
                _sortItem(_SortMode.distance, Icons.near_me_rounded, 'Gần nhất', _sortMode),
                _sortItem(_SortMode.itemCount, Icons.format_list_numbered_rounded, 'Nhiều sản phẩm nhất', _sortMode),
                _sortItem(_SortMode.name, Icons.sort_by_alpha_rounded, 'Tên A–Z', _sortMode),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(all.isEmpty ? 0 : 58),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm cửa hàng...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _query = '';
                              _searchCtrl.clear();
                            }),
                            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: all.isEmpty
          ? const _EmptyState()
          : entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'Không tìm thấy "$_query"',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: entries.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StoreCard(
                      entry: entries[i],
                      onItemTap: (item) => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
                      ),
                    ),
                  ),
                ),
    );
  }
}


// ─── Store card ────────────────────────────────────────────────────────────

class _StoreCard extends StatefulWidget {
  final _StoreEntry entry;
  final ValueChanged<ShoppingItem> onItemTap;
  const _StoreCard({required this.entry, required this.onItemTap});

  @override
  State<_StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<_StoreCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: _expanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Name + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${e.totalCount} sản phẩm', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            if (e.distanceMeters != null) ...[
                              const SizedBox(width: 10),
                              const Icon(Icons.near_me_outlined, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(_fmtDistance(e.distanceMeters!), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                        if (e.lat != null && e.lon != null) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${e.lat},${e.lon}'),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions_rounded, size: 13, color: AppColors.primary),
                                  SizedBox(width: 5),
                                  Text('Chỉ đường', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Chevron
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Items ──
          if (_expanded) ...[
            const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF0F0F0)),
            ...e.items.map((ia) => _ItemRow(
                  ia: ia,
                  storeName: e.name,
                  onTap: () => widget.onItemTap(ia.item),
                )),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

// ─── Status badge ──────────────────────────────────────────────────────────


// ─── Item row ──────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final _ItemAtStore ia;
  final String storeName;
  final VoidCallback onTap;

  const _ItemRow({required this.ia, required this.storeName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = ia.hasPurchasedHere ? Colors.orange.shade700 : AppColors.textSecondary;
    final statusText = ia.hasPurchasedHere
        ? 'Đã mua ${ia.purchasedHere}/${ia.required} ${ia.item.unit}'
        : ia.hasPurchasedElsewhere
            ? 'Mua ở nơi khác · còn cần ${ia.required - ia.totalPurchased} ${ia.item.unit}'
            : 'Cần ${ia.required} ${ia.item.unit}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ia.item.imageUrl != null
                  ? AppNetworkImage(url: ia.item.imageUrl!, width: 44, height: 44, fit: BoxFit.cover)
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, size: 22, color: Color(0xFFBBBBBB)),
                    ),
            ),
            const SizedBox(width: 12),
            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ia.item.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(statusText, style: TextStyle(fontSize: 11, color: statusColor)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _refPrice(),
          ],
        ),
      ),
    );
  }

  Widget _refPrice() {
    final sp = ia.item.storePrices
        .where((s) => s.storeName.trim() == storeName.trim())
        .firstOrNull;
    if (sp == null || sp.pricePerUnit <= 0) return const SizedBox.shrink();
    final s = sp.pricePerUnit.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${buf.toString()} ₫',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
  }

}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có điểm mua sắm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Thêm giá tham chiếu hoặc xác nhận mua ở một cửa hàng để hiện danh sách',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
