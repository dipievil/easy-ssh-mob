import 'dart:async' as i9;
import 'dart:ui' as i10;
import 'package:easy_ssh_mob_new/models/execution_result.dart' as i2;
import 'package:easy_ssh_mob_new/models/file_content.dart' as i3;
import 'package:easy_ssh_mob_new/models/log_entry.dart' as i8;
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart' as i5;
import 'package:easy_ssh_mob_new/models/ssh_file.dart' as i6;
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart' as i4;
import 'package:mockito/mockito.dart' as i1;
import 'package:mockito/src/dummies.dart' as i7;

class FakeExecutionResult0 extends i1.SmartFake implements i2.ExecutionResult {
  FakeExecutionResult0(
    super.parent,
    super.parentInvocation,
  );
}

class FakeFileContent1 extends i1.SmartFake implements i3.FileContent {
  FakeFileContent1(
    super.parent,
    super.parentInvocation,
  );
}

class MockSshProvider extends i1.Mock implements i4.SshProvider {
  MockSshProvider() {
    i1.throwOnMissingStub(this);
  }
  @override
  i5.SshConnectionState get connectionState => (super.noSuchMethod(
        Invocation.getter(#connectionState),
        returnValue: i5.SshConnectionState.disconnected,
      ) as i5.SshConnectionState);
  @override
  List<i6.SshFile> get currentFiles => (super.noSuchMethod(
        Invocation.getter(#currentFiles),
        returnValue: <i6.SshFile>[],
      ) as List<i6.SshFile>);
  @override
  String get currentPath => (super.noSuchMethod(
        Invocation.getter(#currentPath),
        returnValue: i7.dummyValue<String>(
          this,
          Invocation.getter(#currentPath),
        ),
      ) as String);
  @override
  List<String> get navigationHistory => (super.noSuchMethod(
        Invocation.getter(#navigationHistory),
        returnValue: <String>[],
      ) as List<String>);
  @override
  bool get shouldPlayErrorSound => (super.noSuchMethod(
        Invocation.getter(#shouldPlayErrorSound),
        returnValue: false,
      ) as bool);
  @override
  List<i8.LogEntry> get sessionLog => (super.noSuchMethod(
        Invocation.getter(#sessionLog),
        returnValue: <i8.LogEntry>[],
      ) as List<i8.LogEntry>);
  @override
  bool get loggingEnabled => (super.noSuchMethod(
        Invocation.getter(#loggingEnabled),
        returnValue: false,
      ) as bool);
  @override
  int get maxLogEntries => (super.noSuchMethod(
        Invocation.getter(#maxLogEntries),
        returnValue: 0,
      ) as int);
  @override
  bool get isConnecting => (super.noSuchMethod(
        Invocation.getter(#isConnecting),
        returnValue: false,
      ) as bool);
  @override
  bool get isConnected => (super.noSuchMethod(
        Invocation.getter(#isConnected),
        returnValue: false,
      ) as bool);
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);
  @override
  i9.Future<void> initialize() => (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<bool> connect({
    required String? host,
    required int? port,
    required String? username,
    required String? password,
    bool? saveCredentials = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #connect,
          [],
          {
            #host: host,
            #port: port,
            #username: username,
            #password: password,
            #saveCredentials: saveCredentials,
          },
        ),
        returnValue: i9.Future<bool>.value(false),
      ) as i9.Future<bool>);
  @override
  i9.Future<void> listDirectory(String? path) => (super.noSuchMethod(
        Invocation.method(
          #listDirectory,
          [path],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<void> navigateToDirectory(String? path) => (super.noSuchMethod(
        Invocation.method(
          #navigateToDirectory,
          [path],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<void> navigateBack() => (super.noSuchMethod(
        Invocation.method(
          #navigateBack,
          [],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<void> navigateToParent() => (super.noSuchMethod(
        Invocation.method(
          #navigateToParent,
          [],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<void> navigateToHome() => (super.noSuchMethod(
        Invocation.method(
          #navigateToHome,
          [],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<void> refreshCurrentDirectory() => (super.noSuchMethod(
        Invocation.method(
          #refreshCurrentDirectory,
          [],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<i2.ExecutionResult> executeFile(
    i6.SshFile? file, {
    Duration? timeout = const Duration(seconds: 30),
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #executeFile,
          [file],
          {#timeout: timeout},
        ),
        returnValue: i9.Future<i2.ExecutionResult>.value(FakeExecutionResult0(
          this,
          Invocation.method(
            #executeFile,
            [file],
            {#timeout: timeout},
          ),
        )),
      ) as i9.Future<i2.ExecutionResult>);
  @override
  i9.Future<String?> executeCommand(String? command) => (super.noSuchMethod(
        Invocation.method(
          #executeCommand,
          [command],
        ),
        returnValue: i9.Future<String?>.value(),
      ) as i9.Future<String?>);
  @override
  void setErrorSoundEnabled(bool? enabled) => super.noSuchMethod(
        Invocation.method(
          #setErrorSoundEnabled,
          [enabled],
        ),
        returnValueForMissingStub: null,
      );

  @override
  i9.Future<String?> executeCommandWithResult(String? command) =>
      (super.noSuchMethod(
        Invocation.method(
          #executeCommandWithResult,
          [command],
        ),
        returnValue: i9.Future<String?>.value(),
      ) as i9.Future<String?>);
  @override
  i9.Future<i3.FileContent> readFile(i6.SshFile? file) => (super.noSuchMethod(
        Invocation.method(
          #readFile,
          [file],
        ),
        returnValue: i9.Future<i3.FileContent>.value(FakeFileContent1(
          this,
          Invocation.method(
            #readFile,
            [file],
          ),
        )),
      ) as i9.Future<i3.FileContent>);
  @override
  i9.Future<i3.FileContent> readFileWithMode(
    i6.SshFile? file,
    i3.FileViewMode? mode,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #readFileWithMode,
          [
            file,
            mode,
          ],
        ),
        returnValue: i9.Future<i3.FileContent>.value(FakeFileContent1(
          this,
          Invocation.method(
            #readFileWithMode,
            [
              file,
              mode,
            ],
          ),
        )),
      ) as i9.Future<i3.FileContent>);
  @override
  i9.Future<void> disconnect() => (super.noSuchMethod(
        Invocation.method(
          #disconnect,
          [],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  i9.Future<void> logout({bool? forgetCredentials = false}) =>
      (super.noSuchMethod(
        Invocation.method(
          #logout,
          [],
          {#forgetCredentials: forgetCredentials},
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  void clearError() => super.noSuchMethod(
        Invocation.method(
          #clearError,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  i9.Future<bool> hasSavedCredentials() => (super.noSuchMethod(
        Invocation.method(
          #hasSavedCredentials,
          [],
        ),
        returnValue: i9.Future<bool>.value(false),
      ) as i9.Future<bool>);
  @override
  i9.Future<void> clearSavedCredentials() => (super.noSuchMethod(
        Invocation.method(
          #clearSavedCredentials,
          [],
        ),
        returnValue: i9.Future<void>.value(),
        returnValueForMissingStub: i9.Future<void>.value(),
      ) as i9.Future<void>);
  @override
  Map<String, dynamic> getSessionStats() => (super.noSuchMethod(
        Invocation.method(
          #getSessionStats,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
  @override
  List<i8.LogEntry> filterSessionLog({
    i8.CommandType? type,
    i8.CommandStatus? status,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #filterSessionLog,
          [],
          {
            #type: type,
            #status: status,
            #searchTerm: searchTerm,
            #startDate: startDate,
            #endDate: endDate,
          },
        ),
        returnValue: <i8.LogEntry>[],
      ) as List<i8.LogEntry>);
  @override
  void clearSessionLog() => super.noSuchMethod(
        Invocation.method(
          #clearSessionLog,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setLoggingEnabled(bool? enabled) => super.noSuchMethod(
        Invocation.method(
          #setLoggingEnabled,
          [enabled],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setMaxLogEntries(int? max) => super.noSuchMethod(
        Invocation.method(
          #setMaxLogEntries,
          [max],
        ),
        returnValueForMissingStub: null,
      );
  @override
  String exportSessionLog({
    required String? format,
    List<i8.LogEntry>? entries,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #exportSessionLog,
          [],
          {
            #format: format,
            #entries: entries,
          },
        ),
        returnValue: i7.dummyValue<String>(
          this,
          Invocation.method(
            #exportSessionLog,
            [],
            {
              #format: format,
              #entries: entries,
            },
          ),
        ),
      ) as String);
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void addListener(i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
