# Spotter — iOS Fitness Tracker
## Claude Code Handoff Document

### Overview

Spotter is an offline-first iOS fitness tracking app designed around the user's existing training rhythm. It's not a coach that tells you what to do — it's a quiet observer that surfaces insights, tracks progress, and adapts to your plan.

The core philosophy: the app should feel like an extension of the mental inventory a lifter does on the way to the gym. "What did I do last session? Where am I at with progressions? What hurts? What should I adjust today?"

### Target User

Intermediate lifters who already have a training plan (or want help building one) but need:
- Fast, frictionless logging at the rack
- Pattern recognition across sessions (consistency, stalls, volume trends)
- Subtle recovery-informed suggestions without being naggy
- Their plan as a living template, not a rigid prescription

### Technical Stack

- **Platform**: iOS 17+
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData (preferred) or Core Data
- **Health Integration**: HealthKit
- **LLM Integration**: Claude API (for plan parsing/building)
- **Architecture**: MVVM with observable state

---

## Data Model

### Exercise

```swift
@Model
class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var muscleGroups: [String] // ["chest", "triceps", "shoulders"]
    var modality: ExerciseModality
    var notes: String?
    var isCustom: Bool
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \SetEntry.exercise)
    var sets: [SetEntry]
}

enum ExerciseModality: String, Codable, CaseIterable {
    case barbell
    case dumbbell
    case machine
    case cable
    case bodyweight
    case cardio
    case climb
    case other
}
```

### TrainingPlan

```swift
@Model
class TrainingPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var daysPerWeek: Int
    var isActive: Bool
    var createdAt: Date
    var notes: String?
    
    @Relationship(deleteRule: .cascade, inverse: \PlanDay.plan)
    var days: [PlanDay]
}

@Model
class PlanDay {
    @Attribute(.unique) var id: UUID
    var name: String // "Day A - Squat Focus"
    var orderIndex: Int
    var plan: TrainingPlan?
    
    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.planDay)
    var exercises: [PlannedExercise]
}

@Model
class PlannedExercise {
    @Attribute(.unique) var id: UUID
    var exerciseName: String
    var sets: Int
    var reps: String // "5" or "8-12" or "AMRAP"
    var notes: String?
    var orderIndex: Int
    var planDay: PlanDay?
    
    // Optional link to Exercise entity for history lookup
    var exerciseId: UUID?
}
```

### Session

```swift
@Model
class Session {
    @Attribute(.unique) var id: UUID
    var date: Date
    var planDayName: String? // Which day from the plan, if any
    var duration: TimeInterval?
    var sessionRPE: Int? // 1-5 scale
    var notes: String?
    var painTags: [String] // ["shoulders", "lower back"]
    var completedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \SetEntry.session)
    var sets: [SetEntry]
}

@Model
class SetEntry {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise?
    var session: Session?
    var weight: Double
    var weightUnit: WeightUnit
    var reps: Int
    var rpe: Int? // 6-10 scale, optional
    var notes: String?
    var timestamp: Date
    var orderIndex: Int
}

enum WeightUnit: String, Codable {
    case lbs
    case kg
}
```

### HealthSnapshot

```swift
@Model
class HealthSnapshot {
    @Attribute(.unique) var id: UUID
    var date: Date
    var sleepHours: Double?
    var hrvAverage: Double?
    var restingHR: Double?
    var caloriesConsumed: Double?
    var bodyweight: Double?
    var bodyweightUnit: WeightUnit?
}
```

### Insight

```swift
// Not persisted long-term, generated on demand
struct Insight: Identifiable {
    var id: UUID
    var type: InsightType
    var message: String
    var relevantExerciseId: UUID?
    var severity: InsightSeverity
    var actionable: Bool
    var suggestion: String?
}

enum InsightType {
    case consistency      // Missed sessions
    case volumeTrend      // Volume up/down significantly
    case stall            // Lift hasn't progressed
    case recovery         // Health signals suggest back off
    case progression      // Ready to increase weight
    case pain             // Recurring pain tags
    case streak           // Positive reinforcement
}

enum InsightSeverity {
    case info
    case nudge
    case warning
}
```

