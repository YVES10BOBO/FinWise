# Firebase Console - Step by Step Guide

## 📱 **Step 1: Add New Android App**

### What You See:
- Current app: "FinWise" with package `com.example.finewise` (old)

### What To Do:
1. Click the blue **"Add app"** button (top right of the card)
2. Select **Android** icon
3. Fill in the form:
   - **Android package name**: `com.finwise.app`
   - **App nickname** (optional): `FinWise` or `FinWise Production`
   - **Debug signing certificate SHA-1** (optional - skip for now)
4. Click **"Register app"**

---

## 📥 **Step 2: Download New google-services.json**

### After Adding the App:
1. You'll see a page with "Download google-services.json"
2. Click **"Download google-services.json"**
3. **Replace** the file in your project:
   - Location: `android/app/google-services.json`
   - Delete the old one
   - Put the new downloaded file there

---

## 🔥 **Step 3: Firestore Rules**

1. In Firebase Console, click **"Firestore Database"** in left menu
2. Click **"Rules"** tab
3. **Delete** all existing rules
4. **Paste** this code:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

5. Click **"Publish"**

---

## 🗄️ **Step 4: Storage Rules**

1. In Firebase Console, click **"Storage"** in left menu
2. Click **"Rules"** tab
3. **Delete** all existing rules
4. **Paste** this code:

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

5. Click **"Publish"**

---

## ✅ **After These Steps:**

1. ✅ New Android app added with `com.finwise.app`
2. ✅ New `google-services.json` downloaded and replaced
3. ✅ Firestore rules published
4. ✅ Storage rules published

**Then you're ready to build and publish!** 🚀

---

## 📝 **Quick Checklist:**

- [ ] Add new Android app (package: `com.finwise.app`)
- [ ] Download new `google-services.json`
- [ ] Replace file in `android/app/` folder
- [ ] Paste Firestore rules → Publish
- [ ] Paste Storage rules → Publish

**That's it!** 🎉
