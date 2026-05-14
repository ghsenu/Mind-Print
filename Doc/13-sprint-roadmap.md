# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-13**
> Sprint Roadmap — Status & Remaining Work
> Reference Date: May 2026



# 1. Overview

MindPrint follows an Agile methodology with 8 two-week sprints across 6 phases. This document shows each sprint's original deliverables, current completion status, and what work remains to reach the sprint's acceptance criteria.

| Property | Value |
|---|---|
| Methodology | Agile, 2-week sprints |
| Total Sprints | 8 |
| Total Duration | 16 weeks |
| Sprint Length | 2 weeks |
| Review Cadence | End of each sprint |

---

# 2. Sprint Status Key

| Symbol | Meaning |
|---|---|
| COMPLETE | All deliverables built and acceptance criteria met |
| PARTIAL | Deliverables partially built — remaining work listed |
| NOT STARTED | No implementation done for this sprint's scope |

---

# 3. Sprint Details

---

## Sprint 1 — Foundation
**Phase:** Foundation | **Duration:** Weeks 1–2 | **Status: COMPLETE**

### Deliverables
- Firebase project setup and Flutter project scaffold
- Feature-first folder architecture (`lib/features/`)
- Riverpod state management wired
- GoRouter navigation configured
- Firebase Auth integration (email/password)
- Firestore security rules baseline

### Acceptance Criteria
User can register, log in, and log out. Firebase connection verified.

### Outcome
All deliverables complete. Firebase Auth works with email/password. App bootstraps with offline persistence. Feature folder structure in place. 25+ routes configured in GoRouter.

---

## Sprint 2 — Onboarding
**Phase:** Foundation | **Duration:** Weeks 3–4 | **Status: COMPLETE**

### Deliverables
- Onboarding walkthrough (3 slides: Privacy, Features, Security)
- Sign Up and Login screens
- Language selection screen
- Permissions screen
- Biometric setup screen (Face ID / Fingerprint via `local_auth`)
- Onboarding questionnaire (4 mood baseline questions)
- Splash screen
- Phone + OTP authentication
- Google Sign-In
- Forgot password / reset password flow

### Acceptance Criteria
Full first-time onboarding flow navigable end-to-end. User data saved to Firestore.

### Outcome
All 9 auth/onboarding screens built and wired. Firebase Auth covers email, Google, phone, and biometric paths. `UserProfile` document created in Firestore on registration.

---

## Sprint 3 — Text Journaling & NLP Analysis
**Phase:** Core Journaling | **Duration:** Weeks 5–6 | **Status: COMPLETE**

### Deliverables
- Home Dashboard (mood check-in widget, navigation)
- Text journal entry screen (free-text + mood selector 1–5)
- Save & Analyze flow
- HuggingFace NLP API integration (emotion + sentiment + cognitive distortion)
- Journal entry saved to Firestore
- Emotion Result screen (primary emotion, intensity, secondary emotions, AI insight, CBT reframe)

### Acceptance Criteria
User can write a journal entry, trigger analysis, and see emotion result. API returns valid scores.

### Outcome
Fully working. HuggingFace runs 3 parallel API calls with auto-retry on 503. EmotionResult stored in Firestore. CBT reframing triggers when distortion detected. Journal history streams from Firestore via Riverpod `StreamProvider`.

---

## Sprint 4 — Voice Journaling & Storage
**Phase:** Core Journaling | **Duration:** Weeks 7–8 | **Status: COMPLETE**

### Deliverables
- Voice recording screen (waveform UI, timer)
- AssemblyAI API integration (transcription direct upload — no Firebase Storage required)
- Voice emotion result screen
- Journal history with search and monthly grouping
- Journal detail screen

### Acceptance Criteria
User can record voice, transcript is generated, emotion analysis is displayed. History shows all entries.

### Outcome
All deliverables complete. Firebase Storage and Blaze plan requirement removed — audio uploaded directly to AssemblyAI's `/v2/upload` binary endpoint. `firebase_storage` removed from pubspec.yaml. Journal search wired via `SearchDelegate`. Journal detail screen built with full emotion analysis display. AssemblyAI key placeholder in `.env` with instructions to set real key when ready.

---

## Sprint 5 — Analytics & Insights
**Phase:** Analytics | **Duration:** Weeks 9–10 | **Status: COMPLETE**

