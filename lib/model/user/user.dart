class User {
  User({
    this.contacts,
    this.email,
    this.groups,
    this.name,
    this.online,
    this.profile,
    this.channel,
  });

  String? name, profile, email;
  bool? online;
  List? contacts, groups;
  Map<String, dynamic>? channel;

  // Map
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      contacts: data['contacts'],
      email: data['email'],
      groups: data['groups'],
      name: data['name'],
      online: data['online'],
      profile: data['profile'],
      channel: data['channel'],
    );
  }
}
