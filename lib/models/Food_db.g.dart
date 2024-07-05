// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Food_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FooddbAdapter extends TypeAdapter<Food_db> {
  @override
  final int typeId = 0;

  @override
  Food_db read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food_db(
      productId: fields[0] as String,
      productTitle: fields[1] as String,
      productPrice: fields[2] as double,
      productImg: fields[3] as String,
      productDesc: fields[4] as String,
      productOwnership: fields[5] as String,
      productRating: fields[6] as double,
      productOffer: fields[7] as double,
      productMainCategory: fields[8] as String,
      productPrepTime: fields[9] as String,
      productType: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Food_db obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productTitle)
      ..writeByte(2)
      ..write(obj.productPrice)
      ..writeByte(3)
      ..write(obj.productImg)
      ..writeByte(4)
      ..write(obj.productDesc)
      ..writeByte(5)
      ..write(obj.productOwnership)
      ..writeByte(6)
      ..write(obj.productRating)
      ..writeByte(7)
      ..write(obj.productOffer)
      ..writeByte(8)
      ..write(obj.productMainCategory)
      ..writeByte(9)
      ..write(obj.productPrepTime)
      ..writeByte(10)
      ..write(obj.productType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FooddbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
