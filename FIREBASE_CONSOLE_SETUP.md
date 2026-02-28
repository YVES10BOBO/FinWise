# Firebase Console Setup - Final Checklist

## ✅ **Complete Setup Guide for Play Store Publishing**

---

## 🔥 **1. Firestore Database Rules**

### Location: Firebase Console → Firestore Database → Rules

### Copy and paste this EXACT code:

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

### Steps:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your FinWise project
3. Click **Firestore Database** in left menu
4. Click **Rules** tab
5. Delete all existing rules
6. Paste the code above
7. Click **Publish**

---

## 🗄️ **2. Firebase Storage Rules**

### Location: Firebase Console → Storage → Rules

### Copy and paste this EXACT code:

```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Steps:
1. In Firebase Console, click **Storage** in left menu
2. Click **Rules** tab
3. Delete all existing rules
4. Paste the code above
5. Click **Publish**

---

## ✅ **3. Verify Firebase Services Are Enabled**

### Check these are enabled in Firebase Console:

1. **Authentication** ✅
   - Go to: Authentication → Sign-in method
   - Ensure **Email/Password** is enabled

2. **Firestore Database** ✅
   - Go to: Firestore Database
   - Ensure database is created (Native mode)
   - If not, click "Create database" → Choose "Start in production mode"

3. **Storage** ✅
   - Go to: Storage
   - Ensure Storage is enabled
   - If not, click "Get started" → Start in production mode

---

## 🔐 **4. Security Checklist**

### Before Publishing, Verify:

- [x] Firestore rules pasted and published
- [x] Storage rules pasted and published
- [x] Authentication enabled (Email/Password)
- [x] Database created (Native mode)
- [x] Storage bucket created
- [x] No test data in production database (optional - clean up if needed)

---

## 📱 **5. App Configuration (Already Fixed)**

- [x] Package name: `com.finwise.app` ✅
- [x] Privacy policy email: `yvesrutembeza@gmail.com` ✅
- [x] App version: `1.0.0+1` ✅
- [x] App description: Updated ✅

---

## 🚀 **After Firebase Setup - You're Ready!**

Once you've:
1. ✅ Pasted Firestore rules
2. ✅ Pasted Storage rules
3. ✅ Verified services are enabled

**Your app is ready to publish to Play Store!**

---

## 📝 **Quick Reference**

**Firebase Console URL**: https://console.firebase.google.com

**What to do:**
1. Firestore → Rules → Paste Firestore rules → Publish
2. Storage → Rules → Paste Storage rules → Publish
3. Verify Authentication is enabled
4. Done! ✅

---

**Everything else is already configured in your code!** 🎉
