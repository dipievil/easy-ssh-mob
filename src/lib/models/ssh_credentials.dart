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

  /// Create SSHCredentials from JSON map
  factory SSHCredentials.fromJson(Map<String, dynamic> json) {
    return SSHCredentials(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  /// Convert SSHCredentials to JSON map
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    };
  }

  /// Validate credentials data
  bool isValid() {
    return host.trim().isNotEmpty &&
        port > 0 &&
        port <= 65535 &&
        username.trim().isNotEmpty &&
        password.isNotEmpty;
  }

  /// Create a copy with modified values
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
    return Object.hash(host, port, username, password);
  }

  @override
  String toString() {
    return 'SSHCredentials(host: $host, port: $port, username: $username)';
  }
}
