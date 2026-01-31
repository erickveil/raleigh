# Hive Database Guide for Raleigh

This document explains how Hive is used in the Raleigh Data Tracker application, from setup through CRUD operations.

## Table of Contents

1. [Project Setup](#project-setup)
2. [Database Initialization](#database-initialization)
3. [Defining Models with Hive](#defining-models-with-hive)
4. [Creating the Repository Pattern](#creating-the-repository-pattern)
5. [CRUD Operations](#crud-operations)
6. [Building the Project](#building-the-project)
7. [Generated Files](#generated-files)

## Project Setup

### Dependencies

To use Hive in a Flutter project, add these dependencies to `pubspec.yaml`:

```yaml
dependencies:
  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # File operations (for import/export)
  path_provider: ^2.1.1
  file_picker: ^10.0.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

- **hive**: Core database package
- **hive_flutter**: Flutter-specific initialization and utilities
- **hive_generator**: Generates adapter code from your model annotations
- **build_runner**: Tool that runs code generators

Install dependencies with:
```bash
flutter pub get
```

## Database Initialization

### Main Entry Point

Hive must be initialized before your app runs. In `lib/main.dart`:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'repositories/tables_repository.dart';
import 'models/record.dart';
import 'models/column_type.dart';
import 'models/column.dart';
import 'models/table_definition.dart';
import 'models/table_data.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with Flutter
  await Hive.initFlutter();
  
  // Register all Hive adapters (generated automatically)
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(ColumnTypeAdapter());
  Hive.registerAdapter(ColumnDefAdapter());
  Hive.registerAdapter(TableDefinitionAdapter());
  Hive.registerAdapter(TableDataAdapter());
  
  // Initialize the repository (opens the database box)
  await TablesRepository.initialize();
  
  runApp(const MyApp());
}
```

**Key Points:**
- `WidgetsFlutterBinding.ensureInitialized()` - Required before any async operations
- `Hive.initFlutter()` - Initializes Hive with Flutter-specific defaults (handles paths, etc.)
- `Hive.registerAdapter()` - Registers adapters so Hive knows how to serialize your custom types
- Adapters must be registered in the correct order if there are dependencies

## Defining Models with Hive

### Model Structure

Each model that will be stored in Hive must have Hive annotations. Here's an example with the `Record` model:

```dart
import 'package:hive/hive.dart';

part 'record.g.dart';  // Generated adapter file

@HiveType(typeId: 0)   // Unique typeId for this model
class Record {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final DateTime recordDate;

  @HiveField(2)
  final Map<String, dynamic> data;

  Record({
    this.id,
    DateTime? recordDate,
    required this.data,
  }) : recordDate = recordDate ?? DateTime.now();

  // Serialization for JSON export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordDate': recordDate.toIso8601String(),
      ...data,
    };
  }

  // Deserialization from JSON
  factory Record.fromJson(Map<String, dynamic> json) {
    final jsonCopy = Map<String, dynamic>.from(json);
    final id = jsonCopy.remove('id') as int?;
    final recordDate = jsonCopy.remove('recordDate') as String?;

    return Record(
      id: id,
      recordDate: recordDate != null ? DateTime.parse(recordDate) : DateTime.now(),
      data: jsonCopy,
    );
  }
}
```

### Annotation Details

| Annotation | Purpose |
|-----------|---------|
| `@HiveType(typeId: X)` | Marks the class as Hive-serializable. `typeId` must be unique across all models |
| `@HiveField(X)` | Marks a field for serialization. Fields are indexed by these numbers, not names |
| `part 'filename.g.dart'` | Links to the generated adapter file |

### Type IDs

Each model needs a unique `typeId`:
- `Record` - `typeId: 0`
- `ColumnType` - `typeId: 1`
- `ColumnDef` - `typeId: 2`
- `TableDefinition` - `typeId: 3`
- `TableData` - `typeId: 4`

**Important:** Never reuse or change typeIds in existing projects - they're used to identify serialized data.

## Creating the Repository Pattern

The repository pattern separates data access logic from the rest of the app. Here's the `TablesRepository`:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/table_data.dart';

class TablesRepository {
  static const String _tableName = 'tables';
  static late Box<TableData> _tablesBox;

  // Initialize the Hive box
  static Future<void> initialize() async {
    _tablesBox = await Hive.openBox<TableData>(_tableName);
  }

  // Get all tables
  Future<Map<String, TableData>> getAllTables() async {
    final tables = <String, TableData>{};
    for (var key in _tablesBox.keys) {
      final table = _tablesBox.get(key);
      if (table != null) {
        tables[key.toString()] = table;
      }
    }
    return tables;
  }

  // Get a specific table
  Future<TableData?> getTable(String name) async {
    return _tablesBox.get(name);
  }

  // Create a new table
  Future<void> createTable(String name, TableDefinition definition) async {
    final tableData = TableData(
      definition: definition,
      records: [],
    );
    await _tablesBox.put(name, tableData);
  }

  // Delete a table
  Future<void> deleteTable(String name) async {
    await _tablesBox.delete(name);
  }

  // Save a table (for updates)
  Future<void> saveTable(String name, TableData tableData) async {
    await _tablesBox.put(name, tableData);
  }

  // Close the database
  Future<void> close() async {
    await _tablesBox.close();
  }
}
```

**Benefits:**
- Hive operations are isolated in one place
- Easy to test (can mock the repository)
- Easy to switch databases later
- Clear separation of concerns

## CRUD Operations

### CREATE

Creating a new table:

```dart
// In TablesProvider
Future<void> createTable(String name, List<ColumnDef> columns) async {
  final definition = TableDefinition(
    name: name,
    columns: columns,
  );
  await _repository.createTable(name, definition);
  _tables[name] = TableData(
    definition: definition,
    records: [],
  );
  notifyListeners();
}

// Adding a record to a table
Future<void> addRecord(String tableName, Record record) async {
  if (_tables.containsKey(tableName)) {
    final lastId = _tables[tableName]!.records.isEmpty
        ? 0
        : _tables[tableName]!.records.fold<int>(
            0, (prev, record) => 
              record.id != null && record.id! > prev ? record.id! : prev
          );
    
    final newRecord = record.copyWith(id: lastId + 1);
    _tables[tableName]!.addRecord(newRecord);
    await _repository.saveTable(tableName, _tables[tableName]!);
    notifyListeners();
  }
}
```

**Key Points:**
- Always call `notifyListeners()` after changes to update UI
- IDs are auto-incremented based on existing records
- Changes are immediately persisted to Hive via `saveTable()`

### READ

Reading tables from Hive:

```dart
// In TablesProvider
Future<void> _loadTables() async {
  _tables = await _repository.getAllTables();
  notifyListeners();
}

// Get a specific table
TableData? getTableByName(String name) {
  return _tables[name];
}

// Get all records in a table
List<Record> getRecords(String tableName) {
  return _tables[tableName]?.records ?? [];
}
```

### UPDATE

Updating existing records:

```dart
Future<void> updateRecord(String tableName, int index, Record record) async {
  if (_tables.containsKey(tableName)) {
    // Preserve the original ID
    final oldId = _tables[tableName]!.records[index].id;
    _tables[tableName]!.updateRecord(index, record.copyWith(id: oldId));
    
    // Persist to Hive
    await _repository.saveTable(tableName, _tables[tableName]!);
    notifyListeners();
  }
}
```

### DELETE

Deleting tables and records:

```dart
// Delete a table
Future<void> deleteTable(String name) async {
  await _repository.deleteTable(name);
  _tables.remove(name);
  notifyListeners();
}

// Delete a record from a table
Future<void> deleteRecord(String tableName, int index) async {
  if (_tables.containsKey(tableName)) {
    _tables[tableName]!.deleteRecord(index);
    await _repository.saveTable(tableName, _tables[tableName]!);
    notifyListeners();
  }
}
```

## Building the Project

### Development Build

For quick iteration during development:

```bash
flutter pub get
dart run build_runner build
flutter run -d windows
```

Or use the provided script:
```bash
.\scripts\dev_win.ps1
```

### Production Build

For a release-ready build:

```bash
flutter pub get
dart run build_runner build
flutter build windows
```

Or use:
```bash
.\scripts\build_win.ps1 -Clean
```

### Build Steps Explained

1. **`flutter pub get`** - Installs dependencies from `pubspec.yaml`
2. **`dart run build_runner build`** - Generates `.g.dart` adapter files
3. **`flutter run/build`** - Compiles the app

## Generated Files

When you run `build_runner`, Hive automatically generates adapter files for your models.

### Generated Adapter Example

For `Record` model, `build_runner` generates `record.g.dart`:

```dart
// This file is GENERATED and should not be edited manually

part of 'record.dart';

class RecordAdapter extends TypeAdapter<Record> {
  @override
  final int typeId = 0;

  @override
  Record read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      dynamic value;
      switch (key) {
        case 0:
          value = reader.read();
          break;
        case 1:
          value = reader.read();
          break;
        case 2:
          value = reader.read();
          break;
        default:
          value = reader.read();
      }
      fields[key] = value;
    }
    return Record(
      id: fields[0] as int?,
      recordDate: fields[1] as DateTime,
      data: fields[2] as Map<String, dynamic>,
    );
  }

  @override
  void write(BinaryWriter writer, Record obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recordDate)
      ..writeByte(2)
      ..write(obj.data);
  }
}
```

### Important: Generated Files in Git

Generated `.g.dart` files should **NOT** be committed to version control:

```gitignore
# Generated files
*.g.dart
```

**Why?**
- They're deterministic - same source always produces identical output
- They're regenerated automatically on build
- Prevents merge conflicts
- Keeps repository size small

### File Structure After Build

```
lib/
├── models/
│   ├── record.dart
│   ├── record.g.dart          ← Generated
│   ├── column.dart
│   ├── column.g.dart          ← Generated
│   ├── column_type.dart
│   ├── column_type.g.dart     ← Generated
│   ├── table_definition.dart
│   ├── table_definition.g.dart ← Generated
│   ├── table_data.dart
│   └── table_data.g.dart      ← Generated
├── repositories/
│   └── tables_repository.dart
├── services/
│   └── storage_service.dart    ← For JSON/CSV export
└── main.dart                   ← Initializes Hive

build/
├── windows/
│   └── x64/
│       └── runner/
│           ├── Debug/
│           │   └── raleigh.exe ← Compiled app
│           └── Release/
│               └── raleigh.exe
```

## Data Storage Location

Hive stores data in the device's app documents directory:

- **Windows**: `C:\Users\[User]\AppData\Local\[App]\raleigh\`
- **macOS**: `~/Library/Application Support/com.example.raleigh/raleigh/`
- **Linux**: `~/.local/share/raleigh/`
- **Android**: App-specific documents directory
- **iOS**: App documents directory

Each box (database table) is stored as a binary file, e.g., `tables.hive` and `tables.lock`.

## Troubleshooting

### Build Runner Not Generating Files

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Type ID Conflicts

If you see errors about conflicting typeIds, check that each model has a unique `@HiveType(typeId: X)` annotation.

### Box Already Open Error

If you see "Box already open", ensure `Hive.openBox()` is only called once (in `TablesRepository.initialize()`).

### Generated Files Not Found

Make sure the `part 'model.g.dart';` statement is at the top of your model file, right after imports.

## Summary

Hive provides:
- ✅ Type-safe local storage
- ✅ Automatic serialization via code generation
- ✅ Fast binary format (much faster than JSON)
- ✅ Easy CRUD operations
- ✅ Integration with Flutter lifecycle
- ✅ Clean separation via repository pattern

The combination of Hive for persistence and `StorageService` for JSON/CSV export/import gives Raleigh a robust data layer that's both performant and user-friendly.
