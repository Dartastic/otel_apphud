# otel_apphud

Dartastic OpenTelemetry bridge for Apphud (IAP + paywall orchestrator).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_apphud/otel_apphud.dart';

await tracedApphud<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return ApphudCallResult(value: r, result: ApphudResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutApphudInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
