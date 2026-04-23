# NoteShare

**A modern Flutter app for college students to upload, discover, save, review, and download academic notes inside a trusted campus ecosystem.**

NoteShare turns scattered study material into a searchable, moderated, college-first notes library. Students can share PDFs, images, documents, previous year papers, short notes, and important questions, while admins keep the feed clean through Supabase-powered moderation.

## Repository Description

NoteShare is a production-oriented Flutter and Supabase mobile app for student note sharing, academic resource discovery, campus collaboration, reviews, saved notes, downloads, leaderboards, and admin moderation.

## Tags

`flutter` `dart` `supabase` `mobile-app` `android` `material-design-3` `student-app` `notes-sharing` `college-app` `education` `authentication` `google-login` `supabase-auth` `supabase-database` `supabase-storage` `row-level-security` `file-upload` `admin-panel` `leaderboard` `open-source`

## Highlights

- Email/password authentication, Google OAuth, session persistence, logout, and password reset support
- Guided college setup with college, branch, and semester profile fields
- Home feed for approved notes with filters and pull-to-refresh
- Search by keyword, subject, semester, and branch
- Upload flow for PDFs, images, DOC, and DOCX files through Supabase Storage
- Note details with download tracking, save/unsave, ratings, and peer reviews
- Exam Survival Mode for short notes, important questions, previous year papers, and top downloaded resources
- Profile screen with uploaded, saved, and downloaded notes
- College-scoped leaderboard for contributor ranking
- Admin moderation panel for approving or rejecting uploaded notes
- Supabase schema with tables, RLS policies, helper functions, storage policies, and triggers
- Material Design 3 UI with a clean blue academic brand and dark mode foundation

## Screens And Flows

### Authentication

```text
Splash -> Existing session check -> Login / Signup -> College setup -> Home
```

Auth is powered by Supabase and supports:

- Email signup
- Email login
- Google OAuth login on Android
- Forgot password flow
- Session persistence after app restart
- Profile creation after first login
- Logout and auth-state routing

### Notes Lifecycle

```text
Student upload -> Pending review -> Admin approval -> Feed/Search visibility
```

Uploaded notes are submitted as pending by default. Admin users can review and approve/reject submissions before they appear in public feeds.

### College Model

```text
College -> Branch -> Semester -> Subject -> Notes
```

The app is currently configured for a single-college launch and structured for future multi-college expansion.

## Tech Stack

| Layer | Technology |
| --- | --- |
| Mobile app | Flutter |
| Language | Dart with null safety |
| Design system | Material Design 3 |
| Auth | Supabase Auth |
| Database | Supabase Postgres |
| Storage | Supabase Storage |
| Backend rules | Row Level Security policies |
| Android build | Gradle / Kotlin Android |

## Core Features

### Student Features

- Create an account or sign in with email/password
- Continue with Google on Android
- Complete college profile setup
- Browse approved notes in the home feed
- Search academic resources with filters
- Upload notes and documents
- Save and unsave useful notes
- Download note files
- Write and read peer reviews
- Track uploaded, saved, and downloaded notes from profile
- View contributor leaderboard

### Admin Features

- View pending uploads
- Approve valid notes
- Reject unsuitable notes
- Keep the public feed curated and relevant

## Project Structure

```text
lib/
  main.dart
  config/
    college_config.dart
    supabase_config.dart
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
    supabase_service.dart
  widgets/
    bottom_nav_bar.dart
    filter_chip.dart
    note_card.dart
    user_avatar.dart

supabase/
  schema.sql

android/
  app/
    build.gradle.kts
    src/main/AndroidManifest.xml
```

## Supabase Data Model

The included `supabase/schema.sql` defines:

- `colleges`
- `users`
- `notes`
- `downloads`
- `saved_notes`
- `reviews`

It also includes:

- Row Level Security policies
- Profile creation function
- Upload/download counter functions
- Leaderboard point recalculation
- Admin role helper
- Review rating trigger
- Storage bucket policies for `notes-files`

## Getting Started

### Prerequisites

- Flutter SDK installed
- Android Studio or Android SDK installed
- A Supabase project
- Google Cloud OAuth credentials if using Google Sign-In

### Setup

1. Clone the repository.

   ```bash
   git clone https://github.com/Pranav0931/NoteShare.git
   cd NoteShare
   ```

2. Install dependencies.

   ```bash
   flutter pub get
   ```

3. Create a Supabase project.

4. Run the SQL schema from `supabase/schema.sql` in the Supabase SQL editor.

5. Confirm the `notes-files` storage bucket exists and is public.

6. Set Supabase credentials via Dart defines:

   ```bash
   export SUPABASE_URL="https://<your-project-ref>.supabase.co"
   export SUPABASE_ANON_KEY="<your-anon-key>"
   ```

7. Add this redirect URL in Supabase Authentication URL settings:

   ```text
   io.supabase.noteshare://login-callback/
   ```

8. Run the app.

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=$SUPABASE_URL \
     --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
   ```

## Google Sign-In Setup

Google login requires configuration in both Google Cloud and Supabase.

### Android OAuth Client

- Create an Android OAuth client in Google Cloud Console
- Package name:

  ```text
  com.noteshare.noteshare
  ```

- Add the SHA-1 certificate fingerprint for your debug or release keystore

### Web OAuth Client

- Create a Web OAuth client in Google Cloud Console
- Add this authorized redirect URI:

  ```text
  https://<your-supabase-project-ref>.supabase.co/auth/v1/callback
  ```

### Supabase Provider

- Enable Google provider in Supabase Auth
- Paste the Web OAuth Client ID and Client Secret
- Save provider settings

## Android Release Notes

The Android app is configured with:

- Package ID: `com.noteshare.noteshare`
- Deep link scheme: `io.supabase.noteshare://login-callback/`
- Internet permission
- Multidex enabled
- Min SDK: 23
- Release signing support through `android/key.properties`

Example `android/key.properties`:

```properties
storeFile=../upload-keystore.jks
storePassword=your-store-password
keyAlias=upload
keyPassword=your-key-password
```

Build a release APK:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Design System

- Primary color: `#136DEC`
- Exam accent: `#FF6B35`
- Typography: Lexend
- UI style: clean, rounded, student-friendly Material Design 3
- Theme: light theme with dark mode foundation

## Suggested GitHub Topics

Use these repository topics for discoverability:

```text
flutter, dart, supabase, mobile-app, android, material-design-3, student-app, notes-sharing, college-app, education, authentication, google-login, supabase-auth, supabase-database, supabase-storage, row-level-security, file-upload, admin-panel, leaderboard
```

## Roadmap

- Add production-grade state management
- Add pagination for large note feeds
- Add document preview support
- Add push notifications for approvals and reviews
- Add richer admin analytics
- Add multi-college onboarding
- Add tests for auth, upload, and Supabase service behavior

## License

MIT License