---

## Core Views

### 1. TodayView (Home)

**Purpose**: Pre-gym mental inventory and session launcher

**Components**:
- Date header
- Current plan day indicator (if plan is active)
- LastSessionCard: summary of previous workout
- InsightCard: contextual nudge (only if relevant, not every day)
- TodaySessionCard: upcoming exercises with prescribed sets/reps, pre-filled from plan
- "Start Session" button

**Behavior**:
- On appear, determine which plan day is next based on rotation or user selection
- Pre-populate today's template from the plan
- Generate insights from InsightEngine
- Show last session summary for context

**Design Notes**:
- Clean, scannable at a glance
- No unnecessary chrome
- Insight card should feel helpful, not naggy — muted styling, dismissable

### 2. ActiveSessionView

**Purpose**: Frictionless logging at the rack

**Components**:
- Header: plan day name, elapsed timer
- Current exercise name
- Set counter ("Set 2 of 4")
- Weight stepper (defaults to last session or plan prescription)
- Reps stepper (defaults to plan prescription)
- Optional RPE selector (horizontal pills: 6, 7, 8, 9, 10)
- "Log Set" button
- Completed sets list (scrollable, below fold)
- Next exercise preview
- Navigation to skip/reorder exercises

**Behavior**:
- Weight and reps pre-fill from last session for this exercise, or plan if no history
- Logging a set advances to next set, not next exercise
- After final set of an exercise, auto-advance to next exercise
- Rest timer optional (can be enabled in settings), unobtrusive if active
- Swipe gestures: left to skip exercise, right to add note

**Design Notes**:
- One-thumb operation, bottom-heavy interaction targets
- Large tap targets for weight/reps steppers
- Minimal color, high contrast for gym lighting
- Haptic feedback on set log

### 3. SessionCompleteView

**Purpose**: Quick wrap-up without friction

**Components**:
- Session duration
- Overall feel selector (1-5 emoji scale or simple buttons)
- Pain tag multi-select (common body parts as toggles)
- Optional notes field
- "Save & Finish" button

**Behavior**:
- All fields optional except feel rating (soft requirement)
- Pain tags persist across sessions for pattern detection
- On save, write session to SwiftData, sync to HealthKit as workout

**Design Notes**:
- Get out of the user's way — they're tired and want to leave
- Everything tappable, no keyboard required unless adding notes

### 4. HistoryView

**Purpose**: Review past sessions

**Components**:
- Calendar view (month grid with dots on training days)
- List view toggle option
- Session cards showing: date, plan day name, duration, feel rating
- Tap to expand full session details

**Behavior**:
- Default to calendar view
- Tapping a date with a session shows that session
- Session detail view allows editing (change weight, reps, notes)

### 5. TrendsView

**Purpose**: Progress visualization

**Components**:
- Exercise picker (focus on main lifts)
- Estimated 1RM chart over time (line chart)
- Weekly volume chart (bar chart)
- Consistency tracker (sessions this week/month vs target)
- Streak counter

**Behavior**:
- 1RM calculated from best set using Epley or Brzycki formula
- Volume = total tonnage (sets × reps × weight)
- Charts should be simple, not overly detailed

**Design Notes**:
- Swift Charts for visualization
- Keep it scannable — insights matter more than raw data

### 6. PlanSetupView (LLM-Powered)

**Purpose**: Create or import training plan

**Components**:
- Large text input field with placeholder: "Paste your program or tell me what you're working toward..."
- Chat-style message thread (appears after first submission)
- Plan preview card (appears when LLM returns structured plan)
- "Confirm Plan" button

**Behavior**:
- First submission goes to Claude API with system prompt + user context
- LLM determines mode: parsing, guided building, or formalizing
- Conversation continues until plan is confirmed
- On confirm, parse JSON from LLM response, create TrainingPlan + PlanDays + PlannedExercises

