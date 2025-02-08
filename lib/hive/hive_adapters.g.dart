// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class SettingModelAdapter extends TypeAdapter<SettingModel> {
  @override
  final int typeId = 0;

  @override
  SettingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingModel(
      themeMode: fields[0] as ThemeMode,
      useSystemAccent: fields[1] as bool,
      accentColor: fields[2] as Color,
      termMaxLines: (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SettingModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.useSystemAccent)
      ..writeByte(2)
      ..write(obj.accentColor)
      ..writeByte(3)
      ..write(obj.termMaxLines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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

class TerminalTypeAdapter extends TypeAdapter<TerminalType> {
  @override
  final int typeId = 10;

  @override
  TerminalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TerminalType.local;
      case 1:
        return TerminalType.remote;
      default:
        return TerminalType.local;
    }
  }

  @override
  void write(BinaryWriter writer, TerminalType obj) {
    switch (obj) {
      case TerminalType.local:
        writer.writeByte(0);
      case TerminalType.remote:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TerminalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RemoteTerminalTypeAdapter extends TypeAdapter<RemoteTerminalType> {
  @override
  final int typeId = 11;

  @override
  RemoteTerminalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RemoteTerminalType.ssh;
      case 1:
        return RemoteTerminalType.telnet;
      default:
        return RemoteTerminalType.ssh;
    }
  }

  @override
  void write(BinaryWriter writer, RemoteTerminalType obj) {
    switch (obj) {
      case RemoteTerminalType.ssh:
        writer.writeByte(0);
      case RemoteTerminalType.telnet:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteTerminalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalTerminalModelAdapter extends TypeAdapter<LocalTerminalModel> {
  @override
  final int typeId = 12;

  @override
  LocalTerminalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalTerminalModel(
      terminalKey: fields[1] as String,
      terminalName: fields[2] as String,
      terminalShell: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTerminalModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.terminalShell)
      ..writeByte(1)
      ..write(obj.terminalKey)
      ..writeByte(2)
      ..write(obj.terminalName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTerminalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RemoteTerminalModelAdapter extends TypeAdapter<RemoteTerminalModel> {
  @override
  final int typeId = 13;

  @override
  RemoteTerminalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemoteTerminalModel(
      terminalKey: fields[5] as String,
      terminalName: fields[6] as String,
      terminalSubType: fields[0] as RemoteTerminalType,
      terminalHost: fields[1] as String,
      terminalPort: (fields[2] as num).toInt(),
      terminalUser: fields[3] as String?,
      terminalPass: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RemoteTerminalModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.terminalSubType)
      ..writeByte(1)
      ..write(obj.terminalHost)
      ..writeByte(2)
      ..write(obj.terminalPort)
      ..writeByte(3)
      ..write(obj.terminalUser)
      ..writeByte(4)
      ..write(obj.terminalPass)
      ..writeByte(5)
      ..write(obj.terminalKey)
      ..writeByte(6)
      ..write(obj.terminalName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteTerminalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
