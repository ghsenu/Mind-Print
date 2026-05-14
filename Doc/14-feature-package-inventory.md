# MindPrint - Feature and Package Inventory

Date: 2026-05-13
Project: mind_print (Flutter)
Purpose: Data-gathering reference for current project reporting.

## 1) Scope and Method
This document was prepared from:
- `pubspec.yaml` (declared dependencies)
- `lib/features/**` and route wiring in `lib/app/router.dart`
- package imports detected across `lib/**/*.dart`

Notes:
- "Imported in code" means the package is currently referenced in source files.
- A package can still be useful even if not currently imported (for future work or pending integration).

## 2) Current Feature Inventory

### Core App and Architecture
- App bootstrap and startup error handling
- Firebase initialization and Firestore offline persistence setup
- Material app setup, theme, and named-route navigation
- Riverpod state management integrated at app root

Evidence files:
- `lib/main.dart`
- `lib/core/bootstrap/app_bootstrap.dart`
- `lib/app/app.dart`
- `lib/app/router.dart`

### Authentication and Onboarding
- Splash screen
- Onboarding screens
- Signup and login
- Forgot/reset password
- Phone authentication and OTP verification
- Post-signup congratulations flow
- Biometrics privacy screen and biometric service
- Auth provider and auth service

Primary files:
- `lib/features/auth/screens/*.dart`
- `lib/features/auth/providers/auth_provider.dart`
- `lib/features/auth/services/auth_service.dart`
- `lib/features/auth/services/biometric_service.dart`

### Home Dashboard
- Main home dashboard
- Mood check-in interaction
- Stress alert/insight card behavior
- Quick actions entry points to journal, activities, games, reports
- Bottom navigation UI component

Primary files:
- `lib/features/home/screens/home_screen.dart`
- `lib/features/home/services/mood_checkin_service.dart`
- `lib/features/shared/widgets/custom_bottom_nav.dart`

### Journal and Emotion Analysis
- Journal tab and journal detail flow
- Voice journal and voice record screens
- Emotion result screen
- Journal provider and journal service
- Voice service
- AssemblyAI and Hugging Face service integrations for analysis/transcription pipeline

Primary files:
- `lib/features/journal/screens/*.dart`
- `lib/features/journal/providers/journal_provider.dart`
- `lib/features/journal/services/*.dart`

### Analytics
- Analytics tab UI
- Analytics provider and service layer
- Prediction/insight model usage through shared models

Primary files:
- `lib/features/analytics/screens/analytics_tab.dart`
- `lib/features/analytics/providers/analytics_provider.dart`
- `lib/features/analytics/services/analytics_service.dart`

### Coping Toolkit and Activities
- Activities toolkit entry screen
- Breathing exercise screen
- Meditation screen
- CBT exercise screen
- Music therapy screen and player widget
- Audio service support for coping content

Primary files:
- `lib/features/coping/screens/*.dart`
- `lib/features/coping/services/audio_service.dart`
- `lib/features/coping/widgets/music_player.dart`

### Games and Interactive Relief
- Games hub screen
- Star Rain game
- Bubble Pop game
- Memory Match game
- Breathing Ball game

Primary files:
- `lib/features/games/screens/*.dart`
- `lib/features/games/widgets/game_card.dart`

### Notifications
- Notification list screen
- Notification details screen
- Notification provider and notification service
- Local + push notification integration points

Primary files:
- `lib/features/notifications/screens/*.dart`
- `lib/features/notifications/providers/notification_provider.dart`
- `lib/features/notifications/services/notification_service.dart`

### Profile and Settings
- Edit profile screen
- Profile service
- Settings screen

Primary files:
- `lib/features/profile/screens/edit_profile_screen.dart`
- `lib/features/profile/services/profile_service.dart`
- `lib/features/settings/screens/settings_screen.dart`

### Reports and Export
- Export/report screen for user journey output

Primary file:
- `lib/features/reports/screens/export_screen.dart`

