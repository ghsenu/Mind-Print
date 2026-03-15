# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-07**
Data Flow
End-to-End Data Journey Through the MindPrint System


# 1. Data Flow Overview
This document describes how data moves through MindPrint from user input to storage, AI analysis, and UI display. All data flows are designed to be privacy-preserving, offline-resilient, and asynchronous to ensure a seamless user experience.

# 2. Text Journal Data Flow

| Step | Action | Layer |
|---|---|---|
| 1 | User writes journal entry text and selects mood in Flutter UI | Presentation |
| 2 | Riverpod JournalNotifier.saveEntry() called | Presentation |
| 3 | Journal document written to Firestore (isAnalyzed: false) | Firestore |
| 4 | HTTP POST sent to Cloud Function: analyzeTextEntry with { userId, journalId, textContent } | Business Logic |
| 5 | Cloud Function calls HuggingFace emotion classification API | External AI API |
| 6 | Cloud Function calls HuggingFace sentiment API (secondary) | External AI API |
| 7 | Cloud Function calls zero-shot classifier for cognitive distortion detection | External AI API |
| 8 | Emotion scores mapped to display labels by emotionMapper utility | Business Logic |
| 9 | Hashtags generated from top emotion + content keywords | Business Logic |
| 10 | emotionResult sub-document written to Firestore | Firestore |
| 11 | Journal document updated: isAnalyzed = true | Firestore |
| 12 | Firestore onSnapshot listener in journalDetailProvider fires in Flutter | Presentation |
| 13 | Emotion Analysis Result Screen displays to user | Presentation |

# 3. Voice Journal Data Flow

| Step | Action | Layer |
|---|---|---|
| 1 | User records voice entry — audio captured by record Flutter package | Presentation |
| 2 | User taps Stop — audio file (.m4a) saved to device temp storage | Presentation |
| 3 | Audio file uploaded to Firebase Storage: voice/{userId}/{journalId}.m4a | Firebase Storage |
| 4 | Storage onCreate trigger fires Cloud Function: analyzeVoiceEntry | Business Logic |
| 5 | Cloud Function generates signed URL for audio file | Firebase Storage |
| 6 | Audio URL submitted to AssemblyAI transcription API | External AI API |
| 7 | Cloud Function polls AssemblyAI every 3 seconds until complete | External AI API |
| 8 | AssemblyAI returns: transcript text + per-sentence sentiment scores | External AI API |
| 9 | Transcript text passed to HuggingFace emotion classification | External AI API |
| 10 | Results merged: AssemblyAI sentiment + HuggingFace emotions | Business Logic |
| 11 | Journal document updated with transcript text, emotionResult written | Firestore |
| 12 | Riverpod listener fires — Emotion Result Screen displays | Presentation |

# 4. Mood Prediction Data Flow

| Step | Action | Layer |
|---|---|---|
| 1 | Scheduled Cloud Function runs daily at midnight | Business Logic |
| 2 | Iterates all users with onboardingCompleted = true | Firestore |
| 3 | Reads last 7 days of moodCheckins (moodScore 1–4) | Firestore |
| 4 | Reads last 7 days of emotionResult primaryIntensity values | Firestore |
| 5 | Calculates daily weighted average of mood + emotion scores | Business Logic |
| 6 | Calculates trend slope across the 7-day series | Business Logic |
| 7 | If slope < threshold and latest score < 2.0: dipPredicted = true | Business Logic |
| 8 | Prediction document written to predictions/{userId}/latest | Firestore |
| 9 | predictionProvider listener fires — Home Dashboard alert banner updates | Presentation |
| 10 | If dipPredicted: sendMoodAlert called — FCM notification sent to device | FCM |

# 5. Notification Data Flow

| Step | Action | Layer |
|---|---|---|
| 1 | Cloud Function (scheduled or triggered) prepares notification content | Business Logic |
| 2 | FCM token retrieved from Firestore: users/{uid}/fcmToken | Firestore |
| 3 | FCM API called with token, title, body, and deepLink data | FCM |
| 4 | Device receives FCM message | Device OS |
| 5 | Notification document created in Firestore: users/{uid}/notifications | Firestore |
| 6 | notificationProvider onSnapshot fires — bell badge updates in UI | Presentation |
| 7 | User taps push notification — app opens to deepLink target screen | Presentation |
| 8 | User views in-app notification — isRead: true written to Firestore | Firestore |

# 6. Export Report Data Flow

| Step | Action | Layer |
|---|---|---|
| 1 | User selects date range and format (PDF/CSV) on Export Screen | Presentation |
| 2 | Flutter calls Cloud Function: generateReport with { userId, startDate, endDate, format } | Business Logic |
| 3 | Cloud Function queries Firestore for journals and emotionResults in date range | Firestore |
| 4 | Data compiled into structured report format | Business Logic |
| 5 | For PDF: data returned to Flutter — pdf package generates file on device | Presentation |
| 6 | For CSV: Cloud Function generates CSV string — returned as response | Business Logic |
| 7 | File saved to device storage via path_provider + flutter_file_picker | Presentation |
| 8 | Report metadata saved to Firestore: users/{uid}/reports | Firestore |
| 9 | User can share file via share_plus package (e.g. email to therapist) | Presentation |

# 7. Offline Data Flow

| Scenario | Data Handling |
|---|---|
| No internet — journal written | Firestore SDK caches write locally — queued for sync |
| No internet — journal read | Served from Firestore local cache — no visible difference to user |
| No internet — Cloud Function call | Flutter catches network error — shows "Analysis pending" state |
| Internet restored | Firestore flushes pending writes — server acknowledges |
| Cloud Function retried | Flutter detects isAnalyzed: false on journal — retries analysis call |
| Voice upload pending | Firebase Storage resumes upload automatically on reconnection |
| Sync complete | Cloud Function creates sync notification in Firestore |
