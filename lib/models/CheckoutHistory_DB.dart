import 'package:hive/hive.dart';

part 'CheckoutHistory_DB.g.dart';

@HiveType(typeId: 4)
class CheckoutHistory_DB extends HiveObject {
  @HiveField(0)
  final String UserId;

  @HiveField(1)
  final String ItemId;

  @HiveField(2)
  late double ItemCount;

  @HiveField(4)
  late String TimeStamp;

  @HiveField(3)
  final int key;

  CheckoutHistory_DB({
    required this.UserId,
    required this.ItemId,
    required this.ItemCount,
    required this.TimeStamp,
    required this.key,
  });

  CheckoutHistory_DB copyWith({
    String? UserId,
    String? ItemId,
    double? ItemCount,
    String? TimeStamp,
    int? key,
  }) {
    return CheckoutHistory_DB(
      UserId: UserId ?? this.UserId,
      ItemId: ItemId ?? this.ItemId,
      ItemCount: ItemCount ?? this.ItemCount,
      TimeStamp: TimeStamp ?? this.TimeStamp,
      key: key ?? this.key,
    );
  }
}
