import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raleigh/widgets/add_column_dialog.dart';
import 'package:raleigh/models/column_type.dart';
import 'package:raleigh/models/column.dart' as col;

void main() {
  group('AddColumnDialog Widget Tests', () {
    testWidgets('renders correctly with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddColumnDialog(onSave: (col, val) {}),
          ),
        ),
      );

      expect(find.text('Add New Column'), findsOneWidget);
      expect(find.text('Column Name'), findsOneWidget);
      expect(find.text('Data Type'), findsOneWidget);
      expect(find.text('Default Value'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
    });

    testWidgets('shows error snackbar when column name is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddColumnDialog(onSave: (col, val) {}),
          ),
        ),
      );

      await tester.tap(find.text('Add Column'));
      await tester.pump(); // Start snackbar animation

      expect(find.text('Please enter a column name'), findsOneWidget);
    });

    testWidgets('successfully calls onSave with correct string data', (WidgetTester tester) async {
      col.ColumnDef? capturedColumn;
      dynamic capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddColumnDialog(
              onSave: (column, value) {
                capturedColumn = column;
                capturedValue = value;
              },
            ),
          ),
        ),
      );

      // Enter name
      await tester.enterText(find.widgetWithText(TextField, 'e.g., Email, Category'), 'Category');
      
      // Enter default value
      await tester.enterText(find.widgetWithText(TextField, 'Default text'), 'General');

      await tester.tap(find.text('Add Column'));
      await tester.pumpAndSettle();

      expect(capturedColumn?.name, 'Category');
      expect(capturedColumn?.type, ColumnType.string);
      expect(capturedValue, 'General');
    });

    testWidgets('shows error snackbar for invalid integer default value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddColumnDialog(onSave: (col, val) {}),
          ),
        ),
      );

      // Enter name
      await tester.enterText(find.widgetWithText(TextField, 'e.g., Email, Category'), 'Age');

      // Change type to Integer
      await tester.tap(find.byType(DropdownButton<ColumnType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Integer').last);
      await tester.pumpAndSettle();

      // Enter invalid text
      await tester.enterText(find.widgetWithText(TextField, '0'), 'abc');

      await tester.tap(find.text('Add Column'));
      await tester.pump();

      expect(find.text('Invalid default value for Integer'), findsOneWidget);
    });

    testWidgets('handles boolean checkbox selection', (WidgetTester tester) async {
      col.ColumnDef? capturedColumn;
      dynamic capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddColumnDialog(
              onSave: (column, value) {
                capturedColumn = column;
                capturedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextField, 'e.g., Email, Category'), 'IsActive');

      // Change type to Boolean
      await tester.tap(find.byType(DropdownButton<ColumnType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boolean').last);
      await tester.pumpAndSettle();

      // Toggle checkbox (it's off by default)
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.tap(find.text('Add Column'));
      await tester.pumpAndSettle();

      expect(capturedColumn?.name, 'IsActive');
      expect(capturedColumn?.type, ColumnType.boolean);
      expect(capturedValue, true);
    });
  });
}
