// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Favourites_DB.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavouritesDBAdapter extends TypeAdapter<Favourites_DB> {
  @override
  final int typeId = 3;

  @override
  Favourites_DB read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Favourites_DB(
      UserId: fields[0] as String,
      ItemId: fields[1] as String,
      key: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Favourites_DB obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.UserId)
      ..writeByte(1)
      ..write(obj.ItemId)
      ..writeByte(2)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouritesDBAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
