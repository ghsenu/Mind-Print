# MindPrint — Project Technical Report

**Project Title:** MindPrint — AI-Powered Mental Health Awareness Mobile Application  
**Platform:** Flutter (Android · iOS · Web · Windows)  
**Version:** 1.0.0+1  
**Firebase Project:** mindprint-db (asia-south1)  
**Package ID:** com.example.mind_print  
**Dart SDK:** ≥ 3.7.2 · Flutter SDK ≥ 3.29.0

---

## Table of Contents

1. [Abstract](#1-abstract)
2. [Problem Statement & Motivation](#2-problem-statement--motivation)
3. [System Architecture](#3-system-architecture)
4. [Technology Stack](#4-technology-stack)
5. [Authentication & Security](#5-authentication--security)
6. [Database Design](#6-database-design)
7. [AI / ML Pipeline](#7-ai--ml-pipeline)
8. [Voice Journal Pipeline](#8-voice-journal-pipeline)
9. [State Management — Riverpod](#9-state-management--riverpod)
10. [Navigation Architecture](#10-navigation-architecture)
11. [Feature Inventory](#11-feature-inventory)
12. [Coping Toolkit](#12-coping-toolkit)
13. [Wellness Mini-Games](#13-wellness-mini-games)
14. [Analytics Engine](#14-analytics-engine)
15. [Flutter Packages Reference](#15-flutter-packages-reference)
16. [Environment & Configuration](#16-environment--configuration)
17. [Multi-Language Support](#17-multi-language-support)
18. [Implementation Status](#18-implementation-status)

---

## 1. Abstract

MindPrint is a cross-platform mobile application built with Flutter that targets the mental health and emotional well-being of Sri Lankan university students. The application leverages three external AI/ML APIs — HuggingFace Inference, AssemblyAI, and Google Gemini — in combination with Google Firebase backend services to deliver an intelligent, privacy-first journaling and self-care platform.

Core capabilities include:

- **AI-driven journaling**: Users write or record mood journals; the system runs three NLP models in parallel to classify emotions, detect sentiment, and identify cognitive distortions, then generates CBT reframing suggestions.
- **Voice-to-insight pipeline**: Audio journals are captured locally, uploaded to Firebase Storage, transcribed by AssemblyAI, and then processed through the same NLP pipeline.
- **Personalised analytics**: A mood trend prediction engine analyses 30-day journal history to identify improving, stable, or declining trends and raise alerts when needed.
- **Therapeutic toolkit**: Evidence-based coping activities including breathing exercises, guided meditation, CBT exercises, and music therapy.
- **Wellness games**: Four interactive mini-games designed to interrupt anxious thought loops through playful engagement.
- **Multi-method authentication**: Email/password, Google Sign-In, phone OTP, and biometric (fingerprint/face ID).

The project demonstrates the integration of modern cloud-native architecture (Firebase BaaS), reactive state management (Flutter Riverpod), and production-grade NLP inference within a consumer mobile application.

---

## 2. Problem Statement & Motivation

University students in Sri Lanka face compounding stressors: academic pressure, financial uncertainty, social isolation, and limited access to professional mental health services. Traditional therapist-led interventions remain inaccessible for most students due to cost, stigma, and geographic constraints.

MindPrint addresses this gap by providing:

| Gap | MindPrint Solution |
|---|---|
| No easy way to self-reflect daily | Frictionless text & voice journaling |
| Journaling produces no actionable insight | NLP-powered emotion + distortion detection |
| CBT techniques require a therapist | In-app guided CBT exercises and reframes |
| Stress has no healthy outlet | Therapeutic games and coping activities |
| Trends go unnoticed until crisis | 30-day mood analytics with predictive alerts |
| No support in native language | English, Sinhala, and Tamil UI support |

The design philosophy is **offline-first** (Firestore persistence enabled), **privacy-first** (biometric lock, no plain-text API keys on-device in production), and **evidence-based** (emotion categories align with Ekman's six basic emotions; CBT distortion categories align with Aaron Beck's cognitive distortion taxonomy).

---

## 3. System Architecture

### 3.1 Three-Tier Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION TIER                            │
│              Flutter Application (Dart 3.7.2)                  │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│   │  Auth    │  │ Journal  │  │Analytics │  │Coping/Games  │  │
│   │ Screens  │  │ Screens  │  │ Screens  │  │   Screens    │  │
│   └──────────┘  └──────────┘  └──────────┘  └──────────────┘  │
│              State: Flutter Riverpod 2.6.1                     │
│              Navigation: GoRouter (29 named routes)            │
└───────────────────────────┬─────────────────────────────────────┘
                            │ Firebase SDK / HTTP
┌───────────────────────────▼─────────────────────────────────────┐
│                  BACKEND-AS-A-SERVICE TIER                      │
│                  Google Firebase (mindprint-db)                 │
│  ┌─────────────┐  ┌────────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Firebase    │  │   Cloud    │  │ Firebase │  │ Firebase │  │
│  │    Auth     │  │ Firestore  │  │ Storage  │  │Messaging │  │
│  └─────────────┘  └────────────┘  └──────────┘  └──────────┘  │
└──────────┬────────────────────────────┬────────────────────────┘
           │ HTTPS REST                 │ HTTPS REST
┌──────────▼────────────┐  ┌───────────▼──────────────────────┐
│  HuggingFace          │  │  AssemblyAI                      │
│  Inference API        │  │  Speech-to-Text API              │
│  3 NLP models         │  │  Transcription + polling         │
└───────────────────────┘  └──────────────────────────────────┘
```

### 3.2 Feature-First Folder Structure

```
lib/
├── main.dart                          ← App entry point
├── firebase_options.dart              ← FlutterFire-generated platform config
├── app/
│   ├── app.dart                       ← Root MaterialApp widget
│   ├── router.dart                    ← GoRouter definition
│   └── theme.dart                     ← App-wide ThemeData
├── core/
│   ├── bootstrap/
│   │   └── app_bootstrap.dart         ← Initialisation sequence
│   ├── config/
│   │   └── env.dart                   ← flutter_dotenv wrapper
│   └── database/
│       └── firestore_database.dart    ← Firestore collection references
└── features/
    ├── analytics/                     ← Analytics tab, providers, service
    ├── auth/                          ← Auth screens, providers, services
    ├── chatbot/                       ← Gemini chatbot (UI shell)
    ├── coping/                        ← Coping toolkit screens
    ├── games/                         ← 4 mini-game screens
    ├── home/                          ← Home dashboard
    ├── journal/                       ← Journal screens + AI services
    ├── notifications/                 ← Notification list & service
    ├── profile/                       ← Profile editing
    ├── reports/                       ← Export/report screens
    ├── settings/                      ← Settings screen
    └── shared/
        ├── constants/                 ← Route names, app constants
        ├── models/                    ← All data model classes
        ├── providers/                 ← Cross-feature providers
        ├── utils/                     ← Utility helpers
        └── widgets/                  ← Reusable UI components
```

---

## 4. Technology Stack

| Layer | Technology | Version | Role |
|---|---|---|---|
| Language | Dart | 3.7.2 | Application language |
| Framework | Flutter | 3.29.0+ | Cross-platform UI framework |
| State Management | Flutter Riverpod | 2.6.1 | Reactive state + dependency injection |
| Navigation | GoRouter | (transitive via flutter) | Declarative routing, 29 named routes |
| Backend | Google Firebase | — | BaaS platform |
| Authentication | Firebase Auth | 5.4.2 | Multi-method auth |
| Database | Cloud Firestore | 5.6.12 | NoSQL document database, offline persistence |
| File Storage | Firebase Storage | (via firebase_core) | Voice audio file storage |
| Push Notifications | Firebase Messaging | 15.2.10 | FCM push delivery |
| Biometric Auth | local_auth | 2.2.2 | Fingerprint / Face ID |
| Google Sign-In | google_sign_in | 6.3.2 | OAuth 2.0 Google flow |
| NLP / Emotion AI | HuggingFace Inference API | REST | 3 NLP models (emotion, sentiment, distortion) |
| Voice Transcription | AssemblyAI STT API | REST | Speech-to-text with polling |
| Fonts | Google Fonts | 6.3.0 | Lora (headings) · Inter (body) |
| Charts | fl_chart | — | Radar + line charts (analytics) |
| Audio Recording | record | 5.1.2 | AAC-LC audio capture |
| Audio Playback | just_audio | 0.10.5 | Playback for meditation / music |
| Local Notifications | flutter_local_notifications | 19.5.0 | Scheduled in-app alerts |
| Image Picker | image_picker | 1.6.0 | Profile photo selection |
| HTTP Client | http | 1.2.1 | REST calls to external APIs |
| Permissions | permission_handler | 11.4.0 | Microphone, storage, notification permissions |
| File Paths | path_provider | 2.1.5 | Platform-safe temp/app directories |
| Timezones | timezone | 0.10.1 | Notification scheduling timezone support |
| Environment | flutter_dotenv | 5.2.1 | `.env` file loading |
| SVG Rendering | flutter_svg | 2.0.10+ | Asset SVG icons |
| iOS Icons | cupertino_icons | 1.0.8+ | iOS Cupertino icon set |

---

## 5. Authentication & Security

### 5.1 Authentication Methods

MindPrint implements four distinct authentication pathways via Firebase Authentication:

**Email / Password**
- Standard `createUserWithEmailAndPassword` / `signInWithEmailAndPassword`
- Full forgot-password and reset-password flow
- Password validation on client before submission

**Google Sign-In**
- OAuth 2.0 flow via `google_sign_in` package
- `GoogleAuthProvider.credential(idToken, accessToken)` used to link to Firebase Auth
- Google cleanup on sign-out (`_googleSignIn.disconnect()`)

**Phone OTP**
- `verifyPhoneNumber()` with auto-retrieval timeout
- Two-step UI: phone number entry → 6-digit OTP entry
- `PhoneAuthProvider.credential(verificationId, smsCode)` sign-in

**Biometric Authentication**
- `local_auth` package wraps platform-level APIs (Android Fingerprint, iOS Face ID / Touch ID)
- Availability checked at runtime (`BiometricService.isAvailable()`)
- Privacy consent screen shown before enabling biometrics
- Biometric preference stored in `UserProfile.biometricEnabled` in Firestore

### 5.2 Session & Profile Creation

On first sign-up (any method), a `UserProfile` document is created in `users/{uid}` Firestore collection. The profile includes: display name, email, FCM token slot, language preference, year of study, and all feature flags.

### 5.3 Offline Persistence

Firestore is configured with `persistenceEnabled: true`, meaning all reads and writes are cached to local storage. Users can view past journal entries and analytics without internet access; writes are queued and synced when connectivity resumes.

### 5.4 Environment Variable Security

API keys are loaded from a `.env` file packaged as a Flutter asset via `flutter_dotenv`. In production, the HuggingFace and AssemblyAI keys should be moved server-side (Firebase Cloud Functions) so they are never shipped inside the app binary.

---

## 6. Database Design

### 6.1 Firestore Collection Hierarchy

```
users/                              ← root collection
└── {userId}/                       ← document per user
    ├── [UserProfile fields]        ← user document itself
    ├── journals/                   ← subcollection
    │   └── {journalId}/
    │       ├── [JournalEntry fields]
    │       └── emotionResults/     ← nested subcollection
    │           └── {resultId}/
    │               └── [EmotionResult fields]
    ├── moodCheckins/               ← subcollection
    │   └── {checkinId}/
    │       └── [MoodCheckin fields]
    ├── predictions/                ← subcollection
    │   └── {predictionId}/
    │       └── [Prediction fields]
    ├── notifications/              ← subcollection
    │   └── {notificationId}/
    │       └── [NotificationItem fields]
    └── reports/                    ← subcollection
        └── {reportId}/
```

### 6.2 Data Models

#### UserProfile

Stored at: `users/{userId}`

| Field | Type | Description |
|---|---|---|
| `userId` | String | Firebase Auth UID |
| `displayName` | String | User's chosen display name |
| `email` | String | Email address |
| `profilePhoto` | String? | URL to profile image (Firebase Storage) |
| `language` | String | UI language: `'en'` · `'si'` · `'ta'` |
| `yearOfStudy` | int? | University year (1–4+) |
| `fcmToken` | String? | Firebase Cloud Messaging device token |
| `biometricEnabled` | bool | Whether biometric lock is active |
| `notificationsEnabled` | bool | Push notification consent |
| `offlineSyncEnabled` | bool | Offline mode preference |
| `onboardingCompleted` | bool | Whether onboarding questionnaire is done |
| `createdAt` | Timestamp | Account creation time |
| `updatedAt` | Timestamp | Last profile update time |

#### JournalEntry

Stored at: `users/{userId}/journals/{journalId}`

| Field | Type | Description |
|---|---|---|
| `id` | String | Firestore document ID |
| `userId` | String | Owner's Firebase UID |
| `content` | String | Text content of the journal entry |
| `moodScore` | int | Self-reported mood: 1 (very low) – 5 (very high) |
| `entryType` | String | `'text'` or `'voice'` |
| `voiceUrl` | String? | Firebase Storage URL for audio file |
| `isAnalyzed` | bool | Whether AI analysis has completed |
| `createdAt` | Timestamp | Entry creation time |

#### MoodCheckin

Stored at: `users/{userId}/moodCheckins/{checkinId}`

| Field | Type | Description |
|---|---|---|
| `id` | String | Firestore document ID |
| `userId` | String | Owner's Firebase UID |
| `score` | int | Mood score 1–5 |
| `label` | String | Human label: `Stressed` · `Sad` · `Neutral` · `Happy` · `Overjoy` |
| `createdAt` | Timestamp | Check-in timestamp |

#### EmotionResult

Stored at: `users/{userId}/journals/{journalId}/emotionResults/{resultId}`

| Field | Type | Description |
|---|---|---|
| `id` | String | Firestore document ID |
| `primaryEmotion` | String | Top detected emotion: joy · sadness · anger · fear · surprise · disgust · neutral |
| `intensity` | double | Confidence score 0.0–1.0 for primary emotion |
| `secondaryEmotions` | List\<String\> | Additional detected emotions |
| `sentiment` | String | Overall valence: `positive` · `negative` · `neutral` |
| `distortionType` | String? | Detected CBT distortion: overgeneralization · catastrophizing · black-and-white · personalization · mental-filtering |
| `aiInsight` | String | Personalised emotional reflection text |
| `cbtReframe` | String? | Cognitive reframe suggestion if distortion detected |
| `analyzedAt` | Timestamp | When AI analysis completed |

#### Prediction

Stored at: `users/{userId}/predictions/{predictionId}`

| Field | Type | Description |
|---|---|---|
| `id` | String | Firestore document ID |
| `averageMood` | double | Rolling average mood score 1.0–5.0 |
| `trend` | String | `improving` · `stable` · `declining` |
| `alertNeeded` | bool | True when trend is declining and below threshold |
| `generatedAt` | Timestamp | Prediction generation timestamp |

#### NotificationItem

Stored at: `users/{userId}/notifications/{notificationId}`

| Field | Type | Description |
|---|---|---|
| `id` | String | Firestore document ID |
| `title` | String | Notification headline |
| `body` | String | Notification body text |
| `type` | String | `affirmation` · `reminder` · `alert` |
| `isRead` | bool | Read/unread state |
| `createdAt` | Timestamp | Notification creation time |

---

## 7. AI / ML Pipeline

### 7.1 Overview

When a user saves a journal entry, `JournalService.analyzeAndSave()` fires three HuggingFace Inference API calls **in parallel** using Dart's `Future.wait()`. All three models are hosted on HuggingFace's serverless inference infrastructure and accessed via REST.

```
Journal Text
     │
     ├─── Model 1: j-hartmann/emotion-english-distilroberta-base
     │              → primaryEmotion, intensity, secondaryEmotions
     │
     ├─── Model 2: cardiffnlp/twitter-roberta-base-sentiment-latest
     │              → sentiment (positive / negative / neutral)
     │
     └─── Model 3: facebook/bart-large-mnli (zero-shot)
                    → distortionType (threshold > 0.30)
                          │
                          ▼
                  EmotionResult assembled
                          │
                    ┌─────▼──────┐
                    │ CBT Engine │ → aiInsight + cbtReframe
                    └────────────┘
                          │
                    Saved to Firestore
          users/{uid}/journals/{id}/emotionResults/
```

### 7.2 Model 1 — Emotion Classification

**Model:** `j-hartmann/emotion-english-distilroberta-base`  
**Type:** Text classification (fine-tuned DeBERTa/RoBERTa)  
**Input:** Raw journal text string  
**Output:** Ranked list of emotion labels with confidence scores

Emotions detected (Ekman taxonomy + neutral):

| Label | Meaning |
|---|---|
| joy | Happiness, excitement, contentment |
| sadness | Grief, loneliness, disappointment |
| anger | Frustration, irritation, rage |
| fear | Anxiety, worry, dread |
| surprise | Shock, astonishment (positive or negative) |
| disgust | Revulsion, strong disapproval |
| neutral | No strong emotion detected |

The top-scoring emotion becomes `primaryEmotion`; its score becomes `intensity`. Remaining emotions above a secondary threshold populate `secondaryEmotions`.

### 7.3 Model 2 — Sentiment Analysis

**Model:** `cardiffnlp/twitter-roberta-base-sentiment-latest`  
**Type:** Text classification (RoBERTa fine-tuned on Twitter data)  
**Input:** Raw journal text string  
**Output:** `LABEL_0` (negative) · `LABEL_1` (neutral) · `LABEL_2` (positive)

The highest-scoring label is mapped to the `sentiment` field of `EmotionResult`.

### 7.4 Model 3 — Cognitive Distortion Detection

**Model:** `facebook/bart-large-mnli`  
**Type:** Zero-shot classification (BART trained on NLI)  
**Input:** Journal text + five candidate CBT distortion labels  
**Output:** Confidence score per distortion label

Distortion types and their clinical definitions:

| Distortion | Beck's Definition |
|---|---|
| overgeneralization | Drawing broad conclusions from a single negative event |
| catastrophizing | Predicting or magnifying the worst possible outcome |
| black-and-white thinking | Seeing situations in extreme all-or-nothing terms |
| personalization | Attributing external events to oneself without justification |
| mental filtering | Focusing exclusively on the negative while discounting positives |

A distortion is reported only when its confidence score exceeds **0.30** (the detection threshold). The highest-scoring distortion above threshold is stored as `distortionType`.

### 7.5 CBT Reframing Engine

When a cognitive distortion is detected, a pre-mapped reframe string is generated. Each distortion type has a corresponding reframe template stored as Dart constants in `JournalService`. Examples:

- **overgeneralization** → *"Try to consider this as one specific event rather than a pattern that always happens..."*
- **catastrophizing** → *"Let's look at this more realistically. What are some other possible outcomes?..."*
- **black-and-white** → *"Most situations exist on a spectrum. What might the middle ground look like?..."*

Similarly, per-emotion AI insight strings are generated based on `primaryEmotion`.

### 7.6 Retry Logic

HuggingFace serverless inference models may be in a cold-start state (returns HTTP 503 with `"loading"` in the body). The service retries up to **3 times** with a **20-second delay** between attempts before failing. This prevents spurious errors when a model warms up after inactivity.

### 7.7 Mood Prediction Algorithm

`AnalyticsService.generatePrediction()` operates on the last 30 journal entries:

1. Compute `averageMood` across all `moodScore` fields.
2. Split entries into first-half (older) and second-half (recent).
3. Compute mean mood for each half.
4. Calculate delta = recent_mean − older_mean.
5. Classify trend:
   - delta > +0.3 → `improving`
   - delta < −0.3 → `declining`
   - otherwise → `stable`
6. If trend is `declining` AND `averageMood < 2.5`, set `alertNeeded = true`.

The result is stored as a `Prediction` document in Firestore.

---

## 8. Voice Journal Pipeline

### 8.1 Recording Stage

The `VoiceService` class manages audio capture using the `record` package:

| Parameter | Value |
|---|---|
| Format | AAC-LC (MPEG-4 AAC Low Complexity) |
| Sample Rate | 16,000 Hz (16 kHz) |
| Bit Rate | 64,000 bps (64 kbps) |
| Channels | Mono |
| Storage | App temp directory (path_provider) |

The recording screen displays a live duration timer. On stop, the raw `.m4a` file is handed to `AssemblyAIService`.

Permission handling uses `permission_handler` to request and check `Permission.microphone` before recording starts.

### 8.2 Transcription Stage

`AssemblyAIService` manages the full upload → poll → result cycle:

```
┌──────────────────────────────────────────────────┐
│  Step 1: Upload audio bytes directly to AssemblyAI│
│  POST https://api.assemblyai.com/v2/upload         │
│  Headers: Authorization: {ASSEMBLYAI_API_KEY}      │
│  Body: raw audio bytes                            │
│  Response: { upload_url: "..." }                  │
└──────────────────┬───────────────────────────────┘
                   │
┌──────────────────▼───────────────────────────────┐
│  Step 2: Submit transcription job                │
│  POST https://api.assemblyai.com/v2/transcript    │
│  Body: { audio_url: upload_url }                  │
│  Response: { id: "transcript_id", status: "queued"│
└──────────────────┬───────────────────────────────┘
                   │
┌──────────────────▼───────────────────────────────┐
│  Step 3: Poll for result (every 5 seconds)       │
│  GET https://api.assemblyai.com/v2/transcript/{id}│
│  Timeout: 2 minutes (24 polls max)               │
│  Status: queued → processing → completed/error   │
│  On completed: return { text: "..." }            │
└──────────────────┬───────────────────────────────┘
                   │
┌──────────────────▼───────────────────────────────┐
│  Step 4: Pass transcript text to HuggingFace     │
│  Same 3-model parallel pipeline as text journal  │
│  EmotionResult saved to Firestore                │
└──────────────────────────────────────────────────┘
```

No external cloud storage service is required at the transcription stage — audio is uploaded directly to AssemblyAI's infrastructure.

---

## 9. State Management — Riverpod

All application state is managed through Flutter Riverpod 2.6.1 using a `ProviderScope` at the root widget tree.

### 9.1 Auth Providers (`features/auth/providers/`)

| Provider | Type | Description |
|---|---|---|
| `authServiceProvider` | Provider | `AuthService` instance |
| `authStateChangesProvider` | StreamProvider | Firebase `User?` stream |
| `currentUserProvider` | Provider | Current `User?` (sync read) |

### 9.2 User / Profile Providers (`features/shared/providers/`)

| Provider | Type | Description |
|---|---|---|
| `firestoreDatabaseProvider` | Provider | `FirestoreDatabase` instance |
| `profileServiceProvider` | Provider | `ProfileService` instance |
| `userProfileProvider` | StreamProvider | Live `UserProfile?` stream from Firestore |
| `connectivityProvider` | StateProvider | Online / offline boolean |

### 9.3 Journal Providers (`features/journal/`)

| Provider | Type | Description |
|---|---|---|
| `huggingFaceServiceProvider` | Provider | `HuggingFaceService` instance |
| `journalServiceProvider` | Provider | `JournalService` instance |
| `journalsProvider` | StreamProvider | Real-time list of `JournalEntry` |
| `assemblyAiServiceProvider` | Provider | `AssemblyAIService` instance |
| `voiceServiceProvider` | Provider | `VoiceService` instance |

### 9.4 Analytics Providers (`features/analytics/`)

| Provider | Type | Description |
|---|---|---|
| `analyticsServiceProvider` | Provider | `AnalyticsService` instance |
| `analyticsSummaryProvider` | FutureProvider | Aggregated analytics data object |
| `latestPredictionProvider` | StreamProvider | Most recent `Prediction` document |
| `moodCheckinServiceProvider` | Provider | `MoodCheckinService` instance |

### 9.5 Notification Providers (`features/notifications/`)

| Provider | Type | Description |
|---|---|---|
| `notificationServiceProvider` | Provider | `NotificationService` instance |
| `notificationListProvider` | StreamProvider | Real-time `List<NotificationItem>` |
| `unreadNotificationCountProvider` | Provider | Derived count of unread notifications |

---

## 10. Navigation Architecture

### 10.1 Router

Navigation is handled by GoRouter with named route constants defined in `AppRoutes` (`lib/features/shared/constants/route_names.dart`).

### 10.2 Route Groups

**Authentication Flow (11 routes)**

| Route Constant | Path | Screen |
|---|---|---|
| `splash` | `/` | Animated splash / auth gate |
| `onboarding` | `/onboarding` | 3-slide feature walkthrough |
| `login` | `/login` | Email/Google/Phone login |
| `signup` | `/signup` | Registration form |
| `congratulations` | `/congratulations` | Welcome after sign-up |
| `biometricsPrivacy` | `/biometrics-privacy` | Biometric consent screen |
| `forgotPassword` | `/forgot-password` | Password reset request |
| `resetPassword` | `/reset-password` | New password entry |
| `phoneAuth` | `/phone-auth` | Phone number entry |
| `otp` | `/otp` | OTP verification |
| `onboardingQuestionnaire` | `/onboarding-questionnaire` | 4-question baseline mood |

**Main Application (8 routes)**

| Route Constant | Path | Screen |
|---|---|---|
| `home` | `/home` | Home dashboard |
| `notifications` | `/notifications` | Notification list |
| `journal` | `/journal` | Journal entry + history |
| `emotionResult` | `/journal/emotion-result` | AI analysis result |
| `analytics` | `/analytics` | Analytics dashboard |
| `coping` | `/coping` | Coping toolkit hub |
| `reports` | `/reports` | Reports & export |
| `settings` | `/settings` | App settings |

**Profile & Setup (2 routes)**

| Route Constant | Path | Screen |
|---|---|---|
| `editProfile` | `/edit-profile` | Profile editing |
| `games` | `/games` | Games hub |

**Activities / Coping Toolkit (4 routes)**

| Route Constant | Path | Screen |
|---|---|---|
| `breathing` | `/activities/breathing` | Breathing exercises |
| `musicTherapy` | `/activities/music` | Music therapy |
| `meditation` | `/activities/meditation` | Guided meditation |
| `cbtExercises` | `/activities/cbt` | CBT exercises |

**Mini-Games (4 routes)**

| Route Constant | Path | Screen |
|---|---|---|
| `starRain` | `/games/star-rain` | Star Rain game |
| `bubblePop` | `/games/bubble-pop` | Bubble Pop game |
| `memoryMatch` | `/games/memory-match` | Memory Match game |
| `breathingBall` | `/games/breathing-ball` | Breathing Ball game |

**Total: 29 named routes**

---

## 11. Feature Inventory

### 11.1 Authentication & Onboarding

- Animated splash screen with Firebase auth-gate (routes to home if signed in, onboarding if not)
- 3-slide onboarding: Privacy, Features, Security introduction
- Full email/password registration with form validation
- Google Sign-In OAuth flow
- Phone number authentication with OTP (6-digit, auto-retrieval)
- Forgot password + reset password screens
- Biometric privacy consent screen
- 4-question onboarding questionnaire (year of study, stress baseline, sleep, primary stressor)
- Congratulations screen post-registration
- On registration, Firestore `UserProfile` document created automatically

### 11.2 Text Journal & AI Analysis

- Journal entry screen: free-text input + 1–5 mood selector
- On save: three HuggingFace models run in parallel, `EmotionResult` written to Firestore
- Emotion result screen: displays primary emotion, intensity %, secondary emotions, AI insight, CBT reframe (if distortion detected)
- Journal history screen with real-time Firestore stream (Riverpod `StreamProvider`)
- Monthly grouping of entries in history list
- Search functionality across journal entries

### 11.3 Voice Journal

- Record screen with live duration timer and waveform animation
- Microphone permission request flow
- Audio recorded as AAC-LC at 16 kHz, mono
- Transcript submitted to AssemblyAI; polling at 5-second intervals (2-minute timeout)
- On completion: transcript passed through full NLP pipeline (same as text journal)
- Voice entries saved as `JournalEntry` with `entryType: 'voice'`

### 11.4 Home Dashboard

- Mood check-in widget: quick 1–5 mood score + label selection
- Quick-access cards to Journal, Activities, Games, Reports
- Stress insight card (driven by latest `Prediction.alertNeeded` flag)
- Bottom navigation bar with 5 tabs: Home · Journal · Analytics · Notifications · (Chatbot)

### 11.5 Analytics Dashboard

- Emotional fingerprint radar chart (6-axis: joy, sadness, anger, fear, surprise, disgust)
- Mood timeline chart (last 30 entries)
- Cognitive patterns section (distortion frequency breakdown)
- Mood prediction display (trend label + 48-hour forecast)
- `AnalyticsService` queries and aggregates real Firestore data; charts currently display mock data (UI wiring in progress)

---

## 12. Coping Toolkit

### 12.1 Breathing Exercises (4 types)

| Exercise | Pattern | Clinical Purpose |
|---|---|---|
| 4-7-8 Breathing | Inhale 4s · Hold 7s · Exhale 8s | Calms nervous system, reduces anxiety |
| Box Breathing | Inhale 4s · Hold 4s · Exhale 4s · Hold 4s | Builds focus and mental clarity |
| Belly Breathing | Deep diaphragmatic breathing | Reduces physical stress response |
| Calming Breath | Simple slow-pace breath | Quick stress relief |

Each exercise has a guided animation (AnimationController-driven breathing circle), configurable round count, and session timer.

### 12.2 Guided Meditation (5 sessions)

| Session | Duration | Focus |
|---|---|---|
| Morning Clarity | 5 min | Starting the day grounded |
| Stress Release | 10 min | Releasing tension and worry |
| Body Scan | 15 min | Progressive physical relaxation |
| Loving Kindness | 10 min | Building self-compassion |
| Deep Rest | 20 min | Sleep preparation |

### 12.3 CBT Exercises (3 types)

| Exercise | Steps | Purpose |
|---|---|---|
| Thought Record | Identify trigger → emotion → automatic thought → evidence for/against → balanced thought | Challenge cognitive distortions |
| Gratitude Check | List 3 things you're grateful for, why they matter, how they make you feel | Shift attention to positives |
| 5-4-3-2-1 Grounding | Name 5 things you see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste | Anchor to present moment (panic intervention) |

### 12.4 Music Therapy (8 tracks)

| Track | Mood Tag |
|---|---|
| Ocean Calm | Anxiety relief |
| Forest Rain | Stress relief |
| Zen Focus | Concentration |
| Deep Sleep | Sleep aid |
| Morning Light | Mood uplift |
| Gentle Flow | General relaxation |
| Soft Horizon | Quiet focus |
| Still Waters | Emotional calm |

---

## 13. Wellness Mini-Games

All four games are designed to provide a healthy mental interruption — redirecting rumination through gentle engagement.

### 13.1 Star Rain

- Stars fall from the top of the screen at varying speeds
- Player taps falling stars to destroy them before they hit the bottom
- Score tracks consecutive hits
- Increasing difficulty as pace accelerates

### 13.2 Bubble Pop

- Bubbles drift across the screen in random trajectories
- Player taps bubbles to pop them (satisfying stress-relief mechanic)
- Tracks pop count per session

### 13.3 Memory Match

- Grid of face-down cards with hidden emoji/icon pairs
- Player flips two cards per turn; matched pairs stay revealed
- Win detection when all pairs are revealed
- Tracks number of attempts

### 13.4 Breathing Ball

- A circle expands (inhale) and contracts (exhale) in a rhythmic cycle
- Player follows the visual rhythm with their breathing
- 5 rounds per session (configurable)
- Uses Flutter `AnimationController` with `CurvedAnimation` for smooth transitions

---

## 14. Analytics Engine

`AnalyticsService` (`lib/features/analytics/services/analytics_service.dart`) implements the following computations over Firestore data:

### 14.1 Data Queries

- Fetches last 30 journal entries ordered by `createdAt` descending
- Extracts `EmotionResult` from each analyzed entry
- Queries `MoodCheckin` for supplementary mood data

### 14.2 Summary Statistics

| Metric | Calculation |
|---|---|
| Total journal entries | Count of all journal documents |
| Average mood score | Mean of all `moodScore` fields |
| Best journaling weekday | Day-of-week with highest average mood |
| Emotion frequencies | Count per emotion label, normalised to 0–1 for radar chart |
| Distortion counts | Count per distortion type across all EmotionResults |

### 14.3 Trend Prediction

See [Section 7.7](#77-mood-prediction-algorithm) for the full algorithm.

The `latestPredictionProvider` watches the most recent `Prediction` document via a Firestore real-time stream, surfacing live trend information to the home screen and analytics tab.

---

## 15. Flutter Packages Reference

### 15.1 Production Dependencies

| Package | Version (pubspec) | Resolved | Category | Purpose |
|---|---|---|---|---|
| `firebase_core` | ^3.9.0 | 3.15.2 | Firebase | Core Firebase SDK initialisation |
| `cloud_firestore` | ^5.6.0 | 5.6.12 | Firebase | NoSQL database with offline persistence |
| `firebase_auth` | ^5.3.4 | 5.4.2 | Firebase | Multi-method authentication |
| `firebase_messaging` | ^15.2.10 | 15.2.10 | Firebase | FCM push notifications |
| `flutter_riverpod` | ^2.4.9 | 2.6.1 | State | Reactive state management & DI |
| `google_sign_in` | ^6.2.1 | 6.3.2 | Auth | Google OAuth 2.0 sign-in |
| `local_auth` | ^2.2.0 | 2.2.2 | Auth | Biometric fingerprint/face auth |
| `google_fonts` | ^6.2.1 | 6.3.0 | UI | Lora (headings) + Inter (body) fonts |
| `flutter_svg` | ^2.0.10 | — | UI | SVG asset rendering |
| `cupertino_icons` | ^1.0.8 | — | UI | iOS Cupertino icon set |
| `flutter_dotenv` | ^5.1.0 | 5.2.1 | Config | `.env` file loading |
| `http` | ^1.2.2 | 1.2.1 | Network | REST API calls (HuggingFace, AssemblyAI) |
| `record` | ^5.1.2 | 5.1.2 | Audio | Audio recording (AAC-LC, 16 kHz) |
| `just_audio` | ^0.10.5 | 0.10.5 | Audio | Audio playback for meditation/music |
| `permission_handler` | ^11.3.1 | 11.4.0 | Device | Microphone, storage, notification permissions |
| `path_provider` | ^2.1.4 | 2.1.5 | File System | Platform-safe temp/app directory paths |
| `image_picker` | ^1.1.2 | 1.6.0 | Device | Gallery/camera photo selection |
| `flutter_local_notifications` | ^19.5.0 | 19.5.0 | Notifications | Scheduled in-app local alerts |
| `timezone` | ^0.10.1 | 0.10.1 | Utilities | Timezone data for notification scheduling |

### 15.2 Development Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_lints` | ^5.0.0 | Static analysis and lint rules |
| `flutter_test` | SDK | Widget and unit testing framework |

---

## 16. Environment & Configuration

### 16.1 Environment Variables (`.env`)

The `.env` file is packaged as a Flutter asset and loaded at startup via `flutter_dotenv`. It is referenced in `pubspec.yaml` under `flutter.assets`.

```
HUGGINGFACE_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxx
ASSEMBLYAI_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxx

# Firebase Web
FIREBASE_WEB_API_KEY=...
FIREBASE_WEB_APP_ID=...
FIREBASE_WEB_AUTH_DOMAIN=mindprint-db.firebaseapp.com
FIREBASE_WEB_MESSAGING_SENDER_ID=987595589557
FIREBASE_WEB_PROJECT_ID=mindprint-db
FIREBASE_WEB_STORAGE_BUCKET=mindprint-db.firebasestorage.app
FIREBASE_WEB_MEASUREMENT_ID=...

# Firebase Android
FIREBASE_ANDROID_API_KEY=...
FIREBASE_ANDROID_APP_ID=1:987595589557:android:21f7da80a56bfb7ca37bfc

# Firebase iOS
FIREBASE_IOS_API_KEY=...
FIREBASE_IOS_APP_ID=1:987595589557:ios:1469061a6540ecfea37bfc
FIREBASE_IOS_BUNDLE_ID=com.example.mindPrint

# Firebase Windows / macOS / Linux
# (platform-specific keys)
```

### 16.2 Bootstrap Sequence

```
main()
  └── WidgetsFlutterBinding.ensureInitialized()
  └── AppBootstrap.initialize()
        ├── Env.load()                     ← flutter_dotenv loads .env asset
        ├── Firebase.initializeApp(
        │     options: DefaultFirebaseOptions.currentPlatform
        │   )                              ← platform-appropriate config
        └── FirebaseFirestore.instance.settings = Settings(
              persistenceEnabled: true     ← offline cache enabled
            )
  └── runApp(
        ProviderScope(                     ← Riverpod root
          child: MindPrintApp()
        )
      )
```

### 16.3 Firebase Project Details

| Property | Value |
|---|---|
| Project ID | mindprint-db |
| Region | asia-south1 (Mumbai) |
| Project Number | 987595589557 |
| Android Package | com.example.mind_print |
| iOS Bundle ID | com.example.mindPrint |
| Storage Bucket | mindprint-db.firebasestorage.app |
| Auth Domain | mindprint-db.firebaseapp.com |

### 16.4 Platform Support

The app is configured for six platforms:

| Platform | App ID | Config File |
|---|---|---|
| Android | `1:987595589557:android:21f7da80a56bfb7ca37bfc` | `android/app/google-services.json` |
| iOS | `1:987595589557:ios:1469061a6540ecfea37bfc` | `ios/Runner/GoogleService-Info.plist` |
| Web | `1:987595589557:web:c2f7e7d7cdec5c73a37bfc` | `lib/firebase_options.dart` |
| Windows | `1:987595589557:web:81621a5d452367eaa37bfc` | `lib/firebase_options.dart` |
| macOS | (configured) | `lib/firebase_options.dart` |
| Linux | (configured) | `lib/firebase_options.dart` |

---

## 17. Multi-Language Support

MindPrint is designed to serve Sri Lanka's multilingual student population:

| Language | Code | Coverage |
|---|---|---|
| English | `en` | Full app UI |
| Sinhala | `si` | Planned — language preference stored |
| Tamil | `ta` | Planned — language preference stored |

The selected language is stored in `UserProfile.language` in Firestore, persisting across sessions and devices. Language selection is available in the Settings screen.

---

## 18. Implementation Status

| Feature Module | Status | Completion |
|---|---|---|
| Authentication & Onboarding | Complete | 100% |
| Text Journal + NLP Analysis | Complete | 100% |
| Voice Recording (local capture) | Complete | 100% |
| Voice Cloud Pipeline (AssemblyAI) | Partial — service coded, Firebase Storage integration in progress | 70% |
| Home Dashboard + Mood Check-in | Complete | 100% |
| Analytics UI (charts, layout) | Complete — real data wiring in progress | 80% |
| Analytics Service (Firestore queries + prediction) | Complete | 100% |
| Coping Toolkit — UI Screens | Complete | 100% |
| Breathing Exercise (animated) | Complete | 100% |
| Meditation Sessions | Complete (UI + content) | 100% |
| CBT Exercises | Complete (UI + step content) | 100% |
| Music Therapy | Complete (track list + UI) | 100% |
| Mini-Games (all 4) | Complete | 100% |
| Push Notifications (FCM) | Not yet started | 0% |
| Gemini Chatbot | UI shell only | 5% |
| Profile Save / Edit | UI complete — Firestore persistence partial | 40% |
| Settings Persistence | UI complete — Firestore sync partial | 30% |
| Reports & Export (PDF/CSV) | Shell only | 10% |
| Multi-language (Sinhala/Tamil) | Preference stored — UI translations pending | 20% |
| Firebase Cloud Functions | Documented, not yet implemented | 0% |

---

*Report generated: 2026-05-13*  
*Project branch: feature/backend*  
*Firebase project: mindprint-db (asia-south1)*
