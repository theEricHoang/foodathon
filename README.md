# foodathon

A Flutter food delivery app.

## Setup

### Google Maps API Key

The order tracking screen uses Google Maps. To enable it, you need a Google Maps API key.

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project (or select an existing one)
3. Enable the **Maps SDK for Android** and **Maps SDK for iOS** APIs
4. Go to **Credentials** and create an API key
5. (Recommended) Restrict the key to the Maps SDK APIs and your app's package name / bundle ID

### Android

Copy the example secrets file and add your key:

```sh
cp android/secrets.properties.example android/secrets.properties
```

Edit `android/secrets.properties`:

```properties
MAPS_API_KEY=your_actual_api_key
```

### iOS

Copy the example secrets file and add your key:

```sh
cp ios/Runner/Secrets.xcconfig.example ios/Runner/Secrets.xcconfig
```

Edit `ios/Runner/Secrets.xcconfig`:

```
MAPS_API_KEY=your_actual_api_key
```

> The secrets files are gitignored and will not be committed.

### Firebase App Check (Android)

The app uses Firebase App Check with a debug provider. Each developer needs to register their device's debug token in the Firebase Console:

1. Run the app on your device or emulator
2. In logcat, search for `FirebaseAppCheck` — look for a line like:
   ```
   D/FirebaseAppCheck: Enter this debug secret into the allow list in the Firebase Console for your project: <token>
   ```
3. Copy the token
4. Go to the [Firebase Console](https://console.firebase.google.com/) > **App Check** > **Apps** > your Android app > three-dot menu > **Manage debug tokens**
5. Click **Add debug token**, paste your token, and save
6. Restart the app

> Each device/emulator generates a unique token. Every team member must register their own.
