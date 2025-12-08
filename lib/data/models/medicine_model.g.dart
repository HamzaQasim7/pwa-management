// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineModelAdapter extends TypeAdapter<MedicineModel> {
  @override
  final int typeId = 2;

  @override
  MedicineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineModel(
      id: fields[0] as String,
      name: fields[1] as String,
      genericName: fields[2] as String,
      category: fields[3] as String,
      image: fields[4] as String?,
      batchNo: fields[5] as String,
      mfgDate: fields[6] as DateTime,
      expiryDate: fields[7] as DateTime,
      manufacturer: fields[8] as String,
      purchasePrice: fields[9] as double,
      sellingPrice: fields[10] as double,
      discount: fields[11] as double,
      quantity: fields[12] as int,
      minStockLevel: fields[13] as int,
      unit: fields[14] as String,
      storage: fields[15] as String?,
      description: fields[16] as String?,
      createdAt: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
      isSynced: fields[19] as bool,
      firebaseId: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.genericName)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.batchNo)
      ..writeByte(6)
      ..write(obj.mfgDate)
      ..writeByte(7)
      ..write(obj.expiryDate)
      ..writeByte(8)
      ..write(obj.manufacturer)
      ..writeByte(9)
      ..write(obj.purchasePrice)
      ..writeByte(10)
      ..write(obj.sellingPrice)
      ..writeByte(11)
      ..write(obj.discount)
      ..writeByte(12)
      ..write(obj.quantity)
      ..writeByte(13)
      ..write(obj.minStockLevel)
      ..writeByte(14)
      ..write(obj.unit)
      ..writeByte(15)
      ..write(obj.storage)
      ..writeByte(16)
      ..write(obj.description)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.isSynced)
      ..writeByte(20)
      ..write(obj.firebaseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