### Chatbot Module (UI Present)
- Chatbot screen UI exists
- Not currently wired in named routes from `appRoutes`

Primary file:
- `lib/features/chatbot/screens/chatbot_screen.dart`

### Shared Domain and Utilities
- Shared models: journal entry, emotion result, mood checkin, prediction, notification item, user profile
- Shared providers: connectivity and user profile
- Shared widgets: buttons, indicators, placeholders
- Route name constants and validators

Primary files:
- `lib/features/shared/models/*.dart`
- `lib/features/shared/providers/*.dart`
- `lib/features/shared/widgets/*.dart`
- `lib/features/shared/constants/route_names.dart`
- `lib/features/shared/utils/validators.dart`

## 3) Route Inventory (Named Routes)
Current routes defined in `lib/features/shared/constants/route_names.dart` and wired in `lib/app/router.dart` include:
- `/` (splash)
- `/onboarding`
- `/login`
- `/signup`
- `/congratulations`
- `/biometrics-privacy`
- `/forgot-password`
- `/reset-password`
- `/phone-auth`
- `/otp`
- `/onboarding-questionnaire`
- `/home`
- `/notifications`
- `/journal`
- `/analytics`
- `/coping`
- `/reports`
- `/settings`
- `/edit-profile`
- `/games`
- `/games/star-rain`
- `/games/bubble-pop`
- `/games/memory-match`
- `/games/breathing-ball`
- `/activities/breathing`
- `/activities/music`
- `/activities/meditation`
- `/activities/cbt`

## 4) Package Inventory (from pubspec.yaml)

### Runtime Dependencies
| Package | Version | Imported in code now | Typical usage in this project |
|---|---:|---|---|
| cupertino_icons | ^1.0.8 | No direct import found | iOS-style icons support |
| firebase_core | ^3.9.0 | Yes | Firebase initialization |
| cloud_firestore | ^5.6.0 | Yes | Firestore database and persistence |
| flutter_dotenv | ^5.1.0 | Yes | Environment variable loading |
| flutter_svg | ^2.0.10 | No direct import found | SVG rendering (available for UI assets) |
| local_auth | ^2.2.0 | Yes | Biometric authentication |
| firebase_auth | ^5.3.4 | Yes | User authentication |
| google_sign_in | ^6.2.1 | Yes | Google sign-in flow |
| flutter_riverpod | ^2.4.9 | Yes | State management |
| google_fonts | ^6.2.1 | Yes | Typography and font theming |
| image_picker | ^1.1.2 | Yes | Image/media selection |
| http | ^1.2.2 | Yes | API/network requests |
| record | ^5.1.2 | Yes | Audio recording |
| permission_handler | ^11.3.1 | Yes | Runtime permission handling |
| path_provider | ^2.1.4 | Yes | Local file/directory paths |
| just_audio | ^0.10.5 | Yes | Audio playback |
| firebase_messaging | ^15.2.10 | Yes | Push notifications |
| flutter_local_notifications | ^19.5.0 | Yes | Local notifications |
| timezone | ^0.10.1 | Yes | Timezone-aware notification scheduling |

### Dev Dependencies
| Package | Version | Purpose |
|---|---:|---|
| flutter_test | sdk | Widget/unit testing |
| flutter_lints | ^5.0.0 | Lint rules and code quality |

## 5) Summary for Project Report
- Feature modules currently implemented: auth, home, journal, analytics, coping, games, notifications, profile, reports, settings, shared, and chatbot UI.
- Route-driven user flow is active for core modules (auth, home, journal, analytics, coping, reports, settings, games, notifications, profile edit).
- Most declared runtime dependencies are actively imported in source.
- Packages declared but not currently imported: `cupertino_icons`, `flutter_svg`.

## 6) Suggested Update Process
When you need to refresh this report later:
1. Re-scan `pubspec.yaml` for dependency/version changes.
2. Re-scan `lib/features/**` and `lib/app/router.dart` for feature/route additions.
3. Re-run import scan across `lib/**/*.dart` to verify package usage status.
