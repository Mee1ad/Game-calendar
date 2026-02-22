class GameFilters {
  const GameFilters({
    this.platformIds = const {},
    this.genreIds = const {},
    this.releaseStatus = ReleaseStatus.all,
  });

  final Set<int> platformIds;
  final Set<int> genreIds;
  final ReleaseStatus releaseStatus;

  GameFilters copyWith({
    Set<int>? platformIds,
    Set<int>? genreIds,
    ReleaseStatus? releaseStatus,
  }) =>
      GameFilters(
        platformIds: platformIds ?? this.platformIds,
        genreIds: genreIds ?? this.genreIds,
        releaseStatus: releaseStatus ?? this.releaseStatus,
      );
}

enum ReleaseStatus { all, released, upcoming }

enum GameListType { popular, upcoming, top, recent }

const platformIds = {
  6: 'PC',
  48: 'PS4',
  167: 'PS5',
  49: 'Xbox One',
  169: 'Xbox Series',
  130: 'Switch',
};

const genreIds = {
  12: 'RPG',
  4: 'Fighting',
  5: 'Shooter',
  31: 'Adventure',
  33: 'Arcade',
  2: 'Point & Click',
  25: 'Hack and Slash',
  32: 'Indie',
  15: 'Strategy',
  26: 'Quiz',
};
