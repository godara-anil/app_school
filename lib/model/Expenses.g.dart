// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Expenses.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpensesAdapter extends TypeAdapter<Expenses> {
  @override
  final int typeId = 0;

  @override
  Expenses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expenses()
      ..amount = fields[0] as double
      ..isExpense = fields[1] as bool
      ..date = fields[2] as DateTime
      ..category = fields[3] as String
      ..sessionKey = fields[5] as int?
      ..isBank = fields[6] as bool?;
  }

  @override
  void write(BinaryWriter writer, Expenses obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.isExpense)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.sessionKey)
      ..writeByte(6)
      ..write(obj.isBank);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpensesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionsAdapter extends TypeAdapter<Sessions> {
  @override
  final int typeId = 1;

  @override
  Sessions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sessions()
      ..isActive = fields[0] as bool
      ..session = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, Sessions obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.isActive)
      ..writeByte(1)
      ..write(obj.session);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
