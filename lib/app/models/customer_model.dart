class CustomerModel {
  final int id;
  final String name;
  final String? imagePath;
  final String? email;
  final String? primaryAddress;
  final String? secoundaryAddress;
  final String? notes;
  final String? phone;
  final String? custType;
  final String? parentCustomer;
  final double? totalDue;
  final String? lastTransactionDate;
  final String? clinetCompanyName;

  CustomerModel({
    required this.id,
    required this.name,
    this.imagePath,
    this.email,
    this.primaryAddress,
    this.secoundaryAddress,
    this.notes,
    this.phone,
    this.custType,
    this.parentCustomer,
    this.totalDue,
    this.lastTransactionDate,
    this.clinetCompanyName,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? '',
      imagePath: json['ImagePath'],
      email: json['Email'],
      primaryAddress: json['PrimaryAddress'],
      secoundaryAddress: json['SecoundaryAddress'],
      notes: json['Notes'],
      phone: json['Phone'],
      custType: json['CustType'],
      parentCustomer: json['ParentCustomer'],
      totalDue: (json['TotalDue'] is num) ? (json['TotalDue'] as num).toDouble() : null,
      lastTransactionDate: json['LastTransactionDate'],
      clinetCompanyName: json['ClinetCompanyName'],
    );
  }
} 