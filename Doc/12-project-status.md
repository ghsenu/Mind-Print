# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-12**
> Project Status — Completed Work & Future Works
> Reference Date: May 2026



# 1. Project Identity

MindPrint is an AI-powered mental health awareness mobile application for Sri Lankan undergraduate students. It integrates multimodal emotional analysis (text + voice), predictive mood forecasting, and guided self-care interventions through a Flutter Android app backed by Firebase cloud services and pre-trained AI APIs.

---

# 2. Completed Work

## 2.1 Authentication & Onboarding
Full authentication system with all screens implemented and Firebase wired end-to-end.

| Item | Status |
|---|---|
| Splash screen | Done |
| Onboarding walkthrough (3 slides) | Done |
| Email / password registration and login | Done |
| Google Sign-In | Done |
| Phone number + OTP login | Done |
| Forgot password / reset password flow | Done |
| Biometric authentication (Face ID / Fingerprint) | Done |
| Biometric privacy consent screen | Done |
| Onboarding questionnaire (4 baseline mood questions) | Done |
| Congratulations / welcome screen | Done |
| Firebase Auth integration | Done |
| Firestore user profile creation on registration | Done |

## 2.2 Application Shell
Core app infrastructure is fully set up.

| Item | Status |
|---|---|
| Feature-first Flutter folder structure (`lib/features/`) | Done |
| Riverpod state management (StreamProviders, Providers) | Done |
| GoRouter navigation with 25+ named routes | Done |
| App theme (Lora headings, Inter body, light blue palette) | Done |
| Firebase initialization with offline persistence enabled | Done |
| Environment config via `.env` file (`flutter_dotenv`) | Done |
| Firestore collection references (users, journals, emotions, checkins, predictions, notifications, reports) | Done |

## 2.3 Data Layer
All core data models and Firestore integration in place.

| Item | Status |
|---|---|
| `UserProfile` model | Done |
| `JournalEntry` model (text + voice) | Done |
| `EmotionResult` model | Done |
| `MoodCheckin` model | Done |
| `Prediction` model | Done |
| `NotificationItem` model | Done |
| Firestore CRUD for journals | Done |
| Firestore security rules (user-scoped access) | Done |

## 2.4 Text Journal & AI Analysis
The core journaling feature is fully operational end-to-end.

| Item | Status |
|---|---|
| Text journal entry screen (free-text + mood 1–5 selector) | Done |
| HuggingFace emotion classification (`j-hartmann/emotion-english-distilroberta-base`) | Done |
| HuggingFace sentiment analysis (`cardiffnlp/twitter-roberta-base-sentiment-latest`) | Done |
| HuggingFace cognitive distortion detection (`facebook/bart-large-mnli`) | Done |
| Parallel API calls with auto-retry on 503 errors | Done |
| CBT reframing suggestions on distortion detection | Done |
| Emotion result screen (primary emotion, intensity %, secondary emotions, AI insight) | Done |
| Journal entry saved to Firestore with emotion result | Done |
| Journal history list (streamed from Firestore via Riverpod) | Done |

## 2.5 Voice Journal — Recording
Voice recording UI and capture pipeline is functional.

| Item | Status |
|---|---|
| Voice record screen with waveform UI and timer | Done |
| Audio recording using `record` package (AAC-LC, 16kHz, mono) | Done |
| Microphone permission handling | Done |
| AssemblyAI transcription submission and polling (5s interval, 2min timeout) | Done |

## 2.6 UI Screens (All Built)
All 25 planned screens have UI implementations.

| Screen | Feature Area |
|---|---|
| Home dashboard (mood check-in, quick stats, greeting) | Home |
| Journal tab (text + voice entry list) | Journal |
| Voice journal entry screen | Journal |
| Voice record screen | Journal |
| Emotion result screen | Journal |
| Analytics tab (radar chart, mood prediction, cognitive patterns) | Analytics |
| Games screen (grid of 4 games) | Games |
| Star Rain game | Games |
| Bubble Pop game | Games |
| Memory Match game | Games |
| Breathing Ball game | Games |
| Coping toolkit screen | Coping |
| Breathing exercises screen | Coping |
| Meditation screen | Coping |
| Music therapy screen | Coping |
| CBT exercises screen | Coping |
| Chatbot screen (shell) | Chatbot |
| Notifications screen | Notifications |
| Export/reports screen (shell) | Reports |
| Settings screen | Settings |
| Edit profile screen | Profile |
| Login, Sign-up, Onboarding (9 auth screens) | Auth |

