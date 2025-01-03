import 'package:hive/hive.dart';

part 'Favourites_DB.g.dart';

@HiveType(typeId: 3)
class Favourites_DB extends HiveObject {
  @HiveField(0)
  final String UserId;

  @HiveField(1)
  final String ItemId;

  @override
  @HiveField(2)
  final int key; // Add a key field for Hive box key

  Favourites_DB({
    required this.UserId,
    required this.ItemId,
    required this.key, // Include the key in the constructor
  });

  // Add a copyWith method to create a new instance with updated fields
  Favourites_DB copyWith({
    String? UserId,
    String? ItemId,
    int? key,
  }) {
    return Favourites_DB(
      UserId: UserId ?? this.UserId,
      ItemId: ItemId ?? this.ItemId,
      key: key ?? this.key,
    );
  }
}
