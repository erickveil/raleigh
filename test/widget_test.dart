import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raleigh/main.dart';
import 'package:raleigh/models/record.dart';
import 'package:raleigh/models/column_type.dart';
import 'package:raleigh/models/column.dart';
import 'package:raleigh/models/table_definition.dart';
import 'package:raleigh/models/table_data.dart';
import 'package:raleigh/repositories/tables_repository.dart';
import 'dart:io';

void main() {
  setUpAll(() async {
    // Setup temporary directory for Hive
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(RecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ColumnTypeAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ColumnDefAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TableDefinitionAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(TableDataAdapter());

    // Initialize repository
    await TablesRepository.initialize();
  });

  testWidgets('App smoke test - verifies home screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('Raleigh Data Tracker'), findsOneWidget);
    
    // Verify that the "No tables yet" message is shown (since box is empty)
    expect(find.text('No tables yet'), findsOneWidget);
    
    // Verify that the "Create New Table" button is present
    expect(find.text('Create New Table'), findsOneWidget);
  });
}
