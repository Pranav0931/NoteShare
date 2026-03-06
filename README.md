# NoteShare

**Study Together** - Share knowledge with your college

A Flutter mobile application for students to share and discover study notes with their peers.

## Features

- **Splash Screen** - Animated logo with loading indicator
- **Login/Signup** - Google and Email authentication options
- **Home Feed** - Browse uploaded notes with category filters
- **Search** - Find notes by subject, semester, and branch
- **Upload Notes** - Share your study materials with others
- **Note Details** - View, download, and review notes
- **User Profile** - Track uploads, downloads, and saved notes
- **Leaderboard** - Top contributors ranking

## Project Structure

```
lib/
├── main.dart                    # App entry point with routes
├── models/
│   ├── note.dart               # Note data model
│   └── user.dart               # User data model
├── screens/
│   ├── splash_screen.dart      # Splash screen with animation
│   ├── login_screen.dart       # Login/Signup screen
│   ├── home_screen.dart        # Home feed with notes
│   ├── search_screen.dart      # Search and filter notes
│   ├── upload_screen.dart      # Upload new notes
│   ├── note_details_screen.dart # Note details and reviews
│   ├── profile_screen.dart     # User profile
│   └── leaderboard_screen.dart # Top contributors
└── widgets/
    ├── note_card.dart          # Reusable note card
    ├── filter_chip.dart        # Filter chips and dropdowns
    ├── user_avatar.dart        # User avatar components
    └── bottom_nav_bar.dart     # Bottom navigation bar
```

## Design

- **Primary Color**: #136DEC (Blue)
- **Font**: Lexend
- **Style**: Modern, clean Material Design
- **Corner Radius**: 8-16px rounded corners

## Getting Started

1. Make sure you have Flutter installed
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Dependencies

- flutter
- cupertino_icons
- google_fonts

## Screenshots

The app follows the UI design from Stitch with:
- Clean card-based layouts
- Smooth animations
- Consistent spacing and typography
- Intuitive navigation

## License

MIT License
