import Flutter
import UIKit
import YPImagePicker
import Photos

public class SwiftYpImagePickerPlugin: NSObject, FlutterPlugin {
    var config = YPImagePickerConfiguration()
    var controller: FlutterViewController!
    var imagesResult: FlutterResult?
    var messenger: FlutterBinaryMessenger;
    var picker: YPImagePicker;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "yp_image_picker", binaryMessenger: registrar.messenger())
        let app =  UIApplication.shared
        
        let controller : FlutterViewController = app.delegate!.window!!.rootViewController as! FlutterViewController;
        let instance = SwiftYpImagePickerPlugin.init(cont: controller, messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    init(cont: FlutterViewController, messenger: FlutterBinaryMessenger) {
        self.config.screens = [.library, .photo]
        self.config.startOnScreen = .library
        self.config.library.mediaType = .photo
        self.config.shouldSaveNewPicturesToAlbum = false
        self.picker = YPImagePicker(configuration: self.config)
        self.controller = cont;
        self.messenger = messenger;
        super.init();
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "finish":
            self.picker = YPImagePicker()
        default:
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            var assets = [Data?]();
            let maxImages = arguments["maxImages"] as! Int
            let width = arguments["width"] as! Int
            let quality = arguments["quality"] as! CGFloat
            let videos = arguments["videos"] as? Bool ?? false
            let onlySquare = arguments["onlySquare"] as? Bool ?? false
            
            if (videos) {
                self.config.screens.append(.video)
                self.config.library.mediaType = .photoAndVideo
            }
            self.config.library.onlySquare = onlySquare
            self.config.library.maxNumberOfItems = maxImages
            self.config.targetImageSize = YPImageSize.cappedTo(size: CGFloat(width))
            YPImagePickerConfiguration.shared = self.config
            
            self.picker.didFinishPicking { [unowned picker] items, _ in
                for item in items {
                    switch item {
                    case .photo(let photo):
                        assets.append(photo.image.jpegData(compressionQuality:quality)!)
                    case .video(let video):
                        print(video)
                    }
                }
                result(assets)
                picker.dismiss(animated: true, completion: nil)
            }
            controller!.present(self.picker, animated: true, completion: nil)
        }
    }
}










