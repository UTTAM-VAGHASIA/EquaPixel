import 'package:csv/csv.dart';
import '../models/connection.dart';

class ExportService {
  /// Export connections to CSV format
  static String exportToCSV(List<Connection> connections) {
    List<List<dynamic>> rows = [
      ['Step', 'From Nail', 'To Nail', 'Thread Color', 'Thread Name']
    ];

    for (int i = 0; i < connections.length; i++) {
      Connection conn = connections[i];
      rows.add([
        i + 1,
        conn.fromNailId,
        conn.toNailId,
        '#${conn.thread.color.toARGB32().toRadixString(16).padLeft(8, '0')}',
        conn.thread.name,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export summary statistics
  static String exportSummary(List<Connection> connections) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('String Art Generation Summary');
    buffer.writeln('============================');
    buffer.writeln('Total Connections: ${connections.length}');
    buffer.writeln('');

    // Count by thread
    Map<String, int> threadCounts = {};
    for (var conn in connections) {
      threadCounts[conn.thread.name] = (threadCounts[conn.thread.name] ?? 0) + 1;
    }

    buffer.writeln('Connections by Thread:');
    threadCounts.forEach((name, count) {
      buffer.writeln('  $name: $count');
    });

    return buffer.toString();
  }
}