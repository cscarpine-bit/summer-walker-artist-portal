# Summer Walker Artist Portal

A modern Flutter web application for Summer Walker's artist portal, featuring content management, live streaming capabilities, and premium content access.

## Features

- **Home Dashboard**: Analytics overview and quick actions
- **Live Streaming**: Go live functionality with camera preview
- **Content Management**: Posts and media management
- **Profile Management**: User profile and settings
- **Premium Content**: Subscription-based exclusive content
- **Admin Dashboard**: Content management tools

## Tech Stack

- **Frontend**: Flutter Web
- **Styling**: Custom theme system with brand colors
- **State Management**: Flutter's built-in state management
- **Deployment**: GitHub Pages with GitHub Actions

## Getting Started

### Prerequisites

- Flutter SDK (3.16.0 or higher)
- Dart SDK
- Git

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd summerwalkerFLUTTER
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app locally:
```bash
flutter run -d chrome
```

4. Build for web:
```bash
flutter build web --release
```

## Deployment

This app is automatically deployed to GitHub Pages using GitHub Actions. Simply push to the main branch and the app will be built and deployed automatically.

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   └── themes/
├── features/
│   ├── admin/
│   ├── auth/
│   └── content/
└── main.dart
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is proprietary and confidential.
