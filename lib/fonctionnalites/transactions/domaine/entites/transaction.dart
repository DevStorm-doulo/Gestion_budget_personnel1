import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String type; // 'income' ou 'expense'
  final double amount;
  final DateTime date;
  final String category; // source si revenu, catégorie si dépense
  final String? description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, type, amount, date, category, description, createdAt];
}