**Design Notes**:
- Text input should feel inviting, not intimidating
- Chat messages styled simply — user right, assistant left
- Plan preview should be editable before final confirmation

### 7. SettingsView

**Purpose**: Configuration and management

**Sections**:
- **Plan**: View/edit current plan, switch plans, create new
- **Exercise Library**: Browse, add custom exercises
- **Health Integration**: HealthKit permissions, what data is pulled
- **Preferences**: Weight unit (lbs/kg), rest timer settings
- **Account**: Future — sync, export data

---

## Insight Engine

The insight engine runs on app launch (TodayView appear) and generates relevant nudges.

### Insight Generation Logic

```swift
class InsightEngine {
    func generateInsights(
        sessions: [Session],
        plan: TrainingPlan?,
        healthSnapshots: [HealthSnapshot]
    ) -> [Insight] {
        var insights: [Insight] = []
        
        // Consistency check
        if let consistency = checkConsistency(sessions: sessions, plan: plan) {
            insights.append(consistency)
        }
        
        // Stall detection (per major lift)
        insights.append(contentsOf: detectStalls(sessions: sessions))
        
        // Volume trend
        if let volume = checkVolumeTrend(sessions: sessions) {
            insights.append(volume)
        }
        
        // Recovery signals (subtle)
        if let recovery = checkRecovery(healthSnapshots: healthSnapshots) {
            insights.append(recovery)
        }
        
        // Pain patterns
        if let pain = detectPainPatterns(sessions: sessions) {
            insights.append(pain)
        }
        
        // Progression opportunities
        insights.append(contentsOf: detectProgressionOpportunities(sessions: sessions))
        
        // Limit to most relevant
        return prioritize(insights).prefix(2).map { $0 }
    }
}
```

### Insight Types Detail

**Consistency**:
- Compare sessions this week vs plan's daysPerWeek
- "You're at 2 sessions this week with 2 days left — one more hits your target"
- Only surface mid-week, not Monday

**Stall Detection**:
- For each main lift, look at estimated 1RM over last 3-4 weeks
- If flat or declining: "Bench has been at 205 for 3 weeks — try a new rep scheme or small jump"
- Threshold: <2% improvement over 3 weeks

**Volume Trend**:
- Calculate weekly tonnage, compare to 4-week rolling average
- If >20% above: "Volume is up 25% this week — might be time for a lighter session"
- If >20% below: "Volume is down — intentional deload or life getting in the way?"

**Recovery (Subtle)**:
- Don't show explicit HRV/sleep warnings
- Instead, bias other suggestions: if recovery is poor, stall detection might suggest lighter work instead of pushing through
- Only surface directly if user asks or if pattern is severe (e.g., HRV down 20%+ for 2 weeks)

**Pain Patterns**:
- Track painTags across sessions
- If same tag appears 3+ times in 2 weeks: "You've flagged shoulder discomfort in 4 of your last 6 sessions — might be worth addressing"

**Progression Opportunities**:
- If last session hit all prescribed reps at RPE <8, suggest bump
- "You hit 275x5x4 at RPE 7 last squat day — 280 might be there"

---

## HealthKit Integration

### Permissions Required

**Read**:
- HKQuantityType.sleepAnalysis
- HKQuantityType.heartRateVariabilitySDNN
- HKQuantityType.restingHeartRate
- HKQuantityType.dietaryEnergyConsumed
- HKQuantityType.bodyMass

**Write**:
- HKWorkoutType.workoutType()

### HealthKitManager

```swift
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization() async throws { ... }
    
    func fetchHealthSnapshot(for date: Date) async throws -> HealthSnapshot { ... }
    
    func saveWorkout(session: Session) async throws { ... }
}
```

### Data Fetching Strategy

- Fetch last 7 days of health data on app launch
- Cache in HealthSnapshot entities
- Refresh daily or on TodayView appear if stale (>6 hours)
- Don't block UI on health data — load async, update insights when ready

---

## Claude API Integration

### API Configuration

