import 'package:hive/hive.dart';

part 'Food_db.g.dart';

@HiveType(typeId: 0)
class Food_db {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productTitle;

  @HiveField(2)
  final double productPrice;

  @HiveField(3)
  final String productImg;

  @HiveField(4)
  final String productDesc;

  @HiveField(5)
  final String productOwnership;

  @HiveField(6)
  final double productRating;

  @HiveField(7)
  final double productOffer;

  @HiveField(8)
  final String productMainCategory;

  @HiveField(9)
  final String productPrepTime;

  @HiveField(10)
  final String productType;

  @HiveField(11)
  final int calories;

  @HiveField(12)
  final bool isVeg;


  Food_db({
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.productImg,
    required this.productDesc,
    required this.productOwnership,
    required this.productRating,
    required this.productOffer,
    required this.productMainCategory,
    required this.productPrepTime,
    required this.productType,
    required this.calories,
    required this.isVeg
  });
}
