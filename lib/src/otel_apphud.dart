// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_apphud_suppression.dart';

class ApphudResult {
  /// Creates a result.
  const ApphudResult({
    this.appId,
    this.userId,
    this.productBundleId,
    this.paywallId,
    this.placementId,
    this.subscriptionState,
    this.priceAmount,
    this.currency,
    this.store,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? appId;
  final String? userId;
  final String? productBundleId;
  final String? paywallId;
  final String? placementId;
  final String? subscriptionState;
  final double? priceAmount;
  final String? currency;
  final String? store;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class ApphudCallResult<T> {
  /// Creates a call result.
  const ApphudCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final ApphudResult? result;
}

Future<T> tracedApphud<T>({
  required String operation,
  required Future<ApphudCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (apphudInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_apphud');
  final span = t.startSpan('apphud $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'apphud')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.appId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('apphud.app.id', res.appId!)]));
      }
      if (res.userId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('user.id', res.userId!)]));
      }
      if (res.productBundleId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'apphud.product.bundle_id', res.productBundleId!)
        ]));
      }
      if (res.paywallId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('apphud.paywall.id', res.paywallId!)]));
      }
      if (res.placementId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('apphud.placement.id', res.placementId!)
        ]));
      }
      if (res.subscriptionState != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'apphud.subscription.state', res.subscriptionState!)
        ]));
      }
      if (res.priceAmount != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeDouble('apphud.price.amount', res.priceAmount!)
        ]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('apphud.currency', res.currency!)]));
      }
      if (res.store != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('apphud.store', res.store!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('apphud.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              ErrorAttributes.errorType.key, res.errorCode ?? 'apphud.error')
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
