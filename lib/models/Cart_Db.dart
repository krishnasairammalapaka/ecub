import 'package:hive/hive.dart';

part 'Cart_Db.g.dart';

@HiveType(typeId: 2)
class Cart_Db extends HiveObject {
  @HiveField(0)
  late String UserId;

  @HiveField(1)
  late String ItemId;

  @HiveField(2)
  late double ItemCount;

  @HiveField(3)
  late int key; // Add a key field for Hive box key

  Cart_Db({
    required this.UserId,
    required this.ItemId,
    required this.ItemCount,
    required this.key, // Include the key in the constructor
  });

  // Add a copyWith method to create a new instance with updated fields
  Cart_Db copyWith({
    String? UserId,
    String? ItemId,
    double? ItemCount,
    int? key,
  }) {
    return Cart_Db(
      UserId: UserId ?? this.UserId,
      ItemId: ItemId ?? this.ItemId,
      ItemCount: ItemCount ?? this.ItemCount,
      key: key ?? this.key,
    );
  }
}
