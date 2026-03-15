# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-08**
Flutter App Structure
Project Architecture, Screen Inventory & Riverpod State Management


# 1. Flutter Project Overview

| Property | Value |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Min SDK (Android) | API 21 (Android 5.0+) |
| Target Platform | Android only |
| State Management | Riverpod (flutter_riverpod) |
| Navigation | GoRouter |
| Architecture Pattern | Feature-first folder structure with Riverpod providers |

# 2. Folder Structure
lib/
main.dart — app entry point, Firebase initialization, Riverpod ProviderScope
app/
router.dart — GoRouter route definitions for all screens
theme.dart — app color scheme, text styles, dark/light theme
features/
auth/
screens/ — splash, onboarding, signup, login, biometric_setup, questionnaire
providers/ — authProvider, userProfileProvider
services/ — auth_service.dart (wraps Firebase Auth)
home/
screens/ — home_screen.dart, notification_screen.dart
providers/ — homeProvider, notificationProvider
journal/
screens/ — journal_tab, text_entry, voice_recorder, emotion_result, history, detail
providers/ — journalProvider, emotionResultProvider
services/ — journal_service.dart, nlp_service.dart, voice_service.dart
analytics/
screens/ — analytics_tab, fingerprint_screen, prediction_screen, patterns_screen
providers/ — analyticsProvider, predictionProvider
coping/
screens/ — toolkit_screen, breathing_screen, meditation_screen, music_player, cbt_screen
providers/ — toolkitProvider
reports/
screens/ — export_screen, report_preview_screen
services/ — report_service.dart (PDF/CSV generation)
settings/
screens/ — settings_screen, privacy_screen, help_screen, about_screen
providers/ — settingsProvider
shared/
widgets/ — reusable UI components (emotion_chip, mood_selector, waveform_display)
models/ — JournalEntry, EmotionResult, MoodPrediction, UserProfile data classes
utils/ — date_formatter, emotion_mapper, connectivity_checker
constants/ — app_colors, api_constants, route_names

# 3. Screen Inventory

| Screen | Route | Feature Module |
|---|---|---|
| Splash Screen | /splash | auth |
| Onboarding Slide 1 (Privacy) | /onboarding/1 | auth |
| Onboarding Slide 2 (Features) | /onboarding/2 | auth |
| Onboarding Slide 3 (Security) | /onboarding/3 | auth |
| Sign Up Screen | /signup | auth |
| Login Screen | /login | auth |
| Language Selection | /language | auth |
| Permissions Screen | /permissions | auth |
| Biometric Setup | /biometric-setup | auth |
| Onboarding Questionnaire | /questionnaire | auth |
| Forgot Password | /forgot-password | auth |
| Home Dashboard | /home | home |
| Notifications Screen | /notifications | home |
| Journal Tab | /journal | journal |
| Text Journal Entry | /journal/text | journal |
| Voice Journal Recorder | /journal/voice | journal |
| Emotion Analysis Result | /journal/result/:id | journal |
| Journal History | /journal/history | journal |
| Journal Detail | /journal/detail/:id | journal |
| Analytics Tab | /analytics | analytics |
| Emotional Fingerprint | /analytics/fingerprint | analytics |
| Mood Prediction | /analytics/prediction | analytics |
| Cognitive Patterns | /analytics/patterns | analytics |
| Coping Toolkit | /coping | coping |
| Breathing Exercise | /coping/breathing | coping |
| Meditation Screen | /coping/meditation | coping |
| Mindful Focus | /coping/focus | coping |
| Subliminal Music Player | /coping/music | coping |
| CBT Exercise | /coping/cbt | coping |
| Progress Overview | /progress | analytics |
| Reports Tab | /reports | reports |
| Export Journey | /reports/export | reports |
| Report Preview | /reports/preview | reports |
| Settings Screen | /settings | settings |
| Privacy & Security | /settings/privacy | settings |
| Help Center | /settings/help | settings |
| Privacy Policy | /settings/policy | settings |
| About MindPrint | /settings/about | settings |

# 4. Riverpod Providers

| Provider | Type | State Managed |
|---|---|---|
| authProvider | StreamProvider | Firebase Auth user state (logged in / out) |
| userProfileProvider | FutureProvider | User profile document from Firestore |
| journalListProvider | StreamProvider | Real-time list of journal entries |
| journalDetailProvider | StreamProvider | Single journal + emotion result (live) |
| emotionResultProvider | StateNotifierProvider | Loading/success/error state for analysis |
| predictionProvider | StreamProvider | Live mood prediction document |
| notificationProvider | StreamProvider | Live notification list + unread count |
| moodCheckinProvider | StateNotifierProvider | Today's mood check-in state |
| analyticsProvider | FutureProvider | Aggregated emotion history for charts |
| settingsProvider | StateNotifierProvider | Language, biometrics, notification prefs |
| connectivityProvider | StreamProvider | Online/offline state via connectivity_plus |
| toolkitProvider | StateNotifierProvider | Active toolkit session state |

# 5. Key Flutter Packages

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.x | State management |
| go_router | ^13.x | Declarative navigation |
| firebase_core | ^2.x | Firebase initialization |
| firebase_auth | ^4.x | Authentication |
| cloud_firestore | ^4.x | Database + offline persistence |
| firebase_storage | ^11.x | Voice file uploads |
| firebase_messaging | ^14.x | Push notifications |
| local_auth | ^2.x | Biometric authentication |
| record | ^5.x | Voice recording |
| just_audio | ^0.9.x | Audio playback for music player |
| pdf | ^3.x | PDF report generation |
| share_plus | ^7.x | File sharing |
| connectivity_plus | ^5.x | Online/offline detection |
| fl_chart | ^0.66.x | Mood timeline and analytics charts |
| intl | ^0.18.x | Date formatting and localisation |
| shared_preferences | ^2.x | Local app preferences storage |
