import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domaine/entites/transaction.dart';

class TransactionModele extends TransactionEntity {
  const TransactionModele({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    required super.date,
    required super.category,
    super.description,
    required super.createdAt,
  });

  factory TransactionModele.depuisFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return TransactionModele(
      id: doc.id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'expense',
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      category: map['category'] ?? '',
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> versFirestore() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TransactionModele.depuisEntite(TransactionEntity entity) {
    return TransactionModele(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      amount: entity.amount,
      date: entity.date,
      category: entity.category,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
