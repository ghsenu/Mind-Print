# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-10**
Production Readiness
Security Checklist, Testing Strategy & Deployment Plan

Student: Gihansa S Buwanayake
Index Number: 10952999
Supervisor: Dr. Rasika Ranaweera
Programme: BSc (Hons) Software Engineering — NSBM Green University
Module: PUSL3190 Computing Project

# 1. Production Readiness Overview
This document defines the criteria that must be met before MindPrint is considered production-ready for the MVP pilot deployment. It covers security, testing, performance, and deployment requirements.

# 2. Security Checklist
## 2.1 Authentication & Access Control

| Item | Status | Notes |
|---|---|---|
| Firebase Auth enabled with email + Google providers | Required | Configure in Firebase console |
| Firestore Security Rules — users access own data only | Required | Deny all reads/writes without auth |
| Firebase Storage Rules — user-scoped paths | Required | Deny cross-user file access |
| Biometric auth tested on Android | Required | Test Fingerprint + Face Unlock (Android) |
| Password reset email flow tested | Required | Verify email delivery |
| Session persistence and token refresh verified | Required | Test after 24hr gap |

## 2.2 API Security

| Item | Status | Notes |
|---|---|---|
| HuggingFace API key stored in Cloud Function env variable only | Required | Never in Flutter client code |
| AssemblyAI API key stored in Cloud Function env variable only | Required | Never in Flutter client code |
| All external API calls via HTTPS | Required | Verify no HTTP endpoints used |
| Cloud Function authorization — verify userId in request matches auth token | Required | Prevent cross-user data access |
| API key rotation schedule documented | Required | Every 90 days |

## 2.3 Data Privacy

| Item | Status | Notes |
|---|---|---|
| Journal content never sent to third-party analytics services | Required | Firebase Analytics: no content tracking |
| Voice recordings deleted from Storage after analysis (optional) | Recommended | User preference in Settings |
| Firestore offline cache encrypted | Required | AES-256 via device keystore |
| Export reports contain only user's own data | Required | Cloud Function userId validation |
| Privacy Policy screen accessible without login | Required | Link from Login Screen |

# 3. Performance Requirements

| Metric | Target | How Measured |
|---|---|---|
| App cold start time | < 3 seconds | Flutter DevTools performance profiler |
| Text NLP analysis response time | < 30 seconds | Cloud Function execution logs |
| Voice transcription + SER time | < 60 seconds | AssemblyAI processing time in logs |
| Firestore read (cached) | < 100ms | Flutter DevTools network tab |
| Firestore read (live) | < 1 second | Network timing in DevTools |
| PDF report generation | < 5 seconds | Manual timing test |
| App size (APK) | < 50MB | Flutter build output |

# 4. Testing Strategy
## 4.1 Unit Testing
emotionMapper utility — test all API score → display label mappings
moodPrediction logic — test trend calculation with mock 7-day data
report generation — test date range filtering and data compilation
auth_service — test login, logout, registration, and error states

## 4.2 Widget Testing
EmotionResultScreen — test displays correct primary emotion, intensity, and secondary emotions
JournalHistoryScreen — test empty state, search functionality, monthly grouping
HomeScreen — test mood check-in saves correctly, alert banner shows/hides
SettingsScreen — test all toggles persist to Firestore

## 4.3 Integration Testing
Full onboarding flow — Splash → Questionnaire → Home (new user)
Full biometric login flow — Splash → Biometric → Home (returning user)
Text journal → analysis → result → history (end-to-end)
Voice journal → transcription → analysis → result (end-to-end)
Offline journaling → reconnect → sync (end-to-end)
PDF export → preview → share (end-to-end)
Push notification → tap → deep link navigation (end-to-end)

## 4.4 Pilot User Testing
Pilot group: 5–10 undergraduate students from Sri Lanka
Testing focus: onboarding clarity, journaling experience, analysis accuracy perception
Usability metric: System Usability Scale (SUS) score — target ≥ 70/100
Feedback collected via structured questionnaire after pilot session

# 5. Deployment Plan
## 5.1 Firebase Environment Setup

| Environment | Firebase Project | Purpose |
|---|---|---|
| Development | mindprint-dev | Local emulator + development testing |
| Production | mindprint-prod | Pilot deployment for user testing |

## 5.2 Deployment Steps
Firebase production project created (mindprint-prod)
Firestore Security Rules deployed to production project
Firebase Storage Rules deployed to production project
Cloud Functions deployed: firebase deploy --only functions
Cloud Function environment variables set for production API keys
Flutter app built for release: flutter build apk --release  # Android APK
APK uploaded to Google Play Console (internal testing track)
Internal testers invited via Google Play Console
App performance monitored via Firebase Performance Monitoring

## 5.3 Post-Deployment Monitoring
Firebase Crashlytics — automatic crash reporting and alerting
Firebase Performance Monitoring — network latency, screen render times
Cloud Function execution logs — monitor API call success rates and latency
Firestore usage dashboard — monitor read/write counts and costs
FCM delivery reports — monitor push notification delivery rates

# 6. Known Limitations (MVP)

| Limitation | Impact | Mitigation |
|---|---|---|
| HuggingFace free tier rate limits | Slow responses during high concurrent usage | Upgrade to HuggingFace Pro if needed; add retry logic |
| AssemblyAI transcription latency | Voice analysis takes up to 60s | Show progress indicator; notify via Firestore listener when done |
| Sinhala/Tamil content not translated | Non-English users have English-only UI | UI language toggle available; full translation in future release |
| LSTM/GRU mood prediction not implemented | Prediction is rule-based trend analysis only | Sufficient for MVP; document as future enhancement |
| No wearable integration | Biometric data limited to self-report | Documented as future scope in proposal |