## 2.7 Mini-Games (Playable)
All 4 games have working game mechanics.

| Game | Mechanics Status |
|---|---|
| Star Rain | Falling stars animation, tap to destroy |
| Bubble Pop | Bubbles with tap-to-pop interaction |
| Memory Match | Card flip matching with win detection |
| Breathing Ball | Inflate / deflate breathing rhythm guide |

---

# 3. Partially Completed Work

These features have UI and partial logic but are not fully functional.

## 3.1 Voice Journal — Upload & Full Pipeline
Recording works locally but the full cloud pipeline is blocked.

| What's Done | What's Missing |
|---|---|
| Audio recording captures file locally | `firebase_storage` not added to `pubspec.yaml` |
| AssemblyAI transcription service coded | AssemblyAI API key is placeholder in `.env` |
| VoiceService has `uploadToStorage()` method | Method cannot run without Firebase Storage dependency |
| Voice entry model supports `voiceUrl` field | `voiceUrl` never populated — always null |

## 3.2 Analytics Tab
Visually complete but running on hardcoded mock data.

| What's Done | What's Missing |
|---|---|
| Radar chart UI (emotional fingerprint) | Real Firestore queries to aggregate journal emotions |
| Mood prediction chart UI (48-hour view) | Cloud Function to calculate mood predictions |
| Cognitive patterns section UI | Pattern analysis logic not written |
| fl_chart library integrated | All chart values are hardcoded constants |

## 3.3 Coping Toolkit
All activity screens exist but contain no real content.

| What's Done | What's Missing |
|---|---|
| Breathing exercise screen (4-7-8, box breathing UI) | No audio guidance files |
| Meditation screen with countdown timer | No guided audio, no content library |
| CBT screen with template cards | Exercise database/content not defined |
| Music therapy screen + `MusicPlayer` widget | No audio files, no CDN links, `just_audio` not in pubspec |

## 3.4 Profile & Settings
Forms exist but nothing saves to Firestore.

| What's Done | What's Missing |
|---|---|
| Edit profile screen UI | Profile photo upload (`image_picker` not in pubspec) |
| ProfileService with Firestore CRUD methods | Edit profile screen not wired to service |
| Settings screen with all toggles | All toggle values lost on app restart (no persistence) |
| Biometric toggle in settings | Not synced to `UserProfile` in Firestore |

---

# 4. Future Works

These items are defined in the original project scope but have not been built.

## 4.1 Firebase Infrastructure

| Item | Priority | Notes |
|---|---|---|
| Add missing `pubspec.yaml` dependencies (`firebase_storage`, `record`, `permission_handler`, `image_picker`, `http`, `path_provider`) | High | Blocks voice upload and profile photo features |
| Activate Firebase Blaze (pay-as-you-go) plan | High | Required before Cloud Functions can be deployed |
| Firebase Cloud Functions — `analyzeTextEntry` | High | Moves HuggingFace calls server-side (secure API key) |
| Firebase Cloud Functions — `analyzeVoiceEntry` | High | Orchestrates AssemblyAI upload + polling server-side |
| Firebase Cloud Functions — `generateMoodPrediction` (daily scheduler) | High | Powers the 48-hour mood forecast chart |
| Firebase Cloud Functions — `triggerPredictiveAlert` | Medium | Sends FCM when mood dip detected |
| Firebase Cloud Functions — `sendDailyAffirmation` | Medium | 8am scheduled FCM notification |
| Firebase Cloud Functions — `sendJournalReminder` | Medium | 7pm FCM if no entry logged today |
| Firebase Cloud Functions — `generateReport` | Medium | Aggregates journal data for PDF/CSV export |
| Firebase Storage security rules (voice recordings + profile photos) | High | Must be user-scoped before going live |

