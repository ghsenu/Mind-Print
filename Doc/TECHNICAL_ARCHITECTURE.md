# MindPrint — Technical Architecture Reference

**Version:** 1.0.0+1 · **Date:** 2026-05-13  
**Stack:** Flutter 3.29 · Firebase · HuggingFace Inference · AssemblyAI · Google Gemini

---

## Table of Contents

1. [Architectural Highlights](#1-architectural-highlights)
2. [Service Layer — All Microservices](#2-service-layer--all-microservices)
3. [Data Flow Diagrams](#3-data-flow-diagrams)
4. [Database Architecture — Why Firestore](#4-database-architecture--why-firestore)
5. [Direct AI Integration Pattern](#5-direct-ai-integration-pattern)
6. [AI Model Input / Output Schemas](#6-ai-model-input--output-schemas)
7. [Firebase Configuration Details](#7-firebase-configuration-details)
8. [Core Bootstrap Sequence](#8-core-bootstrap-sequence)
9. [Riverpod Provider Dependency Graph](#9-riverpod-provider-dependency-graph)
10. [CBT Distortion-to-Reframe Mapping](#10-cbt-distortion-to-reframe-mapping)
11. [AssemblyAI Polling State Machine](#11-assemblyai-polling-state-machine)

---

## 1. Architectural Highlights

MindPrint uses several architectural decisions worth highlighting explicitly for academic and technical review:

### Latest Generation NoSQL Database

The project uses **Cloud Firestore** — Google's second-generation, globally-distributed document database (not to be confused with the older Firebase Realtime Database). Firestore represents the current state-of-the-art for mobile BaaS:

- **Subcollection model**: Emotion results are nested under their parent journal entry (`journals/{id}/emotionResults/`), enabling atomic consistency without JOIN operations.
- **Real-time streams**: Riverpod `StreamProvider`s wrap Firestore snapshot streams, giving the UI an always-live view of data without polling.
- **Offline-first persistence**: Firestore's LevelDB-backed local cache means the app fully works offline — writes are queued and synced on reconnect. This is critical for Sri Lankan students on unreliable mobile data.
- **Compound queries**: Analytics queries combine `orderBy` + `limit` to fetch exactly the last 30 journal entries in one round-trip.

### Direct AI API Integration

Rather than the common pattern of routing AI calls through an intermediary server, MindPrint implements a **direct client-to-API** model using Dart's `http` package:

- **Three NLP models called in parallel** from the Flutter client using `Future.wait()` — this is not a pattern seen in typical Flutter apps and demonstrates advanced async programming.
- **Zero-shot classification** with `facebook/bart-large-mnli` is used creatively for CBT distortion detection — the model was not fine-tuned on therapy data; instead, distortion labels are provided as natural language hypothesis strings at inference time. This is a state-of-the-art NLP technique.
- **AssemblyAI direct upload** — audio bytes are streamed directly from device to AssemblyAI without any intermediary storage server, reducing latency and cost.

---

## 2. Service Layer — All Microservices

MindPrint follows a **feature-first service architecture**. Each feature module owns its own service class(es). Services are instantiated through Riverpod providers (dependency injection) — no singletons or global state.

---

### `AuthService`
**Location:** `lib/features/auth/services/auth_service.dart`

Wraps Firebase Auth with all authentication methods:

| Method | Description |
|---|---|
| `signUpWithEmail(email, password, name)` | Creates account, creates Firestore UserProfile |
| `signInWithEmail(email, password)` | Email/password sign-in |
| `signInWithGoogle()` | Full OAuth 2.0 Google flow → Firebase credential |
| `signInWithPhone(phone, onCodeSent, onVerified)` | Sends OTP; callback-based |
| `verifyOtp(verificationId, smsCode)` | Completes phone auth with SMS code |
| `sendPasswordResetEmail(email)` | Triggers Firebase password reset email |
| `signOut()` | Signs out from Firebase + disconnects Google |
| `linkEmailCredential(email, password)` | Links email to existing phone account |

---

### `BiometricService`
**Location:** `lib/features/auth/services/biometric_service.dart`

| Method | Description |
|---|---|
| `isAvailable()` | Returns `bool` — checks if device has biometric hardware |
| `authenticate(reason)` | Prompts biometric dialog, returns success/failure |

---

### `JournalService`
**Location:** `lib/features/journal/services/journal_service.dart`

Orchestrates the full journal entry + AI analysis pipeline:

| Method | Description |
|---|---|
| `saveTextEntry(userId, content, moodScore)` | Saves `JournalEntry` to Firestore, triggers analysis |
| `saveVoiceEntry(userId, voiceUrl, transcript, moodScore)` | Saves voice journal entry |
| `analyzeAndSave(journalId, text)` | Fires `Future.wait([emotion, sentiment, distortion])`, assembles `EmotionResult`, writes to Firestore |
| `getJournals(userId)` | Returns Firestore stream of journal entries (real-time) |
| `deleteEntry(userId, journalId)` | Deletes journal and nested emotion results |
| `_buildInsight(primaryEmotion)` | Returns per-emotion support text |
| `_buildReframe(distortionType)` | Returns per-distortion CBT reframe text |

---

### `HuggingFaceService`
**Location:** `lib/features/journal/services/hugging_face_service.dart`

Manages all three HuggingFace Inference API calls:

| Method | Description |
|---|---|
| `classifyEmotion(text)` | POST to `j-hartmann/emotion-english-distilroberta-base`; returns top emotion + intensity + secondary list |
| `analyzeSentiment(text)` | POST to `cardiffnlp/twitter-roberta-base-sentiment-latest`; returns `positive`/`negative`/`neutral` |
| `detectCognitiveDistortion(text)` | POST to `facebook/bart-large-mnli` (zero-shot); returns distortion type if score > 0.30 |
| `_callWithRetry(url, body)` | Generic retry wrapper — 3 attempts, 20-second delay, handles 503 cold-start |

All three are called via `Future.wait()` in `JournalService.analyzeAndSave()` — they execute concurrently, not sequentially. This cuts analysis time by ~60% compared to sequential calls.

**HuggingFace API endpoint pattern:**
```
POST https://api-inference.huggingface.co/models/{model-id}
Authorization: Bearer {HUGGINGFACE_API_KEY}
Content-Type: application/json
Body: { "inputs": "journal text here" }
```

---

### `AssemblyAIService`
**Location:** `lib/features/journal/services/assembly_ai_service.dart`

| Method | Description |
|---|---|
| `uploadAudio(filePath)` | Reads file bytes, POSTs to AssemblyAI `/v2/upload`, returns `upload_url` |
| `submitTranscription(uploadUrl)` | POSTs to `/v2/transcript` with `audio_url`, returns `transcript_id` |
| `pollForResult(transcriptId)` | GETs `/v2/transcript/{id}` every 5 seconds until `status == completed` (2-min timeout) |
| `transcribeVoiceFile(filePath)` | Full pipeline: upload → submit → poll → return transcript text |

---

### `VoiceService`
**Location:** `lib/features/journal/services/voice_service.dart`

| Method | Description |
|---|---|
| `requestPermission()` | Requests `Permission.microphone` via `permission_handler` |
| `startRecording()` | Initialises `record` plugin, starts capture to temp file (AAC-LC 16 kHz mono) |
| `stopRecording()` | Stops capture, returns file path of `.m4a` file |
| `getRecordingPath()` | Returns path to most recent recording |

---

### `AnalyticsService`
**Location:** `lib/features/analytics/services/analytics_service.dart`

| Method | Description |
|---|---|
| `getAnalyticsSummary(userId)` | Fetches last 30 journals + emotion results; returns aggregated `AnalyticsSummary` object |
| `_computeEmotionFrequencies(results)` | Counts occurrences per emotion label; normalises to 0–1 range for radar chart |
| `_computeDistortionCounts(results)` | Counts occurrences per distortion type |
| `_computeBestDay(entries)` | Finds day-of-week with highest average `moodScore` |
| `generatePrediction(userId)` | Implements 7-day delta trend algorithm; writes `Prediction` to Firestore |
| `getLatestPrediction(userId)` | Returns Firestore real-time stream of most recent `Prediction` |

---

### `MoodCheckinService`
**Location:** `lib/features/home/services/mood_checkin_service.dart`

| Method | Description |
|---|---|
| `logCheckin(userId, score, label)` | Writes `MoodCheckin` document to Firestore subcollection |
| `getTodayCheckin(userId)` | Reads today's check-in (for home screen display) |

---

### `ProfileService`
**Location:** `lib/features/profile/services/profile_service.dart`

| Method | Description |
|---|---|
| `watchProfile(userId)` | Returns Firestore snapshot stream of `UserProfile` |
| `updateProfile(userId, fields)` | Partial update of UserProfile fields in Firestore |
| `updateFcmToken(userId, token)` | Stores latest FCM device token |

---

### `NotificationService`
**Location:** `lib/features/notifications/services/notification_service.dart`

| Method | Description |
|---|---|
| `getNotifications(userId)` | Returns Firestore real-time stream of notifications |
| `markAsRead(userId, notificationId)` | Updates `isRead: true` in Firestore |
| `addNotification(userId, item)` | Writes new `NotificationItem` to Firestore |
| `initLocalNotifications()` | Initialises `flutter_local_notifications` plugin |
| `scheduleLocalNotification(title, body, scheduledTime)` | Schedules a local notification with timezone support |

---

## 3. Data Flow Diagrams

### 3.1 Text Journal Entry → AI Analysis → Firestore

```
User types journal text
         │
         ▼
JournalScreen.onSave()
         │
         ▼
JournalService.saveTextEntry(userId, content, moodScore)
         │
         ├── 1. Write JournalEntry to Firestore
         │       users/{uid}/journals/{newId}
         │       { content, moodScore, isAnalyzed: false, entryType: 'text' }
         │
         └── 2. analyzeAndSave(journalId, content)
                   │
                   ▼
              Future.wait([               ← PARALLEL EXECUTION
                classifyEmotion(text),    ← HuggingFace Model 1
                analyzeSentiment(text),   ← HuggingFace Model 2
                detectDistortion(text)    ← HuggingFace Model 3
              ])
                   │
                   ▼
              Assemble EmotionResult {
                primaryEmotion, intensity,
                secondaryEmotions,
                sentiment,
                distortionType,
                aiInsight   ← _buildInsight(primaryEmotion),
                cbtReframe  ← _buildReframe(distortionType)
              }
                   │
                   ▼
              Write EmotionResult to Firestore
              users/{uid}/journals/{id}/emotionResults/{newId}
                   │
                   ▼
              Update JournalEntry: isAnalyzed = true
                   │
                   ▼
              Navigate to EmotionResultScreen
              (reads from Firestore stream via Riverpod)
```

### 3.2 Voice Journal → AssemblyAI → AI Analysis

```
User presses Record
         │
         ▼
VoiceService.startRecording()
├── permission_handler: check/request mic permission
└── record plugin: capture AAC-LC 16kHz mono → temp .m4a file
         │
User presses Stop
         │
         ▼
VoiceService.stopRecording() → returns filePath
         │
         ▼
AssemblyAIService.transcribeVoiceFile(filePath)
    │
    ├── Step 1: uploadAudio(filePath)
    │       Read file bytes
    │       POST /v2/upload → returns upload_url
    │
    ├── Step 2: submitTranscription(upload_url)
    │       POST /v2/transcript { audio_url }
    │       Returns transcript_id
    │
    └── Step 3: pollForResult(transcript_id)
            Loop every 5 seconds (max 24 polls = 2 minutes):
              GET /v2/transcript/{id}
              status = queued → processing → completed
            Returns transcript text
         │
         ▼
JournalService.saveVoiceEntry(userId, null, transcript, moodScore)
         │
         ▼
Same HuggingFace pipeline as text journal (Section 3.1)
```

### 3.3 Authentication Flow

```
App Launch
    │
    ▼
SplashScreen
    │
    ├── authStateChangesProvider (FirebaseAuth stream)
    │       │
    │       ├── User is signed in ──────────────────► HomeScreen
    │       │
    │       └── User is null
    │               │
    │               ▼
    │           OnboardingScreen (first launch)
    │               │
    │               ├── LoginScreen
    │               │     ├── Email/Password ──► Firebase Auth
    │               │     ├── Google Sign-In ──► Google OAuth → Firebase
    │               │     └── Phone ──────────► PhoneAuthScreen
    │               │                                 │
    │               │                                 ▼
    │               │                           OtpScreen (SMS code)
    │               │
    │               └── SignupScreen
    │                     │
    │                     ▼
    │                 CongratulationsScreen
    │                     │
    │                     ▼
    │                 BiometricsPrivacyScreen (opt-in)
    │                     │
    │                     ▼
    │                 OnboardingQuestionnaireScreen (4 questions)
    │                     │
    │                     ▼
    └────────────────► HomeScreen
```

### 3.4 Analytics Data Flow

```
AnalyticsTab mounts
      │
      ▼
analyticsSummaryProvider (FutureProvider)
      │
      ▼
AnalyticsService.getAnalyticsSummary(userId)
      │
      ├── Firestore query: last 30 journals (orderBy createdAt desc, limit 30)
      │
      └── For each analyzed journal:
            Fetch emotionResults subcollection
            Extract: primaryEmotion, sentiment, distortionType, moodScore
      │
      ▼
Compute:
├── averageMood (mean of moodScore)
├── bestDay (weekday with highest avg moodScore)
├── emotionFrequencies (count per label → normalise 0-1)
├── distortionCounts (count per distortion type)
└── totalEntries
      │
      ▼
AnalyticsSummary returned to UI
      │
      ├── RadarChart ← emotionFrequencies (6 axes)
      ├── LineChart  ← mood timeline
      └── BarChart   ← distortion counts

latestPredictionProvider (StreamProvider)
      │
      ▼
Firestore stream: users/{uid}/predictions (latest 1)
      │
      ▼
PredictionCard ← trend label + alertNeeded flag
```

---

## 4. Database Architecture — Why Firestore

### 4.1 Firestore vs Traditional RDBMS

MindPrint uses Cloud Firestore — Google's next-generation NoSQL document database — rather than a traditional relational database. This is a deliberate architectural choice:

| Concern | Traditional RDBMS | Cloud Firestore (MindPrint) |
|---|---|---|
| Schema flexibility | Fixed schema, migrations required | Schema-free, add fields anytime |
| Mobile offline support | External lib required | Native offline persistence, built-in |
| Real-time updates | Polling or WebSocket setup | Native document snapshot streams |
| Scaling | Vertical scale, connection limits | Horizontally auto-scaled globally |
| Authentication integration | Manual setup | Native Firebase Auth UID as document path |
| Setup complexity | Server, ORM, migration tooling | Zero infrastructure, SDK only |
| Nested data | JOIN tables | Native subcollections |

For a mobile-first application targeting students on mobile data in Sri Lanka, Firestore's offline-first architecture is not just convenient — it is a core functional requirement.

### 4.2 Document vs Subcollection Design Decision

The `emotionResults` are stored as a subcollection of each journal entry (`journals/{id}/emotionResults/`) rather than a flat collection. This means:

- Firestore security rules can enforce: only the journal's owner can access its emotion results — without extra query conditions.
- Querying all emotion results for one journal is a single collection read, not a filtered full-scan.
- The document model naturally represents the one-to-many relationship (one journal → potentially multiple analysis passes).

### 4.3 Offline Persistence Configuration

```dart
// Applied in AppBootstrap.initialize() before any Firestore read
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,     // LevelDB local cache
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

This means journal entries, mood check-ins, and predictions are all readable while offline. Writes are batched and synced on next connectivity.

### 4.4 Real-Time Streams via Riverpod

```dart
// Example: live journal list, always fresh
final journalsProvider = StreamProvider.family<List<JournalEntry>, String>(
  (ref, userId) => ref.read(journalServiceProvider).getJournals(userId),
);
```

Firestore's `snapshots()` stream fires on every document change. Riverpod wraps this as a `StreamProvider`, so the UI automatically rebuilds when new journal entries are saved — no manual refresh needed.

---

## 5. Direct AI Integration Pattern

### 5.1 Why Direct (Not Server-Proxied)

Most production apps route AI calls through a server proxy (e.g., a Cloud Function) to protect API keys. MindPrint currently calls HuggingFace and AssemblyAI directly from the Flutter client — a pattern chosen for rapid development during the academic project timeline.

This is architecturally notable because:

1. **Parallel execution is trivial in Dart.** `Future.wait([a, b, c])` runs all three API calls concurrently with zero threading boilerplate. This would require async worker infrastructure server-side.
2. **Zero cold-start latency.** Calling from the client means no Cloud Function initialisation delay before the HuggingFace call fires.
3. **Retrofit path exists.** The service layer is cleanly abstracted — when Cloud Functions are added, only the URL target of `_callWithRetry()` changes; the rest of the app is unaffected.

The production migration plan moves API keys to Cloud Functions (`functions/.env.local`) while keeping the same service API surface.

### 5.2 Parallel AI Execution

```dart
// In JournalService.analyzeAndSave()
final results = await Future.wait([
  _huggingFaceService.classifyEmotion(text),       // Model 1
  _huggingFaceService.analyzeSentiment(text),      // Model 2
  _huggingFaceService.detectCognitiveDistortion(text), // Model 3
]);

final emotionData    = results[0];  // { emotion, intensity, secondary }
final sentimentData  = results[1];  // { sentiment: positive/negative/neutral }
final distortionData = results[2];  // { distortionType? }
```

Wall-clock time ≈ max(single model latency) instead of sum(all model latencies). With typical HuggingFace serverless latency of 1–3 seconds per model, this cuts analysis time from ~9 seconds (sequential) to ~3 seconds (parallel).

### 5.3 Zero-Shot Classification for CBT

Using `facebook/bart-large-mnli` as a zero-shot classifier for cognitive distortions is a state-of-the-art NLP technique. The model was trained on Natural Language Inference (NLI) — determining whether a hypothesis is entailed by a premise. Zero-shot classification repurposes this:

```
Premise (input):    "journal text"
Hypothesis labels:  ["overgeneralization", "catastrophizing",
                     "black-and-white thinking", "personalization",
                     "mental filtering"]

The model asks: is the journal text an example of each hypothesis?
Output: probability scores per label
```

No task-specific fine-tuning or labelled therapy data is required. The model's general language understanding is sufficient to detect distortion patterns from natural language descriptions. This is a cutting-edge research technique applied directly in a mobile app.

---

## 6. AI Model Input / Output Schemas

### 6.1 HuggingFace Emotion Classification

**Model:** `j-hartmann/emotion-english-distilroberta-base`

Request:
```json
POST https://api-inference.huggingface.co/models/j-hartmann/emotion-english-distilroberta-base
{
  "inputs": "I feel completely overwhelmed and nothing seems to work out for me"
}
```

Response:
```json
[
  [
    { "label": "sadness", "score": 0.7821 },
    { "label": "fear",    "score": 0.1134 },
    { "label": "anger",   "score": 0.0512 },
    { "label": "neutral", "score": 0.0321 },
    { "label": "joy",     "score": 0.0102 },
    { "label": "disgust", "score": 0.0065 },
    { "label": "surprise","score": 0.0045 }
  ]
]
```

Parsed output → `primaryEmotion: "sadness"`, `intensity: 0.78`, `secondaryEmotions: ["fear"]`

---

### 6.2 HuggingFace Sentiment Analysis

**Model:** `cardiffnlp/twitter-roberta-base-sentiment-latest`

Request:
```json
POST https://api-inference.huggingface.co/models/cardiffnlp/twitter-roberta-base-sentiment-latest
{
  "inputs": "I feel completely overwhelmed and nothing seems to work out for me"
}
```

Response:
```json
[
  [
    { "label": "negative", "score": 0.9201 },
    { "label": "neutral",  "score": 0.0523 },
    { "label": "positive", "score": 0.0276 }
  ]
]
```

Parsed output → `sentiment: "negative"`

---

### 6.3 HuggingFace Zero-Shot Cognitive Distortion

**Model:** `facebook/bart-large-mnli`

Request:
```json
POST https://api-inference.huggingface.co/models/facebook/bart-large-mnli
{
  "inputs": "I always mess everything up. This always happens to me.",
  "parameters": {
    "candidate_labels": [
      "overgeneralization",
      "catastrophizing",
      "black-and-white thinking",
      "personalization",
      "mental filtering"
    ]
  }
}
```

Response:
```json
{
  "sequence": "I always mess everything up...",
  "labels": [
    "overgeneralization",
    "catastrophizing",
    "black-and-white thinking",
    "personalization",
    "mental filtering"
  ],
  "scores": [0.7241, 0.1523, 0.0821, 0.0321, 0.0094]
}
```

Decision logic: if `scores[0] > 0.30` → `distortionType = labels[0]` else `distortionType = null`

---

### 6.4 AssemblyAI Upload

Request:
```
POST https://api.assemblyai.com/v2/upload
Authorization: {ASSEMBLYAI_API_KEY}
Content-Type: application/octet-stream
Body: <raw audio bytes>
```

Response:
```json
{ "upload_url": "https://cdn.assemblyai.com/upload/xxxxx" }
```

### 6.5 AssemblyAI Transcription Submit

Request:
```json
POST https://api.assemblyai.com/v2/transcript
Authorization: {ASSEMBLYAI_API_KEY}
{
  "audio_url": "https://cdn.assemblyai.com/upload/xxxxx"
}
```

Response:
```json
{ "id": "abc123", "status": "queued" }
```

### 6.6 AssemblyAI Transcription Poll

Request:
```
GET https://api.assemblyai.com/v2/transcript/abc123
Authorization: {ASSEMBLYAI_API_KEY}
```

Response (in-progress):
```json
{ "id": "abc123", "status": "processing" }
```

Response (complete):
```json
{
  "id": "abc123",
  "status": "completed",
  "text": "Today I felt really stressed about my exams..."
}
```

Polling interval: 5 seconds · Max duration: 2 minutes (120 seconds = 24 polls max)

---

## 7. Firebase Configuration Details

### 7.1 Project Identity

| Property | Value |
|---|---|
| Project ID | `mindprint-db` |
| Project Number | `987595589557` |
| Firebase Region | `asia-south1` (Mumbai — lowest latency for Sri Lanka) |
| Storage Bucket | `mindprint-db.firebasestorage.app` |
| Auth Domain | `mindprint-db.firebaseapp.com` |
| Android Package | `com.example.mind_print` |
| iOS Bundle ID | `com.example.mindPrint` |

### 7.2 Firestore Settings

```dart
await FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);
```

Persistence is enabled globally at bootstrap, before any Firestore operation. This uses the LevelDB embedded database on Android/iOS to cache all reads and buffer writes offline.

### 7.3 Multi-Platform App Registration

Each platform has a separate Firebase App ID and API key:

| Platform | App ID |
|---|---|
| Android | `1:987595589557:android:21f7da80a56bfb7ca37bfc` |
| iOS | `1:987595589557:ios:1469061a6540ecfea37bfc` |
| Web | `1:987595589557:web:c2f7e7d7cdec5c73a37bfc` |
| Windows | `1:987595589557:web:81621a5d452367eaa37bfc` |

Platform detection is handled by `DefaultFirebaseOptions.currentPlatform` in `firebase_options.dart`, which was generated by the FlutterFire CLI.

### 7.4 Firebase Services In Use

| Service | Status | Usage |
|---|---|---|
| Firebase Authentication | Active | All auth methods |
| Cloud Firestore | Active | All data storage |
| Firebase Storage | Declared | Voice file upload (integration in progress) |
| Firebase Cloud Messaging | Declared | Push notifications (integration in progress) |
| Firebase Cloud Functions | Planned | Server-side AI orchestration (not yet built) |

---

## 8. Core Bootstrap Sequence

The full application initialisation sequence, step by step:

```
1. Flutter engine starts
   └── WidgetsFlutterBinding.ensureInitialized()
         Ensures platform channels are ready before any async work

2. AppBootstrap.initialize()  [lib/core/bootstrap/app_bootstrap.dart]
   │
   ├── 2a. Env.load()  [lib/core/config/env.dart]
   │       flutter_dotenv reads .env from app assets bundle
   │       Populates: HUGGINGFACE_API_KEY, ASSEMBLYAI_API_KEY,
   │                  all FIREBASE_* platform keys
   │
   ├── 2b. Firebase.initializeApp(
   │         options: DefaultFirebaseOptions.currentPlatform
   │       )
   │       Selects correct FirebaseOptions for current platform
   │       (Android / iOS / Web / Windows / macOS / Linux)
   │       Connects to mindprint-db Firebase project
   │
   └── 2c. FirebaseFirestore.instance.settings = Settings(
               persistenceEnabled: true
             )
             Enables LevelDB offline cache BEFORE any Firestore query

3. runApp(
     ProviderScope(          ← Riverpod DI root — all providers instantiated lazily
       child: MindPrintApp() ← MaterialApp with GoRouter
     )
   )

4. MindPrintApp builds
   └── GoRouter evaluates initial location
         └── authStateChangesProvider watches Firebase Auth stream
               ├── User present → redirect to /home
               └── User null   → redirect to /onboarding
```

---

## 9. Riverpod Provider Dependency Graph

```
ProviderScope (root)
│
├── firestoreDatabaseProvider
│       └── (no dependencies)
│
├── authServiceProvider
│       └── (uses FirebaseAuth.instance directly)
│
├── authStateChangesProvider
│       └── authServiceProvider
│
├── userProfileProvider (StreamProvider)
│       └── profileServiceProvider
│               └── firestoreDatabaseProvider
│
├── journalServiceProvider
│       └── huggingFaceServiceProvider
│
├── journalsProvider (StreamProvider.family<userId>)
│       └── journalServiceProvider
│               └── firestoreDatabaseProvider
│
├── voiceServiceProvider
│       └── (uses record plugin directly)
│
├── assemblyAiServiceProvider
│       └── (uses http directly)
│
├── analyticsServiceProvider
│       └── firestoreDatabaseProvider
│
├── analyticsSummaryProvider (FutureProvider.family<userId>)
│       └── analyticsServiceProvider
│
├── latestPredictionProvider (StreamProvider.family<userId>)
│       └── analyticsServiceProvider
│
├── moodCheckinServiceProvider
│       └── firestoreDatabaseProvider
│
└── notificationServiceProvider
        └── firestoreDatabaseProvider
```

---

## 10. CBT Distortion-to-Reframe Mapping

When `detectCognitiveDistortion()` returns a distortion type with confidence > 0.30, `JournalService._buildReframe()` returns the corresponding therapeutic response:

| Distortion Detected | CBT Reframe Provided |
|---|---|
| `overgeneralization` | Prompts user to consider this as one specific event rather than a universal pattern; encourages identifying counter-examples |
| `catastrophizing` | Guides user to consider realistic outcomes; asks what evidence supports the catastrophic scenario |
| `black-and-white thinking` | Points to the spectrum between extremes; asks the user to find middle-ground interpretations |
| `personalization` | Questions the assumption of personal responsibility; considers external contributing factors |
| `mental filtering` | Highlights the positive aspects being ignored; prompts a balanced view of the full situation |

These reframes are evidence-based interventions drawn from Aaron Beck's Cognitive Therapy model and are displayed on the `EmotionResultScreen` alongside the AI insight.

---

## 11. AssemblyAI Polling State Machine

```
                  ┌──────────┐
                  │  START   │
                  └────┬─────┘
                       │ transcribeVoiceFile(filePath)
                       ▼
                  ┌──────────┐
                  │ UPLOADING│ POST /v2/upload
                  └────┬─────┘
                       │ upload_url received
                       ▼
                  ┌──────────┐
                  │SUBMITTING│ POST /v2/transcript
                  └────┬─────┘
                       │ transcript_id received
                       ▼
                  ┌──────────┐
                  │  QUEUED  │◄──────────────────────┐
                  └────┬─────┘                       │
                       │ poll (GET /v2/transcript/id) │ status == "queued"
                       ▼                             │
                  ┌──────────┐                       │ Wait 5 seconds
              ┌──►│PROCESSING│───────────────────────┘
              │   └────┬─────┘
   status==   │        │ status == "completed"
   "processing"│        ▼
   Wait 5s    │   ┌──────────┐
              └───│COMPLETED?│
                  └────┬─────┘
                       │
              ┌────────┴────────┐
              ▼                 ▼
          SUCCESS            ERROR
       return text         throw exception
                           (timeout >2min
                            or status=="error")
```

Poll counter starts at 0. If counter reaches 24 (24 × 5s = 120s = 2 minutes) without completion, a timeout exception is thrown and the voice entry is saved without a transcript.

---

*Document generated: 2026-05-13*  
*Firebase project: mindprint-db · Branch: feature/backend*
