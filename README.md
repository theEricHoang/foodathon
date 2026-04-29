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
