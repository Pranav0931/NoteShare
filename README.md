# NoteShare

**Study Together** - Share knowledge with your college

A Flutter mobile application for students to share and discover study notes with their peers. Designed as a **crowdsourced academic library for a single college** — structured for future multi-college expansion. Fully wired to **Supabase** for authentication, database, file storage, and admin moderation.

## Features

- **Splash Screen** - Animated logo with auth state routing
- **Login/Signup** - Email/password and Google OAuth authentication
- **College Setup** - Select college, branch, and semester at signup
- **Home Feed** - Browse approved notes with subject category filters, pull-to-refresh
- **Exam Survival Mode** - Quick revision: most downloaded, short notes, important questions, previous year papers
- **Search** - Find notes by subject, semester, branch, and keyword with live Supabase queries
- **Upload Notes** - Real file picker (PDF, images, documents) with Supabase Storage upload
- **Note Details** - View, download (opens file URL), save/unsave, write & read peer reviews
- **User Profile** - Live uploaded/saved/downloaded notes, logout, admin panel access
- **Leaderboard** - Top contributors ranked by uploads, downloads received, and community score
- **Admin Moderation Panel** - Approve or reject pending note uploads (admin role only)
- **Note Trust System** - Each note shows uploader name, branch, and semester

## Project Structure

```
lib/
├── main.dart                        # App entry point with routes & Supabase init
├── config/
│   ├── college_config.dart          # College, branch, semester, subject constants
│   └── supabase_config.dart         # Supabase URL & anon key configuration
├── services/
│   └── supabase_service.dart        # Supabase backend service (auth, CRUD, storage)
├── models/
│   ├── note.dart                    # Note, Review, Download, SavedNote models
│   └── user.dart                    # User (with role), LeaderboardEntry models
├── screens/
│   ├── splash_screen.dart           # Splash → auth check → route
│   ├── login_screen.dart            # Email/password + Google OAuth
│   ├── college_setup_screen.dart    # College/Branch/Semester selection → Supabase
│   ├── home_screen.dart             # Live note feed with save/unsave
│   ├── exam_survival_screen.dart    # Exam mode (tabbed, filtered, live data)
│   ├── search_screen.dart           # Real-time search with Supabase filters
│   ├── upload_screen.dart           # File picker + Supabase Storage upload
│   ├── note_details_screen.dart     # Download, save, reviews (read & write)
│   ├── profile_screen.dart          # Live profile, logout, admin access
│   ├── leaderboard_screen.dart      # College-scoped leaderboard from Supabase
│   └── admin_screen.dart            # Admin moderation: approve/reject pending notes
└── widgets/
    ├── note_card.dart               # Note card with file type & trust badge
    ├── filter_chip.dart             # Filter chips and dropdowns
    ├── user_avatar.dart             # User avatar components
    └── bottom_nav_bar.dart          # Bottom navigation bar

supabase/
└── schema.sql                       # Full database schema, RLS policies, functions
```

## Architecture

### College Hierarchy
```
College → Branch → Semester → Subject → Notes
```
Single college at launch, database structured for easy multi-college expansion.

### Data Flow
```
Upload → Pending Review → Admin Approves/Rejects → Approved notes visible in Feed/Search
```

### Auth Flow
```
Splash → Check Session → Login (email/Google) → College Setup (first time) → Home
```

### Supabase Backend
- **Authentication**: Email/password signup + Google OAuth
- **Database Tables**: colleges, users (with role), notes, downloads, saved_notes, reviews
- **Storage Bucket**: notes-files (PDFs, images, documents)
- **Row Level Security**: Policies for read/write access, admin moderation
- **Functions**: increment_download_count, increment_upload_count, recalculate_user_points, is_admin

### User Roles
| Role    | Capabilities                                  |
|---------|-----------------------------------------------|
| student | Upload, download, save, review notes           |
| admin   | All student capabilities + approve/reject notes |

### Leaderboard Scoring
```
Points = (uploads × 10) + (downloads received × 2) + community_score
```

## Design

- **Primary Color**: #136DEC (Blue)
- **Accent Color**: #FF6B35 (Exam Survival Mode)
- **Font**: Lexend
- **Style**: Modern, clean Material Design 3
- **Corner Radius**: 8-16px rounded corners

## Getting Started

1. Make sure you have Flutter installed (SDK >=3.0.0)
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Set up a Supabase project:
   - Run `supabase/schema.sql` in the SQL editor
   - Create a `notes-files` storage bucket (public)
   - Enable **Email** auth provider
   - Enable **Google** auth provider (see Google OAuth Setup below)
5. Update `lib/config/supabase_config.dart` with your Supabase URL and anon key
6. In Supabase → Authentication → URL Configuration → **Redirect URLs**, add:
   ```
   io.supabase.noteshare://login-callback/
   ```
7. Run `flutter run` to start the app
8. To make a user an admin, update their `role` to `'admin'` in the users table

## Google OAuth Setup

Google sign-in requires **two separate OAuth clients** in Google Cloud Console:

### 1. Android Client (for the Flutter app)
- Go to [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials
- Create OAuth 2.0 Client ID → **Android**
- Package name: `com.noteshare.noteshare`
- SHA-1 fingerprint: run the command below to get it
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

### 2. Web Application Client (for Supabase)
- Create OAuth 2.0 Client ID → **Web application**
- Under **Authorized redirect URIs**, add:
  ```
  https://<your-supabase-project-ref>.supabase.co/auth/v1/callback
  ```
- Copy the **Client ID** and **Client Secret** from this client (not the Android one)

### 3. Configure Supabase
- Go to Supabase → Authentication → Providers → **Google**
- Paste the **Web Application** Client ID and Client Secret
- Save

> The Android Client ID is used by Google internally to verify the app. The Web Application client is what Supabase uses to exchange tokens.

## Dependencies

- flutter
- cupertino_icons
- google_fonts
- supabase_flutter
- file_picker
- path
- url_launcher

## Note File Types

| Type     | Extensions          |
|----------|---------------------|
| PDF      | .pdf                |
| Image    | .jpg, .png, .jpeg   |
| Document | .doc, .docx         |

## Note Categories

- Regular Notes
- Short Notes
- Important Questions
- Previous Year Papers

## License

MIT License
