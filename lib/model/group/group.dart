class Group {
  Group({
    this.chatDate,
    this.members,
    this.name,
    this.owner,
    this.profile,
  });

  String? name, owner, chatDate, profile;
  List? members;

  // Map
  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
      chatDate: data['chat_date'],
      members: data['members'],
      name: data['name'],
      owner: data['owner'],
      profile: data['profile'],
    );
  }
}
