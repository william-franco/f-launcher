import 'package:f_launcher/src/common/constants/value_constant.dart';
import 'package:f_launcher/src/common/enums/launcher_filter_enum.dart';
import 'package:f_launcher/src/common/patterns/app_state_pattern.dart';
import 'package:f_launcher/src/common/patterns/result_pattern.dart';
import 'package:f_launcher/src/features/launcher/models/launcher_model.dart';
import 'package:f_launcher/src/features/launcher/repositories/launcher_repository.dart';
import 'package:f_launcher/src/features/launcher/view_models/launcher_view_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../launcher_mocks.mocks.dart';

void main() {
  // MethodChannel (used in openApp) requires the Flutter binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LauncherViewModel Test', () {
    late MockLauncherRepository mockLauncherRepository;
    late LauncherViewModel viewModel;

    final dummySuccess = SuccessResult<List<LauncherModel>, Exception>(
      value: [],
    );
    final dummyError = ErrorResult<List<LauncherModel>, Exception>(
      error: Exception('dummy'),
    );

    setUpAll(() {
      provideDummy<LauncherResult>(dummySuccess);
      provideDummy<LauncherResult>(dummyError);
    });

    setUp(() {
      mockLauncherRepository = MockLauncherRepository();
      viewModel = LauncherViewModelImpl(
        launcherRepository: mockLauncherRepository,
      );

      // Stub the MethodChannel used by openApp inside the ViewModel.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            MethodChannel(ValueConstant.pathChannel),
            (_) async => null,
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            MethodChannel(ValueConstant.pathChannel),
            null,
          );
      viewModel.dispose();
    });

    // ---------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------

    final tApps = [
      LauncherModel(
        name: 'Flutter',
        packageName: 'com.flutter.app',
        icon: Uint8List.fromList([0, 0, 0, 0]),
      ),
      LauncherModel(
        name: 'Dart',
        packageName: 'com.dart.app',
        icon: Uint8List.fromList([255, 255, 255, 255]),
      ),
    ];

    // ---------------------------------------------------------------------------
    // Initial state
    // ---------------------------------------------------------------------------

    test('should start with InitialState', () {
      expect(viewModel.state, isA<InitialState<List<LauncherModel>>>());
    });

    test('should start with filter set to LauncherFilterEnum.all', () {
      expect(viewModel.currentFilter, equals(LauncherFilterEnum.all));
    });

    // ---------------------------------------------------------------------------
    // getApps
    // ---------------------------------------------------------------------------

    group('getApps', () {
      test('should emit [LoadingState, SuccessState] '
          'when repository returns SuccessResult', () async {
        // arrange
        when(
          mockLauncherRepository.findApps(any),
        ).thenAnswer((_) async => SuccessResult(value: tApps));

        final emittedStates = <LauncherState>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getApps();

        // assert
        expect(emittedStates.length, equals(2));
        expect(emittedStates[0], isA<LoadingState<List<LauncherModel>>>());
        expect(emittedStates[1], isA<SuccessState<List<LauncherModel>>>());

        final success = emittedStates[1] as SuccessState<List<LauncherModel>>;
        expect(success.data.length, equals(tApps.length));
        expect(success.data.first.name, equals(tApps.first.name));
      });

      test('should emit [LoadingState, ErrorState] '
          'when repository returns ErrorResult', () async {
        // arrange
        when(mockLauncherRepository.findApps(any)).thenAnswer(
          (_) async => ErrorResult(error: Exception('Channel unavailable')),
        );

        final emittedStates = <LauncherState>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getApps();

        // assert
        expect(emittedStates[0], isA<LoadingState<List<LauncherModel>>>());
        expect(emittedStates[1], isA<ErrorState<List<LauncherModel>>>());

        final error = emittedStates[1] as ErrorState<List<LauncherModel>>;
        expect(error.message, contains('Channel unavailable'));
      });

      test('should emit SuccessState with empty list '
          'when repository returns an empty SuccessResult', () async {
        // arrange
        when(
          mockLauncherRepository.findApps(any),
        ).thenAnswer((_) async => SuccessResult(value: <LauncherModel>[]));

        final emittedStates = <LauncherState>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getApps();

        // assert
        final success = emittedStates[1] as SuccessState<List<LauncherModel>>;
        expect(success.data, isEmpty);
      });

      test('should notify listeners exactly twice per getApps call', () async {
        // arrange
        when(
          mockLauncherRepository.findApps(any),
        ).thenAnswer((_) async => SuccessResult(value: tApps));

        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        // act
        await viewModel.getApps();

        // assert
        expect(notifyCount, equals(2));
      });

      // -----------------------------------------------------------------------
      // Filter → method name mapping
      // -----------------------------------------------------------------------

      final filterMethodMap = {
        LauncherFilterEnum.all: 'getAllApps',
        LauncherFilterEnum.system: 'getSystemApps',
        LauncherFilterEnum.user: 'getUserApps',
        LauncherFilterEnum.playStore: 'getAppsFromPlayStore',
        LauncherFilterEnum.recentlyUsed: 'getRecentlyUsedApps',
      };

      for (final entry in filterMethodMap.entries) {
        test('should call findApps with "${entry.value}" '
            'when currentFilter is ${entry.key.name}', () async {
          // arrange
          when(
            mockLauncherRepository.findApps(any),
          ).thenAnswer((_) async => SuccessResult(value: tApps));

          // Set internal filter via updateFilter (also calls getApps).
          // Reset listener count after that call.
          await viewModel.updateFilter(entry.key);

          // assert — verify the exact method string was forwarded
          verify(
            mockLauncherRepository.findApps(entry.value),
          ).called(greaterThanOrEqualTo(1));
        });
      }
    });

    // ---------------------------------------------------------------------------
    // updateFilter
    // ---------------------------------------------------------------------------

    group('updateFilter', () {
      test('should update currentFilter and call getApps', () async {
        // arrange
        when(
          mockLauncherRepository.findApps(any),
        ).thenAnswer((_) async => SuccessResult(value: tApps));

        // act
        await viewModel.updateFilter(LauncherFilterEnum.system);

        // assert
        expect(viewModel.currentFilter, equals(LauncherFilterEnum.system));
        verify(mockLauncherRepository.findApps('getSystemApps')).called(1);
      });

      test(
        'should emit [LoadingState, SuccessState] after filter change',
        () async {
          // arrange
          when(
            mockLauncherRepository.findApps(any),
          ).thenAnswer((_) async => SuccessResult(value: tApps));

          final emittedStates = <LauncherState>[];
          viewModel.addListener(() => emittedStates.add(viewModel.state));

          // act
          await viewModel.updateFilter(LauncherFilterEnum.user);

          // assert
          expect(emittedStates.length, equals(2));
          expect(emittedStates[0], isA<LoadingState<List<LauncherModel>>>());
          expect(emittedStates[1], isA<SuccessState<List<LauncherModel>>>());
        },
      );

      test(
        'should reflect the latest filter after multiple sequential updates',
        () async {
          // arrange
          when(
            mockLauncherRepository.findApps(any),
          ).thenAnswer((_) async => SuccessResult(value: tApps));

          // act
          await viewModel.updateFilter(LauncherFilterEnum.user);
          await viewModel.updateFilter(LauncherFilterEnum.recentlyUsed);

          // assert
          expect(
            viewModel.currentFilter,
            equals(LauncherFilterEnum.recentlyUsed),
          );
        },
      );
    });

    // ---------------------------------------------------------------------------
    // openApp
    // ---------------------------------------------------------------------------

    group('openApp', () {
      test(
        'should invoke openApp on the MethodChannel with the correct packageName',
        () async {
          // arrange
          String? capturedPackage;
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                MethodChannel(ValueConstant.pathChannel),
                (call) async {
                  if (call.method == 'openApp') {
                    capturedPackage =
                        (call.arguments as Map)['packageName'] as String?;
                  }
                  return null;
                },
              );

          // act
          await viewModel.openApp('com.flutter.app');

          // assert
          expect(capturedPackage, equals('com.flutter.app'));
        },
      );

      test(
        'should complete without error when channel call succeeds',
        () async {
          await expectLater(viewModel.openApp('com.flutter.app'), completes);
        },
      );

      test('should complete without throwing when channel call fails '
          '(error is only logged via debugPrint)', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              MethodChannel(ValueConstant.pathChannel),
              (_) async => throw PlatformException(
                code: 'ERROR',
                message: 'App not found',
              ),
            );

        // act & assert — ViewModel swallows the error (only debugPrint)
        await expectLater(viewModel.openApp('com.invalid.app'), completes);
      });

      test(
        'should not change the LauncherState when openApp is called',
        () async {
          // arrange
          when(
            mockLauncherRepository.findApps(any),
          ).thenAnswer((_) async => SuccessResult(value: tApps));
          await viewModel.getApps();
          final stateBeforeOpen = viewModel.state;

          // act
          await viewModel.openApp('com.flutter.app');

          // assert
          expect(viewModel.state, same(stateBeforeOpen));
        },
      );
    });
  });
}
