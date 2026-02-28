# 🌐 Host Privacy Policy on GitHub Pages - Step by Step

## 📋 **What You Need:**
- GitHub account (free)
- `PRIVACY_POLICY.html` file from your project

---

## 🚀 **Method 1: Same Repository (Recommended)**

### **Step 1: Create GitHub Repository**

1. Go to: https://github.com/new
2. Fill in:
   - **Repository name**: `finwise` (or your app name)
   - **Description**: "FinWise - Personal Finance Tracker"
   - **Visibility**: Public or Private (your choice)
   - **Don't check** "Add a README file" (you'll push your code)
3. Click **"Create repository"**

---

### **Step 2: Push Your Code**

If you haven't pushed your code yet:

```bash
cd C:\FinWiseApp\finewise
git init
git add .
git commit -m "Initial commit: FinWise app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/finwise.git
git push -u origin main
```

**Replace `YOUR_USERNAME` with your GitHub username!**

---

### **Step 3: Enable GitHub Pages**

1. Go to your repository on GitHub
2. Click **"Settings"** (top menu)
3. Scroll down to **"Pages"** (left sidebar)
4. Under **"Source"**, select:
   - **Branch**: `main`
   - **Folder**: `/ (root)`
5. Click **"Save"**

---

### **Step 4: Rename Privacy Policy File**

Your privacy policy needs to be named `index.html` for GitHub Pages:

**Option A: Rename in GitHub (Easier)**
1. Go to your repository
2. Click on `PRIVACY_POLICY.html`
3. Click **"Edit"** (pencil icon)
4. Copy all content
5. Click **"Add file"** → **"Create new file"**
6. Name it: `index.html`
7. Paste the content
8. Click **"Commit new file"**
9. (Optional) Delete `PRIVACY_POLICY.html` if you want

**Option B: Rename Locally**
```bash
cd C:\FinWiseApp\finewise
copy PRIVACY_POLICY.html index.html
git add index.html
git commit -m "Add privacy policy for GitHub Pages"
git push
```

---

### **Step 5: Get Your Privacy Policy URL**

After enabling GitHub Pages, your privacy policy will be available at:

```
https://YOUR_USERNAME.github.io/finwise/
```

**Example:**
- If username is `yvesrutembeza` and repo is `finwise`
- URL: `https://yvesrutembeza.github.io/finwise/`

**Wait 1-2 minutes** for GitHub to build the page, then visit the URL!

---

## 🚀 **Method 2: Separate Repository (Alternative)**

If you want a separate repository just for privacy policy:

### **Step 1: Create New Repository**

1. Go to: https://github.com/new
2. Repository name: `finwise-privacy-policy`
3. Make it **Public** (required for free GitHub Pages)
4. Click **"Create repository"**

---

### **Step 2: Upload Privacy Policy**

1. Click **"Add file"** → **"Create new file"**
2. Name it: `index.html`
3. Copy content from `PRIVACY_POLICY.html` and paste
4. Click **"Commit new file"**

---

### **Step 3: Enable GitHub Pages**

1. Go to **Settings** → **Pages**
2. Source: `main` branch, `/ (root)` folder
3. Click **"Save"**

---

### **Step 4: Get URL**

Your privacy policy URL:
```
https://YOUR_USERNAME.github.io/finwise-privacy-policy/
```

---

## ✅ **Verify It Works**

1. Visit your privacy policy URL
2. You should see the privacy policy page
3. Copy the URL - you'll need it for Play Store!

---

## 📝 **Quick Checklist:**

- [ ] Create GitHub repository
- [ ] Push code (or create separate repo for privacy policy)
- [ ] Rename `PRIVACY_POLICY.html` to `index.html`
- [ ] Enable GitHub Pages in Settings
- [ ] Wait 1-2 minutes
- [ ] Visit URL to verify
- [ ] Copy URL for Play Store submission

---

## 🎯 **For Play Store:**

When filling out Play Store listing:
- **Privacy Policy URL**: `https://YOUR_USERNAME.github.io/finwise/`
- Paste this URL in the "Privacy Policy" field

---

## 💡 **Tips:**

1. **Public Repository**: Required for free GitHub Pages
2. **File Name**: Must be `index.html` (not `PRIVACY_POLICY.html`)
3. **Wait Time**: GitHub Pages takes 1-2 minutes to build
4. **Custom Domain**: You can add a custom domain later if needed
5. **Updates**: Any changes to `index.html` will auto-update the page

---

## 🚀 **Ready to Start?**

**Recommended:** Use Method 1 (same repository) - easier and keeps everything together!

**Need help?** Let me know which method you prefer!
