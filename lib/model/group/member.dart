class Member {
  Member({
    this.userId,
    this.join,
  });

  String? userId, join;

  // Map
  Map<String, dynamic> toMap(String userId) {
    return {
      "join":
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}",
      "user_id": userId,
    };
  }

  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      join: data['join'],
      userId: data['user_id'],
    );
  }
}
