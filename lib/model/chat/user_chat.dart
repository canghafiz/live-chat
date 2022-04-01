class UserChat {
  UserChat({
    this.chats,
    this.date,
    this.totalUnread,
  });

  String? date;
  int? totalUnread;
  List? chats;

  // Map
  factory UserChat.fromMap(Map<String, dynamic> data) {
    return UserChat(
      chats: data['chats'],
      date: data['date'],
      totalUnread: data['total_unread'] as int,
    );
  }
}
