import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domaine/entites/resultat_scan.dart';
import '../../domaine/entites/echec_scan.dart';

// ─────────────────────────────────────────────
// Source de reconnaissance de texte pour les reçus
// ─────────────────────────────────────────────
abstract class SourceReconnaissanceRecu {
  Future<ResultatScan> analyserImage(File image);
}

class SourceReconnaissanceRecuImpl implements SourceReconnaissanceRecu {
  final TextRecognizer _reconnaissance;

  SourceReconnaissanceRecuImpl({TextRecognizer? reconnaissance})
      : _reconnaissance = reconnaissance ?? TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<ResultatScan> analyserImage(File image) async {
    // Vérifier que le fichier existe et n'est pas vide
    if (!await image.exists()) {
      throw EchecScan.erreurFichier();
    }

    final taille = await image.length();
    if (taille == 0) {
      throw EchecScan.erreurFichier();
    }

    try {
      // Créer InputImage à partir du fichier
      final inputImage = InputImage.fromFilePath(image.path);

      // Appeler le recognizer
      final recognisedText = await _reconnaissance.processImage(inputImage);

      // Extraire le texte complet
      final texteComplet = recognisedText.text;

      if (texteComplet.isEmpty) {
        throw EchecScan.aucuneDonneeDetectee();
      }

      // Parser les données
      final montant = _extraireMontant(texteComplet);
      final date = _extraireDate(texteComplet);
      final nomCommerce = _extraireNomCommerce(texteComplet);

      // Calculer la confiance
      final confiance = _calculerConfiance(texteComplet, montant, date, nomCommerce);

      // Vérifier si au moins un montant a été trouvé
      if (montant == null) {
        throw EchecScan.aucuneDonneeDetectee();
      }

      // Vérifier si l'image est trop floue (confiance trop basse)
      if (confiance < 0.3) {
        throw EchecScan.imageFloue();
      }

      return ResultatScan(
        montant: montant,
        date: date,
        nomCommerce: nomCommerce,
        description: nomCommerce != null ? '$nomCommerce - Reçu scanné' : 'Reçu scanné',
        texteComplet: texteComplet,
        confiance: confiance,
      );
    } on EchecScan {
      rethrow;
    } catch (e) {
      throw EchecScan.erreurMLKit();
    }
  }

  /// Extrait le montant du texte
  double? _extraireMontant(String texte) {
    // Patterns à rechercher (par ordre de priorité)
    final patterns = [
      RegExp(r'(?:total|TOTAL|Total\s+TTC|Net\s+à\s+payer|MONTANT|Somme|À\s+payer|Prix|Montant\s+dû)\s*[:\s]*\s*([\d\s,.]+)', caseSensitive: false),
      RegExp(r'([\d\s,.]+)\s*€'),
      RegExp(r'€\s*([\d\s,.]+)'),
    ];

    double? montantMax;

    for (final pattern in patterns) {
      final matches = pattern.allMatches(texte);
      for (final match in matches) {
        final texteMontant = match.group(1)?.replaceAll(RegExp(r'\s'), '') ?? '';
        final montant = _parserMontant(texteMontant);
        if (montant != null && montant > 0) {
          if (montantMax == null || montant > montantMax) {
            montantMax = montant;
          }
        }
      }
    }

    return montantMax;
  }

