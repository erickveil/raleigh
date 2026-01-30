import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/record.dart';
import 'models/column_type.dart';
import 'models/column.dart';
import 'models/table_definition.dart';
import 'models/table_data.dart';
import 'repositories/tables_repository.dart';
import 'providers/tables_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(ColumnTypeAdapter());
  Hive.registerAdapter(ColumnDefAdapter());
  Hive.registerAdapter(TableDefinitionAdapter());
  Hive.registerAdapter(TableDataAdapter());
  
  // Initialize repository
  await TablesRepository.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TablesProvider()),
      ],
      child: MaterialApp(
        title: 'Raleigh Data Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
