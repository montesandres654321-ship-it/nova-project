import 'package:flutter/material.dart';
import '../models/place_type.dart';
import '../core/design/app_colors.dart';
import '../widgets/place_category_tabs.dart';
import '../widgets/places_list.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Explorar'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: AppColors.surface,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bottom: PlaceCategoryTabs(controller: _tabController),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PlacesList(type: PlaceType.hotel),
          PlacesList(type: PlaceType.restaurant),
          PlacesList(type: PlaceType.bar),
        ],
      ),
    );
  }
}
