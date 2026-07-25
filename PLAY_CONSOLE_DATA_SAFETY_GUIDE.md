# 🔒 Play Console - Data Safety Guide for FinWise

## 📋 **STEP 1: DATA COLLECTION**

**Question:** "Does your app collect or share any of the required user data types?"

**Answer:** ✅ **Select "Yes"**

**Why:** FinWise collects:
- Email address (for account)
- Financial data (transactions, budgets, goals)
- App usage data
- Device information

---

## 📋 **STEP 2: DATA TYPES TO DECLARE**

After selecting "Yes", you'll need to specify what data you collect. Here's what to select:

### **1. Personal Info** ✅
- ☑ **Email address** (Required - for account creation/login)
- ☑ **Name** (Optional - if user provides it)
- ☑ **User IDs** (Firebase User ID)

### **2. Financial Info** ✅
- ☑ **Financial info** (Required - transactions, budgets, goals)
  - Select: "Other financial info"
  - Details: "Expense transactions, income information, budget data, financial goals"

### **3. Photos and Videos** ✅
- ☑ **Photos** (Optional - if user uploads profile picture)
  - Select: "User photos"
  - Details: "Profile pictures uploaded by users"

### **4. App Activity** ✅
- ☑ **App interactions** (Optional - for analytics)
  - Details: "Features accessed, time spent in app"

### **5. Device or Other IDs** ✅
- ☑ **Device or other IDs** (Optional - for app functionality)
  - Details: "Device identifiers for app functionality"

---

## 📋 **STEP 3: DATA USAGE**

For each data type, specify:

### **How is it collected?**
- ☑ **App functionality** (Required for all)
- ☑ **Analytics** (Optional - if you track usage)

### **How is it used?**
- ☑ **App functionality** (To provide the service)
- ☑ **Analytics** (To improve the app)
- ☑ **Personalization** (To provide personalized recommendations)

### **Is data shared?**
- ☑ **Yes** (Data is shared with Firebase/Google for app functionality)

### **Who is data shared with?**
- ☑ **Service providers** (Firebase/Google)
  - Details: "Firebase Authentication, Cloud Firestore, Firebase Storage"

---

## 📋 **STEP 4: DATA SECURITY**

**Question:** "Is this data encrypted in transit?"
- ✅ **Yes** (HTTPS/TLS)

**Question:** "Is this data encrypted at rest?"
- ✅ **Yes** (Firebase encrypts data at rest)

**Question:** "Can users request data deletion?"
- ✅ **Yes** (Users can delete their account and data)

---

## 📋 **STEP 5: ADDITIONAL BADGES**

**Independent security review:**
- ☐ **No** (Not required, optional)

**UPI Payments verified:**
- ☐ **No** (Not applicable - app doesn't use UPI)

---

## ✅ **QUICK SUMMARY**

1. **Select:** "Yes" - app collects data
2. **Declare data types:**
   - Personal info (Email, Name)
   - Financial info (Transactions, budgets, goals)
   - Photos (Profile pictures - optional)
   - App activity (Usage data - optional)
   - Device IDs (Optional)
3. **Data usage:** App functionality, analytics
4. **Data sharing:** Yes, with Firebase/Google
5. **Security:** Encrypted in transit and at rest
6. **Deletion:** Users can request deletion

---

## 🎯 **WHAT TO DO NOW**

1. **Click "Yes"** (app collects data)
2. **Click "Next"** or "Continue"
3. **You'll see a list of data types** - select the ones listed above
4. **Fill out details** for each data type
5. **Complete all 5 steps**

Tell me when you're on the next step and I'll help you fill it out! 💪
