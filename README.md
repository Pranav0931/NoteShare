# NoteShare

A Flutter + Firebase app where college students can **upload, discover, save, review, and download** academic notes in a moderated, campus-first library.

> **Status:** actively developed • **Platform:** Android-first (Flutter) • **Backend:** Firebase (Auth, Firestore) + External Link File Uploads

## Why NoteShare?
Study material is usually scattered across WhatsApp groups, drive links, and random PDFs. NoteShare brings it into one place with:

- **Moderation** (uploads go to *Pending* → *Approved/Rejected*)
- **Search + filters** by keyword/subject/semester/branch
- **Reviews & ratings** to highlight useful notes
- **Downloads + saves** to build a personal library
- **Leaderboards** to reward contributions (college-scoped)

## Key Features

### Student
- Email/password auth + Google OAuth (Android)
- College profile setup (college / branch / semester)
- Home feed of **approved** notes
- Upload external file links (Google Drive, Dropbox, etc.) to the platform
- Save/unsave, download tracking
- Rate & review notes
- Profile: uploaded / saved / downloaded
- Exam Survival Mode (short notes, PYQs, important questions)

### Admin
- Review pending uploads
- Approve / reject submissions
- Keep the public feed curated

## App Flow (High level)

```text
Splash → Session check → Login/Signup → College setup → Home

Student upload → Pending review → Admin approval → Feed/Search
```

## Tech Stack

| Layer | Technology |
| --- | --- |
| Mobile | Flutter |
| Language | Dart (null safety) |
| UI | Material Design 3 |
| Auth | Firebase Auth |
| DB | Firebase Firestore |
| Storage | External Link-based file uploads (zero-cost architecture) |
| Security | Firestore Security Rules |

## Project Structure

```text
lib/
  main.dart
  config/
    college_config.dart
    firebase_config.dart
  models/
    note.dart
    user.dart
  screens/
    admin_screen.dart
    college_setup_screen.dart
    exam_survival_screen.dart
    home_screen.dart
    leaderboard_screen.dart
    login_screen.dart
    note_details_screen.dart
    profile_screen.dart
    search_screen.dart
    splash_screen.dart
    upload_screen.dart
  services/
    firebase_service.dart
  widgets/
    bottom_nav_bar.dart
    filter_chip.dart
    note_card.dart
    user_avatar.dart

firebase/
  firestore.rules
```

## Firebase Firestore Schema
The Firestore database includes collections like:

- `colleges`, `users`, `notes`, `downloads`, `saved_notes`, `reviews`
- Firestore security rules for access control and moderation validation

## Getting Started

### Prerequisites
- Flutter SDK
- Android Studio / Android SDK
- A Firebase project

### Setup
1. Clone:

   ```bash
   git clone https://github.com/Pranav0931/NoteShare.git
   cd NoteShare
   ```

2. Install deps:

   ```bash
   flutter pub get
   ```

3. Create a Firebase project.

4. Add `google-services.json` to your `android/app/` directory (you can download it from the Firebase console).

5. Run the app:

   ```bash
   flutter run
   ```

## Google Sign-In (Android)
1. In Firebase Console → Authentication → Sign-in method:
   - Enable Google Sign-In.

2. Ensure you have added the SHA-1 and SHA-256 fingerprints to your Firebase Android app configuration.

## Roadmap (ideas)
- Pagination for large feeds
- Push notifications (approvals, reviews)
- Multi-college onboarding
- Automated tests (auth/upload/service)

## License
MIT (recommended). Add a LICENSE file if you want this to be explicit.
