# MindPrint
AI-Powered Mental Health Awareness Application

> **DOC-03**
API Endpoints
External AI APIs, Firebase Cloud Functions & Integration Reference

Student: Gihansa S Buwanayake
Index Number: 10952999
Supervisor: Dr. Rasika Ranaweera
Programme: BSc (Hons) Software Engineering — NSBM Green University
Module: PUSL3190 Computing Project

# 1. API Integration Overview
MindPrint consumes three categories of APIs: external AI APIs (HuggingFace, AssemblyAI), Firebase Cloud Functions (internal serverless endpoints), and Firebase platform APIs (Auth, Firestore, Storage, FCM). All external API keys are stored as Cloud Function environment variables and are never exposed in client-side Flutter code.

# 2. HuggingFace Inference API
## 2.1 Connection Details

| Property | Value |
|---|---|
| Base URL | https://api-inference.huggingface.co/models/ |
| Authentication | Bearer token — stored in Cloud Function env variable HF_API_KEY |
| Request Format | JSON POST |
| Response Format | JSON array of label/score pairs |
| Free Tier | Rate-limited inference — sufficient for development and pilot testing |

## 2.2 Text Emotion Classification

| Property | Value |
|---|---|
| Endpoint | POST /j-hartmann/emotion-english-distilroberta-base |
| Purpose | Classify emotions from journal text entry |
| Request Body | { "inputs": "<journal text string>" } |
| Response | [{ "label": "joy", "score": 0.85 }, { "label": "sadness", "score": 0.10 }, ...] |
| Emotions Returned | anger, disgust, fear, joy, neutral, sadness, surprise |
| Called By | Cloud Function: analyzeTextEntry |

## 2.3 Sentiment Analysis

| Property | Value |
|---|---|
| Endpoint | POST /cardiffnlp/twitter-roberta-base-sentiment-latest |
| Purpose | Positive / Negative / Neutral sentiment scoring |
| Request Body | { "inputs": "<journal text string>" } |
| Response | [{ "label": "POSITIVE", "score": 0.92 }] |
| Called By | Cloud Function: analyzeTextEntry (secondary analysis) |

## 2.4 Cognitive Distortion Detection

| Property | Value |
|---|---|
| Endpoint | POST /facebook/bart-large-mnli (zero-shot classification) |
| Purpose | Detect cognitive distortion patterns in text |
| Request Body | { "inputs": "<text>", "parameters": { "candidate_labels": ["catastrophising", "black and white thinking", "mind reading", "overgeneralisation", "personalisation", "no distortion"] } } |
| Response | Labels with probability scores |
| Called By | Cloud Function: detectCognitiveDistortion |

# 3. AssemblyAI API
## 3.1 Connection Details

| Property | Value |
|---|---|
| Base URL | https://api.assemblyai.com/v2/ |
| Authentication | Authorization header — stored in Cloud Function env variable ASSEMBLYAI_API_KEY |
| Free Credit | $50 USD credit on signup (sufficient for development and testing) |
| Called By | Cloud Function: analyzeVoiceEntry |

## 3.2 Voice Transcription (STT)

| Property | Value |
|---|---|
| Endpoint | POST /v2/transcript |
| Purpose | Convert voice journal recording to text |
| Request Body | { "audio_url": "<Firebase Storage URL>", "sentiment_analysis": true } |
| Polling Endpoint | GET /v2/transcript/{transcript_id} |
| Response Fields | text (full transcript), sentiment_analysis_results (per sentence) |
| Audio Format | .m4a (Flutter record package default) |

## 3.3 Voice Sentiment & Emotion

| Property | Value |
|---|---|
| Feature | sentiment_analysis (enabled in transcription request) |
| Purpose | Emotion / sentiment detection per sentence in transcript |
| Values Returned | POSITIVE | NEUTRAL | NEGATIVE with confidence scores |
| Combined With | HuggingFace NLP analysis of transcript text for richer emotion labels |

# 4. Firebase Cloud Functions (Internal Endpoints)
Cloud Functions are invoked either by HTTP triggers from the Flutter app or by Firestore/Storage event triggers and scheduled jobs.

| Function | Type | Trigger | Description |
|---|---|---|---|
| analyzeTextEntry | HTTP | POST from Flutter | Orchestrates HuggingFace NLP + distortion detection |
| analyzeVoiceEntry | Event | Firebase Storage upload | Orchestrates AssemblyAI transcription + SER |
| generateMoodPrediction | Scheduled | Daily cron job | Calculates 48hr mood trend for each user |
| sendDailyAffirmation | Scheduled | Daily 08:00 | Sends FCM affirmation push notification |
| sendJournalReminder | Scheduled | Daily 19:00 | Sends FCM reminder if no journal entry today |
| sendMoodAlert | Called internally | By generateMoodPrediction | Sends FCM mood dip warning notification |
| generateReport | HTTP | POST from Flutter | Compiles and returns PDF/CSV report data |

# 5. Firebase Platform APIs

| Service | SDK | Usage in MindPrint |
|---|---|---|
| Firebase Auth | firebase_auth (Flutter) | Email/password registration, Google Sign-In, password reset email |
| Cloud Firestore | cloud_firestore (Flutter) | All CRUD operations, real-time listeners, offline persistence |
| Firebase Storage | firebase_storage (Flutter) | Voice recording uploads, PDF report downloads |
| Firebase Cloud Messaging | firebase_messaging (Flutter) | Push notification receipt and handling on device |
| Firebase Analytics | firebase_analytics (Flutter) | Feature usage tracking (no journal content tracked) |

# 6. API Key Security Policy
HuggingFace API key stored as: Firebase Cloud Function environment variable HF_API_KEY
AssemblyAI API key stored as: Firebase Cloud Function environment variable ASSEMBLYAI_API_KEY
FCM Server Key stored as: Firebase Cloud Function environment variable FCM_SERVER_KEY
Flutter client code contains ZERO API keys — all external calls proxied through Cloud Functions
Keys rotated every 90 days as part of production security policy
