// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

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
