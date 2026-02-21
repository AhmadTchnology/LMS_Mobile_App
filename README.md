# 🎓 University LMS Mobile App

A modern, offline-capable Cross-Platform Mobile Application built with Flutter and Firebase. This application serves as a comprehensive University Lecture Management System, designed for Students, Teachers, and Administrators to seamlessly manage educational content and collaborate.

## ✨ Features

*   **Role-Based Authentication (RBAC):** Distinct interfaces and privileges for Students, Teachers, and Admins.
*   **Lecture & Document Management:** Upload, view, and manage PDF lectures effortlessly. (Integrated with Zipline Storage for reliable multipart uploading).
*   **Offline Support:** Caching system allows students to view previously loaded lectures and announcements without an internet connection.
*   **AI Chat Assistant:** Integrated AI study partner powered by n8n workflows and an Express.js proxy.
*   **Announcements System:** Real-time push notifications and global announcements for homework, exams, and university events.
*   **Customizable Theming:** Beautiful Light & Dark mode setups with user-configurable accent presets.
*   **Cross-Platform:** Compiles to iOS, Android, macOS, Windows, Linux, and Web from a single codebase.

---

## 🛠️ Tech Stack

*   **Framework:** Flutter (Dart)
*   **Backend & Database:** Firebase (Auth, Firestore)
*   **Cloud Storage:** Zipline (Object Storage for PDFs)
*   **AI Backend:** Express.js Proxy + n8n + PostgreSQL
*   **State Management:** Provider
*   **Local Storage:** Flutter Secure Storage (for offline caching)

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You will need the following installed on your environment:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.24+ recommended)
*   [Dart SDK](https://dart.dev/get-dart)
*   An IDE (Android Studio, VS Code, or IntelliJ)
*   A Firebase Project

### 1. Clone the repository

```bash
git clone https://github.com/AhmadTchnology/LMS_Mobile_App.git
cd LMS_Mobile_App/lms_mobile_app
```

### 2. Install Dependencies

Fetch all the required Dart packages:
```bash
flutter pub get
```

### 3. Configure Environments

This project relies on localized environment variables and Firebase configurations that are intentionally excluded from version control to protect API keys.

1. **Firebase Configuration:**
   * Open `lib/config/firebase_config.example.dart`
   * Duplicate the file and rename it to `firebase_config.dart`
   * Replace the placeholder variables (`YOUR_API_KEY_HERE`, etc.) with the actual credentials from your Firebase Console.

2. **Backend & AI Configuration:**
   * Open `lib/config/env_config.example.dart`
   * Duplicate the file and rename it to `env_config.dart`
   * Insert your Zipline URLs, API Tokens, and your Express AI Proxy endpoint.

### 4. Run the Application

You can run the application on any connected emulator or device.

**To run on a mobile emulator (iOS/Android):**
```bash
flutter run
```

**To run on Chrome (Web):**
> *Note: If connecting to the AI Express proxy backend, you must run the web server specifically on port 5173 to bypass CORS whitelisting.*
```bash
flutter run -d chrome --web-port=5173
```

---

## 🏗️ Project Structure

```bash
lms_mobile_app/
├── lib/
│   ├── config/      # Environment and Firebase configs
│   ├── models/      # Dart data models (UserModel, LectureModel)
│   ├── providers/   # State management (AuthProvider, ThemeProvider)
│   ├── screens/     # UI Pages (Admin, Teacher, Student views)
│   ├── services/    # External API communicators (Firestore, Zipline, AI)
│   ├── theme/       # App styling, Colors, and Dark Mode definitions
│   └── main.dart    # Application Entry Point
```

---

## 🔒 Security

*   **Firebase Rules:** Ensure your Firestore database rules restrict access appropriately based on the User's role (`uid` validation).
*   **Secrets:** Never commit `firebase_config.dart` or `env_config.dart`. They are strictly tracked in `.gitignore`.

## 🤝 Contributing

Contributions, issues, and feature requests are always welcome! Feel free to check the issues page before opening a pull request.
