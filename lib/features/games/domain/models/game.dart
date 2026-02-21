import 'package:equatable/equatable.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.name,
    this.coverUrl,
    this.releaseDate,
    this.summary,
    this.screenshots = const [],
    this.videos = const [],
    this.totalRating,
    this.platformIds = const [],
    this.genreIds = const [],
  });

  final int id;
  final String name;
  final String? coverUrl;
  final DateTime? releaseDate;
  final String? summary;
  final List<String> screenshots;
  final List<String> videos;
  final double? totalRating;
  final List<int> platformIds;
  final List<int> genreIds;

  String get releaseMonthKey {
    if (releaseDate == null) return 'Unknown';
    return '${releaseDate!.year}-${releaseDate!.month.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, name, coverUrl, releaseDate];
}
