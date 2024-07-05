// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Hotels_Db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HotelsDbAdapter extends TypeAdapter<Hotels_Db> {
  @override
  final int typeId = 1;

  @override
  Hotels_Db read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hotels_Db(
      hotelId: fields[0] as String,
      hotelName: fields[1] as String,
      hotelMail: fields[2] as String,
      hotelAddress: fields[3] as String,
      hotelPhoneNo: fields[4] as String,
      hotelUsername: fields[5] as String,
      hotelType: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Hotels_Db obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.hotelId)
      ..writeByte(1)
      ..write(obj.hotelName)
      ..writeByte(2)
      ..write(obj.hotelMail)
      ..writeByte(3)
      ..write(obj.hotelAddress)
      ..writeByte(4)
      ..write(obj.hotelPhoneNo)
      ..writeByte(5)
      ..write(obj.hotelUsername)
      ..writeByte(6)
      ..write(obj.hotelType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotelsDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
