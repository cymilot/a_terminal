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

class LocalTermModelAdapter extends TypeAdapter<LocalTermModel> {
  @override
  final int typeId = 2;

  @override
  LocalTermModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalTermModel(
      termKey: fields[1] as String,
      termName: fields[2] as String,
      termShell: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTermModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.termShell)
      ..writeByte(1)
      ..write(obj.termKey)
      ..writeByte(2)
      ..write(obj.termName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTermModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TermTypeAdapter extends TypeAdapter<TermType> {
  @override
  final int typeId = 4;

  @override
  TermType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TermType.local;
      case 4:
        return TermType.remote;
      default:
        return TermType.local;
    }
  }

  @override
  void write(BinaryWriter writer, TermType obj) {
    switch (obj) {
      case TermType.local:
        writer.writeByte(0);
      case TermType.remote:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermTypeAdapter &&
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

class RemoteTermModelAdapter extends TypeAdapter<RemoteTermModel> {
  @override
  final int typeId = 8;

  @override
  RemoteTermModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemoteTermModel(
      termKey: fields[5] as String,
      termName: fields[6] as String,
      termSubType: fields[0] as RemoteTermType,
      termHost: fields[1] as String,
      termPort: (fields[2] as num).toInt(),
      termUser: fields[3] as String,
      termPass: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RemoteTermModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.termSubType)
      ..writeByte(1)
      ..write(obj.termHost)
      ..writeByte(2)
      ..write(obj.termPort)
      ..writeByte(3)
      ..write(obj.termUser)
      ..writeByte(4)
      ..write(obj.termPass)
      ..writeByte(5)
      ..write(obj.termKey)
      ..writeByte(6)
      ..write(obj.termName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteTermModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RemoteTermTypeAdapter extends TypeAdapter<RemoteTermType> {
  @override
  final int typeId = 9;

  @override
  RemoteTermType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RemoteTermType.ssh;
      case 1:
        return RemoteTermType.telnet;
      default:
        return RemoteTermType.ssh;
    }
  }

  @override
  void write(BinaryWriter writer, RemoteTermType obj) {
    switch (obj) {
      case RemoteTermType.ssh:
        writer.writeByte(0);
      case RemoteTermType.telnet:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteTermTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
