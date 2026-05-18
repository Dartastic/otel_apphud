// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_apphud/otel_apphud.dart';
import 'package:test/test.dart';

void main() {
  group('otel_apphud', () {
    test('suppression toggles in zone', () async {
      expect(apphudInstrumentationSuppressed(), isFalse);
      await runWithoutApphudInstrumentationAsync(() async {
        expect(apphudInstrumentationSuppressed(), isTrue);
      });
      expect(apphudInstrumentationSuppressed(), isFalse);
    });

    test('ApphudResult fields default null', () {
      const r = ApphudResult();
      expect(r.statusCode, isNull);
    });
  });
}
