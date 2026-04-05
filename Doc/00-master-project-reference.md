# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-00**
Master Project Reference
Complete Technical Overview & Document Index


# 1. Project Overview
MindPrint is an AI-powered mental health awareness mobile application designed for Sri Lankan undergraduate students. The application integrates multimodal emotional analysis, predictive mood forecasting, and privacy-secured self-care interventions through a Flutter-based Android mobile application backed by Firebase cloud services and pre-trained AI APIs.

## 1.1 Application Identity

| Property | Value |
|---|---|
| Application Name | MindPrint |
| Tagline | Understand your emotions one moment at a time |
| Platform | Android (Flutter) |
| Primary Language | English (Sinhala & Tamil UI — future) |
| Target Users | Sri Lankan undergraduate students |
| Version (MVP) | 1.0.0 |

## 1.2 Technology Stack Summary

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter (Dart) | Cross-platform Android UI |
| State Management | Riverpod | Reactive state across the app |
| Authentication | Firebase Auth | Email, Google, Biometric login |
| Database | Cloud Firestore | User data, journals, emotions |
| File Storage | Firebase Storage | Voice recordings, PDF reports |
| Push Notifications | Firebase Cloud Messaging (FCM) | Reminders, alerts, affirmations |
| NLP Analysis | HuggingFace Inference API | Text emotion & sentiment detection |
| Voice Transcription | AssemblyAI API | Speech-to-text conversion |
| Voice Emotion (SER) | AssemblyAI API | Emotion detection from audio |
| Biometric Auth | local_auth (Flutter package) | Face ID / Fingerprint login |
| PDF Export | pdf (Flutter package) | Therapist-ready reports |
| Offline Storage | Firestore Offline Persistence | Cache & sync when reconnected |

# 2. Document Index
All project documentation is organized as follows:

| Doc # | Document Name | Description |
|---|---|---|
| DOC-00 | Master Project Reference | This document — full overview and index |
| DOC-01 | System Architecture | Three-tier architecture, component diagram |
| DOC-02 | Database Schema | Firestore collections, fields, relationships |
| DOC-03 | API Endpoints | HuggingFace, AssemblyAI, FCM API reference |
| DOC-04 | Backend Structure | Firebase Cloud Functions, server logic |
| DOC-05 | Realtime Channels | Firestore listeners, live data flows |
| DOC-06 | Auth Flow | Registration, login, biometric, password reset |
| DOC-07 | Data Flow | End-to-end data journey through the system |
| DOC-08 | Flutter App Structure | Folder structure, screens, Riverpod providers |
| DOC-09 | Sprint Timeline | Phase-based development plan |
| DOC-10 | Production Readiness | Security, testing, deployment checklist |

# 3. Confirmed Features (MVP Scope)
## 3.1 Core Features
Onboarding walkthrough (3 slides: Privacy, Features, Security)
User registration with email / Google Sign-In
Language selection (English / Sinhala / Tamil UI toggle)
Biometric authentication (Face ID / Fingerprint via local_auth)
Onboarding questionnaire (4 questions for baseline mood data)
Firebase email password reset

## 3.2 Journaling
Text journaling with free-text entry and mood selection
Voice journaling with real-time waveform visualization
HuggingFace NLP API — sentiment and emotion analysis from text
AssemblyAI API — transcription and SER from voice recordings
Emotion Analysis Result screen (primary emotion, intensity %, secondary emotions, AI insight)
CBT reframing suggestions when cognitive distortion is detected
Journal history with search and monthly grouping
Journal detail screen with emotion table, MindPrint reflection, hashtags

## 3.3 Analytics & Insights
Emotional Fingerprint visualization (longitudinal emotional identity)
Mood Timeline Chart (daily / weekly / monthly views)
Mood Prediction Screen (next 48-hour rhythm based on historical data)
Predictive alert banner and push notification when mood dip detected
Cognitive / Reflective Patterns screen (trends from journal entries)

## 3.4 Coping Toolkit
Breathing exercises (4-7-8, box breathing)
Meditation sessions
Mindful focus exercises
5-4-3-2-1 grounding technique
Subliminal / ambient music player (emotion-matched)
CBT exercise module (thought records, reframing)

## 3.5 Notifications
In-app notification screen (bell icon on Home)
Push notification types: daily affirmation (8am), journal reminder (7pm if no entry), predictive mood alert

## 3.6 Reports & Settings
Export report (PDF or CSV) with date range selection
Report preview before export
Settings: Language, Biometrics, Notifications, Offline Sync
Privacy & Security settings
Help Center, Privacy Policy, About screen
Log Out

## 3.7 Offline & Sync
Full offline journaling via Firestore offline persistence
AES-256 encrypted local cache
Automatic intelligent sync when internet is restored
Offline mode banner when no connection detected

# 4. Features Explicitly Out of Scope (MVP)
Wearable biometric integration (heart-rate sensors)
Community or social networking features
Custom ML model training (using pre-trained APIs instead)
Gamification: achievement badges, coins, shop
Full Sinhala / Tamil content translation (UI toggle only for now)

# 5. Bottom Navigation Structure

| Tab | Icon | Destination |
|---|---|---|
| Journal | Book icon | Journal entry + history |
| Analytics | Chart icon | Emotional Fingerprint, mood prediction, patterns |
| Coping | Toolbox icon | Toolkit exercises, music, CBT |
| Reports | Document icon | Export journey, PDF/CSV generation |
| Settings | Gear icon | Preferences, security, account |

# 6. AI Integration Strategy
MindPrint uses hosted API-based inference rather than self-deployed machine learning models. This architectural decision reduces infrastructure complexity, eliminates cold-start latency issues in Cloud Functions, and maintains focus on application-layer engineering — which is the core contribution of this software engineering project.

| AI Feature | Provider | Method |
|---|---|---|
| Text emotion & sentiment analysis | HuggingFace Inference API | REST POST to classification endpoint |
| Voice transcription (STT) | AssemblyAI API | Audio file upload + polling |
| Voice emotion recognition (SER) | AssemblyAI API | Sentiment analysis on transcription + audio features |
| Mood prediction / forecasting | Rule-based trend analysis | Last 7-day emotion scores → 48hr projection |
| Cognitive distortion detection | HuggingFace NLP + keyword patterns | Combined classification + pattern matching |
| MindPrint reflection insight | HuggingFace text generation | Personalized insight from emotion context |

# 7. Security Architecture Summary
Biometric authentication via Flutter local_auth package (Face ID / Fingerprint)
Firebase Auth token-based session management
AES-256 encryption for all locally cached data
HTTPS-only API communication (TLS 1.2+)
Firestore Security Rules — users can only access their own documents
Voice recordings stored in Firebase Storage with user-scoped access rules
No third-party analytics SDKs with access to journal content