### Deliverables
- Analytics tab with real data
- Emotional Fingerprint (radar chart wired to live emotion frequencies)
- Mood Prediction (client-side algorithm — no Cloud Functions required)
- Cognitive Patterns section (distortion types aggregated from journal history)
- Predictive alert banner on Home Dashboard
- MoodCheckin saved to Firestore on every home screen mood tap

### Acceptance Criteria
Emotional Fingerprint displays with real data. Prediction shows trend from recent journals. Alert banner appears when mood dip is detected.

### Outcome
All deliverables complete. `AnalyticsService` queries last 30 journals + parallel-fetches emotion results from subcollections. Client-side prediction algorithm computes improving/stable/declining trend from last 7 entries and saves `Prediction` doc to Firestore. Home screen banner now shows when `alertNeeded == true`. MoodCheckin written to Firestore on every mood selector tap. Cloud Functions requirement removed — replaced with client-side Dart logic.

---

## Sprint 6 — Coping Toolkit & Notifications
**Phase:** Coping & Notifications | **Duration:** Weeks 11–12 | **Status: PARTIAL**

### Deliverables
- Coping Toolkit with all activity screens functional
- Breathing exercises (4-7-8, box breathing) with audio/visual guidance
- Meditation screen with guided sessions
- Subliminal/ambient music player (`just_audio`) with emotion-matched tracks
- CBT exercise module (thought records, reframing)
- In-app notification screen wired to Firestore
- Bell icon badge (unread count)
- FCM push notification Cloud Functions: daily affirmation (8am), journal reminder (7pm), mood alert

### Acceptance Criteria
All toolkit activities navigable and functional. Push notifications received on device. In-app notification list displays correctly.

### Remaining Work

| Item | Notes |
|---|---|
| Add `just_audio` to `pubspec.yaml` | Music player widget exists but package undeclared |
| Source and embed audio content (breathing guides, meditation, ambient music) | No audio files or CDN links exist |
| Define CBT exercise content database | Template UI exists, no actual exercise data |
| FCM token generation and storage in Firestore | Prerequisite for all push notifications |
| Cloud Function `sendDailyAffirmation` | 8am scheduled trigger |
| Cloud Function `sendJournalReminder` | 7pm conditional trigger — skip if entry exists today |
| Wire in-app notification list to Firestore stream | Notifications screen is currently a shell |
| Bell icon unread badge counter | Not implemented |

---

## Sprint 7 — Reports & Settings
**Phase:** Reports & Settings | **Duration:** Weeks 13–14 | **Status: NOT STARTED**

### Deliverables
- Export Journey screen with date-range selection
- PDF generation (`pdf` Flutter package) with journal data
- CSV export of journal entries
- Report Preview screen (before confirming export)
- Settings screen: all toggles persist to Firestore
- Privacy & Security screen
- Help Center and About screen
- Offline mode banner (no connection detected)
- Sync complete notification (when Firestore reconnects)

### Acceptance Criteria
PDF and CSV exports generated correctly with journal data. All settings persist across app restarts. Offline journaling works without internet.

### Work to Do

| Item | Notes |
|---|---|
| Add `pdf` package to `pubspec.yaml` | Not present |
| PDF report template and generation logic | Export screen is a placeholder |
| CSV export logic | Not written |
| Report Preview screen | Not built |
| Share / email report via system share sheet | Not built |
| Cloud Function `generateReport` | Server-side aggregation for report data |
| Wire all Settings toggles to Firestore `UserProfile` | Currently no persistence |
| Language preference save (English/Sinhala/Tamil) | UI exists, no save |
| Offline mode banner wired to `connectivityProvider` | Provider exists, banner not wired |
| Sync complete snackbar/toast | Not implemented |
| Privacy & Security screen | Not built |
| Help Center screen | Not built |
| About screen | Not built |

---

## Sprint 8 — Testing, Refinement & Release
**Phase:** Quality & Deployment | **Duration:** Weeks 15–16 | **Status: NOT STARTED**

### Deliverables
- End-to-end integration tests for critical journeys
- Widget tests for key screens
- Bug fixes from pilot testing
- UI/UX refinements
- Performance audit (cold start < 3s, AI analysis < 30s, APK < 50MB)
- Firestore security rules audit
- API key security review (no secrets in source)
- Final documentation update
- User manual
- Google Play internal testing track deployment

