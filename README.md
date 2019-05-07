# yp_image_picker

A new flutter plugin project.

## Getting Started

Currently only implemeted in iOS

```
import 'package:yp_image_picker/yp_image_picker.dart';

  final result = await YpImagePicker.pickImage(
                    maxImages: 4,
                    quality: 0.5,
                    width: 1024,
                    height: 1024,
                    videos: false,
                  );
```
