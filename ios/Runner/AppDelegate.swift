import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var mapsApiKey = "placeholder"
    if let dartDefines = Bundle.main.infoDictionary?["DART_DEFINES"] as? String {
        let defines = dartDefines.components(separatedBy: ",")
        for define in defines {
            if let decodedData = Data(base64Encoded: define),
               let decodedString = String(data: decodedData, encoding: .utf8) {
                let parts = decodedString.components(separatedBy: "=")
                if parts.count == 2 && parts[0] == "GOOGLE_MAPS_API_KEY" {
                    mapsApiKey = parts[1]
                    break
                }
            }
        }
    }
    
    GMSServices.provideAPIKey(mapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
