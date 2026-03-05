# DesiDeals

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Firestore-yellow.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> A community-driven iOS app for discovering deals, events, and listings in the desi community.

## 🚀 Features

- **Deals & Discounts** - Browse and redeem exclusive deals from local vendors
- **Events** - Discover and RSVP to community events
- **Community Listings** - Buy, sell, and rent items within the community
- **Vendor Profiles** - Connect with local businesses and restaurants
- **User Profiles** - Track redemptions and manage your activity
- **Maps Integration** - Find deals and events near you

## 🏗️ Architecture

```
DesiDeals/
├── DesiDeals/
│   ├── Models/           # Data models (Deal, Event, User, Vendor, etc.)
│   ├── Views/            # SwiftUI views
│   ├── ViewModels/       # Business logic and state management
│   ├── Services/         # API and data services
│   ├── Data/             # Mock data for development
│   └── Resources/        # Images and assets
└── DesiDeals.xcodeproj/  # Xcode project
```

## 🛠️ Tech Stack

- **Language:** Swift 5.9
- **UI Framework:** SwiftUI
- **Backend:** Firebase (Firestore, Authentication, Storage)
- **Minimum iOS:** 17.0
- **Architecture:** MVVM (Model-View-ViewModel)

## 📋 Prerequisites

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ device or simulator
- Firebase account (for backend services)

## 🔧 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/d3703306-tech/DesiDeals.git
   cd DesiDeals
   ```

2. **Open in Xcode:**
   ```bash
   open DesiDeals.xcodeproj
   ```

3. **Setup Firebase:**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add an iOS app with bundle ID: `com.mobasyalabs.desi.deals`
   - Download `GoogleService-Info.plist`
   - Add it to the `DesiDeals/` folder in Xcode

4. **Build and Run:**
   - Select your target device/simulator
   - Press `Cmd+R` or click the Run button

## 🌿 Branch Strategy

We follow **Git Flow** workflow:

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready releases |
| `develop` | Integration branch for features |
| `feature/*` | New features and enhancements |
| `hotfix/*` | Urgent production fixes |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request to `develop` branch

## 🔒 Security

- Never commit `GoogleService-Info.plist` (already in `.gitignore`)
- Keep API keys and secrets in environment variables
- Report security vulnerabilities to [security@mobasyalabs.com](mailto:security@mobasyalabs.com)

## 📝 License

This project is proprietary software owned by **Mobasya Labs**.

## 👥 Team

- **Company:** Mobasya Labs
- **Bundle ID:** com.mobasyalabs.desi.deals

---

<p align="center">Built with ❤️ by Mobasya Labs</p>
