// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Cart_Db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartDbAdapter extends TypeAdapter<Cart_Db> {
  @override
  final int typeId = 2;

  @override
  Cart_Db read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cart_Db(
      UserId: fields[0] as String,
      ItemId: fields[1] as String,
      ItemCount: fields[2] as double,
      key: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Cart_Db obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.UserId)
      ..writeByte(1)
      ..write(obj.ItemId)
      ..writeByte(2)
      ..write(obj.ItemCount)
      ..writeByte(3)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
