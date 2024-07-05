import 'package:hive/hive.dart';

part 'Hotels_Db.g.dart';

@HiveType(typeId: 1)
class Hotels_Db {
  @HiveField(0)
  final String hotelId;

  @HiveField(1)
  final String hotelName;

  @HiveField(2)
  final String hotelMail;

  @HiveField(3)
  final String hotelAddress;

  @HiveField(4)
  final String hotelPhoneNo;

  @HiveField(5)
  final String hotelUsername;

  @HiveField(6)
  final String hotelType;


  Hotels_Db({
    required this.hotelId,
    required this.hotelName,
    required this.hotelMail,
    required this.hotelAddress,
    required this.hotelPhoneNo,
    required this.hotelUsername,
    required this.hotelType,
  });
}
