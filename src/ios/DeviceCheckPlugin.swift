import Foundation
import DeviceCheck

/// Cordova plugin that exposes Apple's DeviceCheck framework for token generation.
/// Uses DCDevice to generate ephemeral tokens for backend validation with Apple's DeviceCheck API.
@objc(DeviceCheckPlugin)
class DeviceCheckPlugin: CDVPlugin {

    // MARK: - getToken

    /// Generates a DeviceCheck token (Base64-encoded) for backend validation.
    /// Requires: real iOS device, iOS 11+, DeviceCheck capability enabled on App ID.
    /// Fails on: Simulator, unsupported devices, missing capability.
    @objc(getToken:)
    func getToken(_ command: CDVInvokedUrlCommand) {
        let device = DCDevice.current

        guard device.isSupported else {
            let result = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "DeviceCheck is not supported on this device"
            )
            commandDelegate.send(result, callbackId: command.callbackId)
            return
        }

        device.generateToken { tokenData, error in
            if let error = error {
                let result = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: error.localizedDescription
                )
                self.commandDelegate.send(result, callbackId: command.callbackId)
                return
            }

            guard let tokenData = tokenData else {
                let result = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Token data is nil"
                )
                self.commandDelegate.send(result, callbackId: command.callbackId)
                return
            }

            let base64Token = tokenData.base64EncodedString()
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: base64Token)
            self.commandDelegate.send(result, callbackId: command.callbackId)
        }
    }

    // MARK: - isSupported

    /// Returns whether DeviceCheck is supported on the current device.
    /// Returns false on Simulator and devices below iOS 11.
    @objc(isSupported:)
    func isSupported(_ command: CDVInvokedUrlCommand) {
        let supported = DCDevice.current.isSupported
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: supported)
        commandDelegate.send(result, callbackId: command.callbackId)
    }
}
