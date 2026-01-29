# Raleigh Data Tracker

Raleigh Data Tracker is a Flutter app for creating lightweight, local tables and capturing records with typed columns. It’s designed for quick, offline data collection and export.

## Features

- Create custom tables with named, typed columns.
- Supported column types: String, Integer, Double, DateTime, Boolean.
- Add, edit, and delete records per table.
- Automatic Record ID and RecordDate tracking.
- Export a table to JSON or CSV.
- Import tables from JSON, with optional replace when a table name already exists.
- Local persistence (app documents directory).

## How It Works

- Tables are defined by a name and a list of columns.
- Records are stored with an auto-incremented `id` and a `recordDate` timestamp.
- All data is persisted to a local JSON file in the app documents directory.
- Exports are saved into the same app documents directory.

## Project Structure

- UI screens live under lib/screens.
- Table and record models live under lib/models.
- Data persistence and import/export logic is in lib/services/storage_service.dart.
- State management uses Provider in lib/providers.

## Running the App

- Ensure Flutter is installed and configured.
- Fetch dependencies using the standard Flutter workflow.
- Run the app on your preferred device or emulator.

## Import/Export Notes

- JSON imports expect the app’s own export format.
- CSV exports include ID and RecordDate columns, followed by your custom columns.

## Tech Stack

- Flutter (Material 3)
- Provider for state management
- file_picker for JSON import
- path_provider for local storage
