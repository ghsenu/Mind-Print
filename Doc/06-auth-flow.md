# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-06**
Auth Flow
Authentication, Registration, Biometric & Session Management



# 1. Authentication Overview
MindPrint uses Firebase Authentication as the identity provider. The app supports three authentication methods: email/password registration, Google Sign-In, and biometric authentication (Face ID / Fingerprint) as a local security layer on top of Firebase sessions.

| Auth Method | Provider | When Used |
|---|---|---|
| Email + Password | Firebase Auth | Primary registration and login |
| Google Sign-In | Firebase Auth + Google OAuth | Alternative social login on Login Screen |
| Biometric (Face ID / Fingerprint) | Flutter local_auth package | Fast returning-user login (wraps Firebase session) |
| Password Reset | Firebase Auth email action | Forgot password flow — sends reset link via email |

# 2. Registration Flow (New User)
Splash Screen — app checks Firebase Auth currentUser
No user found + first launch flag = true → Onboarding Walkthrough (3 slides)
Sign Up Screen — user enters: display name, email, password, year of study
Flutter calls firebase_auth.createUserWithEmailAndPassword()
On success: Firestore document created at users/{uid} with profile data
Language Selection Screen — user selects English / Sinhala / Tamil
Language preference saved to Firestore: users/{uid}.language
Permissions Screen — microphone permission requested (required for voice journaling)
Notifications permission requested (optional but recommended)
Biometric Setup Screen — user can enable or skip biometric login
If Enable: local_auth.authenticate() called to verify biometric works
biometricEnabled: true saved to Firestore and Flutter SharedPreferences
If Skip: biometricEnabled: false — password login used instead
Onboarding Questionnaire (4 questions) — baseline data saved to Firestore
Navigate to Home Dashboard — onboardingCompleted: true saved

# 3. Returning User Login Flow
Splash Screen — app checks Firebase Auth currentUser
User session found + onboardingCompleted: true → Login Screen
If biometricEnabled = true:
Biometric Login Screen displayed — Face ID / Fingerprint prompt shown
local_auth.authenticate() called with biometricOnly: false (allows fallback)
Success → Home Dashboard
Failure (biometric rejected or unavailable) → PIN / Password fallback
If biometricEnabled = false:
Login Screen shown — email pre-filled, password field active
User enters password → firebase_auth.signInWithEmailAndPassword()
Success → Home Dashboard
Failure → error message shown: "Incorrect password"

# 4. Google Sign-In Flow
User taps Google button on Login or Sign Up Screen
google_sign_in package launches Google OAuth consent screen
User selects Google account and grants permission
Google returns ID token → passed to firebase_auth.signInWithCredential()
Firebase Auth creates or retrieves user account
App checks if this is a new user (first Google sign-in):
New user: redirect to Language Selection (onboarding flow continues)
Returning user: redirect to Home Dashboard

# 5. Forgot Password Flow
User taps "Forgot Password" link on Login Screen
Forgot Password Screen — user enters registered email address
Flutter calls firebase_auth.sendPasswordResetEmail(email)
Firebase sends password reset link to user's email
Success message displayed: "Reset link sent — check your email"
User clicks link in email → Firebase-hosted reset page
User sets new password → can log in with new credentials

# 6. Session Management

| Scenario | Behaviour |
|---|---|
| App opened after recent use | Firebase Auth session persists — no re-login required |
| App opened after long inactivity | Firebase refreshes ID token automatically if session valid |
| Firebase session expired | Auth state listener redirects to Login Screen |
| User logs out | firebase_auth.signOut() + local_auth session cleared + navigate to Splash |
| Biometric change detected | local_auth invalidates on biometric change — password login required |
| Multiple device login | Firebase Auth allows concurrent sessions on multiple devices |

# 7. Biometric Security Details

| Property | Detail |
|---|---|
| Package | local_auth (Flutter) |
| Supported Methods | Fingerprint, Face ID (device capability dependent) |
| Fallback | Device PIN / Pattern / Password (biometricOnly: false) |
| Implementation | Wraps existing Firebase Auth session — does not replace it |
| Storage | biometricEnabled boolean in Firestore + Flutter SharedPreferences |
| Re-enabling | Available in Settings → Biometrics toggle |
| Security Note | Biometric data never leaves the device — handled entirely by OS |
