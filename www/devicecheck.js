/* global cordova */

/**
 * Cordova DeviceCheck Plugin
 * Exposes Apple DeviceCheck API for token generation and device support check.
 * iOS only. Use getToken() to obtain a Base64 token for backend validation with Apple's API.
 */
var DeviceCheck = function () {};

/**
 * Generates a DeviceCheck token. The token is Base64-encoded and should be sent
 * to your backend for validation with Apple's DeviceCheck API.
 *
 * @param {function} successCallback - Called with the Base64 token string on success
 * @param {function} errorCallback - Called with error message when token generation fails
 */
DeviceCheck.prototype.getToken = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    'DeviceCheckPlugin',
    'getToken',
    []
  );
};

/**
 * Checks whether DeviceCheck is supported on the current device.
 * Returns false on Simulator and devices below iOS 11.
 *
 * @param {function} successCallback - Called with boolean (true if supported)
 * @param {function} errorCallback - Called on error
 */
DeviceCheck.prototype.isSupported = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    'DeviceCheckPlugin',
    'isSupported',
    []
  );
};

/**
 * Promise-based wrapper for getToken. Returns token string or null on failure.
 * @returns {Promise<string|null>}
 */
DeviceCheck.prototype.getTokenAsync = function () {
  var self = this;
  return new Promise(function (resolve) {
    self.getToken(
      function (token) { resolve(token); },
      function (err) {
        console.warn('DeviceCheck getToken failed:', err);
        resolve(null);
      }
    );
  });
};

/**
 * Promise-based wrapper for isSupported. Returns boolean.
 * @returns {Promise<boolean>}
 */
DeviceCheck.prototype.isSupportedAsync = function () {
  var self = this;
  return new Promise(function (resolve) {
    self.isSupported(
      function (supported) { resolve(supported); },
      function () { resolve(false); }
    );
  });
};

module.exports = new DeviceCheck();
