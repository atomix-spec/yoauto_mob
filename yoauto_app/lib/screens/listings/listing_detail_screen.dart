import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoauto_api/yoauto_api.dart';
import '../../providers/listings_provider.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late String _id;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _id = ModalRoute.of(context)!.settings.arguments as String;
      _initialized = true;
      context.read<ListingsProvider>().loadDetail(_id);
    }
  }

  String _formatPrice(String price) {
    final parsed = double.tryParse(price);
    if (parsed == null) return price;
    return '\$${parsed.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingsProvider>(
      builder: (context, listingsProvider, _) {
        final detail = listingsProvider.selectedDetail;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              detail?.title ?? 'Listing Detail',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: _buildBody(context, listingsProvider, detail),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ListingsProvider listingsProvider,
    ListingResponse? detail,
  ) {
    if (listingsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listingsProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                listingsProvider.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => listingsProvider.loadDetail(_id),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (detail == null) {
      return const Center(
        child: Text(
          'Listing not found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media section: horizontal scroll of listing images
          if (detail.media != null && detail.media!.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: detail.media!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final media = detail.media![index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      media.url,
                      width: 280,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 280,
                        height: 200,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Price chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_formatPrice(detail.price)} ${detail.currency}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status chip
          Chip(
            label: Text(detail.status),
            backgroundColor: colorScheme.secondaryContainer,
            labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            detail.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Location
          if (detail.city != null || detail.country.isNotEmpty)
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  [detail.city, detail.country].whereType<String>().join(', '),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Vehicle section
          if (detail.vehicle != null) ...[
            Text(
              'Vehicle Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            _VehicleDetails(vehicle: detail.vehicle!),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
          ],

          // Seller section
          if (detail.seller != null) ...[
            Text(
              'Seller',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            _SellerSection(seller: detail.seller!),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
          ],

          // Description section
          if (detail.description != null) ...[
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              detail.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}

class _VehicleDetails extends StatelessWidget {
  final VehicleResponse vehicle;

  const _VehicleDetails({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Make / Model', '${vehicle.makeName} ${vehicle.modelName}'),
      MapEntry('Year', vehicle.year.toString()),
      MapEntry('Body Type', vehicle.bodyType),
      MapEntry('Fuel Type', vehicle.fuelType),
      MapEntry('Transmission', vehicle.transmission),
      MapEntry('Mileage', '${vehicle.mileage} ${vehicle.mileageUnit}'),
      if (vehicle.colorName != null) MapEntry('Color', vehicle.colorName!),
      if (vehicle.engineCapacity != null)
        MapEntry('Engine Capacity', vehicle.engineCapacity!.toString()),
      if (vehicle.enginePower != null)
        MapEntry('Engine Power', '${vehicle.enginePower} hp'),
      if (vehicle.ownersCount != null)
        MapEntry('Owners', vehicle.ownersCount!.toString()),
      MapEntry('Condition', vehicle.condition),
      if (vehicle.accidentFree != null)
        MapEntry('Accident Free', vehicle.accidentFree! ? 'Yes' : 'No'),
    ];

    return Column(
      children: rows.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SellerSection extends StatelessWidget {
  final SellerResponse seller;

  const _SellerSection({required this.seller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = seller.name ?? 'Unknown Seller';

    return Row(
      children: [
        if (seller.avatarUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              seller.avatarUrl!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.secondaryContainer,
                child: Text(name[0].toUpperCase()),
              ),
            ),
          )
        else
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.secondaryContainer,
            child: Text(name[0].toUpperCase()),
          ),
        const SizedBox(width: 12),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
      ],
    );
  }
}
