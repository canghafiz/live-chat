class Member {
  Member({
    this.userId,
    this.join,
  });

  String? userId, join;

  // Map
  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      join: data['join'],
      userId: data['user_id'],
    );
  }
}
