# FinWise AdMob setup before Play release

FinWise has one non-blocking adaptive banner at the end of the Home feed.
Debug builds use Google's sample test app and banner IDs; release builds use
FinWise's AdMob IDs listed below.

## FinWise AdMob identifiers

The Android app ID is configured in `android/gradle.properties`; the release
banner unit ID is configured in `lib/widgets/home_banner_ad.dart`. These are
public AdMob identifiers included in the app, not account credentials.

- AdMob app ID: `ca-app-pub-4250217374753571~2382766467`
- FinWise Home Banner unit ID: `ca-app-pub-4250217374753571/4648083132`

Set up the privacy messages in AdMob's Privacy & messaging area. The app
requests updated UMP consent at launch, waits for the required form, and
requests ads only when UMP says ads can be requested. A Settings privacy
options item appears when UMP says that entry point is required.

## Build a release with the configured banner

The IDs above are already configured in the project. Build the signed app
bundle with:

```powershell
flutter build appbundle --release
```

The Gradle release guard stops a release build if the AdMob app ID is missing.
Debug builds continue to use Google's sample test app and banner IDs; do not
click live ads while testing.

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
