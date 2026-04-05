# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-09**
Sprint Timeline
Phase-Based Agile Development Plan



# 1. Development Methodology
MindPrint follows an Agile development methodology with two-week sprint cycles. Each sprint has defined deliverables, acceptance criteria, and a review checkpoint. The project is divided into six development phases aligned with the academic project timeline.

| Property | Value |
|---|---|
| Methodology | Agile with 2-week sprints |
| Total Sprints | 8 sprints across 6 phases |
| Sprint Length | 2 weeks |
| Review Cadence | End of each sprint with supervisor |
| Version Control | Git with feature branches |
| Issue Tracking | GitHub Projects |

# 2. Sprint Plan
## Phase 1 — Foundation (Sprints 1–2)

| Sprint | Duration | Deliverables | Acceptance Criteria |
|---|---|---|---|
| Sprint 1 | Weeks 1–2 | Firebase project setup, Flutter project scaffold, Riverpod architecture, GoRouter navigation, Firebase Auth integration, Firestore security rules | User can register, log in, and log out. Firebase connection verified. |
| Sprint 2 | Weeks 3–4 | Onboarding flow (3 slides), Sign Up screen, Language selection, Permissions screen, Biometric setup, Onboarding questionnaire, Splash screen | Full first-time onboarding flow navigable end-to-end. Data saved to Firestore. |

## Phase 2 — Core Journaling (Sprints 3–4)

| Sprint | Duration | Deliverables | Acceptance Criteria |
|---|---|---|---|
| Sprint 3 | Weeks 5–6 | Home Dashboard (mood check-in, navigation), Text journal entry screen, Save & Analyze flow, HuggingFace NLP API integration, Cloud Function: analyzeTextEntry, Emotion Result screen | User can write journal, trigger analysis, and see emotion result. API returns valid scores. |
| Sprint 4 | Weeks 7–8 | Voice recording screen (waveform UI), Firebase Storage upload, AssemblyAI API integration, Cloud Function: analyzeVoiceEntry, Voice emotion result screen, Journal History + Detail screens | User can record voice, transcript generated, emotion analysis displayed. History shows all entries. |

## Phase 3 — Analytics & Insights (Sprint 5)

| Sprint | Duration | Deliverables | Acceptance Criteria |
|---|---|---|---|
| Sprint 5 | Weeks 9–10 | Analytics tab, Emotional Fingerprint screen, Mood Timeline Chart (fl_chart), Mood Prediction Cloud Function (daily scheduler), Mood Prediction screen (48hr chart), Cognitive/Reflective Patterns screen, Predictive alert banner on Home Dashboard | Fingerprint visualization displays with real data. Prediction chart shows 48hr forecast. Alert banner appears when dip detected. |

## Phase 4 — Coping & Notifications (Sprint 6)

| Sprint | Duration | Deliverables | Acceptance Criteria |
|---|---|---|---|
| Sprint 6 | Weeks 11–12 | Coping Toolkit screen (all exercises), Breathing exercise, Meditation screen, Subliminal music player (just_audio), CBT exercise module, Notification screen (in-app), Bell icon badge, FCM push notification Cloud Functions (affirmation, reminder, mood alert) | All toolkit activities navigable and functional. Push notifications received on device. In-app notification list displays correctly. |

## Phase 5 — Reports & Settings (Sprint 7)

| Sprint | Duration | Deliverables | Acceptance Criteria |
|---|---|---|---|
| Sprint 7 | Weeks 13–14 | Export Journey screen, PDF generation (pdf package), CSV export, Report Preview screen, Settings screen (all toggles), Privacy & Security screen, Help Center, About screen, Log Out flow, Offline mode banner, Sync complete notification | PDF and CSV exports generated correctly with journal data. All settings persist. Offline journaling works without internet. |

## Phase 6 — Testing, Refinement & Documentation (Sprint 8)

| Sprint | Duration | Deliverables | Acceptance Criteria |
|---|---|---|---|
| Sprint 8 | Weeks 15–16 | End-to-end integration testing, Bug fixes from pilot testing, UI/UX refinements, Performance optimization, Security audit (Firestore rules, API key review), Final documentation, User manual, Deployment to Google Play (internal testing track) | All flows pass end-to-end tests. No critical bugs. App loads within 3 seconds. AI analysis completes within 30 seconds. |

# 3. Milestone Summary

| Milestone | Target (End of Sprint) | Description |
|---|---|---|
| M1 — Auth Complete | Sprint 2 | Full onboarding and authentication working |
| M2 — Journaling MVP | Sprint 4 | Text and voice journaling with AI analysis working |
| M3 — Analytics Complete | Sprint 5 | Emotional Fingerprint, predictions, and patterns working |
| M4 — Full Feature Set | Sprint 7 | All features implemented including toolkit, reports, settings |
| M5 — Production Ready | Sprint 8 | Tested, documented, and deployed to internal track |

# 4. Definition of Done
A sprint is considered complete when all of the following are true:
All deliverables for the sprint are implemented and navigable in the app
New Firestore collections/documents are protected by correct security rules
All new API integrations have error handling and fallback states
UI matches the confirmed screen designs
Code committed to Git feature branch and merged to main via pull request
Sprint deliverables reviewed with supervisor
