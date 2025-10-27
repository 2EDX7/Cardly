# Cardly

## Overview
Cardly is a student-built Flutter app aims to simplify networking by keeping contact information digital, searchable, and always available on mobile devices. It started as part of the ENSIA Mobile Development Module and is developed by a student team to learn best practices in Flutter development and collaboration.

## Features
- Create and edit digital business cards (name, title, company, phone, email, links, avatar).
- Generate and scan QR codes for quick sharing.
- Import contacts manually; planned OCR support to scan physical cards.
- Local storage (SQLite / SharedPreferences) for offline use.
- Tag and organize contacts into categories.
- Export/backup functionality planned.

## Team
- [Zakaria Chetouane](https://github.com/zakaria-chetouane): UI/UX Designer, Developer 
- [Akram Seddik](https://github.com/akr-sed): Developer
- [Abdelhak Benbouziane](https://github.com/AbdelhakBen922): Developer
- [Abderrahmen Mehaddi](https://github.com/AbderrahmenMEHADDI): Developer

## Project structure
```
lib/
├─ models/        # Data models (UserCard, Contact, Tag)
├─ screens/       # App screens (Home, Editor, Scanner, Profile)
├─ widgets/       # Reusable UI components
├─ services/      # Storage, QR, image, (future) API clients
├─ providers/     # State management (Provider / ChangeNotifier)
├─ utils/         # Constants, helpers
└─ main.dart      # App entry point
```

## Tech stack
- Flutter & Dart (mobile UI)
- Local storage: SQLite / SharedPreferences
- State management: Provider (or ChangeNotifier)
- Optional: Firebase / Supabase for future backend and sync
- Tools: Git, GitHub, Figma (design)


## License
This project is licensed under the MIT License. See LICENSE for details.

## Roadmap / Future work
- Add OCR-based card scanning.
- Cloud backup and multi-device sync.
- NFC support for tap-to-share.
- Dark theme and accessibility improvements.
- Third-party integrations (LinkedIn, Google Contacts).