```swift
struct ClaudeAPIConfig {
    static let endpoint = "https://api.anthropic.com/v1/messages"
    static let model = "claude-sonnet-4-20250514"
    static let maxTokens = 4096
}
```

### PlanAssistant

```swift
class PlanAssistant: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var parsedPlan: ParsedPlan?
    
    private let systemPrompt: String
    
    init(userContext: UserContext) {
        self.systemPrompt = buildSystemPrompt(with: userContext)
    }
    
    func send(message: String) async throws {
        // Append user message
        // Call Claude API with system prompt + message history
        // Parse response
        // If response contains JSON plan, extract to parsedPlan
        // Append assistant message
    }
}

struct ParsedPlan: Codable {
    var planName: String
    var daysPerWeek: Int
    var days: [ParsedPlanDay]
}

struct ParsedPlanDay: Codable {
    var name: String
    var exercises: [ParsedExercise]
}

struct ParsedExercise: Codable {
    var name: String
    var sets: Int
    var reps: String
    var notes: String?
}
```

### System Prompt

See full system prompt in appendix. Key points:
- Detects user mode: parsing, guided building, formalizing
- Uses injected user context (training history, health signals, equipment, injuries)
- Outputs structured JSON when plan is ready
- Applies guardrails for beginner-appropriate volume
- Health signals inform suggestions subtly, not explicitly

---

## User Context Injection

Before each LLM call, build context from app state:

```swift
struct UserContext {
    var hasTrainingHistory: Bool
    var totalSessions: Int
    var weeksActive: Int
    var topLifts: [LiftSummary] // name, weight, reps, recency
    var avgSessionsPerWeek: Double
    var equipmentDescription: String?
    var healthDataAvailable: Bool
    var avgSleepHours: Double?
    var sleepTrend: String? // "improving", "declining", "stable"
    var hrvTrend: String?
    var restingHR: Double?
    var concerningPattern: String?
    var injuries: [String]
    var avoidMovements: [String]
    var currentPlan: PlanSummary?
    var customExercises: [String]
}
```

Serialize to template string, prepend to system prompt.

---

## Navigation Structure

```
TabView {
    TodayView()
        .tabItem { Label("Today", systemImage: "calendar") }
    
    HistoryView()
        .tabItem { Label("History", systemImage: "clock") }
    
    TrendsView()
        .tabItem { Label("Trends", systemImage: "chart.line.uptrend.xyaxis") }
    
    SettingsView()
        .tabItem { Label("Settings", systemImage: "gear") }
}
```

Modal presentations:
- ActiveSessionView (full screen cover from TodayView)
- SessionCompleteView (sheet from ActiveSessionView)
- PlanSetupView (full screen cover from Settings or onboarding)

---

## Project Structure

```
Spotter/
├── SpotterApp.swift
├── ContentView.swift
├── Models/
│   ├── Exercise.swift
│   ├── TrainingPlan.swift
│   ├── PlanDay.swift
│   ├── PlannedExercise.swift
│   ├── Session.swift
│   ├── SetEntry.swift
│   ├── HealthSnapshot.swift
│   └── Insight.swift
├── Views/
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── LastSessionCard.swift
│   │   ├── InsightCard.swift
│   │   └── TodaySessionCard.swift
│   ├── Session/
│   │   ├── ActiveSessionView.swift
│   │   ├── SetLoggerView.swift
│   │   ├── ExerciseProgressView.swift
│   │   └── SessionCompleteView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── CalendarView.swift
│   │   └── SessionDetailView.swift
│   ├── Trends/
│   │   ├── TrendsView.swift
│   │   ├── LiftProgressChart.swift
│   │   └── VolumeChart.swift
│   ├── Plan/
│   │   ├── PlanSetupView.swift
│   │   ├── PlanChatView.swift
│   │   └── PlanPreviewCard.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── ExerciseLibraryView.swift
│       └── HealthSettingsView.swift
├── ViewModels/
│   ├── TodayViewModel.swift
│   ├── ActiveSessionViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── TrendsViewModel.swift
│   └── PlanSetupViewModel.swift
├── Services/
│   ├── InsightEngine.swift
│   ├── HealthKitManager.swift
│   ├── ClaudeAPIService.swift
│   └── PlanParser.swift
├── Utilities/
│   ├── OneRepMaxCalculator.swift
│   ├── DateFormatters.swift
│   └── HapticManager.swift
└── Resources/
    ├── Assets.xcassets
    ├── DefaultExercises.json
    └── SystemPrompt.txt
```

