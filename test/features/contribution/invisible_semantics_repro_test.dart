/// Reproduksi assert "Invisible SemanticsNodes should not be added to the
/// tree" saat toggle chip Sederhana -> Lengkap di form kontribusi.
///
/// Node yang dilaporkan: suffix icon "Ambil dari KBBI" (FTextField
/// suffixBuilder) di bawah MergeSemantics bawaan forui 0.22.x.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/contribution/domain/providers/contribution_domain_providers.dart';
import 'package:sambasku_mobile/features/contribution/presentation/pages/contribute_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ReferenceAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final Object body;
    if (path.endsWith('/word-classes')) {
      body = {
        'data': [
          {'id': 'wc-umum', 'name': 'Umum', 'code': 'umum'},
        ],
      };
    } else if (path.endsWith('/languages')) {
      body = {
        'data': [
          {'id': 'lang-sbs', 'name': 'Sambas', 'code': 'SBS'},
          {'id': 'lang-idn', 'name': 'Indonesia', 'code': 'IDN'},
        ],
      };
    } else if (path.endsWith('/dialects')) {
      body = {
        'data': [
          {'id': 'd-umum', 'name': 'Umum', 'code': 'umum', 'is_default': true},
        ],
      };
    } else {
      body = {'data': []};
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('toggle sederhana -> lengkap tidak menambah semantics node kosong', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final dio = Dio()..httpClientAdapter = _ReferenceAdapter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dioProvider.overrideWithValue(dio)],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: ContributePage()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Isi terjemahan dulu supaya isi form menyerupai laporan user.
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(1), 'makan');
    await tester.pump();
    // Fokuskan field terjemahan seperti user asli (keyboard terbuka saat tap
    // chip).
    await tester.tap(find.text('Terjemahan Indonesia *').last, warnIfMissed: false);
    await tester.pump();

    await tester.tap(find.text('Lengkap'));
    // Frame ini menjalankan unfocus; Future.delayed(Duration.zero)
    // dijadwalkan. Frame berikutnya mengeksekusi timer + rebuild.
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    // sendSemanticsUpdate melempar FlutterError via assert; takeException
    // menangkapnya bila repro sukses. Setelah fix, tidak ada error.
    final error = tester.takeException();
    expect(
      error,
      isNull,
      reason: 'Fix berfungsi - tidak ada Invisible SemanticsNodes assert',
    );
  });
}
