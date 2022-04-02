class Channel {
  Channel({
    this.onOtherCall,
    this.proceess,
  });

  String? proceess;
  bool? onOtherCall;

  // Map
  factory Channel.fromMap(Map<String, dynamic> data) {
    return Channel(
      onOtherCall: data['on_other_call'],
      proceess: data['calling_process'],
    );
  }
}
