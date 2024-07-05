// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckoutHistory_DB.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckoutHistoryDBAdapter extends TypeAdapter<CheckoutHistory_DB> {
  @override
  final int typeId = 4;

  @override
  CheckoutHistory_DB read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckoutHistory_DB(
      UserId: fields[0] as String,
      ItemId: fields[1] as String,
      ItemCount: fields[2] as double,
      TimeStamp: fields[4] as String,
      key: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CheckoutHistory_DB obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.UserId)
      ..writeByte(1)
      ..write(obj.ItemId)
      ..writeByte(2)
      ..write(obj.ItemCount)
      ..writeByte(4)
      ..write(obj.TimeStamp)
      ..writeByte(3)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutHistoryDBAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
