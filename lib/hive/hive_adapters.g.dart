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

class SettingsDataAdapter extends TypeAdapter<SettingsData> {
  @override
  final int typeId = 14;

  @override
  SettingsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsData(
      themeMode: fields[0] as ThemeMode,
      useDynamicColor: fields[5] as bool,
      color: fields[6] as Color,
      terminalMaxLines: (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SettingsData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(4)
      ..write(obj.terminalMaxLines)
      ..writeByte(5)
      ..write(obj.useDynamicColor)
      ..writeByte(6)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsDataAdapter &&
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
      clientKey: fields[4] as String,
      clientName: fields[5] as String,
      clientShell: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalClientData obj) {
    writer
      ..writeByte(3)
      ..writeByte(3)
      ..write(obj.clientShell)
      ..writeByte(4)
      ..write(obj.clientKey)
      ..writeByte(5)
      ..write(obj.clientName);
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
      clientKey: fields[11] as String,
      clientName: fields[12] as String,
      remoteClientType: fields[0] as RemoteClientType,
      clientHost: fields[7] as String,
      clientPort: (fields[8] as num).toInt(),
      clientUser: fields[9] as String?,
      clientPass: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RemoteClientData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.remoteClientType)
      ..writeByte(7)
      ..write(obj.clientHost)
      ..writeByte(8)
      ..write(obj.clientPort)
      ..writeByte(9)
      ..write(obj.clientUser)
      ..writeByte(10)
      ..write(obj.clientPass)
      ..writeByte(11)
      ..write(obj.clientKey)
      ..writeByte(12)
      ..write(obj.clientName);
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
