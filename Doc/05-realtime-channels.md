# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-05**
Realtime Channels
Firestore Live Listeners, Data Sync & Push Notification Channels


# 1. Overview
MindPrint uses Firestore real-time listeners (onSnapshot) and Firebase Cloud Messaging (FCM) to deliver live data updates to the Flutter UI without manual polling. This ensures the app always reflects the latest state immediately after server-side processing completes.

# 2. Firestore Real-Time Listeners
## 2.1 Listener Architecture
Firestore listeners are established using Riverpod StreamProviders. Each provider subscribes to a Firestore collection or document and automatically rebuilds the associated Flutter widget tree when data changes. Listeners are lifecycle-aware — they are activated when a screen is mounted and disposed when the screen is removed.

| Riverpod Provider | Firestore Path Listened | Triggers UI Update On |
|---|---|---|
| journalListProvider | users/{uid}/journals (collection) | New journal saved, analysis complete |
| journalDetailProvider | users/{uid}/journals/{id}/emotionResult (collection) | AI analysis result arrives |
| notificationProvider | users/{uid}/notifications (collection) | New notification created by Cloud Function |
| predictionProvider | users/{uid}/predictions/latest (document) | Daily mood prediction updated |
| moodCheckinProvider | users/{uid}/moodCheckins (collection) | New mood check-in saved |
| userProfileProvider | users/{uid} (document) | Profile or settings updated |

## 2.2 Journal Analysis Real-Time Flow
This is the most critical real-time channel in the app — it drives the post-journal analysis experience:
User taps "Save & Analyze" on text journal entry
Flutter writes journal document to Firestore (isAnalyzed: false)
Flutter calls Cloud Function analyzeTextEntry (HTTP POST)
Loading state shown in UI — Riverpod provider is in loading state
Cloud Function completes analysis and writes to Firestore emotionResult sub-collection
Firestore onSnapshot listener in journalDetailProvider fires
Riverpod rebuilds Emotion Analysis Result Screen automatically
User sees results — no manual refresh needed

## 2.3 Notification Real-Time Channel
The in-app notification screen displays live notifications using a Firestore listener on the notifications collection:
Cloud Function creates a new notification document in Firestore
notificationProvider (StreamProvider) receives the onSnapshot event
Bell icon badge count updates immediately on Home screen
User taps bell — Notifications Screen shows updated list
User taps a notification — marked as isRead: true in Firestore
App navigates to the relevant deep-link target screen

## 2.4 Mood Prediction Real-Time Channel
The Home Dashboard and Analytics tab display a predictive alert banner when a mood dip is detected:
generateMoodPrediction Cloud Function runs daily and writes to predictions/{userId}/latest
predictionProvider listener receives update
If dipPredicted = true: alert banner appears on Home Dashboard
Analytics tab Mood Prediction Screen updates with new chart data
Alert remains visible until user dismisses or next prediction overwrites it

# 3. Firebase Cloud Messaging (Push Notifications)
## 3.1 Push Notification Channels

| Channel ID | Channel Name | Type | Schedule |
|---|---|---|---|
| mindprint_affirmations | Daily Affirmations | Scheduled | Every day 08:00 |
| mindprint_reminders | Journal Reminders | Conditional Scheduled | Every day 19:00 (if no entry) |
| mindprint_alerts | Mood Alerts | Event-triggered | When mood dip predicted |
| mindprint_sync | Sync Notifications | Event-triggered | When offline sync completes |

## 3.2 Push Notification Handling in Flutter
App initialized — firebase_messaging.getToken() retrieves FCM device token
FCM token saved to Firestore: users/{uid}/fcmToken
Cloud Functions use this token to send targeted notifications
flutter_local_notifications displays notification when app is in foreground
When app is in background: system tray notification shown by FCM
User taps notification: FirebaseMessaging.onMessageOpenedApp stream fires
App reads notification.data.deepLink and navigates to target screen

# 4. Offline Sync Channel
## 4.1 Firestore Offline Persistence
Firestore SDK handles offline sync automatically with no additional code required. The sync channel works as follows:
Device loses internet connection
Firestore SDK detects offline state — switches to local cache
All reads served from cache — UI continues to work normally
All writes queued in Firestore pending writes queue
App displays offline banner via connectivity_plus package listener
Internet connection restored — Firestore automatically flushes pending writes
Server acknowledges writes — local cache updated with server state
Sync complete notification created in Firestore notifications collection
notificationProvider listener fires — sync confirmation shown in app

## 4.2 AI Analysis Offline Behaviour

| Scenario | Behaviour |
|---|---|
| Journal saved offline | Entry saved to Firestore cache with isAnalyzed: false |
| Cloud Function call fails (no internet) | Flutter retries Cloud Function call when connectivity restored |
| Analysis completes after reconnection | emotionResult written to Firestore, listener fires, UI updates |
| Voice recording offline | Audio file cached locally — uploaded to Storage on reconnection |
