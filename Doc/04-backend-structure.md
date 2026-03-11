# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-04**
Backend Structure
Firebase Cloud Functions Architecture & Server-Side Logic

Student: Gihansa S Buwanayake
Index Number: 10952999
Supervisor: Dr. Rasika Ranaweera
Programme: BSc (Hons) Software Engineering — NSBM Green University
Module: PUSL3190 Computing Project

# 1. Backend Overview
MindPrint uses a serverless backend architecture built entirely on Firebase Cloud Functions (Node.js runtime). There is no traditional server — all business logic, AI API orchestration, scheduled tasks, and data processing are handled by individual Cloud Functions that scale automatically.

| Property | Value |
|---|---|
| Runtime | Node.js 18 |
| Platform | Firebase Cloud Functions (Gen 2) |
| Region | asia-south1 |
| Language | TypeScript (compiled to JavaScript) |
| Admin SDK | firebase-admin for server-side Firestore and FCM access |
| External HTTP | axios for calling HuggingFace and AssemblyAI APIs |

# 2. Cloud Functions Directory Structure
functions/
src/
index.ts — exports all functions
journal/
analyzeTextEntry.ts — NLP + distortion detection
analyzeVoiceEntry.ts — AssemblyAI STT + SER
analytics/
generateMoodPrediction.ts — 48hr trend calculation
generateReport.ts — PDF/CSV report compilation
notifications/
sendDailyAffirmation.ts — scheduled push notification
sendJournalReminder.ts — scheduled push notification
sendMoodAlert.ts — triggered FCM alert
utils/
huggingfaceClient.ts — HuggingFace API wrapper
assemblyaiClient.ts — AssemblyAI API wrapper
fcmHelper.ts — FCM notification builder
emotionMapper.ts — maps API scores to display labels
package.json
.env (local only — never committed to Git)

# 3. Function Specifications
## 3.1 analyzeTextEntry

| Property | Detail |
|---|---|
| Trigger | HTTP POST (called from Flutter via Cloud Functions SDK) |
| Input | { userId, journalId, textContent } |
| Step 1 | Call HuggingFace emotion classification API with textContent |
| Step 2 | Call HuggingFace sentiment analysis API |
| Step 3 | Call detectCognitiveDistortion with textContent |
| Step 4 | Map raw API scores to display-friendly emotion labels |
| Step 5 | Generate hashtags from top emotion + content keywords |
| Step 6 | Write emotionResult sub-document to Firestore |
| Step 7 | Update journal document: isAnalyzed = true |
| Output | { success: true, primaryEmotion, intensity, breakdown, distortion, hashtags } |
| Timeout | 30 seconds (HuggingFace cold start may take up to 20s) |
| Error Handling | Returns fallback neutral emotion if API fails — no silent failures |

## 3.2 analyzeVoiceEntry

| Property | Detail |
|---|---|
| Trigger | Firebase Storage onCreate event (voice recording uploaded) |
| Input | Storage object metadata (file path, userId, journalId from file name) |
| Step 1 | Generate signed download URL for audio file in Storage |
| Step 2 | Submit audio URL to AssemblyAI transcription endpoint |
| Step 3 | Poll AssemblyAI every 3 seconds until transcription complete |
| Step 4 | Extract transcript text and per-sentence sentiment scores |
| Step 5 | Pass transcript text to HuggingFace for full emotion classification |
| Step 6 | Merge AssemblyAI sentiment + HuggingFace emotion into unified result |
| Step 7 | Write emotionResult + update journal with transcript text |
| Output | Firestore document updated with full analysis |
| Timeout | 120 seconds (audio transcription takes variable time) |

## 3.3 generateMoodPrediction

| Property | Detail |
|---|---|
| Trigger | Firebase Scheduler — runs daily at 00:00 (midnight) |
| Input | Iterates all active users from Firestore |
| Step 1 | Fetch last 7 days of moodCheckins and journal emotionResults for user |
| Step 2 | Calculate daily average mood score (1–4 scale) |
| Step 3 | Calculate trend direction: slope of 7-day score series |
| Step 4 | If slope is negative and latest score below threshold: flag dip predicted |
| Step 5 | Write prediction document to Firestore: predictions/{userId}/latest |
| Step 6 | If dipPredicted = true: call sendMoodAlert for this user |
| Output | Prediction document in Firestore + optional FCM alert |

## 3.4 Notification Functions

| Function | Schedule / Trigger | FCM Notification Content |
|---|---|---|
| sendDailyAffirmation | Every day at 08:00 | Title: "Good morning ✨" | Body: rotating affirmation message from curated list |
| sendJournalReminder | Every day at 19:00 | Title: "Your journal is waiting" | Body: "Take 2 minutes to reflect on your day" — only if no entry today |
| sendMoodAlert | Triggered by prediction | Title: "Heads up, [Name]" | Body: "Your rhythm suggests a quieter mood tomorrow. Your toolkit is ready." | Deep link: /coping |

# 4. Environment Variables

| Variable | Value Source | Used In |
|---|---|---|
| HF_API_KEY | HuggingFace account settings | analyzeTextEntry, detectCognitiveDistortion |
| ASSEMBLYAI_API_KEY | AssemblyAI dashboard | analyzeVoiceEntry |
| FCM_SERVER_KEY | Firebase console | All notification functions |
| PROJECT_ID | Firebase project settings | Admin SDK initialization |

All variables set via: firebase functions:config:set or .env.local for local emulator
Never committed to version control — .env in .gitignore
