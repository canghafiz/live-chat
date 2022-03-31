class Call {
  Call({
    this.answer,
    this.time,
    this.type,
    this.userId,
  });

  String? userId, time, type;
  bool? answer;

  // Map
  factory Call.fromMap(Map<String, dynamic> data) {
    return Call(
      answer: data['answer'],
      time: data['time'],
      type: data['type'],
      userId: data['user_id'],
    );
  }
}