## 4.2 Push Notifications (FCM)

| Item | Notes |
|---|---|
| FCM token generation and storage in Firestore | Required before any push notification can be sent |
| Daily affirmation push notification (8am) | Cloud Function trigger |
| Journal reminder push notification (7pm) | Conditional: only if no entry today |
| Predictive mood alert notification | Triggered when 48-hr prediction shows dip |
| In-app notification list wired to Firestore | Notification screen currently shell only |
| Bell icon badge count | Unread notification counter |

## 4.3 Gemini AI Chatbot

| Item | Notes |
|---|---|
| Gemini API integration (API key available) | Chatbot screen shell exists, no logic |
| Real-time message streaming | Gemini streaming responses |
| Chat history saved to Firestore | Per-session and cross-session |
| Emotion-aware context injection | Pass recent journal emotion to Gemini prompt |

## 4.4 Analytics — Real Data

| Item | Notes |
|---|---|
| Firestore query: aggregate emotion scores by day/week/month | Replace hardcoded chart values |
| Emotional fingerprint from real journal history | Radar chart with live Firestore data |
| Mood timeline chart with real entries | Daily / weekly / monthly toggle |
| Cognitive pattern detection from journal trends | Trend across distortion types over time |
| Predictive alert banner on home dashboard | Appears when Cloud Function flags a dip |

## 4.5 Reports & Export

| Item | Notes |
|---|---|
| PDF generation (using `pdf` Flutter package) | Date-range selection → therapist-ready PDF |
| CSV export of journal entries | Raw data download |
| Report preview screen before export | Confirm before generating |
| Share / email report | System share sheet integration |

## 4.6 Settings Persistence

| Item | Notes |
|---|---|
| Language preference save to Firestore UserProfile | English / Sinhala / Tamil toggle |
| Notification preferences persist | Sync toggle state to Firestore |
| Biometric preference sync to Firestore | Currently local only |
| Offline sync setting persist | Write to UserProfile document |

## 4.7 Games — Scoring & Progress

| Item | Notes |
|---|---|
| Game score saved to Firestore after each session | Currently not stored anywhere |
| Game stats screen (personal best, session count) | Not built |
| Leaderboard (optional, low priority) | Out of scope for MVP if time-constrained |

## 4.8 Offline & Sync

| Item | Notes |
|---|---|
| Offline mode banner (no internet detected) | Connectivity provider exists, banner UI not wired |
| Sync complete notification (toast/snackbar) | Show when Firestore sync resumes after offline |
| AES-256 local cache encryption | Documented in architecture but not implemented |

## 4.9 Quality & Release

| Item | Notes |
|---|---|
| AssemblyAI live API key in `.env` | Placeholder still in place |
| Widget tests for key screens | No test files exist yet |
| Integration tests for critical journeys (journal + analysis flow) | Not written |
| Performance audit (cold start < 3s, analysis < 30s, APK < 50MB) | Not measured |
| Firestore security rules audit | Review before production |
| API key audit (no hardcoded secrets in source) | Verify `.env` not committed |
| Google Play internal testing track deployment | Final milestone |
| Language content translation (Sinhala / Tamil) | UI toggle exists, content not translated |

---

# 5. Summary Snapshot

| Area | Status |
|---|---|
| Authentication & Onboarding | Complete |
| Text Journaling + NLP Analysis | Complete |
| Voice Recording (local capture) | Complete |
| Voice Upload + Full Cloud Pipeline | Partial |
| Mini-Games (mechanics) | Complete |
| UI Screen Layer (all 25 screens) | Complete |
| Analytics (UI) | Partial — mock data only |
| Coping Toolkit (UI) | Partial — no content |
| Profile & Settings Persistence | Partial |
| Firebase Cloud Functions | Not started |
| FCM Push Notifications | Not started |
| Gemini Chatbot | Not started |
| PDF / CSV Reports | Not started |
| End-to-End Testing | Not started |
| Production Deployment | Not started |
