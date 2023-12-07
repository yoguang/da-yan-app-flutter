import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// It is essentially a stream but:
//  1. we cache the latestValue of the stream
//  2. the "latestValue" is re-emitted whenever the stream is listened to
class StreamControllerReemit<T> {
  T? _latestValue;

  final StreamController<T> _controller = StreamController<T>.broadcast();

  StreamControllerReemit({T? initialValue}) : _latestValue = initialValue;

  Stream<T> get stream {
    return _latestValue != null
        ? _controller.stream.newStreamWithInitialValue(_latestValue!)
        : _controller.stream;
  }

  T? get value => _latestValue;

  void add(T newValue) {
    _latestValue = newValue;
    _controller.add(newValue);
  }

  Future<void> close() {
    return _controller.close();
  }
}

// return a new stream that imediately emits an initial value
extension _StreamNewStreamWithInitialValue<T> on Stream<T> {
  Stream<T> newStreamWithInitialValue(T initialValue) {
    return transform(_NewStreamWithInitialValueTransformer(initialValue));
  }
}

// Helper for 'newStreamWithInitialValue' method for streams.
class _NewStreamWithInitialValueTransformer<T>
    extends StreamTransformerBase<T, T> {
  final T initialValue;

  _NewStreamWithInitialValueTransformer(this.initialValue);

  @override
  Stream<T> bind(Stream<T> stream) {
    if (stream.isBroadcast) {
      return _bind(stream).asBroadcastStream();
    } else {
      return _bind(stream);
    }
  }

  Stream<T> _bind(Stream<T> stream) {
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      onListen: () {
        // Emit the initial value
        controller?.add(initialValue);

        subscription = stream.listen(
          controller?.add,
          onError: (Object error) {
            controller?.addError(error);
            controller?.close();
          },
          onDone: controller?.close,
        );
      },
      onPause: ([Future<dynamic>? resumeSignal]) {
        subscription?.pause(resumeSignal);
      },
      onResume: () {
        subscription?.resume();
      },
      onCancel: () {
        return subscription?.cancel();
      },
      sync: true,
    );

    return controller.stream;
  }
}

Future<double> calculateDistance(
    double lat1, double lon1, double lat2, double lon2) async {
  double pi = 3.141592653589793;
  // 将经纬度转换为弧度
  lat1 = lat1 * (pi / 180);
  lon1 = lon1 * (pi / 180);
  lat2 = lat2 * (pi / 180);
  lon2 = lon2 * (pi / 180);

  // 使用Haversine公式计算距离
  double dLat = lat2 - lat1;
  double dLon = lon2 - lon1;
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = 6371 * c; // 地球半径为6371km
  // distance.toStringAsFixed(2) 保留两位小数四舍五入
  debugPrint('两点之间的距离：${distance.toStringAsFixed(2)} km');
  debugPrint('两点之间的距离：$distance km');
  return distance;
}
