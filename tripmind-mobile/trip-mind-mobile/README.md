# 📱 TripMind — AI-Powered Travel Planner

An iOS app built with **SwiftUI** that lets users plan trips through an AI-driven chat interface.  
Users can generate itineraries, view trip previews, save trips, and manage their profile — all inside a beautiful, minimalist UI.

---

## 🚀 Features

### ✨ AI Trip Planning  
- Chat-based interface powered by a backend AI  
- Dynamic questions & guided flow  
- Auto-generated itineraries with hotels, activities, and day-by-day plans  

### 📚 Saved Itineraries  
- Save and revisit previously created trips  
- Detailed itinerary preview and full breakdown  
- Robust decoding system for TripPlan JSON  

### 👤 User Authentication  
- Registration, login, logout  
- JWT stored securely in Keychain  
- Auto-login with stored token  

### 🎨 Modern UI  
- Built with SwiftUI & custom Design System  
- Clean spacing, colors, and layout rules  
- Adaptive UI for all iPhone sizes

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| Language | Swift 5.10+ |
| Framework | SwiftUI |
| Networking | URLSession (async/await) |
| Auth | JWT + Keychain |
| State | ObservableObject + @Published |
| Backend | Spring Boot API |
| AI | Custom itinerary generator API |

---

## 📂 Project Structure

```
trip-mind-mobile/
│
├── Models/
│   ├── Itinerary.swift
│   ├── TripPlan.swift
│   └── User.swift
│
├── ViewModels/
│   ├── ChatViewModel.swift
│   ├── AuthManager.swift
│   └── ItinerariesListViewModel.swift
│
├── Views/
│   ├── PlanView.swift
│   ├── ChatInputView.swift
│   ├── ChatBubbleView.swift
│   ├── ItineraryPreviewView.swift
│   ├── ItineraryDetailView.swift
│   ├── ProfileView.swift
│   ├── LoginView.swift
│   ├── RegisterView.swift
│   └── MainTabView.swift
│
├── Services/
│   ├── APIClient.swift
│   ├── KeychainService.swift
│   └── Validators.swift
│
└── DesignSystem/
    ├── DesignSystem.swift
    └── Colors.swift
```

---

## ⚙️ Setup Instructions

### 1️⃣ Clone the repo  
```sh
git clone https://github.com/your-username/trip-mind-mobile.git
cd trip-mind-mobile
```

### 2️⃣ Install dependencies (Can be skipped because there is no external dependencies)
If using Swift Package Manager:  
- Open the project  
- Xcode will resolve packages automatically  

If using CocoaPods:  
```sh
pod install
open trip-mind-mobile.xcworkspace
```

### 3️⃣ Set backend API  
Create a file:

```
trip-mind-mobile/Config/.env
```

Add:

```
API_BASE_URL=https://your-api-url-here.com
```

### 4️⃣ Run the project  
Open in Xcode → choose simulator/device → **⌘ + R**

---

## 🔐 Authentication Details

- JWT token stored securely in **Keychain**  
- App automatically restores session on next launch  
- Invalid/missing token → user logged out  

---

## 📬 API Requirements

Your backend must provide:

| Endpoint | Method | Description |
|---------|--------|-------------|
| `/api/auth/register` | POST | Register new user |
| `/api/auth/login` | POST | Login, returns JWT |
| `/api/users/me` | GET | Validate current token |
| `/api/ai/itinerary` | POST | Generate TripPlan |
| `/api/itineraries` | POST | Save a trip |
| `/api/itineraries` | GET | List saved trips |
| `/api/itineraries/{id}` | GET | Get single trip |

---

## 🎨 Design System Overview

- **Primary color:** `#6B46C1`  
- **Spacing scale:** 4, 8, 12, 16, 24, 32  
- **Radius scale:** 6, 8, 10, 12  
- **Typography scale:** 12 → 30pt  
- **Touch target:** 44pt buttons  
- Unified system across components.

---

## 📸 Screenshots  
The design is implemented in Figma, and the link will be attached soon!
---

## 👤 Author

**KBTU Students**   
Passionate about AI-powered travel experiences.

---
