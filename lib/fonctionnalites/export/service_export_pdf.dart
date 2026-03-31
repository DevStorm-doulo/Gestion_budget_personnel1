import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../fonctionnalites/transactions/domaine/entites/transaction.dart';

// ─────────────────────────────────────────────
// Service d'export PDF
// ─────────────────────────────────────────────
class ServiceExportPdf {
  static final ServiceExportPdf _instance = ServiceExportPdf._internal();
  factory ServiceExportPdf() => _instance;
  ServiceExportPdf._internal();
  
  /// Génère un rapport mensuel PDF
  Future<Uint8List> genererRapportMensuel({
    required List<TransactionEntity> transactions,
    required double totalRevenus,
    required double totalDepenses,
    required double solde,
    required Map<String, double> depensesParCategorie,
    required int mois,
    required int annee,
  }) async {
    final pdf = pw.Document();
    
    // Formater le mois en français
    final nomMois = DateFormat('MMMM yyyy', 'fr').format(DateTime(annee, mois));
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _construireEnTete(context, nomMois),
        footer: (context) => _construirePiedDePage(context),
        build: (context) => [
          // Résumé financier
          _construireResumeFinancier(solde, totalRevenus, totalDepenses),
          pw.SizedBox(height: 20),
          
          // Graphique par catégorie
          if (depensesParCategorie.isNotEmpty) ...[
            _construireTitreSection('Répartition des dépenses par catégorie'),
            pw.SizedBox(height: 10),
            _construireGraphiqueCategories(depensesParCategorie),
            pw.SizedBox(height: 20),
          ],
          
          // Liste des transactions
          _construireTitreSection('Liste des transactions'),
          pw.SizedBox(height: 10),
          _construireTableauTransactions(transactions),
        ],
      ),
    );
    
    return pdf.save();
  }
  
  /// Construit l'en-tête du PDF
  pw.Widget _construireEnTete(pw.Context context, String nomMois) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        children: [
          pw.Text(
            'Rapport Budget Mensuel',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            nomMois.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Généré le ${DateFormat('dd/MM/yyyy à HH:mm', 'fr').format(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construit le pied de page du PDF
  pw.Widget _construirePiedDePage(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} sur ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }
  
  /// Construit le résumé financier
  pw.Widget _construireResumeFinancier(
    double solde,
    double totalRevenus,
    double totalDepenses,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _construireElementResume('Solde', solde, PdfColors.blue900),
          _construireElementResume('Revenus', totalRevenus, PdfColors.green700),
          _construireElementResume('Dépenses', totalDepenses, PdfColors.red700),
        ],
      ),
    );
  }
  
  /// Construit un élément du résumé
  pw.Widget _construireElementResume(
    String label,
    double montant,
    PdfColor couleur,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${_formaterMontant(montant)} FCFA',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: couleur,
          ),
        ),
      ],
    );
  }
  
  /// Construit un titre de section
  pw.Widget _construireTitreSection(String titre) {
    return pw.Text(
      titre,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }
  
  /// Construit le graphique par catégories
  pw.Widget _construireGraphiqueCategories(
    Map<String, double> depensesParCategorie,
  ) {
    final total = depensesParCategorie.values.fold(0.0, (sum, val) => sum + val);
    final entrees = depensesParCategorie.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: entrees.map((entree) {
          final pourcentage = total > 0 ? (entree.value / total * 100) : 0;
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    color: _couleurPourCategorie(entree.key),
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    entree.key[0].toUpperCase() + entree.key.substring(1),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Text(
                  '${_formaterMontant(entree.value)} FCFA',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  '${pourcentage.toStringAsFixed(1)}%',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// Construit le tableau des transactions
  pw.Widget _construireTableauTransactions(List<TransactionEntity> transactions) {
    // Trier les transactions par date (plus récent en premier)
    final transactionsTriees = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return pw.Column(
      children: [
        // En-tête du tableau
        pw.Container(
          color: PdfColors.blue100,
          child: pw.Row(
            children: [
              pw.Expanded(flex: 2, child: _construireCelluleEnTete('Date')),
              pw.Expanded(flex: 3, child: _construireCelluleEnTete('Description')),
              pw.Expanded(flex: 2, child: _construireCelluleEnTete('Catégorie')),
              pw.Expanded(flex: 2, child: _construireCelluleEnTete('Montant')),
            ],
          ),
        ),
        // Lignes de transactions
        ...transactionsTriees.map((transaction) => pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: _construireCellule(
                  DateFormat('dd/MM/yyyy', 'fr').format(transaction.date),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: _construireCellule(transaction.description ?? ''),
              ),
              pw.Expanded(
                flex: 2,
                child: _construireCellule(
                  transaction.category[0].toUpperCase() +
                      transaction.category.substring(1),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: _construireCellule(
                  '${transaction.type == 'income' ? '+' : '-'}${_formaterMontant(transaction.amount)} FCFA',
                  couleur: transaction.type == 'income' ? PdfColors.green700 : PdfColors.red700,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  /// Construit une cellule d'en-tête
  pw.Widget _construireCelluleEnTete(String texte) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texte,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }
  
  /// Construit une cellule de données
  pw.Widget _construireCellule(String texte, {PdfColor? couleur}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texte,
        style: pw.TextStyle(
          fontSize: 9,
          color: couleur ?? PdfColors.black,
        ),
      ),
    );
  }
  
  /// Retourne une couleur pour une catégorie
  PdfColor _couleurPourCategorie(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'salaire':
        return PdfColors.green700;
      case 'bourse':
        return PdfColors.blue700;
      case 'aide':
        return PdfColors.purple700;
      case 'transport':
        return PdfColors.blue500;
      case 'alimentation':
        return PdfColors.orange700;
      case 'loyer':
        return PdfColors.pink700;
      case 'loisirs':
        return PdfColors.teal700;
      case 'sante':
        return PdfColors.red700;
      default:
        return PdfColors.grey700;
    }
  }
  
  /// Formate un montant en FCFA
  String _formaterMontant(double montant) {
    final n = montant.abs().toInt();
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202F');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
  
  /// Affiche la boîte de dialogue d'impression/partage
  Future<void> afficherDialogueImpression(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
  
  /// Enregistre le PDF dans le stockage local
  Future<String> enregistrerPdf(Uint8List pdfBytes, String nomFichier) async {
    final directory = await getApplicationDocumentsDirectory();
    final fichier = File('${directory.path}/$nomFichier.pdf');
    await fichier.writeAsBytes(pdfBytes);
    return fichier.path;
  }
  
  /// Partage le PDF
  Future<void> partagerPdf(Uint8List pdfBytes, String nomFichier) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: '$nomFichier.pdf');
  }
}
