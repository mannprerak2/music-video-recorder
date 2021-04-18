import Cocoa
import FlutterMacOS
import AVFoundation

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    AudioPermissionMacos.register(with: flutterViewController.registrar(forPlugin: "AudioPermissionMacos"))

    super.awakeFromNib()
  }
}
public class AudioPermissionMacos: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "audio_permission_macos",
      binaryMessenger: registrar.messenger)
    let instance = AudioPermissionMacos()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getAudioPermission":
      switch AVCaptureDevice.authorizationStatus(for: .audio) {
          case .authorized: // The user has previously granted access to the microphone.
              NSLog("authorized")
              result(true)
          case .notDetermined: // The user has not yet been asked for microphone access.
              NSLog("not determined")
              AVCaptureDevice.requestAccess(for: .audio) { granted in
                  if granted {
                      result(true)
                  } else {
                      result(false)
                  }
              }
          case .denied: // The user has previously denied access.
              NSLog("denied")
              result(false)
          case .restricted: // The user can't grant access due to restrictions.
              NSLog("restricted")
              result(false)
          default:
              NSLog("unknown")
              result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}