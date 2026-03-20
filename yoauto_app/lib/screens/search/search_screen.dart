import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoauto_api/yoauto_api.dart';
import '../../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  bool _hasSearched = false;
  bool _showSuggestions = false;

  // Filter state
  final TextEditingController _priceFromController = TextEditingController();
  final TextEditingController _priceToController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();

  // Sort state: 'price_asc', 'price_desc', 'created_at'
  String _sortBy = 'price_asc';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    _makeController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _hasSearched = false;
      });
      context.read<SearchProvider>().clearSuggestions();
      return;
    }

    setState(() {
      _showSuggestions = true;
      _hasSearched = false;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<SearchProvider>().loadSuggestions(query);
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    _debounceTimer?.cancel();
    _searchFocusNode.unfocus();

    setState(() {
      _showSuggestions = false;
      _hasSearched = true;
    });

    _executeSearch(query.trim());
  }

  void _onSuggestionTapped(AutocompleteSuggestion suggestion) {
    final text = suggestion.text;
    _searchController.text = text;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _searchFocusNode.unfocus();

    setState(() {
      _showSuggestions = false;
      _hasSearched = true;
    });

    _executeSearch(text);
  }

  void _executeSearch(String query) {
    final priceFromText = _priceFromController.text.trim();
    final priceToText = _priceToController.text.trim();
    final makeText = _makeController.text.trim();

    final double? priceFrom = priceFromText.isNotEmpty ? double.tryParse(priceFromText) : null;
    final double? priceTo = priceToText.isNotEmpty ? double.tryParse(priceToText) : null;
    final String? makeId = makeText.isNotEmpty ? makeText : null;

    SearchFilters? filters;
    if (priceFrom != null || priceTo != null || makeId != null) {
      filters = SearchFilters(
        priceFrom: priceFrom,
        priceTo: priceTo,
        makeId: makeId,
        status: 'active',
      );
    }

    final request = SearchRequest(
      query: query,
      filters: filters,
      sortBy: _sortBy,
    );

    context.read<SearchProvider>().search(request);
  }

  Future<void> _showFilterDialog() async {
    final priceFromSnapshot = _priceFromController.text;
    final priceToSnapshot = _priceToController.text;
    final makeSnapshot = _makeController.text;

    final applied = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _FilterDialog(
          priceFromController: _priceFromController,
          priceToController: _priceToController,
          makeController: _makeController,
          onReset: () {
            _priceFromController.clear();
            _priceToController.clear();
            _makeController.clear();
          },
        );
      },
    );

    if (applied != true) {
      _priceFromController.text = priceFromSnapshot;
      _priceToController.text = priceToSnapshot;
      _makeController.text = makeSnapshot;
    } else if (_hasSearched && _searchController.text.trim().isNotEmpty) {
      _executeSearch(_searchController.text.trim());
    }
  }

  void _toggleSort() {
    setState(() {
      if (_sortBy == 'price_asc') {
        _sortBy = 'price_desc';
      } else if (_sortBy == 'price_desc') {
        _sortBy = 'created_at';
      } else {
        _sortBy = 'price_asc';
      }
    });

    if (_hasSearched && _searchController.text.trim().isNotEmpty) {
      _executeSearch(_searchController.text.trim());
    }
  }

  String _sortLabel() {
    switch (_sortBy) {
      case 'price_asc':
        return 'Price: Low to High';
      case 'price_desc':
        return 'Price: High to Low';
      case 'created_at':
        return 'Newest First';
      default:
        return 'Sort';
    }
  }

  IconData _sortIcon() {
    switch (_sortBy) {
      case 'price_asc':
        return Icons.arrow_upward;
      case 'price_desc':
        return Icons.arrow_downward;
      case 'created_at':
        return Icons.access_time;
      default:
        return Icons.sort;
    }
  }

  String _formatPrice(String price) {
    final parsed = double.tryParse(price);
    if (parsed == null) return price;
    return '\$${parsed.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          Tooltip(
            message: _sortLabel(),
            child: IconButton(
              icon: Icon(_sortIcon()),
              onPressed: _toggleSort,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filters',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search for cars, makes, models...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchTextChanged('');
                    },
                  ),
              ],
              onChanged: _onSearchTextChanged,
              onSubmitted: _onSearchSubmitted,
            ),
          ),

          // Sort / filter status strip
          if (_hasSearched)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _sortIcon(),
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showFilterDialog,
                    icon: const Icon(Icons.tune, size: 14),
                    label: const Text('Filters', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

          // Body
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, _) {
                if (_showSuggestions) {
                  return _buildSuggestions(context, searchProvider);
                }
                if (_hasSearched) {
                  return _buildResults(context, searchProvider);
                }
                return _buildIdleState(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for your next car',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type a make, model, or keyword above.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, SearchProvider searchProvider) {
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final suggestions = searchProvider.suggestions;

    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'No suggestions found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final AutocompleteSuggestion suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(suggestion.text),
          trailing: const Icon(Icons.north_west, size: 16),
          onTap: () => _onSuggestionTapped(suggestion),
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, SearchProvider searchProvider) {
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                searchProvider.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _executeSearch(_searchController.text.trim()),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final results = searchProvider.results;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "${_searchController.text}"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try different keywords or remove filters.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final SearchHit hit = results[index];
        final colorScheme = Theme.of(context).colorScheme;

        Widget leading;
        if (hit.coverImageUrl != null) {
          leading = ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              hit.coverImageUrl!,
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
              onTap: () => Navigator.pushNamed(
                context,
                '/listing-detail',
                arguments: hit.id,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: leading,
                title: Text(
                  '${hit.year} ${hit.makeName} ${hit.modelName}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPrice(hit.price),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (hit.city != null)
                      Text(
                        hit.city!,
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
      },
    );
  }
}

// Filter dialog

class _FilterDialog extends StatefulWidget {
  final TextEditingController priceFromController;
  final TextEditingController priceToController;
  final TextEditingController makeController;
  final VoidCallback onReset;

  const _FilterDialog({
    required this.priceFromController,
    required this.priceToController,
    required this.makeController,
    required this.onReset,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Listings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget.priceFromController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price From',
                prefixText: '\$',
                border: OutlineInputBorder(),
                hintText: 'e.g. 5000',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.priceToController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price To',
                prefixText: '\$',
                border: OutlineInputBorder(),
                hintText: 'e.g. 50000',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.makeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Make',
                border: OutlineInputBorder(),
                hintText: 'e.g. Toyota',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onReset();
            setState(() {});
          },
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
