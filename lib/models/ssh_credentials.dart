import 'dart:convert';

class SSHCredentials {
  final String host;
  final int port;
  final String username;
  final String password;

  const SSHCredentials({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  /// Convert SSH credentials to JSON
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    };
  }

  /// Create SSH credentials from JSON
  factory SSHCredentials.fromJson(Map<String, dynamic> json) {
    return SSHCredentials(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  /// Convert SSH credentials to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create SSH credentials from JSON string
  factory SSHCredentials.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return SSHCredentials.fromJson(json);
  }

  /// Validate SSH credentials data
  bool isValid() {
    return host.isNotEmpty &&
           port > 0 &&
           port <= 65535 &&
           username.isNotEmpty &&
           password.isNotEmpty;
  }

  /// Create a copy of credentials with updated fields
  SSHCredentials copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
  }) {
    return SSHCredentials(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'SSHCredentials(host: $host, port: $port, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SSHCredentials &&
           other.host == host &&
           other.port == port &&
           other.username == username &&
           other.password == password;
  }

  @override
  int get hashCode {
    return host.hashCode ^
           port.hashCode ^
           username.hashCode ^
           password.hashCode;
  }
}