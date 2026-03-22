import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../modeles/transaction_modele.dart';

abstract class SourceTransactionFirebase {
  Future<List<TransactionModele>> obtenirTransactions();
  Future<void> ajouterTransaction(TransactionModele transaction);
  Future<void> modifierTransaction(TransactionModele transaction);
  Future<void> supprimerTransaction(String id);
}

class SourceTransactionFirebaseImpl implements SourceTransactionFirebase {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  SourceTransactionFirebaseImpl({required this.firestore, required this.firebaseAuth});

  String get _userId {
    final user = firebaseAuth.currentUser;
    if (user == null) throw ExceptionAuthentification('Utilisateur non connecté.');
    return user.uid;
  }

  @override
  Future<List<TransactionModele>> obtenirTransactions() async {
    try {
      final snapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Délai d\'attente dépassé'));

      final liste = snapshot.docs.map((doc) => TransactionModele.depuisFirestore(doc)).toList();
      liste.sort((a, b) => b.date.compareTo(a.date)); // Tri décroissant côté client
      return liste;
    } catch (e) {
      throw ExceptionServeur('Erreur lors de la récupération des transactions: $e');
    }
  }

  @override
  Future<void> ajouterTransaction(TransactionModele transaction) async {
    try {
      final docRef = firestore.collection('transactions').doc();
      final data = transaction.versFirestore();
      data['userId'] = _userId; // Sécurité
      await docRef.set(data).timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Délai d\'attente dépassé'));
    } catch (e) {
      throw ExceptionServeur('Erreur lors de l\'ajout de la transaction: $e');
    }
  }

  @override
  Future<void> modifierTransaction(TransactionModele transaction) async {
    try {
      // Sécurité: vérifier au préalable ou faire confiance aux règles Firestore, ici on force le userId
      final data = transaction.versFirestore();
      data['userId'] = _userId; 
      await firestore.collection('transactions').doc(transaction.id).update(data)
          .timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Délai d\'attente dépassé'));
    } catch (e) {
      throw ExceptionServeur('Erreur lors de la modification de la transaction: $e');
    }
  }

  @override
  Future<void> supprimerTransaction(String id) async {
    try {
      await firestore.collection('transactions').doc(id).delete()
          .timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Délai d\'attente dépassé'));
    } catch (e) {
      throw ExceptionServeur('Erreur lors de la suppression de la transaction: $e');
    }
  }
}
