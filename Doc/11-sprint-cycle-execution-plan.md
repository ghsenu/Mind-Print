# 11 - Sprint Cycle Execution Plan

## Scope
This plan maps implementation work to the new feature-first Flutter structure in `lib/`.

## Sprint 1-2: Foundation
- Auth flow shell: splash, login, sign-up, onboarding questionnaire
- App shell: theme, routes, initial navigation flow
- Setup baseline models/services/providers placeholders
- Deliverable: user can launch app, reach auth, and navigate to home placeholder

## Sprint 3-4: Journaling Core
- Build text and voice journal entry UI
- Implement journal storage service and analysis pipeline integration
- Add journal history and detail views
- Deliverable: user can create entry and see analysis result screen

## Sprint 5: Analytics
- Emotional fingerprint view
- Mood prediction view
- Pattern insights page
- Deliverable: user can view trend insights from journal data

## Sprint 6: Coping Toolkit + Notifications
- Breathing, meditation, and CBT exercise screens
- Add in-app notification surfaces
- Deliverable: user can access toolkit and receive/use alerts

## Sprint 7: Reports + Settings
- Export flow for PDF/CSV
- Settings controls (language, privacy, biometrics, notifications)
- Deliverable: user can configure app and export report data

## Sprint 8: Quality + Release Readiness
- Widget tests for key screens
- Integration tests for critical journeys
- Performance and bug fixes
- Deliverable: MVP ready for pilot

## Current Scaffold Coverage
- `app/`: app bootstrap, routes, theme
- `features/auth/`: base screens + auth provider/service placeholders
- `features/home/`: home placeholder screen
- `features/journal/`: journal placeholder
- `features/analytics/`: analytics placeholder
- `features/coping/`: toolkit placeholder
- `features/reports/`: export placeholder
- `features/settings/`: settings placeholder
- `features/shared/`: initial constants/models/utils/widgets/providers
