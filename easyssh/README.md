# EasySSH

A Flutter application for easy SSH connections and file system navigation.

## Description

EasySSH is a mobile application that allows users to connect to SSH servers and navigate their file systems through an intuitive graphical interface. The app simplifies script execution, file viewing, and basic command operations.

## Features

- SSH connection management
- File system navigation with button-based interface
- Secure credential storage
- Script execution
- File viewing
- Material 3 design

## Dependencies

This project uses the following key dependencies:

- **dartssh2** (^2.12.6) - Pure Dart SSH implementation for secure connections
- **provider** (^6.1.1) - State management solution
- **flutter_secure_storage** (^9.0.0) - Secure storage for credentials
- **font_awesome_flutter** (^10.6.0) - Icon library

## Getting Started

### Prerequisites

- Flutter SDK (>=3.1.0)
- Android Studio or VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd easy-ssh-mob/easyssh
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
easyssh/
├── lib/
│   └── main.dart          # Main application entry point
├── test/
│   └── widget_test.dart   # Widget tests
├── android/               # Android-specific configuration
├── ios/                   # iOS-specific configuration
├── pubspec.yaml          # Project dependencies and configuration
└── analysis_options.yaml # Dart analysis configuration
```

## Development Phases

The project is developed in phases:

1. **Phase 1**: Foundation and main connection functionality
2. **Phase 2**: Directory navigation
3. **Phase 3**: File interaction and execution
4. **Phase 4**: UI/UX and additional features
5. **Phase 5**: Logging and finalization

## Testing

Run tests with:

```bash
flutter test
```

## Building

### Android

```bash
flutter build apk
```

### iOS

```bash
flutter build ios
```

## Contributing

This project follows Flutter best practices and uses Material 3 design guidelines.

## License

See the LICENSE file in the root directory for license information.