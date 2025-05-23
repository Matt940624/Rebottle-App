## Overview

Rebottle is a cross-platform mobile application built with Flutter and Firebase that encourages recycling and sustainability through a rewards-based system. The app allows users to scan QR codes on recyclable bottles, earn points, and reach milestones while helping reduce waste and promoting environmental awareness.

## Features

- **QR Code Scanning**: Users can scan unique QR codes attached to recyclable bottles using their smartphone camera
- **Rewards System**: Earn points with each scan and track progress toward sustainability milestones
- **Role-Based Access**: Different experiences for customers and store owners
- **Store Owner Dashboard**: Track scans and customer milestones
- **User Authentication**: Secure login and account management through Firebase
- **Cross-Platform**: Works seamlessly on both iOS and Android devices

## Technical Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase
- **Database**: Cloud Firestore
- **Storage**: AWS
- **Authentication**: Firebase Authentication
- **Hosting**: Firebase Hosting

## Installation

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 2.17 or higher)
- Firebase CLI
- Android Studio / Xcode (for deployment)

### Setup Instructions

1. Clone the repository:
   ```
   git clone https://github.com/Matt940624/Rebottle-App.git
   ```

2. Navigate to the project directory:
   ```
   cd Rebottle-App
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Configure Firebase:
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files to your project
   - Enable Authentication, Firestore, and Storage in Firebase console

5. Run the app:
   ```
   flutter run
   ```

## How It Works

1. **Registration**: Users create an account selecting either customer or store owner role
2. **Bottle Registration** (Store Owners): Store owners can register bottles with unique QR codes
3. **Scanning**: Customers scan the QR code on bottles when recycling them
4. **Rewards**: Points are awarded for each scan, with milestones that unlock benefits
5. **Analytics**: Store owners can view analytics on recycling rates and user engagement

## Project Structure

```
lib/
  ├── models/         # Data models
  ├── screens/        # UI screens
  ├── services/       # Firebase and other services
  ├── utils/          # Utility functions
  ├── widgets/        # Reusable UI components
  ├── main.dart       # Entry point
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

