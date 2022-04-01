class GroupChatText {
  GroupChatText({
    this.from,
    this.message,
    this.read,
    this.time,
    this.type,
  });

  String? type, message, time, from;
  List? read;

  // Map
  factory GroupChatText.fromMap(Map<String, dynamic> data) {
    return GroupChatText(
      from: data['from'],
      message: data['message'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class GroupChatImage {
  GroupChatImage({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  List? read;

  // Map
  factory GroupChatImage.fromMap(Map<String, dynamic> data) {
    return GroupChatImage(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class GroupChatAudio {
  GroupChatAudio({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  List? read;

  // Map
  factory GroupChatAudio.fromMap(Map<String, dynamic> data) {
    return GroupChatAudio(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}
