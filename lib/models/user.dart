class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String currency;
  final bool isDarkMode;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.currency = 'INR',
    this.isDarkMode = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? currency,
    bool? isDarkMode,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'currency': currency,
      'isDarkMode': isDarkMode,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      currency: json['currency'] ?? 'INR',
      isDarkMode: json['isDarkMode'] ?? false,
    );
  }
}
