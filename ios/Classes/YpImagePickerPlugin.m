#import "YpImagePickerPlugin.h"
#import <yp_image_picker/yp_image_picker-Swift.h>

@implementation YpImagePickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYpImagePickerPlugin registerWithRegistrar:registrar];
}
@end