  /// Parse un texte de montant en double
  double? _parserMontant(String texte) {
    try {
      // Gérer les formats : 5 000, 12.50, 1,500.00, 5000, 12,50
      String texteNettoye = texte.replaceAll(RegExp(r'\s'), '');

      // Détecter si c'est un format européen (12,50) ou américain (12.50)
      if (texteNettoye.contains(',') && texteNettoye.contains('.')) {
        // Format : 1,500.00 ou 1.500,00
        if (texteNettoye.lastIndexOf(',') > texteNettoye.lastIndexOf('.')) {
          // Format européen : 1.500,00
          texteNettoye = texteNettoye.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // Format américain : 1,500.00
          texteNettoye = texteNettoye.replaceAll(',', '');
        }
      } else if (texteNettoye.contains(',')) {
        // Vérifier si c'est un séparateur de milliers ou de décimales
        final parties = texteNettoye.split(',');
        if (parties.length == 2 && parties[1].length <= 2) {
          // Probablement un séparateur décimal : 12,50
          texteNettoye = texteNettoye.replaceAll(',', '.');
        } else {
          // Probablement un séparateur de milliers : 1,500
          texteNettoye = texteNettoye.replaceAll(',', '');
        }
      }

      return double.tryParse(texteNettoye);
    } catch (e) {
      return null;
    }
  }

  /// Extrait la date du texte
  DateTime? _extraireDate(String texte) {
    // Patterns de date
    final patterns = [
      // DD/MM/YYYY ou DD-MM-YYYY
      RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})'),
      // YYYY-MM-DD
      RegExp(r'(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})'),
      // DD/MM/YY
      RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{2})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(texte);
      if (match != null) {
        try {
          late DateTime date;
          if (pattern.pattern.contains(r'\d{4}[/\-]')) {
            // Format YYYY-MM-DD
            final annee = int.parse(match.group(1)!);
            final mois = int.parse(match.group(2)!);
            final jour = int.parse(match.group(3)!);
            date = DateTime(annee, mois, jour);
          } else {
            // Format DD/MM/YYYY ou DD/MM/YY
            final jour = int.parse(match.group(1)!);
            final mois = int.parse(match.group(2)!);
            var annee = int.parse(match.group(3)!);
            if (annee < 100) {
              annee += 2000;
            }
            date = DateTime(annee, mois, jour);
          }

          // Valider que la date est plausible
          final maintenant = DateTime.now();
          final ilYAUnAn = DateTime(maintenant.year - 1, maintenant.month, maintenant.day);
          if (date.isAfter(maintenant) || date.isBefore(ilYAUnAn)) {
            continue;
          }

          return date;
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  /// Extrait le nom du commerce
  String? _extraireNomCommerce(String texte) {
    final lignes = texte.split('\n');

    for (final ligne in lignes) {
      final ligneNettoyee = ligne.trim();

      // Ignorer les lignes vides
      if (ligneNettoyee.isEmpty) continue;

      // Ignorer les lignes qui ressemblent à des adresses
      if (RegExp(r'^\d+\s+(rue|avenue|boulevard|place|impasse)', caseSensitive: false).hasMatch(ligneNettoyee)) {
        continue;
      }

      // Ignorer les lignes qui sont uniquement des nombres
      if (RegExp(r'^[\d\s,.€]+$').hasMatch(ligneNettoyee)) continue;

      // Ignorer les lignes trop courtes
      if (ligneNettoyee.length < 3) continue;

      // Nettoyer les caractères spéciaux en trop
      String nom = ligneNettoyee.replaceAll(RegExp(r'^[^a-zA-Z0-9àâäéèêëïîôùûüÿçœæÀÂÄÉÈÊËÏÎÔÙÛÜŸÇŒÆ]+'), '');
      nom = nom.replaceAll(RegExp(r'[^a-zA-Z0-9àâäéèêëïîôùûüÿçœæÀÂÄÉÈÊËÏÎÔÙÛÜŸÇŒÆ\s\-]+$'), '');

      // Limiter à 50 caractères max
      if (nom.length > 50) {
        nom = nom.substring(0, 50).trim();
      }

      if (nom.length >= 3) {
        return nom;
      }
    }

    return null;
  }

  /// Calcule le score de confiance
  double _calculerConfiance(String texte, double? montant, DateTime? date, String? nomCommerce) {
    double score = 0.0;

    if (montant != null) score += 0.4;
    if (date != null) score += 0.3;
    if (nomCommerce != null) score += 0.2;
    if (texte.length > 50) score += 0.1;

    return score.clamp(0.0, 1.0);
  }
}
