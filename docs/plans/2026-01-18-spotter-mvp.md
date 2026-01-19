# Spotter iOS MVP Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an offline-first iOS fitness tracking app with frictionless workout logging, session history, and basic progress trends.

**Architecture:** MVVM with SwiftUI and SwiftData. Tab-based navigation with modal presentation for active sessions. Observable view models manage state and business logic.

**Tech Stack:** Swift 5.9+, SwiftUI, SwiftData, iOS 17+, Swift Charts

---

## Prerequisites

- macOS with Xcode 15+ installed
- iOS 17+ simulator or device for testing
- Basic familiarity with SwiftUI and SwiftData

---

## Task 1: Create Xcode Project

**Files:**
- Create: Xcode project "Spotter" (iOS App, SwiftUI, SwiftData)

**Step 1: Create new Xcode project**

1. Open Xcode → File → New → Project
2. Select iOS → App
3. Configure:
   - Product Name: `Spotter`
   - Team: Your development team
   - Organization Identifier: `com.yourname`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData
   - Include Tests: Yes
4. Save to `/home/joseph/Documents/Spotter/`

**Step 2: Verify project structure**

Confirm these files exist:
- `Spotter/SpotterApp.swift`
- `Spotter/ContentView.swift`
- `Spotter/Item.swift` (delete this - it's the template model)

**Step 3: Configure deployment target**

In project settings, set:
- iOS Deployment Target: 17.0

**Step 4: Commit**

```bash
git init
git add .
git commit -m "chore: initial Xcode project setup"
```

---

## Task 2: Create Project Directory Structure

**Files:**
- Create: Directory structure for organized codebase

**Step 1: Create folder structure in Xcode**

Create these groups in Xcode (right-click Spotter folder → New Group):

```
Spotter/
├── Models/
├── Views/
│   ├── Today/
│   ├── Session/
│   ├── History/
│   ├── Trends/
│   └── Settings/
├── ViewModels/
├── Services/
├── Utilities/
└── Resources/
```

**Step 2: Delete template files**

Delete `Item.swift` (the default SwiftData model)

**Step 3: Commit**

```bash
git add .
git commit -m "chore: create project directory structure"
```

---

## Task 3: Create WeightUnit Enum

**Files:**
- Create: `Spotter/Models/WeightUnit.swift`

**Step 1: Create the enum file**

```swift
import Foundation

enum WeightUnit: String, Codable, CaseIterable {
    case lbs
    case kg

    var displayName: String {
        switch self {
        case .lbs: return "lbs"
        case .kg: return "kg"
        }
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add WeightUnit enum"
```

---

## Task 4: Create ExerciseModality Enum

**Files:**
- Create: `Spotter/Models/ExerciseModality.swift`

**Step 1: Create the enum file**

```swift
import Foundation

enum ExerciseModality: String, Codable, CaseIterable {
    case barbell
    case dumbbell
    case machine
    case cable
    case bodyweight
    case cardio
    case climb
    case other

    var displayName: String {
        switch self {
        case .barbell: return "Barbell"
        case .dumbbell: return "Dumbbell"
        case .machine: return "Machine"
        case .cable: return "Cable"
        case .bodyweight: return "Bodyweight"
        case .cardio: return "Cardio"
        case .climb: return "Climb"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .machine: return "gearshape.fill"
        case .cable: return "cable.connector"
        case .bodyweight: return "figure.walk"
        case .cardio: return "heart.fill"
        case .climb: return "mountain.2.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add ExerciseModality enum"
```

---

## Task 5: Create Exercise Model

**Files:**
- Create: `Spotter/Models/Exercise.swift`

**Step 1: Create the SwiftData model**

```swift
import Foundation
import SwiftData

@Model
class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var muscleGroups: [String]
    var modality: ExerciseModality
    var notes: String?
    var isCustom: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.exercise)
    var sets: [SetEntry] = []

    init(
        id: UUID = UUID(),
        name: String,
        muscleGroups: [String] = [],
        modality: ExerciseModality = .other,
        notes: String? = nil,
        isCustom: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.muscleGroups = muscleGroups
        self.modality = modality
        self.notes = notes
        self.isCustom = isCustom
        self.createdAt = createdAt
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build will fail (SetEntry not yet defined) - this is expected

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add Exercise SwiftData model"
```

---

## Task 6: Create Session Model

**Files:**
- Create: `Spotter/Models/Session.swift`

**Step 1: Create the SwiftData model**

```swift
import Foundation
import SwiftData

@Model
class Session {
    @Attribute(.unique) var id: UUID
    var date: Date
    var planDayName: String?
    var duration: TimeInterval?
    var sessionRPE: Int?
    var notes: String?
    var painTags: [String]
    var completedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.session)
    var sets: [SetEntry] = []

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        planDayName: String? = nil,
        duration: TimeInterval? = nil,
        sessionRPE: Int? = nil,
        notes: String? = nil,
        painTags: [String] = [],
        completedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.planDayName = planDayName
        self.duration = duration
        self.sessionRPE = sessionRPE
        self.notes = notes
        self.painTags = painTags
        self.completedAt = completedAt
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    var exerciseCount: Int {
        Set(sets.compactMap { $0.exercise?.id }).count
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build will fail (SetEntry not yet defined) - this is expected

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add Session SwiftData model"
```

---

## Task 7: Create SetEntry Model

**Files:**
- Create: `Spotter/Models/SetEntry.swift`

**Step 1: Create the SwiftData model**

```swift
import Foundation
import SwiftData

@Model
class SetEntry {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise?
    var session: Session?
    var weight: Double
    var weightUnit: WeightUnit
    var reps: Int
    var rpe: Int?
    var notes: String?
    var timestamp: Date
    var orderIndex: Int

    init(
        id: UUID = UUID(),
        exercise: Exercise? = nil,
        session: Session? = nil,
        weight: Double,
        weightUnit: WeightUnit = .lbs,
        reps: Int,
        rpe: Int? = nil,
        notes: String? = nil,
        timestamp: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = id
        self.exercise = exercise
        self.session = session
        self.weight = weight
        self.weightUnit = weightUnit
        self.reps = reps
        self.rpe = rpe
        self.notes = notes
        self.timestamp = timestamp
        self.orderIndex = orderIndex
    }

    var volume: Double {
        weight * Double(reps)
    }

    var displayWeight: String {
        let formatted = weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
        return "\(formatted) \(weightUnit.displayName)"
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded (all models now defined)

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add SetEntry SwiftData model"
```

---

## Task 8: Create TrainingPlan Models

**Files:**
- Create: `Spotter/Models/TrainingPlan.swift`
- Create: `Spotter/Models/PlanDay.swift`
- Create: `Spotter/Models/PlannedExercise.swift`

**Step 1: Create TrainingPlan model**

```swift
import Foundation
import SwiftData

@Model
class TrainingPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var daysPerWeek: Int
    var isActive: Bool
    var createdAt: Date
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \PlanDay.plan)
    var days: [PlanDay] = []

    init(
        id: UUID = UUID(),
        name: String,
        daysPerWeek: Int = 3,
        isActive: Bool = false,
        createdAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.daysPerWeek = daysPerWeek
        self.isActive = isActive
        self.createdAt = createdAt
        self.notes = notes
    }

    var sortedDays: [PlanDay] {
        days.sorted { $0.orderIndex < $1.orderIndex }
    }
}
```

**Step 2: Create PlanDay model**

```swift
import Foundation
import SwiftData

@Model
class PlanDay {
    @Attribute(.unique) var id: UUID
    var name: String
    var orderIndex: Int
    var plan: TrainingPlan?

    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.planDay)
    var exercises: [PlannedExercise] = []

    init(
        id: UUID = UUID(),
        name: String,
        orderIndex: Int = 0,
        plan: TrainingPlan? = nil
    ) {
        self.id = id
        self.name = name
        self.orderIndex = orderIndex
        self.plan = plan
    }

    var sortedExercises: [PlannedExercise] {
        exercises.sorted { $0.orderIndex < $1.orderIndex }
    }
}
```

**Step 3: Create PlannedExercise model**

```swift
import Foundation
import SwiftData

@Model
class PlannedExercise {
    @Attribute(.unique) var id: UUID
    var exerciseName: String
    var sets: Int
    var reps: String
    var notes: String?
    var orderIndex: Int
    var planDay: PlanDay?
    var exerciseId: UUID?

    init(
        id: UUID = UUID(),
        exerciseName: String,
        sets: Int = 3,
        reps: String = "8-12",
        notes: String? = nil,
        orderIndex: Int = 0,
        planDay: PlanDay? = nil,
        exerciseId: UUID? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.notes = notes
        self.orderIndex = orderIndex
        self.planDay = planDay
        self.exerciseId = exerciseId
    }

    var displayPrescription: String {
        "\(sets) × \(reps)"
    }
}
```

**Step 4: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add TrainingPlan, PlanDay, and PlannedExercise models"
```

---

## Task 9: Configure SwiftData Schema

**Files:**
- Modify: `Spotter/SpotterApp.swift`

**Step 1: Update the app entry point**

Replace the contents of `SpotterApp.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct SpotterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: configure SwiftData schema in app entry point"
```

---

## Task 10: Create Design Tokens

**Files:**
- Create: `Spotter/Utilities/DesignTokens.swift`

**Step 1: Create design tokens file**

```swift
import SwiftUI

// MARK: - Colors

extension Color {
    static let spotterPrimary = Color("SpotterPrimary")
    static let spotterSecondary = Color("SpotterSecondary")
    static let spotterBackground = Color("SpotterBackground")
    static let spotterSurface = Color("SpotterSurface")
    static let spotterText = Color("SpotterText")
    static let spotterTextSecondary = Color("SpotterTextSecondary")
    static let spotterSuccess = Color("SpotterSuccess")
    static let spotterWarning = Color("SpotterWarning")

    // Fallback colors if asset catalog not configured
    static let spotterPrimaryFallback = Color.blue
    static let spotterSecondaryFallback = Color.gray
    static let spotterBackgroundFallback = Color(uiColor: .systemBackground)
    static let spotterSurfaceFallback = Color(uiColor: .secondarySystemBackground)
    static let spotterTextFallback = Color(uiColor: .label)
    static let spotterTextSecondaryFallback = Color(uiColor: .secondaryLabel)
    static let spotterSuccessFallback = Color.green
    static let spotterWarningFallback = Color.orange
}

// MARK: - Fonts

extension Font {
    static let spotterTitle = Font.system(.title, design: .rounded, weight: .bold)
    static let spotterHeadline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let spotterBody = Font.system(.body, design: .default)
    static let spotterCaption = Font.system(.caption, design: .default)
    static let spotterLargeNumber = Font.system(size: 48, weight: .bold, design: .rounded)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Corner Radius

enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add design tokens for consistent styling"
```

---

## Task 11: Create Haptic Manager

**Files:**
- Create: `Spotter/Utilities/HapticManager.swift`

**Step 1: Create haptic manager**

```swift
import UIKit

enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // Convenience methods for common actions
    static func logSet() {
        impact(.medium)
    }

    static func completeExercise() {
        notification(.success)
    }

    static func completeSession() {
        notification(.success)
    }

    static func buttonTap() {
        impact(.light)
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add HapticManager for tactile feedback"
```

---

## Task 12: Create Date Formatters

**Files:**
- Create: `Spotter/Utilities/DateFormatters.swift`

**Step 1: Create date formatters**

```swift
import Foundation

enum DateFormatters {
    static let sessionDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let sessionTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    static func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    static func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return sessionDate.string(from: date)
        }
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add DateFormatters utility"
```

---

## Task 13: Create One Rep Max Calculator

**Files:**
- Create: `Spotter/Utilities/OneRepMaxCalculator.swift`

**Step 1: Create calculator**

```swift
import Foundation

enum OneRepMaxCalculator {
    /// Epley formula: 1RM = weight × (1 + reps/30)
    static func epley(weight: Double, reps: Int) -> Double {
        guard reps > 0 else { return weight }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30)
    }

    /// Brzycki formula: 1RM = weight × (36 / (37 - reps))
    static func brzycki(weight: Double, reps: Int) -> Double {
        guard reps > 0 && reps < 37 else { return weight }
        if reps == 1 { return weight }
        return weight * (36 / Double(37 - reps))
    }

    /// Default formula (using Epley)
    static func estimate(weight: Double, reps: Int) -> Double {
        epley(weight: weight, reps: reps)
    }

    /// Calculate estimated 1RM from a SetEntry
    static func estimate(from set: SetEntry) -> Double {
        estimate(weight: set.weight, reps: set.reps)
    }

    /// Find best estimated 1RM from a collection of sets
    static func bestEstimate(from sets: [SetEntry]) -> Double? {
        guard !sets.isEmpty else { return nil }
        return sets.map { estimate(from: $0) }.max()
    }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add OneRepMaxCalculator utility"
```

---

## Task 14: Create Main Tab View

**Files:**
- Modify: `Spotter/ContentView.swift`

**Step 1: Update ContentView with tab navigation**

Replace the contents of `ContentView.swift`:

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build will fail (views not yet created) - this is expected

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add main tab navigation structure"
```

---

## Task 15: Create TodayView

**Files:**
- Create: `Spotter/Views/Today/TodayView.swift`

**Step 1: Create TodayView**

```swift
import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query(filter: #Predicate<TrainingPlan> { $0.isActive }) private var activePlans: [TrainingPlan]

    @State private var showingActiveSession = false

    private var lastSession: Session? {
        sessions.first { $0.isCompleted }
    }

    private var activePlan: TrainingPlan? {
        activePlans.first
    }

    private var nextPlanDay: PlanDay? {
        guard let plan = activePlan else { return nil }
        let sortedDays = plan.sortedDays
        guard !sortedDays.isEmpty else { return nil }

        // Simple rotation: find last completed day and return next
        if let lastSession = lastSession,
           let lastDayName = lastSession.planDayName,
           let lastIndex = sortedDays.firstIndex(where: { $0.name == lastDayName }) {
            let nextIndex = (lastIndex + 1) % sortedDays.count
            return sortedDays[nextIndex]
        }

        return sortedDays.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Date Header
                    dateHeader

                    // Plan Day Indicator
                    if let planDay = nextPlanDay {
                        planDayIndicator(planDay)
                    }

                    // Last Session Card
                    if let session = lastSession {
                        LastSessionCard(session: session)
                    }

                    // Today's Session Preview
                    if let planDay = nextPlanDay {
                        TodaySessionCard(planDay: planDay)
                    }

                    // Start Session Button
                    startSessionButton
                }
                .padding()
            }
            .navigationTitle("Today")
            .fullScreenCover(isPresented: $showingActiveSession) {
                ActiveSessionView(planDay: nextPlanDay)
            }
        }
    }

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(DateFormatters.dayOfWeek.string(from: Date()))
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
            Text(DateFormatters.shortDate.string(from: Date()))
                .font(.spotterTitle)
        }
    }

    private func planDayIndicator(_ planDay: PlanDay) -> some View {
        HStack {
            Image(systemName: "figure.strengthtraining.traditional")
                .foregroundStyle(.spotterPrimaryFallback)
            Text(planDay.name)
                .font(.spotterHeadline)
            Spacer()
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var startSessionButton: some View {
        Button {
            HapticManager.buttonTap()
            showingActiveSession = true
        } label: {
            Text("Start Session")
                .font(.spotterHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.spotterPrimaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build will fail (subviews not yet created) - this is expected

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add TodayView main screen"
```

---

## Task 16: Create LastSessionCard

**Files:**
- Create: `Spotter/Views/Today/LastSessionCard.swift`

**Step 1: Create LastSessionCard**

```swift
import SwiftUI

struct LastSessionCard: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Last Session")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(DateFormatters.formatRelativeDate(session.date))
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }

            if let planDayName = session.planDayName {
                Text(planDayName)
                    .font(.spotterHeadline)
            }

            HStack(spacing: Spacing.lg) {
                statItem(
                    value: "\(session.exerciseCount)",
                    label: "exercises"
                )

                if let duration = session.duration {
                    statItem(
                        value: DateFormatters.formatDuration(duration),
                        label: "duration"
                    )
                }

                if let rpe = session.sessionRPE {
                    statItem(
                        value: "\(rpe)/5",
                        label: "feel"
                    )
                }
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.spotterHeadline)
            Text(label)
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let session = Session(
        planDayName: "Day A - Squat Focus",
        duration: 3600,
        sessionRPE: 4
    )

    return LastSessionCard(session: session)
        .padding()
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add LastSessionCard component"
```

---

## Task 17: Create TodaySessionCard

**Files:**
- Create: `Spotter/Views/Today/TodaySessionCard.swift`

**Step 1: Create TodaySessionCard**

```swift
import SwiftUI

struct TodaySessionCard: View {
    let planDay: PlanDay

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Today's Plan")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            ForEach(planDay.sortedExercises) { exercise in
                exerciseRow(exercise)
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func exerciseRow(_ exercise: PlannedExercise) -> some View {
        HStack {
            Text(exercise.exerciseName)
                .font(.spotterBody)
            Spacer()
            Text(exercise.displayPrescription)
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    let planDay = PlanDay(name: "Day A - Squat Focus", orderIndex: 0)

    return TodaySessionCard(planDay: planDay)
        .padding()
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add TodaySessionCard component"
```

---

## Task 18: Create ActiveSessionView

**Files:**
- Create: `Spotter/Views/Session/ActiveSessionView.swift`

**Step 1: Create ActiveSessionView**

```swift
import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let planDay: PlanDay?

    @State private var session: Session
    @State private var currentExerciseIndex = 0
    @State private var currentSetNumber = 1
    @State private var weight: Double = 135
    @State private var reps: Int = 5
    @State private var selectedRPE: Int? = nil
    @State private var startTime = Date()
    @State private var showingSessionComplete = false

    @Query private var exercises: [Exercise]

    init(planDay: PlanDay?) {
        self.planDay = planDay
        self._session = State(initialValue: Session(
            planDayName: planDay?.name
        ))
    }

    private var plannedExercises: [PlannedExercise] {
        planDay?.sortedExercises ?? []
    }

    private var currentPlannedExercise: PlannedExercise? {
        guard currentExerciseIndex < plannedExercises.count else { return nil }
        return plannedExercises[currentExerciseIndex]
    }

    private var setsForCurrentExercise: [SetEntry] {
        guard let exerciseName = currentPlannedExercise?.exerciseName else { return [] }
        return session.sets.filter { $0.exercise?.name == exerciseName }
    }

    private var targetSets: Int {
        currentPlannedExercise?.sets ?? 3
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                sessionHeader

                Divider()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Current Exercise
                        if let exercise = currentPlannedExercise {
                            currentExerciseSection(exercise)
                        } else {
                            noExercisesView
                        }

                        // Completed Sets
                        if !setsForCurrentExercise.isEmpty {
                            completedSetsSection
                        }
                    }
                    .padding()
                }

                Divider()

                // Log Set Button
                logSetButton
            }
            .navigationTitle(planDay?.name ?? "Quick Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Finish") {
                        finishSession()
                    }
                }
            }
            .sheet(isPresented: $showingSessionComplete) {
                SessionCompleteView(session: session) {
                    dismiss()
                }
            }
            .onAppear {
                modelContext.insert(session)
            }
        }
    }

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Elapsed")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
                Text(elapsedTime)
                    .font(.spotterHeadline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Sets Logged")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
                Text("\(session.sets.count)")
                    .font(.spotterHeadline)
            }
        }
        .padding()
    }

    private var elapsedTime: String {
        DateFormatters.formatDuration(Date().timeIntervalSince(startTime))
    }

    private func currentExerciseSection(_ exercise: PlannedExercise) -> some View {
        VStack(spacing: Spacing.md) {
            // Exercise Name
            Text(exercise.exerciseName)
                .font(.spotterTitle)

            // Set Counter
            Text("Set \(currentSetNumber) of \(targetSets)")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            // Weight Stepper
            weightStepper

            // Reps Stepper
            repsStepper

            // RPE Selector
            rpeSelector
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var weightStepper: some View {
        HStack {
            Button {
                weight = max(0, weight - 5)
                HapticManager.selection()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
            }

            VStack {
                Text("\(Int(weight))")
                    .font(.spotterLargeNumber)
                Text("lbs")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 120)

            Button {
                weight += 5
                HapticManager.selection()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
        }
    }

    private var repsStepper: some View {
        HStack {
            Button {
                reps = max(1, reps - 1)
                HapticManager.selection()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
            }

            VStack {
                Text("\(reps)")
                    .font(.spotterLargeNumber)
                Text("reps")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 120)

            Button {
                reps += 1
                HapticManager.selection()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
        }
    }

    private var rpeSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("RPE (optional)")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.sm) {
                ForEach([6, 7, 8, 9, 10], id: \.self) { rpe in
                    Button {
                        selectedRPE = selectedRPE == rpe ? nil : rpe
                        HapticManager.selection()
                    } label: {
                        Text("\(rpe)")
                            .font(.spotterBody)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(selectedRPE == rpe ? Color.spotterPrimaryFallback : Color.spotterSurfaceFallback)
                            .foregroundStyle(selectedRPE == rpe ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    }
                }
            }
        }
    }

    private var completedSetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Completed Sets")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            ForEach(Array(setsForCurrentExercise.enumerated()), id: \.element.id) { index, set in
                HStack {
                    Text("Set \(index + 1)")
                        .font(.spotterBody)
                    Spacer()
                    Text("\(set.displayWeight) × \(set.reps)")
                        .font(.spotterBody)
                    if let rpe = set.rpe {
                        Text("@\(rpe)")
                            .font(.spotterCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, Spacing.xs)
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var noExercisesView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.spotterSuccessFallback)
            Text("All exercises complete!")
                .font(.spotterHeadline)
            Text("Tap Finish to wrap up your session")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var logSetButton: some View {
        Button {
            logSet()
        } label: {
            Text("Log Set")
                .font(.spotterHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.spotterPrimaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .padding()
        .disabled(currentPlannedExercise == nil)
    }

    private func logSet() {
        guard let plannedExercise = currentPlannedExercise else { return }

        // Find or create exercise
        let exercise = findOrCreateExercise(named: plannedExercise.exerciseName)

        // Create set entry
        let setEntry = SetEntry(
            exercise: exercise,
            session: session,
            weight: weight,
            reps: reps,
            rpe: selectedRPE,
            orderIndex: session.sets.count
        )

        session.sets.append(setEntry)
        HapticManager.logSet()

        // Advance to next set or exercise
        if currentSetNumber >= targetSets {
            currentSetNumber = 1
            currentExerciseIndex += 1
            selectedRPE = nil

            if currentExerciseIndex >= plannedExercises.count {
                HapticManager.completeExercise()
            }
        } else {
            currentSetNumber += 1
        }
    }

    private func findOrCreateExercise(named name: String) -> Exercise {
        if let existing = exercises.first(where: { $0.name == name }) {
            return existing
        }

        let newExercise = Exercise(name: name)
        modelContext.insert(newExercise)
        return newExercise
    }

    private func finishSession() {
        session.duration = Date().timeIntervalSince(startTime)
        showingSessionComplete = true
    }
}

#Preview {
    ActiveSessionView(planDay: nil)
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build will fail (SessionCompleteView not yet created) - this is expected

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add ActiveSessionView for workout logging"
```

---

## Task 19: Create SessionCompleteView

**Files:**
- Create: `Spotter/Views/Session/SessionCompleteView.swift`

**Step 1: Create SessionCompleteView**

```swift
import SwiftUI

struct SessionCompleteView: View {
    @Environment(\.modelContext) private var modelContext
    let session: Session
    let onComplete: () -> Void

    @State private var sessionRPE: Int = 3
    @State private var selectedPainTags: Set<String> = []
    @State private var notes: String = ""

    private let painTagOptions = [
        "Shoulders", "Lower Back", "Upper Back", "Knees",
        "Elbows", "Wrists", "Hips", "Neck"
    ]

    private let rpeEmojis = ["😫", "😓", "😐", "💪", "🔥"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Session Summary
                    sessionSummary

                    // Feel Rating
                    feelRating

                    // Pain Tags
                    painTagSection

                    // Notes
                    notesSection
                }
                .padding()
            }
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveSession()
                    }
                    .font(.headline)
                }
            }
        }
    }

    private var sessionSummary: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.spotterSuccessFallback)

            if let duration = session.duration {
                Text(DateFormatters.formatDuration(duration))
                    .font(.spotterTitle)
            }

            HStack(spacing: Spacing.lg) {
                statItem(value: "\(session.sets.count)", label: "sets")
                statItem(value: "\(session.exerciseCount)", label: "exercises")
                statItem(value: formatVolume(session.totalVolume), label: "volume")
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.spotterHeadline)
            Text(label)
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }

    private var feelRating: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("How did it feel?")
                .font(.spotterHeadline)

            HStack(spacing: Spacing.md) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        sessionRPE = rating
                        HapticManager.selection()
                    } label: {
                        Text(rpeEmojis[rating - 1])
                            .font(.system(size: 32))
                            .padding(Spacing.sm)
                            .background(sessionRPE == rating ? Color.spotterPrimaryFallback.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var painTagSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Any discomfort?")
                .font(.spotterHeadline)

            Text("Optional — helps track patterns")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: Spacing.sm) {
                ForEach(painTagOptions, id: \.self) { tag in
                    Button {
                        togglePainTag(tag)
                        HapticManager.selection()
                    } label: {
                        Text(tag)
                            .font(.spotterBody)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(selectedPainTags.contains(tag) ? Color.spotterWarningFallback : Color.spotterSurfaceFallback)
                            .foregroundStyle(selectedPainTags.contains(tag) ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Notes")
                .font(.spotterHeadline)

            TextField("Optional notes...", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func togglePainTag(_ tag: String) {
        if selectedPainTags.contains(tag) {
            selectedPainTags.remove(tag)
        } else {
            selectedPainTags.insert(tag)
        }
    }

    private func saveSession() {
        session.sessionRPE = sessionRPE
        session.painTags = Array(selectedPainTags)
        session.notes = notes.isEmpty ? nil : notes
        session.completedAt = Date()

        HapticManager.completeSession()
        onComplete()
    }
}

// Simple flow layout for pain tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing

                self.size.width = max(self.size.width, x)
            }

            self.size.height = y + lineHeight
        }
    }
}

#Preview {
    let session = Session(duration: 3600)

    return SessionCompleteView(session: session) { }
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add SessionCompleteView for session wrap-up"
```

---

## Task 20: Create HistoryView

**Files:**
- Create: `Spotter/Views/History/HistoryView.swift`

**Step 1: Create HistoryView**

```swift
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Session> { $0.completedAt != nil },
        sort: \Session.date,
        order: .reverse
    ) private var sessions: [Session]

    @State private var selectedSession: Session?
    @State private var showingCalendar = true

    var body: some View {
        NavigationStack {
            VStack {
                // View Toggle
                Picker("View", selection: $showingCalendar) {
                    Text("Calendar").tag(true)
                    Text("List").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if showingCalendar {
                    CalendarView(sessions: sessions, selectedSession: $selectedSession)
                } else {
                    sessionList
                }
            }
            .navigationTitle("History")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }

    private var sessionList: some View {
        List {
            ForEach(sessions) { session in
                SessionRowView(session: session)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSession = session
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct SessionRowView: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(DateFormatters.formatRelativeDate(session.date))
                    .font(.spotterHeadline)

                if let planDayName = session.planDayName {
                    Text(planDayName)
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: Spacing.md) {
                if let duration = session.duration {
                    Text(DateFormatters.formatDuration(duration))
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                }

                if let rpe = session.sessionRPE {
                    Text(rpeEmoji(rpe))
                }
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    private func rpeEmoji(_ rpe: Int) -> String {
        let emojis = ["😫", "😓", "😐", "💪", "🔥"]
        guard rpe >= 1 && rpe <= 5 else { return "" }
        return emojis[rpe - 1]
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build will fail (CalendarView and SessionDetailView not yet created) - expected

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add HistoryView with list and calendar toggle"
```

---

## Task 21: Create CalendarView

**Files:**
- Create: `Spotter/Views/History/CalendarView.swift`

**Step 1: Create CalendarView**

```swift
import SwiftUI

struct CalendarView: View {
    let sessions: [Session]
    @Binding var selectedSession: Session?

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    private var sessionDates: Set<DateComponents> {
        Set(sessions.map { calendar.dateComponents([.year, .month, .day], from: $0.date) })
    }

    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
    }

    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: monthStart)!
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        // Pad to complete last week
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Month Navigation
            HStack {
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(DateFormatters.monthYear.string(from: displayedMonth))
                    .font(.spotterHeadline)

                Spacer()

                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // Day Headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Spacing.sm) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    private func dayCell(for date: Date) -> some View {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let hasSession = sessionDates.contains(components)
        let isToday = calendar.isDateInToday(date)
        let sessionForDate = sessions.first { calendar.isDate($0.date, inSameDayAs: date) }

        return Button {
            if let session = sessionForDate {
                selectedSession = session
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.spotterBody)
                    .foregroundStyle(isToday ? .white : .primary)

                if hasSession {
                    Circle()
                        .fill(Color.spotterPrimaryFallback)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(isToday ? Color.spotterPrimaryFallback : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        }
        .disabled(!hasSession)
    }
}

#Preview {
    CalendarView(sessions: [], selectedSession: .constant(nil))
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add CalendarView for history navigation"
```

---

## Task 22: Create SessionDetailView

**Files:**
- Create: `Spotter/Views/History/SessionDetailView.swift`

**Step 1: Create SessionDetailView**

```swift
import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session

    private var exerciseGroups: [(String, [SetEntry])] {
        let grouped = Dictionary(grouping: session.sets) { $0.exercise?.name ?? "Unknown" }
        return grouped.sorted {
            ($0.value.first?.orderIndex ?? 0) < ($1.value.first?.orderIndex ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Session Header
                    sessionHeader

                    // Exercises
                    ForEach(exerciseGroups, id: \.0) { exerciseName, sets in
                        exerciseSection(name: exerciseName, sets: sets)
                    }

                    // Pain Tags
                    if !session.painTags.isEmpty {
                        painTagsSection
                    }

                    // Notes
                    if let notes = session.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                }
                .padding()
            }
            .navigationTitle(DateFormatters.formatRelativeDate(session.date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let planDayName = session.planDayName {
                Text(planDayName)
                    .font(.spotterHeadline)
            }

            HStack(spacing: Spacing.lg) {
                if let duration = session.duration {
                    Label(DateFormatters.formatDuration(duration), systemImage: "clock")
                }

                Label("\(session.sets.count) sets", systemImage: "number")

                if let rpe = session.sessionRPE {
                    Label(rpeEmoji(rpe), systemImage: "heart")
                }
            }
            .font(.spotterCaption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func exerciseSection(name: String, sets: [SetEntry]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(name)
                .font(.spotterHeadline)

            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                HStack {
                    Text("Set \(index + 1)")
                        .font(.spotterBody)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(set.displayWeight) × \(set.reps)")
                        .font(.spotterBody)
                    if let rpe = set.rpe {
                        Text("@\(rpe)")
                            .font(.spotterCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Best Set Summary
            if let bestSet = sets.max(by: { OneRepMaxCalculator.estimate(from: $0) < OneRepMaxCalculator.estimate(from: $1) }) {
                HStack {
                    Text("Best e1RM")
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.0f lbs", OneRepMaxCalculator.estimate(from: bestSet)))
                        .font(.spotterCaption)
                        .foregroundStyle(.spotterPrimaryFallback)
                }
                .padding(.top, Spacing.xs)
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var painTagsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Discomfort Noted")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            HStack {
                ForEach(session.painTags, id: \.self) { tag in
                    Text(tag)
                        .font(.spotterCaption)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.spotterWarningFallback.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Notes")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            Text(notes)
                .font(.spotterBody)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func rpeEmoji(_ rpe: Int) -> String {
        let emojis = ["😫", "😓", "😐", "💪", "🔥"]
        guard rpe >= 1 && rpe <= 5 else { return "" }
        return emojis[rpe - 1]
    }
}

#Preview {
    let session = Session(
        planDayName: "Day A - Squat Focus",
        duration: 3600,
        sessionRPE: 4,
        notes: "Felt strong today. Good sleep last night.",
        painTags: ["Shoulders"]
    )

    return SessionDetailView(session: session)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add SessionDetailView for session history details"
```

---

## Task 23: Create TrendsView

**Files:**
- Create: `Spotter/Views/Trends/TrendsView.swift`

**Step 1: Create TrendsView**

```swift
import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(
        filter: #Predicate<Session> { $0.completedAt != nil },
        sort: \Session.date,
        order: .reverse
    ) private var sessions: [Session]

    @Query private var exercises: [Exercise]

    @State private var selectedExercise: Exercise?

    private var mainLifts: [Exercise] {
        let mainLiftNames = ["Back Squat", "Bench Press", "Deadlift", "Overhead Press", "Barbell Row"]
        return exercises.filter { mainLiftNames.contains($0.name) }
    }

    private var exerciseOptions: [Exercise] {
        if mainLifts.isEmpty {
            return Array(exercises.prefix(5))
        }
        return mainLifts
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Consistency Card
                    consistencyCard

                    // Exercise Picker
                    if !exerciseOptions.isEmpty {
                        exercisePicker
                    }

                    // Progress Chart
                    if let exercise = selectedExercise {
                        progressChart(for: exercise)
                    }

                    // Weekly Volume
                    weeklyVolumeCard
                }
                .padding()
            }
            .navigationTitle("Trends")
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exerciseOptions.first
                }
            }
        }
    }

    private var consistencyCard: some View {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let sessionsThisWeek = sessions.filter { $0.date >= weekStart }

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("This Week")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            HStack(alignment: .bottom, spacing: Spacing.sm) {
                Text("\(sessionsThisWeek.count)")
                    .font(.spotterLargeNumber)

                Text("sessions")
                    .font(.spotterBody)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }

            // Week dots
            HStack(spacing: Spacing.sm) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                    let hasSession = sessions.contains { calendar.isDate($0.date, inSameDayAs: date) }
                    let isToday = calendar.isDateInToday(date)

                    Circle()
                        .fill(hasSession ? Color.spotterSuccessFallback : (isToday ? Color.spotterPrimaryFallback.opacity(0.3) : Color.spotterSurfaceFallback))
                        .frame(width: 24, height: 24)
                        .overlay {
                            if isToday {
                                Circle()
                                    .strokeBorder(Color.spotterPrimaryFallback, lineWidth: 2)
                            }
                        }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var exercisePicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Track Progress")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(exerciseOptions) { exercise in
                        Button {
                            selectedExercise = exercise
                            HapticManager.selection()
                        } label: {
                            Text(exercise.name)
                                .font(.spotterBody)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(selectedExercise?.id == exercise.id ? Color.spotterPrimaryFallback : Color.spotterSurfaceFallback)
                                .foregroundStyle(selectedExercise?.id == exercise.id ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                        }
                    }
                }
            }
        }
    }

    private func progressChart(for exercise: Exercise) -> some View {
        let sets = exercise.sets.sorted { $0.timestamp < $1.timestamp }
        let dataPoints = sets.map {
            (date: $0.timestamp, e1rm: OneRepMaxCalculator.estimate(from: $0))
        }

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Estimated 1RM")
                .font(.spotterHeadline)

            if dataPoints.isEmpty {
                Text("No data yet for \(exercise.name)")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(dataPoints, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("e1RM", point.e1rm)
                        )
                        .foregroundStyle(Color.spotterPrimaryFallback)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("e1RM", point.e1rm)
                        )
                        .foregroundStyle(Color.spotterPrimaryFallback)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var weeklyVolumeCard: some View {
        let calendar = Calendar.current
        let last4Weeks = (0..<4).map { weekOffset -> (weekStart: Date, volume: Double) in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

            let weekSessions = sessions.filter { $0.date >= weekStart && $0.date < weekEnd }
            let volume = weekSessions.reduce(0.0) { $0 + $1.totalVolume }

            return (weekStart, volume)
        }.reversed()

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Weekly Volume")
                .font(.spotterHeadline)

            Chart {
                ForEach(Array(last4Weeks), id: \.weekStart) { data in
                    BarMark(
                        x: .value("Week", data.weekStart, unit: .weekOfYear),
                        y: .value("Volume", data.volume)
                    )
                    .foregroundStyle(Color.spotterPrimaryFallback)
                }
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { value in
                    AxisValueLabel(format: .dateTime.week())
                }
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add TrendsView with progress charts and consistency tracking"
```

---

## Task 24: Create SettingsView

**Files:**
- Create: `Spotter/Views/Settings/SettingsView.swift`

**Step 1: Create SettingsView**

```swift
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [TrainingPlan]
    @Query private var exercises: [Exercise]

    @AppStorage("preferredWeightUnit") private var weightUnit = WeightUnit.lbs.rawValue

    @State private var showingPlanSetup = false
    @State private var showingExerciseLibrary = false

    private var activePlan: TrainingPlan? {
        plans.first { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            List {
                // Current Plan Section
                Section("Training Plan") {
                    if let plan = activePlan {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(plan.name)
                                    .font(.spotterBody)
                                Text("\(plan.daysPerWeek) days/week")
                                    .font(.spotterCaption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.spotterSuccessFallback)
                        }
                    } else {
                        Text("No active plan")
                            .foregroundStyle(.secondary)
                    }

                    Button("Create New Plan") {
                        showingPlanSetup = true
                    }
                }

                // Exercise Library Section
                Section("Exercises") {
                    Button {
                        showingExerciseLibrary = true
                    } label: {
                        HStack {
                            Text("Exercise Library")
                            Spacer()
                            Text("\(exercises.count)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // Preferences Section
                Section("Preferences") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("lbs").tag(WeightUnit.lbs.rawValue)
                        Text("kg").tag(WeightUnit.kg.rawValue)
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $showingPlanSetup) {
                PlanSetupView()
            }
            .sheet(isPresented: $showingExerciseLibrary) {
                ExerciseLibraryView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build will fail (PlanSetupView and ExerciseLibraryView not yet created) - expected

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add SettingsView with plan and preferences management"
```

---

## Task 25: Create PlanSetupView (Manual)

**Files:**
- Create: `Spotter/Views/Plan/PlanSetupView.swift`

**Step 1: Create PlanSetupView**

```swift
import SwiftUI
import SwiftData

struct PlanSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var planName = ""
    @State private var daysPerWeek = 3
    @State private var days: [DayEntry] = []
    @State private var notes = ""

    struct DayEntry: Identifiable {
        let id = UUID()
        var name: String
        var exercises: [ExerciseEntry]
    }

    struct ExerciseEntry: Identifiable {
        let id = UUID()
        var name: String
        var sets: Int
        var reps: String
    }

    var body: some View {
        NavigationStack {
            Form {
                // Plan Info
                Section("Plan Details") {
                    TextField("Plan Name", text: $planName)

                    Stepper("Days per week: \(daysPerWeek)", value: $daysPerWeek, in: 1...7)
                }

                // Days
                Section("Training Days") {
                    ForEach($days) { $day in
                        daySection(day: $day)
                    }

                    Button {
                        addDay()
                    } label: {
                        Label("Add Day", systemImage: "plus")
                    }
                }

                // Notes
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Create Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlan()
                    }
                    .disabled(planName.isEmpty || days.isEmpty)
                }
            }
            .onAppear {
                if days.isEmpty {
                    // Add initial day
                    addDay()
                }
            }
        }
    }

    private func daySection(day: Binding<DayEntry>) -> some View {
        DisclosureGroup {
            ForEach(day.exercises) { $exercise in
                exerciseRow(exercise: $exercise)
            }

            Button {
                day.wrappedValue.exercises.append(ExerciseEntry(name: "", sets: 3, reps: "8-12"))
            } label: {
                Label("Add Exercise", systemImage: "plus")
                    .font(.spotterCaption)
            }
        } label: {
            TextField("Day Name", text: day.name)
                .font(.spotterHeadline)
        }
    }

    private func exerciseRow(exercise: Binding<ExerciseEntry>) -> some View {
        VStack(spacing: Spacing.sm) {
            TextField("Exercise Name", text: exercise.name)

            HStack {
                Stepper("Sets: \(exercise.wrappedValue.sets)", value: exercise.sets, in: 1...10)

                Spacer()

                TextField("Reps", text: exercise.reps)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private func addDay() {
        let dayNumber = days.count + 1
        days.append(DayEntry(
            name: "Day \(dayNumber)",
            exercises: [ExerciseEntry(name: "", sets: 3, reps: "8-12")]
        ))
    }

    private func savePlan() {
        // Deactivate existing plans
        let descriptor = FetchDescriptor<TrainingPlan>()
        if let existingPlans = try? modelContext.fetch(descriptor) {
            for plan in existingPlans {
                plan.isActive = false
            }
        }

        // Create new plan
        let plan = TrainingPlan(
            name: planName,
            daysPerWeek: daysPerWeek,
            isActive: true,
            notes: notes.isEmpty ? nil : notes
        )

        modelContext.insert(plan)

        // Create days and exercises
        for (index, dayEntry) in days.enumerated() {
            let planDay = PlanDay(
                name: dayEntry.name,
                orderIndex: index,
                plan: plan
            )

            modelContext.insert(planDay)

            for (exerciseIndex, exerciseEntry) in dayEntry.exercises.enumerated() {
                guard !exerciseEntry.name.isEmpty else { continue }

                let plannedExercise = PlannedExercise(
                    exerciseName: exerciseEntry.name,
                    sets: exerciseEntry.sets,
                    reps: exerciseEntry.reps,
                    orderIndex: exerciseIndex,
                    planDay: planDay
                )

                modelContext.insert(plannedExercise)
            }
        }

        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    PlanSetupView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add PlanSetupView for manual plan creation"
```

---

## Task 26: Create ExerciseLibraryView

**Files:**
- Create: `Spotter/Views/Settings/ExerciseLibraryView.swift`

**Step 1: Create ExerciseLibraryView**

```swift
import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var showingAddExercise = false
    @State private var selectedModality: ExerciseModality?

    private var filteredExercises: [Exercise] {
        var result = exercises

        if let modality = selectedModality {
            result = result.filter { $0.modality == modality }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    private var groupedExercises: [(ExerciseModality, [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises) { $0.modality }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }
    }

    var body: some View {
        NavigationStack {
            List {
                // Modality Filter
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            filterChip(nil, label: "All")

                            ForEach(ExerciseModality.allCases, id: \.self) { modality in
                                filterChip(modality, label: modality.displayName)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // Exercises
                ForEach(groupedExercises, id: \.0) { modality, exercises in
                    Section(modality.displayName) {
                        ForEach(exercises) { exercise in
                            exerciseRow(exercise)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
        }
    }

    private func filterChip(_ modality: ExerciseModality?, label: String) -> some View {
        Button {
            selectedModality = modality
            HapticManager.selection()
        } label: {
            Text(label)
                .font(.spotterCaption)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(selectedModality == modality ? Color.spotterPrimaryFallback : Color.spotterSurfaceFallback)
                .foregroundStyle(selectedModality == modality ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack {
            Image(systemName: exercise.modality.icon)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.spotterBody)

                if !exercise.muscleGroups.isEmpty {
                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if exercise.isCustom {
                Text("Custom")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var modality = ExerciseModality.barbell
    @State private var muscleGroups = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise Name", text: $name)

                Picker("Type", selection: $modality) {
                    ForEach(ExerciseModality.allCases, id: \.self) { modality in
                        Text(modality.displayName).tag(modality)
                    }
                }

                TextField("Muscle Groups (comma separated)", text: $muscleGroups)

                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveExercise() {
        let muscles = muscleGroups
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        let exercise = Exercise(
            name: name,
            muscleGroups: muscles,
            modality: modality,
            notes: notes.isEmpty ? nil : notes,
            isCustom: true
        )

        modelContext.insert(exercise)
        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    ExerciseLibraryView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
```

**Step 2: Build to verify no errors**

Press Cmd+B in Xcode.
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add ExerciseLibraryView with search and filtering"
```

---

## Task 27: Create Default Exercises JSON

**Files:**
- Create: `Spotter/Resources/DefaultExercises.json`

**Step 1: Create default exercises JSON**

```json
{
  "exercises": [
    {
      "name": "Back Squat",
      "modality": "barbell",
      "muscleGroups": ["quadriceps", "glutes", "hamstrings"]
    },
    {
      "name": "Front Squat",
      "modality": "barbell",
      "muscleGroups": ["quadriceps", "core", "upper back"]
    },
    {
      "name": "Deadlift",
      "modality": "barbell",
      "muscleGroups": ["hamstrings", "glutes", "lower back", "traps"]
    },
    {
      "name": "Romanian Deadlift",
      "modality": "barbell",
      "muscleGroups": ["hamstrings", "glutes", "lower back"]
    },
    {
      "name": "Bench Press",
      "modality": "barbell",
      "muscleGroups": ["chest", "triceps", "shoulders"]
    },
    {
      "name": "Overhead Press",
      "modality": "barbell",
      "muscleGroups": ["shoulders", "triceps", "upper chest"]
    },
    {
      "name": "Barbell Row",
      "modality": "barbell",
      "muscleGroups": ["lats", "rhomboids", "biceps"]
    },
    {
      "name": "Hip Thrust",
      "modality": "barbell",
      "muscleGroups": ["glutes", "hamstrings"]
    },
    {
      "name": "Dumbbell Press",
      "modality": "dumbbell",
      "muscleGroups": ["chest", "triceps", "shoulders"]
    },
    {
      "name": "Incline Dumbbell Press",
      "modality": "dumbbell",
      "muscleGroups": ["upper chest", "shoulders", "triceps"]
    },
    {
      "name": "Dumbbell Row",
      "modality": "dumbbell",
      "muscleGroups": ["lats", "rhomboids", "biceps"]
    },
    {
      "name": "Lateral Raise",
      "modality": "dumbbell",
      "muscleGroups": ["shoulders"]
    },
    {
      "name": "Dumbbell Curl",
      "modality": "dumbbell",
      "muscleGroups": ["biceps"]
    },
    {
      "name": "Dumbbell Tricep Extension",
      "modality": "dumbbell",
      "muscleGroups": ["triceps"]
    },
    {
      "name": "Goblet Squat",
      "modality": "dumbbell",
      "muscleGroups": ["quadriceps", "glutes"]
    },
    {
      "name": "Dumbbell Lunges",
      "modality": "dumbbell",
      "muscleGroups": ["quadriceps", "glutes", "hamstrings"]
    },
    {
      "name": "Cable Fly",
      "modality": "cable",
      "muscleGroups": ["chest"]
    },
    {
      "name": "Tricep Pushdown",
      "modality": "cable",
      "muscleGroups": ["triceps"]
    },
    {
      "name": "Face Pull",
      "modality": "cable",
      "muscleGroups": ["rear delts", "rhomboids", "traps"]
    },
    {
      "name": "Cable Curl",
      "modality": "cable",
      "muscleGroups": ["biceps"]
    },
    {
      "name": "Lat Pulldown",
      "modality": "cable",
      "muscleGroups": ["lats", "biceps"]
    },
    {
      "name": "Seated Cable Row",
      "modality": "cable",
      "muscleGroups": ["lats", "rhomboids", "biceps"]
    },
    {
      "name": "Leg Press",
      "modality": "machine",
      "muscleGroups": ["quadriceps", "glutes"]
    },
    {
      "name": "Leg Curl",
      "modality": "machine",
      "muscleGroups": ["hamstrings"]
    },
    {
      "name": "Leg Extension",
      "modality": "machine",
      "muscleGroups": ["quadriceps"]
    },
    {
      "name": "Chest Press Machine",
      "modality": "machine",
      "muscleGroups": ["chest", "triceps"]
    },
    {
      "name": "Shoulder Press Machine",
      "modality": "machine",
      "muscleGroups": ["shoulders", "triceps"]
    },
    {
      "name": "Seated Row Machine",
      "modality": "machine",
      "muscleGroups": ["lats", "rhomboids"]
    },
    {
      "name": "Pull-up",
      "modality": "bodyweight",
      "muscleGroups": ["lats", "biceps", "core"]
    },
    {
      "name": "Chin-up",
      "modality": "bodyweight",
      "muscleGroups": ["biceps", "lats"]
    },
    {
      "name": "Dip",
      "modality": "bodyweight",
      "muscleGroups": ["chest", "triceps", "shoulders"]
    },
    {
      "name": "Push-up",
      "modality": "bodyweight",
      "muscleGroups": ["chest", "triceps", "shoulders"]
    },
    {
      "name": "Inverted Row",
      "modality": "bodyweight",
      "muscleGroups": ["lats", "rhomboids", "biceps"]
    },
    {
      "name": "Plank",
      "modality": "bodyweight",
      "muscleGroups": ["core"]
    }
  ]
}
```

**Step 2: Add file to Xcode project**

In Xcode, drag `DefaultExercises.json` into the Resources group, ensuring "Copy items if needed" is checked and "Add to targets: Spotter" is selected.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add default exercises JSON seed data"
```

---

## Task 28: Create Exercise Seeding Service

**Files:**
- Create: `Spotter/Services/ExerciseSeeder.swift`

**Step 1: Create ExerciseSeeder**

```swift
import Foundation
import SwiftData

struct ExerciseSeeder {
    struct ExerciseData: Codable {
        let name: String
        let modality: String
        let muscleGroups: [String]
    }

    struct ExercisesFile: Codable {
        let exercises: [ExerciseData]
    }

    static func seedDefaultExercises(modelContext: ModelContext) {
        // Check if exercises already exist
        let descriptor = FetchDescriptor<Exercise>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else {
            return // Already seeded
        }

        // Load JSON
        guard let url = Bundle.main.url(forResource: "DefaultExercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let exercisesFile = try? JSONDecoder().decode(ExercisesFile.self, from: data) else {
            print("Failed to load default exercises")
            return
        }

        // Create exercises
        for exerciseData in exercisesFile.exercises {
            let modality = ExerciseModality(rawValue: exerciseData.modality) ?? .other

            let exercise = Exercise(
                name: exerciseData.name,
                muscleGroups: exerciseData.muscleGroups,
                modality: modality,
                isCustom: false
            )

            modelContext.insert(exercise)
        }

        try? modelContext.save()
        print("Seeded \(exercisesFile.exercises.count) default exercises")
    }
}
```

**Step 2: Update SpotterApp to seed exercises**

Modify `SpotterApp.swift` to call the seeder:

```swift
import SwiftUI
import SwiftData

@main
struct SpotterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    ExerciseSeeder.seedDefaultExercises(modelContext: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**Step 3: Build and run to verify seeding works**

Press Cmd+R in Xcode.
Expected: App launches, default exercises are seeded on first run

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add ExerciseSeeder for default exercise population"
```

---

## Task 29: Final Build and Test

**Step 1: Clean build**

In Xcode: Product → Clean Build Folder (Cmd+Shift+K)

**Step 2: Build project**

Press Cmd+B
Expected: Build Succeeded with no errors

**Step 3: Run on simulator**

Press Cmd+R
Expected: App launches showing TodayView

**Step 4: Manual testing checklist**

- [ ] TodayView displays correctly
- [ ] Can tap "Start Session" to open ActiveSessionView
- [ ] Can log sets with weight/reps steppers
- [ ] Can complete session and see SessionCompleteView
- [ ] History tab shows calendar view
- [ ] Trends tab shows consistency and charts
- [ ] Settings tab shows plan and exercise options
- [ ] Can create a new training plan
- [ ] Exercise library shows default exercises

**Step 5: Final commit**

```bash
git add .
git commit -m "feat: complete Spotter MVP implementation"
```

---

## Summary

This plan implements the Spotter iOS MVP with:

**Models (Tasks 3-8):**
- WeightUnit, ExerciseModality enums
- Exercise, Session, SetEntry SwiftData models
- TrainingPlan, PlanDay, PlannedExercise models

**Utilities (Tasks 10-13):**
- Design tokens for consistent styling
- HapticManager for tactile feedback
- DateFormatters for date display
- OneRepMaxCalculator for strength estimation

**Views (Tasks 14-26):**
- Main tab navigation
- TodayView with session preview
- ActiveSessionView for workout logging
- SessionCompleteView for wrap-up
- HistoryView with calendar
- TrendsView with charts
- SettingsView with plan management
- PlanSetupView for manual plan creation
- ExerciseLibraryView for browsing exercises

**Services (Tasks 27-28):**
- Default exercises JSON
- ExerciseSeeder for initial data population

**Deferred to v1.1:**
- LLM plan assistant (Claude API)
- HealthKit integration
- Insight engine
- Rest timer
