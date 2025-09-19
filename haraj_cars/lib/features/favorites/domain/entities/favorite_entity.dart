/// Favorite entity representing a user's favorite car
class FavoriteEntity {
  final String id;
  final String userId;
  final String carId;
  final DateTime createdAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.carId,
    required this.createdAt,
  });

  /// Copy with method for immutable updates
  FavoriteEntity copyWith({
    String? id,
    String? userId,
    String? carId,
    DateTime? createdAt,
  }) {
    return FavoriteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carId: carId ?? this.carId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FavoriteEntity(id: $id, userId: $userId, carId: $carId)';
  }
}
