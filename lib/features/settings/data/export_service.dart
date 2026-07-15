import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../transactions/domain/entities/money_transaction.dart';

class ExportService {
  Future<void> exportTransactions(
    List<MoneyTransaction> transactions,
  ) async {
    List<List<dynamic>> rows = [];

    rows.add([
      "Date",
      "Type",
      "Amount",
      "Category",
      "Account",
      "Note",
    ]);

    for (final transaction in transactions) {
      rows.add([
        transaction.date.toString(),
        transaction.type.name,
        transaction.amount,
        transaction.categoryId,
        transaction.accountId,
        transaction.note ?? "",
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/phf_money_backup.csv",
    );

    await file.writeAsString(csv);

    await Share.shareXFiles(
      [
        XFile(file.path),
      ],
      text: "PHF Money Transaction Backup",
    );
  }
}
