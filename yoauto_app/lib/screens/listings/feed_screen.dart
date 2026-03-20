import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoauto_api/yoauto_api.dart';
import '../../providers/listings_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ListingsProvider>().loadFeed(),
    );
  }

  String _formatPrice(String price) {
    final parsed = double.tryParse(price);
    if (parsed == null) return price;
    return '\$${parsed.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ListingsProvider>(
        builder: (context, listingsProvider, _) {
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
                      onPressed: () => listingsProvider.loadFeed(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final feed = listingsProvider.feed;

          if (feed.isEmpty) {
            return const Center(
              child: Text(
                'No listings found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => listingsProvider.loadFeed(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: feed.length,
              itemBuilder: (context, index) {
                final ListingCardResponse card = feed[index];
                return _FeedListingCard(
                  card: card,
                  formattedPrice: _formatPrice(card.price),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/listing-detail',
                    arguments: card.id,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FeedListingCard extends StatelessWidget {
  final ListingCardResponse card;
  final String formattedPrice;
  final VoidCallback onTap;

  const _FeedListingCard({
    required this.card,
    required this.formattedPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget leading;
    if (card.coverImageUrl != null) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          card.coverImageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.directions_car, color: colorScheme.onPrimaryContainer),
          ),
        ),
      );
    } else {
      leading = CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(Icons.directions_car, color: colorScheme.onPrimaryContainer),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            leading: leading,
            title: Text(
              card.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedPrice,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (card.city != null)
                  Text(
                    card.city!,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
