package com.yves.finwise

import io.flutter.embedding.android.FlutterFragmentActivity

// Must be FlutterFragmentActivity (not FlutterActivity) — the `local_auth`
// plugin shows the system biometric prompt as a fragment, and will throw
// "no_fragment_activity" at runtime with a plain FlutterActivity.
class MainActivity: FlutterFragmentActivity()
