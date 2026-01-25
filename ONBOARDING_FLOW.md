# FinWise Onboarding & Authentication Flow

## Complete User Journey

### 1. **Authentication (First Time Users)**
   - **Login Screen** (`lib/screens/auth/login_screen.dart`)
     - Email and password login
     - "Forgot Password?" link
     - "Sign Up" link for new users
     - Beautiful gradient design matching app theme
   
   - **Signup Screen** (`lib/screens/auth/signup_screen.dart`)
     - Full name, email, password, confirm password
     - Terms & conditions checkbox
     - "Sign In" link for existing users
     - Form validation
   
   - **Forgot Password Screen** (`lib/screens/auth/forgot_password_screen.dart`)
     - Email input for password reset
     - Success message after email sent
     - Back to login option

### 2. **Onboarding Flow (After Authentication)**

   - **Welcome Screen** (`lib/screens/onboarding/welcome_screen.dart`)
     - App introduction
     - Feature highlights
     - "Get Started" button
   
   - **Profile Setup Screen** (`lib/screens/onboarding/profile_setup_screen.dart`)
     - User name
     - Income amount
     - Income frequency (Monthly/Weekly/Irregular)
     - Navigates to Financial Questionnaire
   
   - **Financial Questionnaire Screen** (`lib/screens/onboarding/financial_questionnaire_screen.dart`) ⭐ NEW
     - **Step 1: Income**
       - Income amount (RWF)
       - Income frequency (Daily/Weekly/Monthly/Yearly)
     
     - **Step 2: Spending**
       - Spending amount (RWF)
       - Spending frequency (Daily/Weekly/Monthly/Yearly)
     
     - **Step 3: Categories**
       - Select spending categories:
         - Transport 🚗
         - Food 🍔
         - Entertainment 🎮
         - Vacation ✈️
         - Clothes 👕
         - Electricity 💡
         - Water 💧
         - Rent 🏠
         - Shoes 👟
       - Add custom categories
       - Remove custom categories
       - Progress indicator (3 steps)
       - Beautiful interactive UI with chips and filters

### 3. **Main App** (After Onboarding Complete)
   - Home Screen
   - Categories/Budget Screen
   - Goals Screen
   - Transactions Screen
   - Settings Screen

---

## Updated Categories

### New Categories Added:
- ✈️ **Vacation** - Travel and vacation expenses
- 👕 **Clothes** - Clothing and apparel
- 💧 **Water** - Water bills and utilities
- 👟 **Shoes** - Footwear expenses

### Existing Categories:
- 🍔 Food
- 🚗 Transport
- 🎮 Entertainment
- 💡 Utilities
- 🏠 Rent
- 🛒 Shopping
- 💼 Income
- 💰 Savings

### Custom Categories:
- Users can add unlimited custom categories during onboarding
- Custom categories are saved to SharedPreferences
- Can be managed in Settings (future feature)

---

## Data Saved During Onboarding

All data is saved to `SharedPreferences`:

```dart
// Authentication
'user_authenticated': bool

// Profile
'user_name': string
'user_income': string
'income_frequency': string (Daily/Weekly/Monthly/Yearly)

// Spending
'user_spending': string
'spending_frequency': string (Daily/Weekly/Monthly/Yearly)

// Categories
'user_categories': List<string> (selected + custom categories)

// Completion Flags
'onboarding_complete': bool
'questionnaire_complete': bool
```

---

## UI/UX Features

### Authentication Screens:
- ✅ Gradient background (matching app theme)
- ✅ Clean, modern design
- ✅ Form validation
- ✅ Loading states
- ✅ Password visibility toggle
- ✅ Smooth navigation
- ✅ Error handling

### Questionnaire Screen:
- ✅ 3-step progress indicator
- ✅ Interactive category selection (FilterChips)
- ✅ Custom category input with add/remove
- ✅ Beautiful gradient design
- ✅ Step-by-step navigation (Back/Next buttons)
- ✅ Form validation per step
- ✅ Helpful info boxes
- ✅ Responsive layout

---

## Flow Diagram

```
App Launch
    ↓
Check Authentication
    ↓
┌─────────────────┐
│ Not Authenticated│
└─────────────────┘
    ↓
Login/Signup Screen
    ↓
Welcome Screen
    ↓
Profile Setup
    ↓
Financial Questionnaire (3 Steps)
    ├─ Step 1: Income
    ├─ Step 2: Spending
    └─ Step 3: Categories
    ↓
Main App (Home Screen)
```

---

## Next Steps (Backend Integration)

When implementing Firebase:

1. **Authentication:**
   - Replace `SharedPreferences` auth check with Firebase Auth
   - Implement real login/signup with Firebase
   - Add password reset functionality

2. **Data Storage:**
   - Save questionnaire data to Firestore
   - Sync user preferences across devices
   - Store custom categories in user document

3. **Initial Statistics:**
   - Use questionnaire data to initialize:
     - Budget recommendations
     - Spending predictions
     - Category-based insights
     - AI recommendations

---

## Testing Checklist

- [x] Login screen displays correctly
- [x] Signup screen displays correctly
- [x] Forgot password screen works
- [x] Navigation between auth screens works
- [x] Welcome screen shows after login
- [x] Profile setup saves data
- [x] Questionnaire 3-step flow works
- [x] Category selection works
- [x] Custom categories can be added/removed
- [x] All data saves to SharedPreferences
- [x] Main app shows after onboarding complete
- [x] Categories updated in transaction model

---

## Files Created/Modified

### New Files:
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/signup_screen.dart`
- `lib/screens/auth/forgot_password_screen.dart`
- `lib/screens/onboarding/financial_questionnaire_screen.dart`

### Modified Files:
- `lib/main.dart` - Added auth flow check
- `lib/models/transaction.dart` - Added new categories
- `lib/screens/onboarding/profile_setup_screen.dart` - Navigate to questionnaire

---

## Notes

- All authentication is currently simulated (will be replaced with Firebase)
- Custom categories are stored but need to be integrated into transaction creation
- Questionnaire data initializes user profile for better AI recommendations
- All screens match the app's teal/cyan gradient theme
- UI is interactive and user-friendly, following modern design patterns
