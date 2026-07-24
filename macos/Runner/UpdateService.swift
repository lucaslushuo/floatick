import Cocoa
import FlutterMacOS
import Sparkle

final class UpdateService {
  private let updaterController: SPUStandardUpdaterController
  private var channel: FlutterMethodChannel?

  init() {
    updaterController = SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: nil,
      userDriverDelegate: nil
    )
  }

  func configure(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "floatick/update",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(
          FlutterError(
            code: "updater_unavailable",
            message: "The Floatick updater is no longer available.",
            details: nil
          )
        )
        return
      }

      switch call.method {
      case "loadSettings":
        result(self.settingsSnapshot())
      case "setAutomaticallyChecksForUpdates":
        guard let enabled = call.arguments as? Bool else {
          result(
            FlutterError(
              code: "invalid_argument",
              message:
                "setAutomaticallyChecksForUpdates expects a Boolean argument.",
              details: nil
            )
          )
          return
        }
        self.updaterController.updater.automaticallyChecksForUpdates = enabled
        result(nil)
      case "checkForUpdates":
        guard self.updaterController.updater.canCheckForUpdates else {
          result(
            FlutterError(
              code: "updater_not_ready",
              message: "Floatick cannot check for updates right now.",
              details: nil
            )
          )
          return
        }
        NSApp.activate(ignoringOtherApps: true)
        self.updaterController.checkForUpdates(nil)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  private func settingsSnapshot() -> [String: Any] {
    let version =
      Bundle.main.object(
        forInfoDictionaryKey: "CFBundleShortVersionString"
      ) as? String ?? "—"
    return [
      "automaticallyChecksForUpdates":
        updaterController.updater.automaticallyChecksForUpdates,
      "currentVersion": version,
    ]
  }
}