### Acceptance Criteria
All flows pass end-to-end tests. No critical bugs. App loads within 3 seconds. AI analysis completes within 30 seconds.

### Work to Do

| Item | Notes |
|---|---|
| Write widget tests for auth, journal, and analytics screens | No test files exist currently |
| Write integration tests for journal → analysis flow | Critical path test |
| Write integration test for voice record → transcription → result | Critical path test |
| Run cold start performance measurement | Target < 3 seconds |
| Run end-to-end AI analysis timing | Target < 30 seconds |
| Check APK build size | Target < 50 MB |
| Audit Firestore security rules | Verify user-scoped rules cover all collections |
| Confirm `.env` not committed to Git | API key hygiene check |
| Verify AssemblyAI, HuggingFace, Gemini API keys are valid and rate-limited | Pre-launch check |
| Pilot test with target users (Sri Lankan undergrads) | Collect feedback |
| Apply UI/UX refinements from pilot feedback | Iterative fixes |
| Write user manual | Step-by-step guide for end users |
| Submit to Google Play internal testing track | Final milestone |

---

# 4. Milestone Summary

| Milestone | Target Sprint | Status |
|---|---|---|
| M1 — Auth & Onboarding Complete | Sprint 2 | REACHED |
| M2 — Journaling MVP (text + voice + AI analysis) | Sprint 4 | REACHED |
| M3 — Analytics Complete | Sprint 5 | REACHED |
| M4 — Full Feature Set | Sprint 7 | NOT REACHED |
| M5 — Production Ready | Sprint 8 | NOT REACHED |

---

# 5. Remaining Work — Priority Order

Sprints 1–5 are complete. Three sprints remain.

## Sprint 6 — Coping Toolkit & Notifications (next)

| # | Task | Notes |
|---|---|---|
| 1 | Add `just_audio` to `pubspec.yaml` | Required for music player |
| 2 | Wire in-app notification list to Firestore stream | Notifications screen is a shell |
| 3 | Bell icon unread badge counter | Not implemented |
| 4 | FCM token generation and save to `UserProfile` in Firestore | Prerequisite for push notifications |
| 5 | FCM daily affirmation notification (8am) | Client-side scheduled via FCM |
| 6 | FCM journal reminder notification (7pm, skip if entry exists) | Client-side FCM |
| 7 | FCM mood alert notification (when alertNeeded == true) | Triggered from prediction |
| 8 | Source audio content for breathing, meditation, ambient music | CDN links or bundled assets |
| 9 | Define CBT exercise content (thought records, reframing prompts) | Data in code or Firestore |

## Sprint 7 — Reports & Settings

| # | Task | Notes |
|---|---|---|
| 1 | Add `pdf` package to `pubspec.yaml` | Not present |
| 2 | PDF report generation with journal data | Export screen is a placeholder |
| 3 | CSV export logic | Not written |
| 4 | Report Preview screen before export | Not built |
| 5 | Share/email report via system share sheet | Not built |
| 6 | Wire all Settings toggles to Firestore `UserProfile` | Currently no persistence |
| 7 | Language preference save (English/Sinhala/Tamil) | UI exists, no save |
| 8 | Offline mode banner wired to `connectivityProvider` | Provider exists, banner not wired |
| 9 | Sync complete snackbar when Firestore reconnects | Not implemented |
| 10 | Privacy & Security, Help Center, About screens | Not built |

## Sprint 8 — Testing, Refinement & Release

| # | Task | Notes |
|---|---|---|
| 1 | Set real AssemblyAI API key in `.env` | Placeholder still in place |
| 2 | Widget tests for auth, journal, analytics screens | No test files exist |
| 3 | Integration test — journal → analysis flow | Critical path |
| 4 | Integration test — voice record → transcription → result | Critical path |
| 5 | Cold start performance audit (target < 3s) | Not measured |
| 6 | AI analysis timing audit (target < 30s) | Not measured |
| 7 | APK size check (target < 50MB) | Not measured |
| 8 | Audit Firestore security rules | Verify user-scoped rules |
| 9 | Confirm `.env` not committed to Git | API key hygiene |
| 10 | Pilot test with Sri Lankan undergrads + apply feedback | User acceptance testing |
| 11 | Write user manual | End-user guide |
| 12 | Submit to Google Play internal testing track | Final milestone |
