import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yp_image_picker/yp_image_picker.dart';

void main() {
  const MethodChannel channel = MethodChannel('yp_image_picker');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