---

## Appendix A: Full LLM System Prompt

```
You are a training plan assistant inside a fitness tracking app called Spotter. Your job is to help users establish a structured, repeatable training program they can execute and track.

You operate in several modes depending on what the user provides:

**Mode 1 — Plan parsing**
If the user pastes what appears to be a structured training program (days, exercises, sets, reps), extract it into a structured format. Confirm back what you found and ask for any clarifications. Don't editorialize unless you spot something genuinely problematic (dangerous exercise selection, wildly unbalanced programming, impossible volume).

**Mode 2 — Guided program building**
If the user describes goals without a plan ("I want to get stronger legs", "I want to build muscle but I'm new"), shift into coaching mode. Ask clarifying questions one or two at a time:
- What's your experience level with resistance training?
- How many days per week can you realistically train?
- How long do you have per session?
- Any injuries or movements you need to avoid?
- What equipment do you have access to?

Then build an appropriate program. Keep it simple for beginners. Explain your reasoning briefly so they understand the structure, but don't lecture.

**Mode 3 — Formalizing existing habits**
If the user describes what they already do but without structure ("I kind of do push pull legs but I wing it"), help them articulate and lock in a repeatable template based on their described habits.

**Mode 4 — Plan modification**
If the user has an existing plan in the app and wants to adjust it, make targeted changes while preserving the overall structure. Explain what you changed and why.

**Guardrails**
- Never recommend more volume or intensity than appropriate for the user's stated experience level
- Flag potential issues (e.g., no recovery days, extreme imbalance, movements that conflict with stated injuries) but don't be preachy
- Stay in your lane — you help with program structure, not injury rehab, nutrition protocols, or medical advice
- If someone describes pain or injury, encourage them to see a professional rather than programming around it yourself

**Health signal integration**
You have access to the user's recent recovery metrics when available. Use this information to subtly inform your recommendations:
- If recovery signals are poor (low HRV trend, inadequate sleep), bias toward conservative volume and intensity suggestions without explicitly citing the data unless asked
- If recovery signals are strong, you can be more confident in higher-volume recommendations
- Never alarm the user about their health metrics — you're a training assistant, not a health monitor
- If directly asked about recovery or whether to push/back off, you can reference the trends conversationally

The goal is quiet intelligence — the plan just happens to fit their current state without them needing to think about why.

**Output format**
When you've established or parsed a plan, return it in this JSON structure wrapped in a code block:

```json
{
  "planName": "string",
  "daysPerWeek": number,
  "days": [
    {
      "name": "Day A - Squat Focus",
      "exercises": [
        {
          "name": "Barbell Back Squat",
          "sets": 4,
          "reps": "5",
          "notes": "optional"
        }
      ]
    }
  ]
}
```

Continue the conversation naturally around the JSON — confirm, ask questions, offer suggestions — but always include the structured output when a plan is ready so the app can parse it.

**Tone**
Friendly, competent, concise. Like a knowledgeable training partner, not a drill sergeant or a professor. Match the user's energy.
```

---

## Appendix B: User Context Template

