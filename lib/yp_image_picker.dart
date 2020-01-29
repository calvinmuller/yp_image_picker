import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yp_image_picker/src/image_asset.dart';

import 'src/metadata.dart';

class YpImagePicker {
  static const MethodChannel _channel = const MethodChannel('yp_image_picker');

  static void finish() async {
    await _channel.invokeMethod('finish');
  }

  static Future<dynamic> pickImage({
    @required int maxImages,
    int width = 800,
    int height = 600,
    bool videos = false,
    double quality = 0.5,
    bool onlySquare = false,
    bool isDark = false,
    String colour = "#FF9900",
    String text = "#FFFFFF",
    bool closeOnLimitReached = false,
    bool isUseDetailView = false,
  }) async {
    assert(maxImages != null);

    if (maxImages != null && maxImages < 0) {
      throw new ArgumentError.value(maxImages, 'maxImages cannot be negative');
    }

    final dynamic items =
        await _channel.invokeMethod('getImages', <String, dynamic>{
      "onlySquare": onlySquare,
      "maxImages": maxImages,
      "width": width,
      "height": height,
      "quality": quality,
      "videos": videos,
      "enableCamera": true,
      "isUseDetailView": isUseDetailView,
      "isDark": isDark,
      "androidOptions": {},
      "selectedAssets": [],
      "colour": colour,
      "text": text,
      "closeOnLimitReached": closeOnLimitReached,
    });

    return items;
  }

  /// Requests the original image data for a given
  /// [identifier].
  ///
  /// This method is used by the asset class, you
  /// should not invoke it manually. For more info
  /// refer to [ImageAsset] class docs.
  ///
  /// The actual image data is sent via BinaryChannel.
  static Future<bool> requestOriginal(String identifier, quality) async {
    bool ret = await _channel.invokeMethod("requestOriginal", <String, dynamic>{
      "identifier": identifier,
      "quality": quality,
    });
    return ret;
  }

  /// Requests a thumbnail with [width], [height]
  /// and [quality] for a given [identifier].
  ///
  /// This method is used by the asset class, you
  /// should not invoke it manually. For more info
  /// refer to [Asset] class docs.
  ///
  /// The actual image data is sent via BinaryChannel.
  static Future<bool> requestThumbnail(
      String identifier, int width, int height, int quality) async {
    assert(identifier != null);
    assert(width != null);
    assert(height != null);

    if (width != null && width < 0) {
      throw new ArgumentError.value(width, 'width cannot be negative');
    }

    if (height != null && height < 0) {
      throw new ArgumentError.value(height, 'height cannot be negative');
    }

    if (quality < 0 || quality > 100) {
      throw new ArgumentError.value(
          quality, 'quality should be in range 0-100');
    }

    bool ret = await _channel.invokeMethod(
        "requestThumbnail", <String, dynamic>{
      "identifier": identifier,
      "width": width,
      "height": height,
      "quality": quality
    });
    return ret;
  }

  // Requests image metadata for a given [identifier]
  static Future<Metadata> requestMetadata(String identifier) async {
    Map<dynamic, dynamic> map = await _channel.invokeMethod(
      "requestMetadata",
      <String, dynamic>{
        "identifier": identifier,
      },
    );

    Map<String, dynamic> metadata = Map<String, dynamic>.from(map);
    if (Platform.isIOS) {
      metadata = _normalizeMetadata(metadata);
    }

    return Metadata.fromMap(metadata);
  }

  /// Refresh image gallery with specific path
  /// [path].
  ///
  /// This method is used by refresh image gallery
  /// Some of the image picker would not be refresh automatically
  /// You can refresh it manually.
  static Future<bool> refreshImage({
    @required String path,
  }) async {
    assert(path != null);
    bool result = await _channel
        .invokeMethod("refreshImage", <String, dynamic>{"path": path});

    return result;
  }

  /// Normalizes the meta data returned by iOS.
  static Map<String, dynamic> _normalizeMetadata(Map<String, dynamic> json) {
    Map map = Map<String, dynamic>();

    json.forEach((String metaKey, dynamic metaValue) {
      if (metaKey == '{Exif}' || metaKey == '{TIFF}') {
        map.addAll(Map<String, dynamic>.from(metaValue));
      } else if (metaKey == '{GPS}') {
        Map gpsMap = Map<String, dynamic>();
        Map<String, dynamic> metaMap = Map<String, dynamic>.from(metaValue);
        metaMap.forEach((String key, dynamic value) {
          if (key == 'GPSVersion') {
            gpsMap['GPSVersionID'] = value;
          } else {
            gpsMap['GPS$key'] = value;
          }
        });
        map.addAll(gpsMap);
      } else {
        map[metaKey] = metaValue;
      }
    });

    return map;
  }

  /// Delete images from the gallery
  /// [List<Asset>].
  ///
  /// Allows you to delete array of Asset objects from the filesystem.
  static Future<bool> deleteImages({@required List<ImageAsset> assets}) async {
    assert(assets != null);
    List<String> identifiers = assets.map((a) => a.identifier).toList();
    bool result = await _channel.invokeMethod(
        "deleteImages", <String, dynamic>{"identifiers": identifiers});

    return result;
  }
}
