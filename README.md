# 🩺 DiabCheck - Diabetes Prediction App

A beautiful Flutter application for diabetes risk prediction powered by Machine Learning, featuring an AI chatbot assistant and modern UI design.

![Flutter](https://img.shields.io/badge/Flutter-3.35-blue?logo=flutter)
![Python](https://img.shields.io/badge/Python-3.10+-green?logo=python)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Features

### 🔮 ML-Powered Prediction
- Predicts diabetes risk using a trained Logistic Regression model
- Takes 6 health parameters: Glucose, Blood Pressure, Skin Thickness, Insulin, BMI, Age
- Provides risk level with confidence percentage

### 🤖 AI Chatbot (DiabBot)
- Powered by Groq's Llama 3.3 70B model
- Answers diabetes-related questions
- Maintains conversation history
- Quick suggestion chips for common questions

### 🔐 User Authentication
- Secure signup/login with password hashing (SHA256)
- Local data storage using SharedPreferences

### 📴 Offline Mode
- Saves prediction history locally
- Shows last prediction when offline
- Connectivity status indicator

### 🔔 Health Reminders
- Daily health check notifications (customizable time)
- Weekly progress reminders
- Configurable in Settings

### 🎨 Themes
- System theme (follows device)
- Light mode
- Dark mode (default)

---

## 📁 Project Structure

```
diabetes_app/
├── backend/
│   ├── app.py                 # Flask API server
│   ├── requirements.txt       # Python dependencies
│   └── classification_model.pkl  # ML model (add your own)
│
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/
│   │   └── user.dart          # User data model
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── home_screen.dart
│   │   ├── result_screen.dart
│   │   ├── chatbot_screen.dart
│   │   └── settings_screen.dart
│   ├── services/
│   │   ├── api_service.dart   # Backend API calls
│   │   ├── chatbot_service.dart # Groq API integration
│   │   ├── connectivity_service.dart
│   │   ├── database_helper.dart
│   │   ├── notification_service.dart
│   │   ├── prediction_history_service.dart
│   │   └── settings_service.dart
│   └── utils/
│       └── theme.dart         # App themes
│
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35+
- Python 3.10+
- Android Studio / VS Code
- Groq API Key (for chatbot)

### 1. Clone the Repository
```bash
git clone https://github.com/Zaeem-Hassan/Flutter-project.git
cd Flutter-project
```

### 2. Setup Backend

```bash
cd backend
pip install -r requirements.txt
```

Add your trained model file `classification_model.pkl` to the backend folder.

```bash
python app.py
```

The server starts at `http://localhost:5000`

### 3. Configure Flutter App

**Update IP Address** (`lib/services/api_service.dart`):
```dart
static const String baseUrl = 'http://YOUR_PC_IP:5000';
```

**Add Groq API Key** (`lib/services/chatbot_service.dart`):
```dart
static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';
```

Get your Groq API key from: https://console.groq.com

### 4. Run Flutter App

```bash
cd diabetes_app
flutter pub get
flutter run -d chrome    # For web
flutter run -d android   # For Android
```

---

## 📱 Screenshots

| Splash | Login | Home |
|--------|-------|------|
| Animated splash screen | Modern login UI | Health data input |

| Result | Chatbot | Settings |
|--------|---------|----------|
| Risk prediction | AI assistant | Theme & notifications |

---

## 🔧 Configuration

### For Mobile Devices
When running on a physical phone, both devices must be on the same WiFi network. Update the API URL with your PC's IP address:

```bash
# Get your IP
ipconfig   # Windows
ifconfig   # Mac/Linux
```

### ML Model Input Features
The model expects these 6 features (after dropping Pregnancies and DiabetesPedigreeFunction):
- Glucose (mg/dL)
- Blood Pressure (mmHg)
- Skin Thickness (mm)
- Insulin (mu U/ml)
- BMI
- Age (years)

---

## 📦 Dependencies

### Flutter
- `http` - API calls
- `shared_preferences` - Local storage
- `google_fonts` - Typography
- `flutter_animate` - Animations
- `provider` - State management
- `connectivity_plus` - Network monitoring
- `flutter_local_notifications` - Reminders

### Python
- `flask` - Web server
- `flask-cors` - CORS support
- `numpy` - Numerical operations
- `scikit-learn` - ML model loading

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

**Zaeem Hassan**

- GitHub: [@Zaeem-Hassan](https://github.com/Zaeem-Hassan)

---

## ⚠️ Disclaimer

This app is for **informational purposes only** and should not replace professional medical advice. Always consult a healthcare provider for medical decisions.
