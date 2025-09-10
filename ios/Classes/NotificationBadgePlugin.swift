import Flutter
import UIKit
import UserNotifications

public class NotificationBadgePlugin: NSObject, FlutterPlugin {
    private var currentBadgeCount: Int = 0
    
    private func log(_ message: String) {
        print("[NotificationBadgePlus] \(message)")
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "notification_badge", binaryMessenger: registrar.messenger())
        let instance = NotificationBadgePlugin()
        instance.log("Plugin registered with Flutter engine")
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Register for application lifecycle notifications
        NotificationCenter.default.addObserver(
            instance,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            instance,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        log("Method call received: \(call.method)")
        
        switch call.method {
        case "setBadgeCount":
            log("setBadgeCount method called")
            setBadgeCount(call: call, result: result)
        case "getBadgeCount":
            log("getBadgeCount method called")
            getBadgeCount(result: result)
        case "isSupported":
            log("isSupported method called - iOS always supports badges")
            result(true) // iOS always supports badges
        case "getDeviceManufacturer":
            log("getDeviceManufacturer method called")
            result("Apple")
        default:
            log("Unimplemented method called: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setBadgeCount(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let count = args["count"] as? Int else {
            log("setBadgeCount failed: Invalid count argument")
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid count argument", details: nil))
            return
        }
        
        log("setBadgeCount called with count: \(count)")
        
        if count < 0 {
            log("setBadgeCount failed: Badge count cannot be negative")
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Badge count cannot be negative", details: nil))
            return
        }
        
        self.currentBadgeCount = count
        log("Current badge count updated to: \(count)")
        
        // Set the badge count on the main thread
        DispatchQueue.main.async {
            if #available(iOS 16.0, *) {
                // iOS 16+ method
                self.log("Using iOS 16+ UNUserNotificationCenter API")
                UNUserNotificationCenter.current().setBadgeCount(count) { error in
                    if let error = error {
                        self.log("Error setting badge count: \(error.localizedDescription)")
                        result(false)
                    } else {
                        self.log("Successfully set badge count using iOS 16+ API")
                        result(true)
                    }
                }
            } else {
                // Legacy method for iOS 15 and earlier
                self.log("Using legacy UIApplication API for iOS 15 and earlier")
                UIApplication.shared.applicationIconBadgeNumber = count
                self.log("Successfully set badge count using legacy API")
                result(true)
            }
        }
    }
    
    private func getBadgeCount(result: @escaping FlutterResult) {
        log("getBadgeCount method executing")
        
        DispatchQueue.main.async {
            let badgeCount = UIApplication.shared.applicationIconBadgeNumber
            self.log("getBadgeCount result: \(badgeCount)")
            result(badgeCount)
        }
    }
    
    @objc private func applicationDidBecomeActive() {
        // App became active - sync badge count if needed
        DispatchQueue.main.async {
            self.currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        }
    }
    
    @objc private func applicationDidEnterBackground() {
        // App entered background - ensure badge count is preserved
        if currentBadgeCount > 0 {
            DispatchQueue.main.async {
                if #available(iOS 16.0, *) {
                    UNUserNotificationCenter.current().setBadgeCount(self.currentBadgeCount) { error in
                        if let error = error {
                            print("Error preserving badge count in background: \(error.localizedDescription)")
                        }
                    }
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = self.currentBadgeCount
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}