# Privacy Policy Setup Guide for Play Store

## ✅ What's Been Done

I've created a comprehensive, Play Store-compliant privacy policy for FinWise that covers:

- ✅ **Data Collection**: Clear explanation of what data is collected
- ✅ **Data Usage**: How your data is used
- ✅ **Data Storage**: Firebase/Google Cloud storage details
- ✅ **Security**: Encryption and security measures
- ✅ **Third-Party Services**: Firebase/Google services disclosure
- ✅ **User Rights**: Access, export, modify, delete rights
- ✅ **Data Retention**: How long data is kept
- ✅ **Children's Privacy**: COPPA compliance (13+ age requirement)
- ✅ **International Transfers**: GDPR compliance
- ✅ **Contact Information**: How users can reach you

## 📁 Files Created

1. **`PRIVACY_POLICY.html`** - Beautiful HTML version for hosting on a website
2. **`PRIVACY_POLICY.txt`** - Plain text version (backup/alternative)
3. **In-App Privacy Policy** - Updated in Settings screen with comprehensive details

## 🚀 How to Host Your Privacy Policy (FREE Options)

### Option 1: GitHub Pages (Recommended - FREE)

1. **Create a GitHub account** (if you don't have one): https://github.com
2. **Create a new repository** called `finwise-privacy` (or similar)
3. **Upload `PRIVACY_POLICY.html`** to the repository
4. **Enable GitHub Pages**:
   - Go to repository Settings → Pages
   - Select "Deploy from a branch"
   - Choose "main" branch and "/ (root)" folder
   - Click Save
5. **Your URL will be**: `https://[your-username].github.io/finwise-privacy/PRIVACY_POLICY.html`
   - Example: `https://john-doe.github.io/finwise-privacy/PRIVACY_POLICY.html`

### Option 2: Google Sites (FREE)

1. Go to https://sites.google.com
2. Create a new site
3. Copy the content from `PRIVACY_POLICY.txt` and paste it
4. Publish the site
5. Your URL will be: `https://sites.google.com/view/[your-site-name]`

### Option 3: Firebase Hosting (FREE)

If you're already using Firebase:
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Run `firebase init hosting`
3. Copy `PRIVACY_POLICY.html` to your hosting folder
4. Run `firebase deploy`
5. Your URL will be: `https://[your-project].web.app/PRIVACY_POLICY.html`

### Option 4: Any Web Hosting

Upload `PRIVACY_POLICY.html` to any web hosting service you have access to.

## 📝 Before Publishing

**IMPORTANT**: Update the contact email in the privacy policy:

1. Open `PRIVACY_POLICY.html`
2. Find: `Email: [Your contact email address]`
3. Replace `[Your contact email address]` with your actual email
4. Do the same in `PRIVACY_POLICY.txt`

## 🎯 Play Store Submission

When submitting to Google Play Store:

1. **Privacy Policy URL**: Enter your hosted privacy policy URL
   - Example: `https://your-username.github.io/finwise-privacy/PRIVACY_POLICY.html`

2. **Data Safety Section**: Fill out based on this information:
   - **Data Collected**: 
     - Personal info: Email, Name
     - Financial info: Transactions, Income, Goals
     - Photos: Profile pictures (optional)
   - **Data Shared**: None (we don't share data)
   - **Data Security**: Encrypted in transit and at rest
   - **Data Deletion**: Users can delete data anytime

3. **Age Rating**: 
   - Set to "Everyone" or "Teen" (13+)
   - Our policy states we don't collect data from children under 13

## ✅ Checklist

- [ ] Privacy policy HTML file created ✅
- [ ] Privacy policy text file created ✅
- [ ] In-app privacy policy updated ✅
- [ ] Update contact email in both files
- [ ] Host privacy policy on GitHub Pages/Google Sites/Firebase
- [ ] Test the privacy policy URL works
- [ ] Add privacy policy URL to Play Store listing
- [ ] Fill out Data Safety section in Play Console

## 📱 In-App Privacy Policy

The privacy policy is also available in the app:
- **Location**: Settings → About → Privacy Policy
- Users can read it anytime without internet connection
- Updated with comprehensive details matching the hosted version

## 🔒 Compliance

This privacy policy is designed to comply with:
- ✅ **Google Play Store Requirements**
- ✅ **GDPR** (General Data Protection Regulation)
- ✅ **COPPA** (Children's Online Privacy Protection Act)
- ✅ **CCPA** (California Consumer Privacy Act) principles

## 💡 Tips

1. **Keep it Updated**: Review and update your privacy policy whenever you add new features that collect data
2. **Version Control**: Keep track of when you update the policy (the "Last Updated" date)
3. **Accessibility**: Make sure the hosted URL is accessible and loads quickly
4. **Mobile-Friendly**: The HTML version is responsive and works on mobile devices

## 🆘 Need Help?

If you need to modify the privacy policy:
- Edit `PRIVACY_POLICY.html` for the hosted version
- Edit `PRIVACY_POLICY.txt` for the text version
- Edit `lib/screens/settings_screen.dart` → `_showPrivacyPolicy()` for the in-app version

---

**Last Updated**: January 2026
