# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-01**
System Architecture
Three-Tier Modular Design with API-Based AI Integration

Student: Gihansa S Buwanayake
Index Number: 10952999
Supervisor: Dr. Rasika Ranaweera
Programme: BSc (Hons) Software Engineering — NSBM Green University
Module: PUSL3190 Computing Project

# 1. Architecture Overview
MindPrint follows a three-tier modular architecture that separates the Presentation Layer, Business Logic Layer, and Data & Services Layer. This design ensures scalability, maintainability, security, and independent component updates without affecting other layers.

## 1.1 Architecture Principles
Separation of Concerns — each tier has a single, well-defined responsibility
Offline-First — Firestore offline persistence ensures full functionality without internet
Security-by-Design — biometric auth, encryption, and scoped access rules at every layer
API-First AI — all machine learning capabilities consumed as REST APIs (no self-hosted models)
Modular & Extensible — AI components can be swapped independently

# 2. Three-Tier Architecture
## 2.1 Tier 1 — Presentation Layer (Flutter)
The Flutter mobile application delivers the user interface across Android from a single Dart codebase. All screens are organized by feature module and state is managed via Riverpod providers.

| Component | Technology | Responsibility |
|---|---|---|
| UI Framework | Flutter (Dart) | Cross-platform screen rendering |
| State Management | Riverpod | Reactive data flow, provider-based architecture |
| Navigation | GoRouter | Declarative routing, deep link support |
| Local Auth | local_auth package | Biometric (Face ID / Fingerprint) integration |
| Audio Recording | record package | Voice journal capture and waveform display |
| PDF Generation | pdf + printing packages | Client-side report generation and export |
| Offline Cache | Firestore SDK (offline mode) | Automatic local persistence and sync |

## 2.2 Tier 2 — Business Logic Layer (Firebase Cloud Functions)
Firebase Cloud Functions (Node.js runtime) serve as the serverless backend, handling AI API orchestration, data processing, scheduled notification tasks, and business logic that must not reside on the client device.

| Function Name | Trigger | Responsibility |
|---|---|---|
| analyzeTextEntry | HTTP POST (Firestore write) | Calls HuggingFace NLP API, stores emotion result |
| analyzeVoiceEntry | HTTP POST (Storage upload) | Calls AssemblyAI for transcription + SER |
| generateMoodPrediction | Scheduled (daily) | Calculates 48hr mood forecast from history |
| sendDailyAffirmation | Scheduled (08:00 daily) | Sends FCM push notification with affirmation |
| sendJournalReminder | Scheduled (19:00 daily) | Sends reminder if no entry logged today |
| generateReport | HTTP POST | Compiles journal data for PDF/CSV export |
| detectCognitiveDistortion | Called by analyzeTextEntry | Pattern matching + HuggingFace classification |

## 2.3 Tier 3 — Data & Services Layer
The data layer comprises Firebase backend services and external AI APIs. All data is stored in Cloud Firestore with user-scoped security rules. Voice recordings and exported reports are stored in Firebase Storage.

| Service | Provider | Data Handled |
|---|---|---|
| Authentication | Firebase Auth | User identity, session tokens, Google Sign-In |
| NoSQL Database | Cloud Firestore | Profiles, journals, emotions, predictions, notifications |
| File Storage | Firebase Storage | Voice recordings (.m4a), exported PDFs/CSVs |
| Push Notifications | Firebase Cloud Messaging | Scheduled alerts, predictive warnings, reminders |
| NLP API | HuggingFace Inference API | Text emotion classification, distortion detection |
| SER + STT API | AssemblyAI API | Voice transcription and emotion recognition |

# 3. Component Interaction Flow
## 3.1 Text Journal Analysis Flow
User writes journal entry in Flutter UI
Riverpod JournalNotifier calls Firebase Cloud Function: analyzeTextEntry
Cloud Function sends text payload to HuggingFace Inference API
HuggingFace returns emotion labels with confidence scores
Cloud Function detects cognitive distortions via pattern matching
Results written to Firestore: journals/{userId}/{entryId}/emotionResult
Riverpod listener triggers UI update — Emotion Result Screen displays

## 3.2 Voice Journal Analysis Flow
User records voice entry — audio saved locally via record package
On stop: audio file uploaded to Firebase Storage
Storage trigger fires Cloud Function: analyzeVoiceEntry
Cloud Function submits audio URL to AssemblyAI for transcription + SER
AssemblyAI returns transcript text + emotion scores
Transcript and emotion results written to Firestore
Riverpod listener updates UI — Emotion Result Screen displays

## 3.3 Mood Prediction Flow
Scheduled Cloud Function runs daily
Reads last 7 days of emotion scores from Firestore for user
Calculates trend: average, variance, direction of change
If downward trend detected: flags as predicted dip
Prediction document written to Firestore: predictions/{userId}/latest
If dip predicted: FCM push notification sent to device
Home Dashboard and Analytics tab display alert banner

# 4. Security Architecture

| Security Concern | Implementation |
|---|---|
| User Authentication | Firebase Auth with JWT tokens; biometric via local_auth |
| Data at Rest | AES-256 encryption for local Firestore cache |
| Data in Transit | HTTPS / TLS 1.2+ for all API calls |
| Database Access Control | Firestore Security Rules: users read/write own documents only |
| File Access Control | Firebase Storage Rules: user-scoped paths only |
| API Key Security | HuggingFace and AssemblyAI keys stored as Cloud Function environment variables — never in client code |
| Biometric Fallback | PIN/Password fallback if biometric fails |
| Session Management | Firebase Auth persistent session with token refresh |

# 5. Offline Architecture
MindPrint is built offline-first using Firestore's built-in offline persistence. When the device has no internet connection:
All read and write operations are served from local Firestore cache
Journal entries, mood check-ins, and settings changes are queued locally
An offline banner is displayed on the Home screen
AI analysis (NLP/SER) is queued and processed when connectivity returns
On reconnection, Firestore automatically syncs all pending writes to the server
A sync confirmation notification is displayed after successful sync
