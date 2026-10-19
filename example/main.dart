// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_apphud/otel_apphud.dart';

/// Traces Apphud calls with OpenTelemetry.
///
/// `otel_apphud` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Apphud call in
/// [tracedApphud]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'apphud-example');

  // Traces a Apphud call.
  final apphudId = await tracedApphud<String>(
    operation: 'create',
    invoke: () async {
      // Make the Apphud call here, then report what it returned.
      const id = 'apphud_8f3a2c';
      return const ApphudCallResult(
          value: id,
          result: ApphudResult(
              appId: 'app_8f3a2c',
              userId: 'user_8f3a2c',
              productBundleId: 'productbundle_8f3a2c',
              paywallId: 'paywall_8f3a2c',
              placementId: 'placement_8f3a2c',
              subscriptionState: 'active',
              priceAmount: 0.5,
              currency: 'usd',
              store: 'example',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedApphud create returned $apphudId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutApphudInstrumentationAsync.
  await runWithoutApphudInstrumentationAsync(
    () => tracedApphud<String>(
      operation: 'create',
      invoke: () async {
        const id = 'apphud_8f3a2c';
        return const ApphudCallResult(
            value: id,
            result: ApphudResult(
                appId: 'app_8f3a2c',
                userId: 'user_8f3a2c',
                productBundleId: 'productbundle_8f3a2c',
                paywallId: 'paywall_8f3a2c',
                placementId: 'placement_8f3a2c',
                subscriptionState: 'active',
                priceAmount: 0.5,
                currency: 'usd',
                store: 'example',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
