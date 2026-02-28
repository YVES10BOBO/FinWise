# Simple Guide: 3 Things to Fix Before Play Store

## 📧 **1. Privacy Policy Email**

### What it means:
The email address where users can contact you with privacy questions.

### Examples:
- ✅ **Personal Gmail**: `yourname@gmail.com`
- ✅ **Personal Email**: `yourname@yahoo.com` or `yourname@outlook.com`
- ✅ **University Email**: `yourname@university.ac.rw`
- ❌ **Don't use**: `support@finwise.com` (unless you own that domain)

### What to do:
- Use YOUR personal email that you check regularly
- Example: If your email is `john.doe@gmail.com`, use that
- Users will email you if they have privacy questions

### Where to update:
- `PRIVACY_POLICY.html` - line 218
- `PRIVACY_POLICY.txt` - line 133

---

## 📦 **2. Package Name**

### What it means:
Package name = **Unique ID for your app** (like a fingerprint - no two apps can have the same one)

### Current (WRONG - Play Store will reject):
```
com.example.finewise
```
❌ Play Store rejects `com.example.*` - it's for testing only

### Examples (GOOD):
```
com.finwise.app
rw.finwise.app
app.finwise.tracker
com.yourname.finwise
```

### How to choose:
- **Format**: `com.` or `rw.` + `yourname` or `appname` + `.app` or `.tracker`
- **Examples**:
  - If your name is John: `com.john.finwise`
  - If you want Rwanda domain: `rw.finwise.app`
  - Simple: `com.finwise.app`

### ⚠️ **IMPORTANT**: 
- Once you publish, you **CANNOT change it**
- Choose carefully!
- Recommended: `com.finwise.app` (simple and professional)

### Where to change:
- `android/app/build.gradle` - lines 10 and 25

---

## 🔒 **3. Firebase Storage Rules**

### What it means:
Security rules for profile pictures stored in Firebase Storage (separate from Firestore)

### What to do:
1. Go to **Firebase Console** → **Storage** → **Rules** tab
2. Paste these rules:

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

3. Click **Publish**

### Why:
- Protects user profile pictures
- Only the owner can upload/delete their picture
- Others can view (for profile display)

---

## ✅ **Quick Summary**

| Item | What It Is | Example | Where |
|------|-----------|---------|-------|
| **Email** | Your contact email | `yourname@gmail.com` | Privacy policy files |
| **Package Name** | App's unique ID | `com.finwise.app` | `android/app/build.gradle` |
| **Storage Rules** | Security for images | Rules code above | Firebase Console |

---

## 🎯 **Recommended Choices**

1. **Email**: Use your personal email (Gmail, etc.)
2. **Package Name**: `com.finwise.app` (simple and professional)
3. **Storage Rules**: Copy-paste the rules above in Firebase Console

---

## ❓ **Questions?**

**Q: Can I use my personal Gmail?**
A: ✅ Yes! Many developers use personal emails for small apps.

**Q: What if I get a professional email later?**
A: You can update the privacy policy anytime (just update the files and republish).

**Q: Can I change package name later?**
A: ❌ No! Once published, it's permanent. Choose carefully.

**Q: Do I need to own finwise.com domain?**
A: ❌ No! Package name doesn't need to match a domain.

---

**Ready to fix these? Tell me:**
1. Your email address (for privacy policy)
2. Your package name choice (I recommend `com.finwise.app`)

Then I'll update everything for you! 🚀
