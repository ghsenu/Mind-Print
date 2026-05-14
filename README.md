# Mind_Print

MindPrint Flutter application.

## Environment and Database Setup

1. Copy `.env.example` to `.env`.
2. Fill `.env` with your Firebase project values for each target platform.
3. Install dependencies:
	- `flutter pub get`
4. Run the app:
	- `flutter run`

The app loads `.env` at startup and initializes Firebase + Cloud Firestore.

## Firestore Structure (MVP)

- `users/{userId}`
- `users/{userId}/journals/{journalId}`
- `users/{userId}/moodCheckins/{id}`
- `users/{userId}/predictions/{id}`
- `users/{userId}/notifications/{id}`
- `users/{userId}/reports/{id}`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
