# How to Reset App and See Login Screen

## Problem
If you've already logged in before, the app remembers your authentication status and skips the login screen, going directly to the main app.

## Solutions

### Solution 1: Use Logout Button (Easiest) ✅

1. Open the app
2. Go to **Settings** (bottom navigation, last icon)
3. Scroll to **Profile** section
4. Tap **"Logout"** button
5. Confirm logout
6. You'll be redirected to the **Login Screen**

### Solution 2: Clear App Data (Android Emulator)

**Option A: Using Android Studio**
1. Open Android Studio
2. Go to **Tools** → **Device Manager**
3. Select your emulator
4. Click **Wipe Data** button
5. Restart emulator

**Option B: Using ADB Command**
```bash
adb shell pm clear com.example.finewise
```
(Replace `com.example.finewise` with your actual package name)

**Option C: Using Emulator Settings**
1. Open emulator
2. Go to **Settings** → **Apps** → **FinWise**
3. Tap **Storage** → **Clear Data**
4. Restart app

### Solution 3: Uninstall and Reinstall

1. Long press app icon
2. Tap **Uninstall**
3. Reinstall from Android Studio
4. App will start fresh with login screen

### Solution 4: Clear SharedPreferences Programmatically

If you want to add a "Reset App" button for testing:

1. Go to Settings
2. Add a "Reset App" option
3. It will clear all SharedPreferences

## Quick Test: Force Show Login Screen

To always see login screen during development, you can temporarily modify `lib/main.dart`:

```dart
// In _checkAuthAndOnboarding method, force authentication to false:
final authenticated = false; // Force show login
```

## Current Flow

```
App Launch
    ↓
Check: user_authenticated = true? 
    ↓
YES → Skip Login → Show Main App
NO  → Show Login Screen ✅
```

## After Logout

When you logout:
- `user_authenticated` = false
- `onboarding_complete` = false
- App returns to Login Screen
- You can login/signup again
- Onboarding will start fresh

---

## Testing Login/Signup Flow

1. **Logout** from Settings
2. You'll see **Login Screen**
3. Tap **"Sign Up"** to create account
4. Or enter credentials and tap **"Sign In"**
5. After login → **Welcome Screen**
6. Complete onboarding → **Main App**

---

**Note**: The logout button is now available in Settings → Profile section!
