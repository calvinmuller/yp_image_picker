import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:yp_image_picker/yp_image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VideoPlayerController _controller;
  List _images = [];
  bool initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Stack(
            children: <Widget>[
              _previewPhoto(),
              _previewVideo(_controller),
              FlatButton(
                onPressed: () async {
                  final result = await YpImagePicker.pickImage(
                    maxImages: 4,
                    quality: 0.5,
                    width: 1024,
                    height: 1024,
                    videos: false,
                  );

                  // video
                  if (result is String) {
                    File file = File(result);
                    _controller = VideoPlayerController.file(file)
                      ..addListener(_onVideoControllerUpdate)
                      ..setVolume(1.0)
                      ..initialize()
                      ..setLooping(true)
                      ..play();
                  } else if (result is List) {
                    setState(() {
                      _images = result;
                    });
                  }
                },
                child: Text("Image Picker"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewVideo(VideoPlayerController controller) {
    if (controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    } else if (controller.value.initialized) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatioVideo(controller),
      );
    } else {
      return const Text(
        'Error Loading Video',
        textAlign: TextAlign.center,
      );
    }
  }

  void _onVideoControllerUpdate() {
    setState(() {});
  }

  _previewPhoto() {
    return ListView.builder(
      itemBuilder: (context, i) {
        Uint8List image = _images[i];

        print(image.lengthInBytes.toString());

        return Image.memory(image);
      },
      itemCount: _images.length,
    );
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