```
<user_context>
**Experience & history**
{{#if hasTrainingHistory}}
User has logged {{totalSessions}} sessions over {{weeksActive}} weeks.
Primary lifts and recent maxes:
{{#each topLifts}}
- {{name}}: {{weight}} x {{reps}} ({{recency}})
{{/each}}
Training frequency: averaging {{avgSessionsPerWeek}} sessions/week
{{else}}
New user, no training history yet.
{{/if}}

**Equipment access**
{{#if equipmentSet}}
{{equipmentDescription}}
{{else}}
Not specified — ask if relevant.
{{/if}}

**Health signals (from HealthKit)**
{{#if healthDataAvailable}}
Recent sleep: {{avgSleepHours}} hrs/night ({{sleepTrend}})
HRV trend: {{hrvTrend}}
Resting HR: {{restingHR}} bpm
{{#if concerningPattern}}
Note: {{concerningPatternDescription}}
{{/if}}
{{else}}
No health data connected.
{{/if}}

**Stated limitations**
{{#if injuries}}
User has noted: {{injuryList}}
{{/if}}
{{#if avoidMovements}}
Movements to avoid: {{avoidMovementsList}}
{{/if}}

**Existing plan**
{{#if hasPlan}}
Currently following: {{planName}}
Structure: {{planSummary}}
{{else}}
No plan established yet.
{{/if}}

**Exercise library**
{{#if customExercises}}
User has added custom exercises: {{customExerciseList}}
{{/if}}
</user_context>
```

---

## Appendix C: Default Exercise Library

Seed the app with common exercises. Store as JSON, import on first launch.

Categories:
- **Barbell**: Back Squat, Front Squat, Deadlift, Romanian Deadlift, Bench Press, Overhead Press, Barbell Row, Hip Thrust
- **Dumbbell**: Dumbbell Press, Incline DB Press, DB Row, Lateral Raise, DB Curl, DB Tricep Extension, Goblet Squat, DB Lunges
- **Cable**: Cable Fly, Tricep Pushdown, Face Pull, Cable Curl, Lat Pulldown, Seated Cable Row
- **Machine**: Leg Press, Leg Curl, Leg Extension, Chest Press Machine, Shoulder Press Machine, Seated Row Machine
- **Bodyweight**: Pull-up, Chin-up, Dip, Push-up, Inverted Row, Plank

Include muscle group tags for each.

---

## Appendix D: Design Tokens

Keep visual language consistent:

```swift
extension Color {
    static let spotterPrimary = Color("SpotterPrimary")       // Action buttons, highlights
    static let spotterSecondary = Color("SpotterSecondary")   // Secondary actions
    static let spotterBackground = Color("SpotterBackground") // Main background
    static let spotterSurface = Color("SpotterSurface")       // Cards, elevated surfaces
    static let spotterText = Color("SpotterText")             // Primary text
    static let spotterTextSecondary = Color("SpotterTextSecondary") // Muted text
    static let spotterSuccess = Color("SpotterSuccess")       // Positive indicators
    static let spotterWarning = Color("SpotterWarning")       // Caution indicators
}

extension Font {
    static let spotterTitle = Font.system(.title, design: .rounded, weight: .bold)
    static let spotterHeadline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let spotterBody = Font.system(.body, design: .default)
    static let spotterCaption = Font.system(.caption, design: .default)
    static let spotterLargeNumber = Font.system(size: 48, weight: .bold, design: .rounded)
}
```

---

## MVP Scope

For initial build, prioritize:

1. **Core logging flow**: TodayView → ActiveSessionView → SessionCompleteView
2. **SwiftData persistence**: Sessions, Sets, Exercises
3. **Basic plan support**: Manual plan creation (not LLM-powered yet)
4. **History view**: Calendar + session detail
5. **Simple trends**: One lift chart, consistency counter

Defer to v1.1:
- LLM plan assistant
- HealthKit integration
- Insight engine
- Rest timer

This lets you validate the core interaction — the logging rhythm — before adding intelligence layers.

---

## Notes for Claude Code

- Use SwiftUI previews liberally for rapid iteration
- SwiftData is preferred over Core Data for cleaner syntax
- Test on device early — gym lighting and one-handed use matter
- Keep haptics subtle but present (UIImpactFeedbackGenerator)
- Avoid over-engineering — this is a personal tool first, scalable product second
- The API key for Claude should be stored in Keychain, not hardcoded
