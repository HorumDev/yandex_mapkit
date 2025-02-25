import Flutter
import UIKit
import YandexMapsMobile

public class YandexPedastrianRouter: NSObject, FlutterPlugin {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let pedastrianRouter: YMKPedestrianRouter!
  private var routeSessions: [Int: YandexPedastrianSession] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_pedestrian",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexPedastrianRouter(channel: channel, registrar: registrar)

    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.methodChannel = channel
      self.pedastrianRouter = YMKTransport.sharedInstance().createPedestrianRouter()

    super.init()

    self.methodChannel.setMethodCallHandler(self.handle)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestRoutes":
      requestRoutes(call, result)
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestRoutes(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let params = call.arguments as! [String: Any]
    let sessionId = params["sessionId"] as! Int
    let requestPoints = (params["points"] as! [[String: Any]]).map {
      (pointParams) -> YMKRequestPoint in Utils.requestPointFromJson(pointParams)
    }
      let session = pedastrianRouter.requestRoutes(
        with: requestPoints, timeOptions:YMKTimeOptions(),
//      drivingOptions: Utils.drivingOptionsFromJson(params["drivingOptions"] as! [String: Any]),
//      vehicleOptions: YMKDrivingVehicleOptions(),
      routeHandler: {(drivingResponse: [YMKMasstransitRoute]?, error: Error?) -> Void in
        self.routeSessions[sessionId]?.handleResponse(drivingResponse: drivingResponse, error: error, result: result)
      }
    )

      routeSessions[sessionId] = YandexPedastrianSession(
      id: sessionId,
      session: session,
      registrar: pluginRegistrar,
      onClose: { (id) in self.routeSessions.removeValue(forKey: id) }
    )
  }
}
