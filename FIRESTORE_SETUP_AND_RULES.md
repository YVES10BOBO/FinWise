## Firestore setup (Transactions Sync) — FinWise

### What we implemented
- When a user is logged in, **transactions sync to Firestore** at:
  - `users/{uid}/transactions/{transactionId}`
- When a user is logged in, **goals sync to Firestore** at:
  - `users/{uid}/goals/{goalId}`
- When logged out (guest), transactions stay **local only**.
- We keep a **local cache** even when logged in (faster startup + fallback if offline).
- On first Firestore sync, the app **migrates local transactions** into Firestore (only the missing ones).

### Firestore rules (paste into Firebase Console → Firestore → Rules)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write only their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Catch-all for any other subcollections (future-proof)
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Notes
- Make sure **Firestore Database** is created in Firebase Console (Native mode).
- If you later add Goals sync, we will create:
  - `users/{uid}/goals/{goalId}`

