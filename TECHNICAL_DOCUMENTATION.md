# MindPrint Technical Documentation

## 1. Project Overview
MindPrint is a premium mental wellness and emotional tracking application designed to provide users with deep insights into their mental state through AI-driven journal analysis, mood tracking, and meditative activities.

## 2. Core Tech Stack
*   **Framework:** [Flutter](https://flutter.dev/) (Cross-platform UI toolkit)
*   **Language:** [Dart](https://dart.dev/)
*   **State Management:** [Riverpod](https://riverpod.dev/) (Reactive caching and dependency injection)
*   **Backend as a Service (BaaS):** [Firebase](https://firebase.google.com/)
    *   **Authentication:** Firebase Auth (Email/Password, Google Sign-In, Biometrics)
    *   **Database:** Cloud Firestore (Real-time NoSQL)
    *   **Messaging:** Firebase Cloud Messaging (Push Notifications)
*   **Local Storage:** SQLite ([sqflite](https://pub.dev/packages/sqflite)) for high-performance caching and [SharedPreferences](https://pub.dev/packages/shared_preferences) for simple key-value settings.

---

## 3. AI & Machine Learning Infrastructure

### 3.1. Sentiment & Emotion Analysis
The heart of MindPrint is its multi-layered analysis engine located in `JournalService`.

*   **Primary Engine: Google Gemini 2.0 Flash**
    *   **Model:** `gemini-2.0-flash`
    *   **Function:** Performs deep contextual analysis of journal entries.
    *   **Outputs:** Extracts primary/secondary emotions (Joy, Sadness, Anger, Fear, Surprise, Disgust, Neutral), sentiment (Positive/Negative/Neutral), and identifies Cognitive Distortions (e.g., Catastrophizing, Black-and-white thinking).
    *   **CBT Integration:** Automatically generates Cognitive Behavioral Therapy (CBT) reframes for detected thought distortions.
*   **Fallback Engine: Hugging Face Inference**
    *   **Model:** Deployed via `HuggingFaceService`.
    *   **Function:** Serves as a reliable fallback for basic emotion classification if the primary LLM is unavailable.

### 3.2. Speech-to-Text (Transcriptions)
*   **Provider:** [AssemblyAI](https://www.assemblyai.com/)
*   **Implementation:** `AssemblyAiService`
*   **Workflow:**
    1.  Local audio is captured via the `record` package.
    2.  Files are streamed directly to AssemblyAI's secure upload servers.
    3.  **Model:** Utilizes `universal-3-pro` for state-of-the-art transcription accuracy.
    4.  **Auto-Analysis:** Transcribed text is immediately passed to the Gemini Analysis engine.

---

## 4. Key Dependencies & Packages

### UI & Styling
*   `google_fonts`: Premium typography (Inter, Lora).
*   `flutter_svg`: High-quality vector asset rendering.
*   `cupertino_icons`: iOS-style iconography.

### Media & Hardware
*   `just_audio`: Professional-grade audio playback for meditation and music therapy.
*   `record`: Low-latency audio recording for voice journals.
*   `image_picker`: Profile photo management.
*   `local_auth`: Biometric authentication (Face ID / Fingerprint).

### Utilities & Data
*   `flutter_dotenv`: Secure management of API keys and environment variables.
*   `intl`: Date formatting and localization.
*   `share_plus`: Exporting reports and sharing insights.
*   `pdf` & `csv`: Document generation for mental health reports.
*   `connectivity_plus`: Real-time network status monitoring.

---

## 5. Advanced Features & Performance

### 5.1. Offline-First Architecture (Sync Logic)
MindPrint implements a sophisticated caching layer via `LocalStorageService`:
*   **SQLite Caching:** Every journal entry fetched from Firestore is mirrored in a local SQLite database.
*   **Instant Load:** On app start, data is yielded from SQLite instantly, while Firestore updates the list in the background.
*   **Immediate Local Save:** New entries are saved to SQLite the moment they are created, ensuring zero data loss during network drops.

### 5.2. API Rate Limiting (Abuse Prevention)
To protect cloud infrastructure and API quotas, the `RateLimiterService` enforces:
*   **Per-Device Limits:** Specifically 10 analysis requests/min for Gemini and 3 transcriptions/min for AssemblyAI.
*   **Sliding Window:** Uses a time-based reset window to ensure fair usage without blocking legitimate users.

### 5.3. Haptic Feedback System
Integration of `HapticFeedback` across all interactive elements (toggles, buttons) to provide a tactile, premium user experience.

---

## 6. Security & Privacy
*   **Biometric Lock:** Secure access via system-level Face ID or Fingerprint.
*   **Data Encryption:** All journal content is stored securely in Firestore with strict Security Rules.
*   **Privacy Controls:** Users can opt-out of anonymized analytics and request full data exports or account deletion directly through the app.
