class ContactUser {
  ContactUser({
    this.block,
    this.userId,
  });

  String? userId;
  bool? block;

  // Map
  factory ContactUser.fromMap(Map<String, dynamic> data) {
    return ContactUser(block: data['block'], userId: data['user_id']);
  }
}
