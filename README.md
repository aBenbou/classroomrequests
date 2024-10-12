# RSVNow - A mobile Application for to place request regarding classroom in a school/ university

## Overview
**RSVNow** is mobile application to automate room management within the university. It targets three types of users: professors, security personnel, and administrators.

## Features
- **Classroom management following a schedule**: 
  - managing rooms, reservations, and user accounts while adhering to specific management rules.

- **Personnalized experience**:
  - Distinct interfaces for each user type, offering tailored functionalities to meet their needs.

- **User Account Management**:
  - Administrators are responsible for managing user accounts, including creating new accounts, suspending accounts as necessary, and overseeing user information to ensure effective access control to the application.

- **Event Notifications**:
  - The application automatically notifies security personnel when a professor requests the opening of a reserved room. This feature enables instant communication, ensuring effective coordination for the safety of the premises.

## Technologies Used
- **Front-end**: Flutter
- **Back-end**: Dart
- **Database**: Firebase firestore
- **Email Notifications**: Automatic email updates for request status

## Getting Started

To run the project locally, you will need Flutter installed. For installation instructions, follow the official [Flutter documentation](https://flutter.dev/docs/get-started/install).

### Prerequisites

- Flutter SDK
- Firebase Account (Firestore for data management)

### Installation

1. Clone the repository:
   git clone https://github.com/aBenbou/classroomrequests
   cd classroomrequests


2. **Install Dependencies**:
   Run the following command to install all necessary Flutter packages:
      flutter pub get
   
3. **Set Up Firebase**:
   Follow the official Firebase setup instructions for Flutter.
   Add google-services.json (for Android) and GoogleService-Info.plist (for iOS) to the respective platforms.

4. **Run the App**:
   To launch the app on your device or emulator, use the command:
      flutter run