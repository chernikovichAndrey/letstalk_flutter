import Flutter
import UIKit
import PushKit
import flutter_local_notifications
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {

  private var voipRegistry: PKPushRegistry?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)

    voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    voipRegistry?.delegate = self
    voipRegistry?.desiredPushTypes = [.voIP]

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
    let token = credentials.token.map { String(format: "%02x", $0) }.joined()
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token)
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload,
                    for type: PKPushType, completion: @escaping () -> Void) {
      guard type == .voIP else { return }
    let d = payload.dictionaryPayload
    let callIdStr = d["call_id"] as? String ?? ""
    let callIdInt = Int(callIdStr) ?? 0
    let uuid = String(format: "00000000-0000-0000-0000-%012d", callIdInt)
    let callerName = d["caller_name"] as? String ?? "Unknown"
    let callerPhone = d["caller_phone"] as? String ?? ""
    let callType = (d["call_type"] as? String) == "video" ? 1 : 0

    let params = flutter_callkit_incoming.Data(
      id: uuid,
      nameCaller: callerName,
      handle: callerPhone,
      type: callType
    )
    params.iconName = "CallKitLogo"
    params.extra = d as NSDictionary

    // Always required by Apple — must report incoming call for every VoIP push
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(params, fromPushKit: true)
    completion()
  }
}
