// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderItemModelAdapter extends TypeAdapter<OrderItemModel> {
  @override
  final int typeId = 6;

  @override
  OrderItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItemModel(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      rate: fields[3] as double,
      discount: fields[4] as double,
      total: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.rate)
      ..writeByte(4)
      ..write(obj.discount)
      ..writeByte(5)
      ..write(obj.total);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 3;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String?,
      orderNumber: fields[3] as String,
      date: fields[4] as DateTime,
      subtotal: fields[5] as double,
      discount: fields[6] as double,
      total: fields[7] as double,
      paymentStatus: fields[8] as String,
      orderType: fields[9] as String,
      items: (fields[10] as List).cast<OrderItemModel>(),
      notes: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      isSynced: fields[14] as bool,
      firebaseId: fields[15] as String?,
      paidAmount: fields[16] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.orderNumber)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.subtotal)
      ..writeByte(6)
      ..write(obj.discount)
      ..writeByte(7)
      ..write(obj.total)
      ..writeByte(8)
      ..write(obj.paymentStatus)
      ..writeByte(9)
      ..write(obj.orderType)
      ..writeByte(10)
      ..write(obj.items)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.isSynced)
      ..writeByte(15)
      ..write(obj.firebaseId)
      ..writeByte(16)
      ..write(obj.paidAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
