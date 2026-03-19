<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.7%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.7%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=for-the-badge" />

<br /><br />

# 💊 MediSafe

### *Smart Medical Management. Right in Your Pocket.*

**MediSafe** is a comprehensive medical management mobile application built with Flutter, featuring an intuitive dark-themed interface. It helps users track medications, manage medical supplies, set smart reminders, and stay on top of their health — all with seamless Firebase integration and real-time notifications.

<br />

[![Demo Video](https://img.shields.io/badge/▶%20Watch%20Demo-YouTube%20Shorts-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/shorts/GqQSCcsHqyg?feature=share)
&nbsp;&nbsp;
[![Download APK](https://img.shields.io/badge/⬇%20Download%20APK-Google%20Drive-4285F4?style=for-the-badge&logo=google-drive&logoColor=white)](https://drive.google.com/file/d/1G8m-KOwQVORpHJuEENnsEQCWnenAvjwo/view)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Permissions](#-permissions-required)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)

---

## ✨ Features

### 💊 Medication Tracking
Keep a complete log of your medications — names, dosages, schedules, and duration. Never lose track of what you're taking or when it's due.

### ⏰ Smart Reminders & Notifications
Powered by `awesome_notifications` and `flutter_foreground_task`, MediSafe delivers reliable push reminders even when the app is running in the background. Never miss a dose again.

### 📦 Medical Supply Management
Track your medicine stock levels and receive low-supply alerts before you run out. Stay prepared at all times.

### 🗂️ Document & File Management
Upload and store medical documents, prescriptions, lab reports, and health records directly within the app using the file picker — organized and always accessible.

### 📲 Emergency SMS Alerts
Send automated SMS messages to emergency contacts at the tap of a button, powered by `telephony_sms`, for situations where immediate communication is critical.

### 📳 Vibration Alerts
Physical vibration alerts via the `vibration` package complement push notifications, ensuring you never miss a critical reminder even on silent mode.

### 🔐 Secure Authentication
Full user login and registration powered by Firebase Authentication, keeping all personal health data private and protected.

### 🌐 REST API Integration
Integrates external health data and services through HTTP API calls, enabling dynamic, up-to-date medical information within the app.

---

## 📸 Screenshots

> _Watch the full app walkthrough in the [demo video](https://www.youtube.com/shorts/GqQSCcsHqyg?feature=share) or [download the APK](https://drive.google.com/file/d/1G8m-KOwQVORpHJuEENnsEQCWnenAvjwo/view) to experience it yourself._

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) — SDK ^3.7.0 |
| **Backend & Auth** | Firebase Core + Firebase Authentication |
| **Notifications** | `awesome_notifications` — rich push alerts |
| **Background Tasks** | `flutter_foreground_task` — persistent background service |
| **Messaging** | `telephony_sms` — emergency SMS |
| **File Handling** | `file_picker` — document upload & storage |
| **HTTP / APIs** | `http` — REST API integration |
| **Local Storage** | `shared_preferences` — persistent local data |
| **Vibration** | `vibration` — haptic alert feedback |
| **Environment** | `flutter_dotenv` — secure environment variable management |
| **Internationalization** | `intl` — date/time formatting |

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.7.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio, VS Code, or IntelliJ IDEA
- A Firebase project with:
  - Firebase Authentication enabled (Email/Password)
  - `google-services.json` (Android) downloaded from the Firebase console

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/Swaraj1657/MEDISAFE1.1.git
cd MEDISAFE1.1
```

**2. Set up environment variables**

Create a `.env` file in the project root and add your required keys:
```env
API_KEY=your_api_key_here
BASE_URL=your_base_url_here
```

> `flutter_dotenv` loads these at runtime — never commit your `.env` file to version control.

**3. Install dependencies**
```bash
flutter pub get
```

**4. Configure Firebase**

- Place `google-services.json` inside `android/app/`
- Place `GoogleService-Info.plist` inside `ios/Runner/` (for iOS builds)

**5. Run the application**
```bash
flutter run
```

---

## 🔐 Permissions Required

MediSafe requests the following permissions to power its core features:

| Permission | Purpose |
|---|---|
| **Notifications** | Medication reminders and dose alerts |
| **SMS** | Emergency SMS to designated contacts |
| **Foreground Service** | Background notification delivery even when app is closed |
| **Vibration** | Haptic feedback for critical alerts |
| **Storage / Files** | Uploading and accessing medical documents |
| **Internet** | Firebase sync and REST API calls |

---

## 📁 Project Structure

```
MEDISAFE1.1/
├── android/                  # Android-specific configuration
├── ios/                      # iOS-specific configuration
├── assets/
│   └── icon/                 # App icons
├── lib/                      # Main Dart source code
│   ├── screens/              # UI screens (Home, Medications, Reminders, etc.)
│   ├── services/             # Firebase, Notification & SMS services
│   ├── models/               # Data models (Medication, Document, etc.)
│   └── main.dart             # App entry point
├── firebase.json             # Firebase project configuration
├── .env                      # Environment variables (do NOT commit)
└── pubspec.yaml              # Dependencies & app metadata
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add: your feature description'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please make sure your changes work without breaking existing features and follow Flutter best practices.

---

<div align="center">

Built with ❤️ for smarter, safer health management.

**[⭐ Star this repo](https://github.com/Swaraj1657/MEDISAFE1.1)** if you find it helpful!

</div>
