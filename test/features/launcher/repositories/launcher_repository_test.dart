import 'package:f_launcher/src/common/constants/value_constant.dart';
import 'package:f_launcher/src/common/patterns/result_pattern.dart';
import 'package:f_launcher/src/features/launcher/models/launcher_model.dart';
import 'package:f_launcher/src/features/launcher/repositories/launcher_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // MethodChannel requires the Flutter binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LauncherRepository Test', () {
    late LauncherRepository repository;
    late MethodChannel channel;

    /// Shorthand to register a mock handler on the launcher MethodChannel.
    void setChannelHandler(Future<dynamic> Function(MethodCall call) handler) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, handler);
    }

    setUp(() {
      channel = MethodChannel(ValueConstant.pathChannel);
      repository = LauncherRepositoryImpl();
    });

    tearDown(() {
      // Remove handler so tests don't bleed into each other.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    // ---------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------

    final tAppMaps = [
      {
        'name': 'Flutter',
        'packageName': 'com.flutter.app',
        'icon': List<int>.filled(4, 0),
      },
      {
        'name': 'Dart',
        'packageName': 'com.dart.app',
        'icon': List<int>.filled(4, 255),
      },
    ];

    final tApps = tAppMaps
        .map((e) => LauncherModel.fromMap(e.cast<String, dynamic>()))
        .toList();

    // ---------------------------------------------------------------------------
    // findApps — success path
    // ---------------------------------------------------------------------------

    group('findApps', () {
      test('should return SuccessResult with a list of LauncherModel '
          'when channel returns valid data', () async {
        // arrange
        setChannelHandler((_) async => tAppMaps);

        // act
        final result = await repository.findApps('getAllApps');

        // assert
        expect(result, isA<SuccessResult<List<LauncherModel>, Exception>>());
        final apps =
            (result as SuccessResult<List<LauncherModel>, Exception>).value;
        expect(apps.length, equals(tApps.length));
        expect(apps.first.name, equals(tApps.first.name));
        expect(apps.first.packageName, equals(tApps.first.packageName));
      });

      test(
        'should pass the received methodName to the MethodChannel',
        () async {
          // arrange
          String? capturedMethod;
          setChannelHandler((call) async {
            capturedMethod = call.method;
            return tAppMaps;
          });

          // act
          await repository.findApps('getSystemApps');

          // assert
          expect(capturedMethod, equals('getSystemApps'));
        },
      );

      test('should return SuccessResult with an empty list '
          'when channel returns an empty array', () async {
        // arrange
        setChannelHandler((_) async => <dynamic>[]);

        // act
        final result = await repository.findApps('getAllApps');

        // assert
        expect(result, isA<SuccessResult<List<LauncherModel>, Exception>>());
        final apps =
            (result as SuccessResult<List<LauncherModel>, Exception>).value;
        expect(apps, isEmpty);
      });

      test('should map icon bytes correctly into Uint8List', () async {
        // arrange
        setChannelHandler((_) async => tAppMaps);

        // act
        final result = await repository.findApps('getAllApps');
        final apps =
            (result as SuccessResult<List<LauncherModel>, Exception>).value;

        // assert
        expect(apps.first.icon, isA<Uint8List>());
        expect(apps.first.icon.length, equals(4));
      });

      test('should use Uint8List(0) when icon field is null', () async {
        // arrange
        setChannelHandler(
          (_) async => [
            {'name': 'NoIcon', 'packageName': 'com.no.icon', 'icon': null},
          ],
        );

        // act
        final result = await repository.findApps('getAllApps');
        final apps =
            (result as SuccessResult<List<LauncherModel>, Exception>).value;

        // assert
        expect(apps.first.icon, isA<Uint8List>());
        expect(apps.first.icon, isEmpty);
      });

      test(
        'should return ErrorResult when channel throws a PlatformException',
        () async {
          // arrange
          setChannelHandler(
            (_) async => throw PlatformException(
              code: 'UNAVAILABLE',
              message: 'Channel not available',
            ),
          );

          // act
          final result = await repository.findApps('getAllApps');

          // assert
          expect(result, isA<ErrorResult<List<LauncherModel>, Exception>>());
        },
      );

      test(
        'should return ErrorResult when channel throws a generic Exception',
        () async {
          // arrange
          setChannelHandler((_) async => throw Exception('Unexpected failure'));

          // act
          final result = await repository.findApps('getAllApps');

          // assert
          expect(result, isA<ErrorResult<List<LauncherModel>, Exception>>());
          final error =
              (result as ErrorResult<List<LauncherModel>, Exception>).error;
          expect(error, isA<Exception>());
        },
      );

      test('should allow fold to extract app list on SuccessResult', () async {
        // arrange
        setChannelHandler((_) async => tAppMaps);

        // act
        final result = await repository.findApps('getAllApps');
        final apps = result.fold(
          onSuccess: (value) => value,
          onError: (_) => <LauncherModel>[],
        );

        // assert
        expect(apps, isNotEmpty);
        expect(apps.first.packageName, equals(tApps.first.packageName));
      });

      test('should allow fold to return empty list on ErrorResult', () async {
        // arrange
        setChannelHandler((_) async => throw Exception('Error'));

        // act
        final result = await repository.findApps('getAllApps');
        final apps = result.fold(
          onSuccess: (value) => value,
          onError: (_) => <LauncherModel>[],
        );

        // assert
        expect(apps, isEmpty);
      });
    });

    // ---------------------------------------------------------------------------
    // openApp
    // ---------------------------------------------------------------------------

    group('openApp', () {
      test(
        'should invoke openApp on the channel with the correct packageName',
        () async {
          // arrange
          Map<String, dynamic>? capturedArgs;
          setChannelHandler((call) async {
            if (call.method == 'openApp') {
              capturedArgs = Map<String, dynamic>.from(call.arguments as Map);
            }
            return null;
          });

          // act
          await repository.openApp('com.flutter.app');

          // assert
          expect(capturedArgs, isNotNull);
          expect(capturedArgs!['packageName'], equals('com.flutter.app'));
        },
      );

      test(
        'should complete without error when channel call succeeds',
        () async {
          // arrange
          setChannelHandler((_) async => null);

          // act & assert
          await expectLater(repository.openApp('com.flutter.app'), completes);
        },
      );

      test('should throw Exception when channel call fails', () async {
        // arrange
        setChannelHandler(
          (_) async =>
              throw PlatformException(code: 'ERROR', message: 'App not found'),
        );

        // act & assert
        expect(
          () => repository.openApp('com.invalid.app'),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains('Something went wrong'),
            ),
          ),
        );
      });
    });
  });
}
