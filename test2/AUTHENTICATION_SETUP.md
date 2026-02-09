# Supabase Authentication Setup Guide

This app implements Gmail-only authentication using Supabase.

## Setup Instructions

### 1. Supabase Project Setup

1. Go to [https://supabase.com](https://supabase.com) and create a new project
2. In the Supabase dashboard, go to **Authentication** > **Providers**
3. Enable **Google** provider
4. Add your OAuth credentials (you'll need Google Cloud Console setup)

### 2. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project
3. Enable the **Google+ API**
4. Create an OAuth 2.0 Client ID:
   - Go to **Credentials** > **Create Credentials** > **OAuth Client ID**
   - Select **Web application**
   - Add authorized redirect URIs:
     - `http://localhost:3000/auth/v1/callback`
     - Your Supabase callback URL: `https://[YOUR_PROJECT].supabase.co/auth/v1/callback`
   - Copy the Client ID and Client Secret

### 3. Supabase Configuration

1. In Supabase Dashboard > **Authentication** > **Providers** > **Google**
2. Paste your Google Client ID and Client Secret
3. Save the configuration

### 4. Update Flutter App

1. Open `lib/main.dart`
2. Replace `YOUR_SUPABASE_URL` with your Supabase project URL
3. Replace `YOUR_SUPABASE_ANON_KEY` with your Supabase anonymous key

You can find these values in:
- Supabase Dashboard > **Settings** > **API**

### 5. Platform-Specific Configuration

#### Android

1. Open `android/app/build.gradle`
2. Ensure minimum SDK is set to 21 or higher
3. Ensure you have Google Play Services dependencies

#### iOS

1. Open `ios/Runner/Info.plist`
2. Add the following keys:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

#### Web

The web platform is automatically configured via the Google Sign-in package.

### 6. Run the App

```bash
flutter pub get
flutter run
```

## Features

- **Gmail-Only Authentication**: Only Google/Gmail sign-in is available
- **Secure Session Management**: Sessions are managed by Supabase
- **User-Friendly UI**: Modern authentication screens with gradient design
- **Error Handling**: Comprehensive error messages and user feedback
- **Sign Out**: Users can securely sign out of the app

## File Structure

```
lib/
├── main.dart                    # App entry point with auth wrapper
├── services/
│   └── auth_service.dart       # Supabase and Google Sign-in integration
└── screens/
    ├── sign_in_screen.dart     # Login screen with Gmail button
    └── home_screen.dart        # Home screen for authenticated users
```

## Security Notes

- The anonymous key is safe to expose in client apps
- Users authenticate through secure OAuth 2.0 flow
- Sessions are stored securely by Supabase
- All sensitive operations use HTTPS

## Troubleshooting

### "Google sign-in cancelled"
- User cancelled the sign-in process - this is normal

### "No access token or ID token"
- Check Google Cloud Console configuration
- Ensure OAuth credentials are correct

### "Supabase not initialized"
- Make sure `main()` function properly initializes AuthService before runApp

### Web Configuration Issues
- Clear browser cache and localStorage
- Check browser console for specific error messages

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Google Sign-in Package](https://pub.dev/packages/google_sign_in)
- [Supabase Flutter Package](https://pub.dev/packages/supabase_flutter)
