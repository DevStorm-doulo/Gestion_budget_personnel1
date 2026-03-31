import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/config_api.dart';
import '../../domaine/entites/conseil_ia.dart';

// ─────────────────────────────────────────────
// Source de données Gemini - Analyse IA
// ─────────────────────────────────────────────
abstract class SourceAnalyseGemini {
  Future<List<ConseilIA>> analyserDepenses(Map<String, dynamic> donnees);
}

class SourceAnalyseGeminiImpl implements SourceAnalyseGemini {
  final http.Client client;

  SourceAnalyseGeminiImpl({required this.client});

  static const List<Map<String, String>> _conseilsParDefaut = [
    {
      'titre': 'Suivez vos dépenses quotidiennes',
      'description':
          'Enregistrez chaque dépense dès qu\'elle survient pour avoir une vue précise de vos habitudes financières.',
      'categorie': 'Dépenses',
    },
    {
      'titre': 'Respectez la règle 50/30/20',
      'description':
          'Allouez 50% de vos revenus aux besoins essentiels, 30% aux loisirs et 20% à l\'épargne.',
      'categorie': 'Budget',
    },
    {
      'titre': 'Constituez une épargne d\'urgence',
      'description':
          'Mettez de côté l\'équivalent de 3 mois de dépenses pour faire face aux imprévus.',
      'categorie': 'Économies',
    },
  ];

  @override
  Future<List<ConseilIA>> analyserDepenses(Map<String, dynamic> donnees) async {
    if (ConfigApi.cleGemini == 'VOTRE_CLE_API_ICI') {
      return _genererConseilsParDefaut();
    }

    try {
      final prompt = _construirePrompt(donnees);

      final reponse = await client
          .post(
            Uri.parse(
                '${ConfigApi.urlBaseGemini}?key=${ConfigApi.cleGemini}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 1024,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (reponse.statusCode != 200) {
        return _genererConseilsParDefaut();
      }

      final corps = jsonDecode(reponse.body) as Map<String, dynamic>;
      final candidates = corps['candidates'] as List<dynamic>?;

      if (candidates == null || candidates.isEmpty) {
        return _genererConseilsParDefaut();
      }

      final texte = (candidates[0]['content']['parts'][0]['text'] as String)
          .trim();

      return _parserReponse(texte);
    } catch (e) {
      return _genererConseilsParDefaut();
    }
  }

  String _construirePrompt(Map<String, dynamic> donnees) {
    final solde = donnees['solde'] ?? 0;
    final totalRevenus = donnees['totalRevenus'] ?? 0;
    final totalDepenses = donnees['totalDepenses'] ?? 0;
    final depensesParCategorie =
        donnees['depensesParCategorie'] ?? <String, double>{};
    final budgetDepasses = donnees['budgetDepasses'] ?? [];
    final comparaison = donnees['comparaison'] ?? 'Aucune donnée précédente';

    return '''Tu es un conseiller financier expert. Analyse ces données financières d'un utilisateur et donne exactement 3 conseils personnalisés en français.

Données du mois en cours :
- Solde actuel : $solde FCFA
- Total revenus : $totalRevenus FCFA
- Total dépenses : $totalDepenses FCFA
- Dépenses par catégorie : $depensesParCategorie
- Budgets dépassés : $budgetDepasses
- Comparaison mois précédent : $comparaison

Réponds UNIQUEMENT en JSON valide avec ce format exact :
{
  "conseils": [
    {
      "titre": "titre court du conseil",
      "description": "explication détaillée et actionnable en 2-3 phrases",
      "categorie": "Économies|Dépenses|Budget|Revenus"
    }
  ]
}''';
  }

  List<ConseilIA> _parserReponse(String texte) {
    try {
      String jsonTexte = texte;
      if (jsonTexte.contains('```json')) {
        jsonTexte = jsonTexte.split('```json')[1].split('```')[0].trim();
      } else if (jsonTexte.contains('```')) {
        jsonTexte = jsonTexte.split('```')[1].split('```')[0].trim();
      }

      final donnees = jsonDecode(jsonTexte) as Map<String, dynamic>;
      final conseils = donnees['conseils'] as List<dynamic>?;

      if (conseils == null || conseils.length != 3) {
        return _genererConseilsParDefaut();
      }

      return conseils.asMap().entries.map((entree) {
        return ConseilIA.depuisJson(
            entree.value as Map<String, dynamic>, entree.key);
      }).toList();
    } catch (e) {
      return _genererConseilsParDefaut();
    }
  }

  List<ConseilIA> _genererConseilsParDefaut() {
    return _conseilsParDefaut.asMap().entries.map((entree) {
      return ConseilIA.depuisJson(entree.value, entree.key);
    }).toList();
  }
}
