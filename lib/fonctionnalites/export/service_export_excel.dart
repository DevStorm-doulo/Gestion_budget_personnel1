import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../fonctionnalites/transactions/domaine/entites/transaction.dart';

// ─────────────────────────────────────────────
// Service d'export Excel
// ─────────────────────────────────────────────
class ServiceExportExcel {
  static final ServiceExportExcel _instance = ServiceExportExcel._internal();
  factory ServiceExportExcel() => _instance;
  ServiceExportExcel._internal();
  
  /// Génère un fichier Excel avec les transactions
  Future<Uint8List> genererExcelTransactions({
    required List<TransactionEntity> transactions,
    required int mois,
    required int annee,
  }) async {
    final excel = Excel.createExcel();
    
    // Supprimer la feuille par défaut
    excel.delete('Sheet1');
    
    // Créer la feuille de transactions
    final Sheet feuille = excel['Transactions'];
    
    // Formater le mois en français
    final nomMois = DateFormat('MMMM yyyy', 'fr').format(DateTime(annee, mois));
    
    // Ajouter le titre
    feuille.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Transactions - $nomMois')
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );
    
    // Fusionner les cellules pour le titre
    feuille.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0));
    
    // Ajouter les en-têtes
    final enTetes = ['Date', 'Description', 'Catégorie', 'Montant (FCFA)'];
    for (var i = 0; i < enTetes.length; i++) {
      feuille.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2))
        ..value = TextCellValue(enTetes[i])
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#FF6C63FF'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFFFF'),
          horizontalAlign: HorizontalAlign.Center,
        );
    }
    
    // Trier les transactions par date (plus récent en premier)
    final transactionsTriees = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    // Ajouter les données
    for (var i = 0; i < transactionsTriees.length; i++) {
      final transaction = transactionsTriees[i];
      final rowIndex = i + 3;
      
      // Date
      feuille.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue(DateFormat('dd/MM/yyyy', 'fr').format(transaction.date))
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);
      
      // Description
      feuille.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(transaction.description ?? '')
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);
      
      // Catégorie
      feuille.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(transaction.category[0].toUpperCase() + transaction.category.substring(1))
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);
      
      // Montant
      final montant = transaction.type == 'income' ? transaction.amount : -transaction.amount;
      feuille.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = DoubleCellValue(montant)
        ..cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Right,
          numberFormat: NumFormat.custom(formatCode: '#,##0'),
          fontColorHex: transaction.type == 'income' 
            ? ExcelColor.fromHexString('#FF10B981') 
            : ExcelColor.fromHexString('#FFEF4444'),
        );
    }
    
    // Ajuster la largeur des colonnes
    feuille.setColumnWidth(0, 15); // Date
    feuille.setColumnWidth(1, 40); // Description
    feuille.setColumnWidth(2, 20); // Catégorie
    feuille.setColumnWidth(3, 20); // Montant
    
    // Ajouter une feuille de résumé
    final Sheet feuilleResume = excel['Résumé'];
    _ajouterFeuilleResume(feuilleResume, transactionsTriees, nomMois);
    
    // Encoder le fichier Excel
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Erreur lors de la génération du fichier Excel');
    }
    
    return Uint8List.fromList(bytes);
  }
  
  /// Ajoute une feuille de résumé
  void _ajouterFeuilleResume(
    Sheet feuille,
    List<TransactionEntity> transactions,
    String nomMois,
  ) {
    // Titre
    feuille.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Résumé - $nomMois')
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );
    
    // Fusionner les cellules pour le titre
    feuille.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0));
    
    // Calculer les totaux
    final totalRevenus = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalDepenses = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final solde = totalRevenus - totalDepenses;
    
    // Ajouter les statistiques
    final statistiques = [
      ['Total Revenus', totalRevenus],
      ['Total Dépenses', totalDepenses],
      ['Solde', solde],
      ['Nombre de transactions', transactions.length.toDouble()],
    ];
    
    for (var i = 0; i < statistiques.length; i++) {
      final label = statistiques[i][0] as String;
      final valeur = statistiques[i][1] as double;
      
      // Label
      feuille.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 2))
        ..value = TextCellValue(label)
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Left,
        );
      
      // Valeur
      feuille.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2))
        ..value = DoubleCellValue(valeur)
        ..cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Right,
          numberFormat: NumFormat.custom(formatCode: '#,##0'),
          fontColorHex: label == 'Solde'
            ? (valeur >= 0 ? ExcelColor.fromHexString('#FF10B981') : ExcelColor.fromHexString('#FFEF4444'))
            : ExcelColor.fromHexString('#FF000000'),
        );
    }
    
    // Ajuster la largeur des colonnes
    feuille.setColumnWidth(0, 25);
    feuille.setColumnWidth(1, 20);
  }
  
  /// Enregistre le fichier Excel dans le stockage local
  Future<String> enregistrerExcel(Uint8List excelBytes, String nomFichier) async {
    final directory = await getApplicationDocumentsDirectory();
    final fichier = File('${directory.path}/$nomFichier.xlsx');
    await fichier.writeAsBytes(excelBytes);
    return fichier.path;
  }
  
  /// Partage le fichier Excel
  Future<void> partagerExcel(Uint8List excelBytes, String nomFichier) async {
    final directory = await getTemporaryDirectory();
    final fichier = File('${directory.path}/$nomFichier.xlsx');
    await fichier.writeAsBytes(excelBytes);
    
    // Note: Le partage sera implémenté ultérieurement
    // Pour l'instant, on sauvegarde juste le fichier
    print('Fichier Excel sauvegardé: ${fichier.path}');
  }
}
