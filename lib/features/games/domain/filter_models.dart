class GameFilters {
  const GameFilters({
    this.platformIds = const {},
    this.genreIds = const {},
    this.releaseStatus = ReleaseStatus.all,
    this.listType = GameListType.popular,
  });

  final Set<int> platformIds;
  final Set<int> genreIds;
  final ReleaseStatus releaseStatus;
  final GameListType listType;

  GameFilters copyWith({
    Set<int>? platformIds,
    Set<int>? genreIds,
    ReleaseStatus? releaseStatus,
    GameListType? listType,
  }) =>
      GameFilters(
        platformIds: platformIds ?? this.platformIds,
        genreIds: genreIds ?? this.genreIds,
        releaseStatus: releaseStatus ?? this.releaseStatus,
        listType: listType ?? this.listType,
      );
}

enum ReleaseStatus { all, released, upcoming }

enum GameListType { popular, upcoming, recent }

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
