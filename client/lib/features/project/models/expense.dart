class Expense {
  final int id;
  final String date;
  final String category; // 'Materials' | 'Labor' | 'Equipment' | 'Other'
  final String description;
  final double amount;
  final String addedBy;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.addedBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      date: json['date'],
      category: json['category'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      addedBy: json['addedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'category': category,
      'description': description,
      'amount': amount,
      'addedBy': addedBy,
    };
  }
}
