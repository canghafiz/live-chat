class Channel {
  Channel({
    this.name,
    this.onOtherCall,
    this.proceess,
    this.token,
  });

  String? proceess, name, token;
  bool? onOtherCall;

  // Map
  factory Channel.fromMap(Map<String, dynamic> data) {
    return Channel(
      name: data['name'],
      onOtherCall: data['on_other_call'],
      proceess: data['calling_process'],
      token: data['token'],
    );
  }
}
