import 'dart:async';

import 'package:mysql1/mysql1.dart';

class DatabaseService {
  final ConnectionSettings settings = ConnectionSettings(
    host: '136.243.50.232',
    port: 3306,
    user: 'bcryptsi_limon',
    db: 'bcryptsi_my_users',
    password: 'PS!*}3#qSBr%',
  );

  MySqlConnection? _connection;
  late StreamController<Map<String, dynamic>> _dataStreamController;

  DatabaseService() {
    _dataStreamController = StreamController<Map<String, dynamic>>();
    _connectToDatabase();
    _fetchDataPeriodically();
  }

  Future<void> _connectToDatabase() async {
    try {
      _connection = await MySqlConnection.connect(settings);
    } catch (e) {
      print('Error connecting to the database: $e');
    }
  }

  Stream<Map<String, dynamic>> getDataStream() async* {
    if (_connection == null) {
      await _connectToDatabase();
    }

    final results = await _connection!.query('SELECT * FROM students');
    for (var row in results) {
      final data = row.fields;
      print('Received data: $data');
      _dataStreamController.add(data);
    }
  }

  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  Future<void> _fetchDataPeriodically() async {
    await for (var _ in Stream.periodic(const Duration(seconds: 5))) {
      if (_connection == null) {
        await _connectToDatabase();
      }

      try {
        final newData = await _connection?.query('SELECT * FROM students');
        for (var row in newData!) {
          final data = row.fields;
          print('Received data periodically: $data');
          _dataStreamController.add(data);
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    }
  }
}
