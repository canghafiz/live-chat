class PersonalChatText {
  PersonalChatText({
    this.from,
    this.message,
    this.read,
    this.time,
    this.type,
  });

  String? type, message, time, from;
  bool? read;

  // Map
  factory PersonalChatText.fromMap(Map<String, dynamic> data) {
    return PersonalChatText(
      from: data['from'],
      message: data['message'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class PersonalChatImage {
  PersonalChatImage({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  bool? read;

  // Map
  factory PersonalChatImage.fromMap(Map<String, dynamic> data) {
    return PersonalChatImage(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class PersonalChatAudio {
  PersonalChatAudio({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  bool? read;

  // Map
  factory PersonalChatAudio.fromMap(Map<String, dynamic> data) {
    return PersonalChatAudio(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}
