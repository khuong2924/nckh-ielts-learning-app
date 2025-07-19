
# 📘 IELTS Learning App

A cross-platform mobile & web application designed to support IELTS learners with interactive practice and performance tracking.

---

## Features

- IELTS question bank (Reading, Listening) with answer review
- Time-tracked practice sessions with result analysis
- Firebase & Supabase authentication
- Real-time data sync between devices
- Personal dashboard and progress analytics
- Web, Android, and iOS support using Flutter single codebase

---

## Technologies Used

- Frontend: Flutter (Web, Android, iOS)
- State Management: Bloc, Provider
- Authentication: Firebase Auth, Supabase
- Database: Supabase Realtime DB
- Storage: Cloudinary (for audio & images)
- AI Integration: Gemini API, Mistral (for analysis & feedback)
- API Key Management: `.env` file with `flutter_dotenv`

---

## ⚠️ Warning – Required `.env` File

> This project requires a `.env` file to run. While the Supabase database is public, the API keys for accessing services like Supabase, Cloudinary, Gemini, and Mistral are stored securely in `.env`.

The `.env` file is not included in this repository for security reasons.  
You must create your own `.env` file or contact the us to request access for testing/demo purposes.

### Example `.env`:
```env
MISTRAL_API_KEY=
GEMINI_API=
````

> Please do not commit `.env` to Git — it is ignored via `.gitignore`.

---

## Getting Started

> You need [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

```bash
# Clone the repository
git clone link
cd nckh-ielts-learning-app

# Install dependencies
flutter pub get

# Create and configure .env file
cp .env.example .env
# Fill in the values based on your Supabase & API credentials

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS (macOS only)
flutter run -d ios
```


## License

This project is developed for academic and research purposes only.
Not licensed for commercial use.

## 🎥 Link demo:
https://drive.google.com/file/u/1/d/1_DgnfJ7LtNTMWoYQo1kBwSuGGEhqhimP/view

