# Developer Overview

This document orients new contributors to the Raleigh Data Tracker codebase. It summarizes the application structure, core data flow, and how the main components work together so you can add features or fix bugs quickly.

## Project at a Glance

Raleigh Data Tracker is a Flutter app that lets users create custom tables with typed columns, add/edit/delete records, and import/export data as JSON or CSV. Data is stored locally in the app documents directory.

## High-Level Architecture

- **UI layer**: Flutter screens and widgets for user interaction.
- **State layer**: Provider-based `TablesProvider` that owns in-memory table state and coordinates persistence.
- **Model layer**: Plain Dart models describing tables, columns, and records.
- **Persistence layer**: `StorageService` for local storage, import, and export.

The UI talks to the provider, the provider updates models and persists them through the storage service, and the UI rebuilds based on provider state.

## Codebase Layout

- lib/main.dart: App entry point and provider setup.
- lib/screens: UI screens for table creation, data entry, viewing tables, and the home page.
- lib/providers: App state and business logic (Provider).
- lib/models: Core data structures.
- lib/services: Persistence, import, export.

## Core Components

### App Entry and DI

**File**: [lib/main.dart](../lib/main.dart)

- Builds the `MaterialApp`.
- Registers `TablesProvider` via `MultiProvider`.
- Sets the `HomeScreen` as the app’s entry screen.

### State Management

**File**: [lib/providers/tables_provider.dart](../lib/providers/tables_provider.dart)

- Owns the in-memory map of tables (`Map<String, TableData>`).
- Loads existing tables on startup.
- Exposes operations for:
  - Creating and deleting tables.
  - Adding, updating, and deleting records.
  - Exporting a table to JSON or CSV.
- Persists changes by calling `StorageService.saveAllTables` after mutations.

### Models

**Files**:
- [lib/models/table_definition.dart](../lib/models/table_definition.dart)
- [lib/models/table_data.dart](../lib/models/table_data.dart)
- [lib/models/column.dart](../lib/models/column.dart)
- [lib/models/column_type.dart](../lib/models/column_type.dart)
- [lib/models/record.dart](../lib/models/record.dart)

Key responsibilities:

- **TableDefinition**: Table name and column definitions.
- **ColumnDef**: Column name and type.
- **ColumnType**: Enum for supported types (String, Integer, Double, DateTime, Boolean).
- **Record**: Row data with an auto-assigned `id` and `recordDate` timestamp.
- **TableData**: Bundles a `TableDefinition` with its list of `Record` entries.

### Persistence and Import/Export

**File**: [lib/services/storage_service.dart](../lib/services/storage_service.dart)

- Stores data in a JSON file in the app documents directory.
- Provides JSON serialization and CSV export.
- Loads all tables at startup and saves all tables on change.
- Imports tables from JSON files exported by the app.

## UI Screens and Flows

### Home Screen

**File**: [lib/screens/home_screen.dart](../lib/screens/home_screen.dart)

- Lists all tables with record and column counts.
- Entry points for:
  - Create table
  - Delete table
  - Import table (JSON)
  - View a table

### Create Table

**File**: [lib/screens/create_table_screen.dart](../lib/screens/create_table_screen.dart)

- Collects a table name and column definitions.
- Validates inputs and passes them to `TablesProvider.createTable`.

### View Table

**File**: [lib/screens/view_table_screen.dart](../lib/screens/view_table_screen.dart)

- Displays records in a `DataTable`.
- Provides add/edit/delete record actions.
- Offers export to JSON or CSV.

### Data Entry

**File**: [lib/screens/data_entry_screen.dart](../lib/screens/data_entry_screen.dart)

- Builds input fields dynamically based on `TableDefinition`.
- Parses typed inputs and creates a `Record`.
- Validation errors are shown via snackbars.

## Data Flow Summary

1. User performs an action in the UI.
2. The screen calls a method on `TablesProvider`.
3. The provider updates models and persists via `StorageService`.
4. Provider notifies listeners; UI rebuilds with updated state.

## Persistence Details

- All tables are stored in a single JSON file under the app documents directory.
- Exported files are placed in the same directory.
- CSV export includes `ID` and `RecordDate` columns before the custom columns.

## Extension Points for Features

Common places to extend:

- **New column types**: Add to `ColumnType`, then update parsing and validation in `DataEntryScreen`.
- **New export formats**: Add method to `StorageService`, then expose it in `TablesProvider` and the UI.
- **Filtering/sorting**: Implement in `ViewTableScreen` and consider storing preferences in provider or storage.
- **Validation rules**: Add validation in `DataEntryScreen` or model-level helpers.

## Troubleshooting Tips

- If tables appear empty on launch, verify `StorageService.loadAllTables` and file permissions.
- If edits don’t persist, check that provider methods call `_saveTables` after mutations.
- If imports fail, confirm the JSON matches the app export schema.

## Quick Navigation

- Main entry: [lib/main.dart](../lib/main.dart)
- Provider: [lib/providers/tables_provider.dart](../lib/providers/tables_provider.dart)
- Storage: [lib/services/storage_service.dart](../lib/services/storage_service.dart)
- Screens: [lib/screens](../lib/screens)
- Models: [lib/models](../lib/models)
