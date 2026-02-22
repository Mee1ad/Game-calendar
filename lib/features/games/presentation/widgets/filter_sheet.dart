import 'package:flutter/material.dart';
import 'package:game_calendar/features/games/domain/filter_models.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  final GameFilters filters;
  final ValueChanged<GameFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'List',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GameListType.values.map((t) {
                  final selected = filters.listType == t;
                  return FilterChip(
                    label: Text(_listTypeLabel(t)),
                    selected: selected,
                    onSelected: (_) {
                      onFiltersChanged(filters.copyWith(listType: t));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Platforms',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: platformIds.entries.map((e) {
                  final selected = filters.platformIds.contains(e.key);
                  return FilterChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) {
                      final next = Set<int>.from(filters.platformIds);
                      if (selected) {
                        next.remove(e.key);
                      } else {
                        next.add(e.key);
                      }
                      onFiltersChanged(filters.copyWith(platformIds: next));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Genres',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genreIds.entries.map((e) {
                  final selected = filters.genreIds.contains(e.key);
                  return FilterChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) {
                      final next = Set<int>.from(filters.genreIds);
                      if (selected) {
                        next.remove(e.key);
                      } else {
                        next.add(e.key);
                      }
                      onFiltersChanged(filters.copyWith(genreIds: next));
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _listTypeLabel(GameListType t) {
    return switch (t) {
      GameListType.popular => 'Popular',
      GameListType.upcoming => 'Upcoming',
      GameListType.top => 'Top',
      GameListType.recent => 'Recent',
    };
  }
}
