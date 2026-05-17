// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_apphud_suppression.dart';

class ApphudResult {
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

class ApphudCallResult<T> {
  const ApphudCallResult({required this.value, this.result});
  final T value;
  final ApphudResult? result;
}

Future<T> tracedApphud<T>({
  required String operation,
  required Future<ApphudCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (apphudInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_apphud');
  final span = t.startSpan('apphud $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'apphud');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.appId != null) {
        span.setStringAttribute('apphud.app.id', res.appId!);
      }
      if (res.userId != null) {
        span.setStringAttribute('user.id', res.userId!);
      }
      if (res.productBundleId != null) {
        span.setStringAttribute(
            'apphud.product.bundle_id', res.productBundleId!);
      }
      if (res.paywallId != null) {
        span.setStringAttribute('apphud.paywall.id', res.paywallId!);
      }
      if (res.placementId != null) {
        span.setStringAttribute('apphud.placement.id', res.placementId!);
      }
      if (res.subscriptionState != null) {
        span.setStringAttribute(
            'apphud.subscription.state', res.subscriptionState!);
      }
      if (res.priceAmount != null) {
        span.setDoubleAttribute('apphud.price.amount', res.priceAmount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('apphud.currency', res.currency!);
      }
      if (res.store != null) {
        span.setStringAttribute('apphud.store', res.store!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('apphud.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
            ErrorResource.errorType.key, res.errorCode ?? 'apphud.error');
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
