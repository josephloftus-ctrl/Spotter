# Spotter

An offline-first iOS fitness tracking app built with SwiftUI and SwiftData.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue)
![SwiftData](https://img.shields.io/badge/SwiftData-green)

## Overview

Spotter is designed around the user's existing training rhythm. It's not a coach that tells you what to do — it's a quiet observer that surfaces insights, tracks progress, and adapts to your plan.

The core philosophy: the app should feel like an extension of the mental inventory a lifter does on the way to the gym.

## Features

- **Frictionless Logging** - One-thumb operation with large tap targets for gym use
- **Training Plans** - Create and follow structured workout programs
- **Session Tracking** - Log sets, reps, weight, and RPE
- **Progress Charts** - Visualize estimated 1RM and volume trends
- **Exercise Library** - 34 pre-loaded exercises with muscle group tags
- **Pain Tracking** - Monitor recurring discomfort patterns
- **Offline-First** - All data stored locally with SwiftData

## Screenshots

*Coming soon*

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/josephloftus-ctrl/Spotter.git
   ```

2. Open `Spotter.xcodeproj` in Xcode

3. Build and run on simulator or device (⌘+R)

## Project Structure

```
Spotter/
├── SpotterApp.swift          # App entry point
├── ContentView.swift         # Main tab navigation
├── Models/                   # SwiftData models
├── Views/
│   ├── Today/               # Home screen components
│   ├── Session/             # Active workout logging
│   ├── History/             # Past session review
│   ├── Trends/              # Progress charts
│   ├── Settings/            # App configuration
│   └── Plan/                # Training plan setup
├── Utilities/               # Helpers and extensions
├── Services/                # Business logic
└── Resources/               # Assets and data files
```

## Architecture

- **MVVM** with observable state
- **SwiftData** for persistence
- **Swift Charts** for visualizations

## Building

### Local Build
```bash
xcodebuild -project Spotter.xcodeproj -scheme Spotter -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### GitHub Actions
The project includes a GitHub Actions workflow that automatically builds an unsigned IPA on every push to `main`. Download artifacts from the Actions tab.

## Roadmap

### v1.0 (Current)
- [x] Core logging flow
- [x] SwiftData persistence
- [x] Manual plan creation
- [x] History with calendar view
- [x] Basic trends and charts

### v1.1 (Planned)
- [ ] Claude API plan assistant
- [ ] HealthKit integration
- [ ] Insight engine
- [ ] Rest timer

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

## Acknowledgments

Built with Claude Code by Anthropic.
