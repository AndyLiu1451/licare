import Flutter
import UIKit
import flutter_local_notifications // 导入

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     // ---- 请求通知权限 ----
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
       let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
       UNUserNotificationCenter.current().requestAuthorization(
         options: authOptions,
         completionHandler: { _, _ in }
       )
    } else {
       let settings: UIUserNotificationSettings =
       UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
       application.registerUserNotificationSettings(settings)
    }
     application.registerForRemoteNotifications() // 如果未来要用推送通知也加上这行
    // ---- 权限请求结束 ----

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
