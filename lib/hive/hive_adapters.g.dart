// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 5;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.system:
        writer.writeByte(0);
      case ThemeMode.light:
        writer.writeByte(1);
      case ThemeMode.dark:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClientTypeAdapter extends TypeAdapter<ClientType> {
  @override
  final int typeId = 15;

  @override
  ClientType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClientType.local;
      case 1:
        return ClientType.remote;
      default:
        return ClientType.local;
    }
  }

  @override
  void write(BinaryWriter writer, ClientType obj) {
    switch (obj) {
      case ClientType.local:
        writer.writeByte(0);
      case ClientType.remote:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RemoteClientTypeAdapter extends TypeAdapter<RemoteClientType> {
  @override
  final int typeId = 16;

  @override
  RemoteClientType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RemoteClientType.ssh;
      case 1:
        return RemoteClientType.telnet;
      default:
        return RemoteClientType.ssh;
    }
  }

  @override
  void write(BinaryWriter writer, RemoteClientType obj) {
    switch (obj) {
      case RemoteClientType.ssh:
        writer.writeByte(0);
      case RemoteClientType.telnet:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteClientTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalClientDataAdapter extends TypeAdapter<LocalClientData> {
  @override
  final int typeId = 17;

  @override
  LocalClientData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalClientData(
      uuid: fields[7] as String,
      name: fields[8] as String,
      shell: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalClientData obj) {
    writer
      ..writeByte(3)
      ..writeByte(6)
      ..write(obj.shell)
      ..writeByte(7)
      ..write(obj.uuid)
      ..writeByte(8)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalClientDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RemoteClientDataAdapter extends TypeAdapter<RemoteClientData> {
  @override
  final int typeId = 18;

  @override
  RemoteClientData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemoteClientData(
      uuid: fields[18] as String,
      name: fields[19] as String,
      rType: fields[13] as RemoteClientType,
      host: fields[14] as String,
      port: (fields[15] as num).toInt(),
      user: fields[16] as String?,
      pass: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RemoteClientData obj) {
    writer
      ..writeByte(7)
      ..writeByte(13)
      ..write(obj.rType)
      ..writeByte(14)
      ..write(obj.host)
      ..writeByte(15)
      ..write(obj.port)
      ..writeByte(16)
      ..write(obj.user)
      ..writeByte(17)
      ..write(obj.pass)
      ..writeByte(18)
      ..write(obj.uuid)
      ..writeByte(19)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteClientDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HistoryDataAdapter extends TypeAdapter<HistoryData> {
  @override
  final int typeId = 19;

  @override
  HistoryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryData(
      fields[0] as String,
      (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, HistoryData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
