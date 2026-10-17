# FinWise AdMob setup before Play release

FinWise currently has one non-blocking adaptive banner at the end of the Home
feed. Debug builds use Google's sample test app and banner IDs. Release builds
will not show a banner until a real banner unit ID is supplied.

## AdMob account values needed

1. Create or sign in to an AdMob account and add FinWise for Android.
2. Create a banner ad unit and copy both values from AdMob:
   - the **AdMob app ID** (`ca-app-pub-...~...`)
   - the **banner ad unit ID** (`ca-app-pub-.../...`)
3. Set up the privacy messages in AdMob's Privacy & messaging area. The app
   requests updated UMP consent at launch, waits for the required form, and
   requests ads only when UMP says ads can be requested. A Settings privacy
   options item appears when UMP says that entry point is required.

## Build a release with live ads

In PowerShell, set the real IDs for the current shell before building:

```powershell
$env:ORG_GRADLE_PROJECT_ADMOB_APP_ID = "ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"
flutter build appbundle --release --dart-define=ADMOB_BANNER_ID=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz
```

The Gradle release guard intentionally stops a release build if the AdMob app
ID is missing. Do not use Google's sample IDs in a Play release. Keep the IDs
out of any public screenshots or support messages if you prefer, though these
IDs are not account passwords or secret keys.

## Play Console items before submitting

- Host the updated Privacy Policy at a public, stable HTTPS URL and enter that
  URL in Play Console. The app's in-app Privacy Policy and Terms were updated
  in English and Kinyarwanda, but an in-app screen alone is not the public URL
  required by Play.
- Update the Play Console Data safety form to include collection and sharing
  by the exact Google Mobile Ads SDK version shipped. Confirm the categories
  against the SDK's current disclosure; SDK data practices can change.
- Recheck the SMS permissions declaration. FinWise's SMS-based money
  management use case is subject to Google Play review and approval.
- Test the debug build using test ads only. Never click live ads during testing.
- Confirm the ad appears after Home content, does not cover the Add button or
  navigation bar, and remains absent when consent does not allow ad requests.

The AdMob account, production IDs, public privacy-policy hosting, and Play
Console declarations must be completed by the publisher; they cannot be
created from this code workspace.
