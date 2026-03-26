# cordova-plugin-device-check

Cordova plugin to use Apple's DeviceCheck API for device token generation and fraud prevention in Ionic/Cordova applications.

## Description

This plugin exposes Apple's [DeviceCheck](https://developer.apple.com/documentation/devicecheck) framework to generate ephemeral, cryptographically signed tokens that identify a device. Your backend can validate these tokens with Apple's DeviceCheck API to:

- Verify requests come from legitimate app instances on real Apple devices
- Store and query two bits of per-device data for fraud prevention
- Reduce abuse (e.g., free trial abuse, promotional offer abuse)

**Platform:** iOS only (11.0+). DeviceCheck is not available on Android or in the browser.

## Installation

### From local path

```bash
cordova plugin add ./cordova-plugin-device-check
```

### From npm (once published)

```bash
cordova plugin add cordova-plugin-device-check
```

## Supported Platforms

- **iOS** 11.0+
- **Android**: Not supported (DeviceCheck is iOS-only)
- **Browser**: Not supported

## API

### getToken(successCallback, errorCallback)

Generates a DeviceCheck token. The token is Base64-encoded and must be sent to your backend for validation with Apple's API.

| Parameter       | Type     | Description                                    |
|----------------|----------|------------------------------------------------|
| successCallback| function | Called with `(token: string)` on success        |
| errorCallback  | function | Called with `(errorMessage: string)` on failure |

**Example:**

```javascript
DeviceCheck.getToken(
  function (token) {
    console.log('Token:', token);
    // Send token to your backend
  },
  function (err) {
    console.error('Error:', err);
  }
);
```

### isSupported(successCallback, errorCallback)

Checks whether DeviceCheck is supported on the current device. Returns `false` on Simulator and devices below iOS 11.

| Parameter       | Type     | Description                                  |
|----------------|----------|----------------------------------------------|
| successCallback| function | Called with `(supported: boolean)` on success |
| errorCallback  | function | Called on error                               |

**Example:**

```javascript
DeviceCheck.isSupported(
  function (supported) {
    if (supported) {
      // Proceed with getToken
    }
  },
  function (err) {
    console.error('Error:', err);
  }
);
```

### getTokenAsync()

Promise-based wrapper for `getToken`. Returns `Promise<string | null>`.

### isSupportedAsync()

Promise-based wrapper for `isSupported`. Returns `Promise<boolean>`.

## Ionic / Angular Usage

```typescript
import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';

declare const DeviceCheck: {
  getToken: (success: (token: string) => void, error: (err: string) => void) => void;
  isSupported: (success: (supported: boolean) => void, error: (err: string) => void) => void;
  getTokenAsync?: () => Promise<string | null>;
  isSupportedAsync?: () => Promise<boolean>;
};

@Injectable({ providedIn: 'root' })
export class DeviceCheckService {
  constructor(private platform: Platform) {}

  async getDeviceToken(): Promise<string | null> {
    if (!this.platform.is('ios')) return null;
    return DeviceCheck.getTokenAsync
      ? DeviceCheck.getTokenAsync()
      : new Promise((resolve) => {
          DeviceCheck.getToken(
            (token) => resolve(token),
            (err) => {
              console.warn(err);
              resolve(null);
            }
          );
        });
  }

  async isDeviceCheckSupported(): Promise<boolean> {
    if (!this.platform.is('ios')) return false;
    return DeviceCheck.isSupportedAsync
      ? DeviceCheck.isSupportedAsync()
      : new Promise((resolve) => {
          DeviceCheck.isSupported((ok) => resolve(ok), () => resolve(false));
        });
  }
}
```

## iOS Setup

### 1. Apple Developer Portal

1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)
2. Select your App ID
3. Enable **DeviceCheck** capability
4. Save

### 2. DeviceCheck Private Key (for backend validation)

1. In Apple Developer Portal, go to **Keys**
2. Create a new key with **DeviceCheck** enabled
3. Download the `.p8` file (you can only download it once)
4. Note the **Key ID** and your **Team ID**

Your backend will use this key to sign JWTs when calling Apple's DeviceCheck API.

### 3. Provisioning Profile

Ensure your provisioning profile includes the DeviceCheck entitlement. Regenerate the profile if you recently enabled the capability.

### 4. Xcode (if needed)

If the plugin does not apply the entitlement automatically:

1. Open the project in Xcode
2. Select your target > **Signing & Capabilities**
3. Click **+ Capability**
4. Add **DeviceCheck**

## Error Handling

| Scenario                         | getToken behavior                                              | isSupported behavior |
|---------------------------------|----------------------------------------------------------------|-----------------------|
| DeviceCheck not supported (iOS < 11) | Error callback: "DeviceCheck is not supported on this device" | Success with `false` |
| Running on Simulator            | Error callback (isSupported is false)                         | Success with `false`  |
| Token generation fails          | Error callback with `error.localizedDescription`               | N/A                   |
| Success                         | Success callback with Base64 string                            | Success with `true`   |

**Note:** DeviceCheck does not work on the iOS Simulator. Always test on a physical device.

## Best Practices

### Sending the token to your backend

1. Call `getToken()` when you need to verify the device (e.g., login, high-risk actions)
2. Send the token in the request body or header to your backend
3. Backend validates with Apple's `validate_device_token` endpoint

### Backend validation with Apple

Your backend must:

1. Generate a JWT signed with your DeviceCheck private key (ES256)
2. POST to `https://api.devicecheck.apple.com/v1/validate_device_token` (production) or `https://api.development.devicecheck.apple.com/v1/validate_device_token` (development)
3. Include headers: `Authorization: Bearer <JWT>`, `Content-Type: application/json`
4. Body: `{ "device_token": "<token>", "transaction_id": "<uuid>", "timestamp": <ms> }`

### Security considerations

- **Replay attacks:** Use a unique `transaction_id` (UUID) per request; reject reused IDs
- **Timestamp:** Use server timestamp; reject requests outside a short time window
- **Rate limiting:** Implement rate limits on your backend and handle Apple's 429 responses with backoff
- **Token reuse:** Tokens can be cached and reused; avoid generating a new token for every request

## References

- [Apple DeviceCheck Documentation](https://developer.apple.com/documentation/devicecheck)
- [Accessing and modifying per-device data](https://developer.apple.com/documentation/devicecheck/accessing-and-modifying-per-device-data)
- [Create a DeviceCheck private key](https://developer.apple.com/help/account/capabilities/create-a-devicecheck-private-key/)

## License

MIT
