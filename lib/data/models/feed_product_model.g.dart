// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedProductModelAdapter extends TypeAdapter<FeedProductModel> {
  @override
  final int typeId = 1;

  @override
  FeedProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedProductModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      image: fields[3] as String?,
      unit: fields[4] as String,
      stock: fields[5] as int,
      lowStockThreshold: fields[6] as int,
      rate: fields[7] as double,
      supplier: fields[8] as String?,
      description: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      isSynced: fields[12] as bool,
      firebaseId: fields[13] as String?,
      purchasePrice: fields[14] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, FeedProductModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.stock)
      ..writeByte(6)
      ..write(obj.lowStockThreshold)
      ..writeByte(7)
      ..write(obj.rate)
      ..writeByte(8)
      ..write(obj.supplier)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.firebaseId)
      ..writeByte(14)
      ..write(obj.purchasePrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
