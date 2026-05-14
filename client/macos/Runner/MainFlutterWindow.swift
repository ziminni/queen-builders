import Cocoa
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // desktop_multi_window only attaches if FlutterAppDelegate.mainFlutterWindow is non-nil.
    // During nib awake, that outlet may not be wired yet — assign explicitly before plugin registration.
    if let delegate = NSApplication.shared.delegate as? FlutterAppDelegate {
      delegate.mainFlutterWindow = self
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      RegisterGeneratedPlugins(registry: controller)
    }

    super.awakeFromNib()
  }
}
