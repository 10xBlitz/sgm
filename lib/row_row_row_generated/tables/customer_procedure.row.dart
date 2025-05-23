// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class CustomerProcedureRow {
  static const table = 'customer_procedure';

  static const field = (
    id: 'id',
    task: 'task',
    clinic: 'clinic',
    procedureCommission: 'procedure_commission',
    totalPrice: 'total_price',
    createdAt: 'created_at',
    procedure: 'procedure',
    dueDate: 'due_date',
    datePaid: 'date_paid',
  );

  final String id;
  final String? task;
  final String? clinic;
  final double? procedureCommission;
  final double? totalPrice;
  final DateTime createdAt;
  final String procedure;
  final DateTime? dueDate;
  final DateTime? datePaid;

  const CustomerProcedureRow({
    required this.id,
    this.task,
    this.clinic,
    this.procedureCommission,
    this.totalPrice,
    required this.createdAt,
    required this.procedure,
    this.dueDate,
    this.datePaid,
  });

  factory CustomerProcedureRow.fromJson(Map<String, dynamic> json) {
    return CustomerProcedureRow(
      id: json[field.id] as String,
      task: json[field.task],
      clinic: json[field.clinic],
      procedureCommission:
          json[field.procedureCommission] == null
              ? null
              : (json[field.procedureCommission] as num?)?.toDouble(),
      totalPrice:
          json[field.totalPrice] == null
              ? null
              : (json[field.totalPrice] as num?)?.toDouble(),
      createdAt: DateTime.parse(json[field.createdAt]),
      procedure: json[field.procedure] as String,
      dueDate:
          json[field.dueDate] == null
              ? null
              : DateTime.tryParse(json[field.dueDate] ?? ''),
      datePaid:
          json[field.datePaid] == null
              ? null
              : DateTime.tryParse(json[field.datePaid] ?? ''),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.task: task,
      field.clinic: clinic,
      field.procedureCommission: procedureCommission,
      field.totalPrice: totalPrice,
      field.createdAt: createdAt.toIso8601String(),
      field.procedure: procedure,
      field.dueDate: dueDate?.toIso8601String(),
      field.datePaid: datePaid?.toIso8601String(),
    };
  }

  CustomerProcedureRow copyWith({
    String? id,
    String? task,
    String? clinic,
    double? procedureCommission,
    double? totalPrice,
    DateTime? createdAt,
    String? procedure,
    DateTime? dueDate,
    DateTime? datePaid,
  }) {
    return CustomerProcedureRow(
      id: id ?? this.id,
      task: task ?? this.task,
      clinic: clinic ?? this.clinic,
      procedureCommission: procedureCommission ?? this.procedureCommission,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      procedure: procedure ?? this.procedure,
      dueDate: dueDate ?? this.dueDate,
      datePaid: datePaid ?? this.datePaid,
    );
  }
}
