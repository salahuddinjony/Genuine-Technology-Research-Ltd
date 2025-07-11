class UserModel {
  final String? token;
  final String? userName;
  final int? comId;

  UserModel({this.token, this.userName, this.comId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['Token'],
      userName: json['UserName'],
      comId: json['ComId'],
    );
  }
} 