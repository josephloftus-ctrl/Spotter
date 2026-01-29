# Spotter UI Redesign: Anthropic-Inspired Aesthetic

**Date**: 2026-01-28
**Status**: Implemented

## Overview

Redesign of the Spotter iOS app UI to adopt an Anthropic-inspired aesthetic with soft, muted blue colors and a streamlined, minimal interface.

## Design Goals

1. **Fewer containers** - Remove heavy card backgrounds, use spacing and typography for hierarchy
2. **Refined typography** - Drop rounded/playful fonts for clean, professional system fonts
3. **Lighter visual weight** - Outlined elements instead of fills, subtle borders
4. **Better information density** - More breathing room, clearer hierarchy

## Design Tokens

### Color Palette

```swift
// Primary - soft, sophisticated slate-blue
spotterPrimary: #64748B      // Slate-500
spotterPrimaryHover: #475569 // Slate-600

// Backgrounds
spotterBackground: #FAFAFA   // Near-white
spotterSurface: #F1F5F9      // Slate-100 (use sparingly)

// Text
spotterText: #1E293B         // Slate-800
spotterTextSecondary: #64748B // Slate-500

// Borders
spotterBorder: #E2E8F0       // Slate-200

// Accents
spotterSuccess: #059669      // Emerald-600
spotterWarning: #D97706      // Amber-600
```

### Typography

| Token | Style |
|-------|-------|
| `spotterTitle` | .title, .default, .semibold |
| `spotterHeadline` | .headline, .default, .medium |
| `spotterBody` | .body, .default, .regular |
| `spotterCaption` | .caption, .default, .regular |
| `spotterLabel` | .subheadline, .default, .medium |
| `spotterLargeNumber` | 48pt, .medium, .default |

### Spacing

| Token | Value |
|-------|-------|
| `xs` | 6pt |
| `sm` | 12pt |
| `md` | 20pt |
| `lg` | 32pt |
| `xl` | 48pt |

### Corner Radius

| Token | Value |
|-------|-------|
| `sm` | 6pt |
| `md` | 10pt |
| `lg` | 14pt |

### Border Width

| Token | Value |
|-------|-------|
| `thin` | 1pt |
| `medium` | 1.5pt |

## Visual Principles

### Buttons

- **Primary CTA**: Filled with `spotterPrimary`, white text
- **Secondary actions**: Outlined with `spotterPrimary` border
- **Tertiary**: Text only with `spotterPrimary` color

### Cards/Containers

- Use sparingly - prefer open layouts with spacing
- When needed: `spotterBorder` stroke, no fill
- Reserve `spotterSurface` fill for special emphasis only

### Selection States

- Selected: Filled background with `spotterPrimary`
- Unselected: `spotterBorder` outline, no fill

### Dividers

- Use `spotterBorder` color
- Thin (1pt) horizontal lines between sections
- Replace card wrappers with dividers where grouping is needed

## Files Changed

- `Utilities/DesignTokens.swift` - Complete token overhaul
- `ContentView.swift` - Tab bar tint
- `Views/Today/TodayView.swift`
- `Views/Today/LastSessionCard.swift`
- `Views/Today/TodaySessionCard.swift`
- `Views/Session/ActiveSessionView.swift`
- `Views/Session/SessionCompleteView.swift`
- `Views/History/HistoryView.swift`
- `Views/History/CalendarView.swift`
- `Views/History/SessionDetailView.swift`
- `Views/Trends/TrendsView.swift`
- `Views/Settings/SettingsView.swift`
- `Views/Settings/ExerciseLibraryView.swift`
- `Views/Plan/PlanSetupView.swift`

## Before/After Summary

| Before | After |
|--------|-------|
| Rounded fonts everywhere | Clean system fonts |
| Every section in a filled card | Open layouts with dividers |
| Bright blue accent | Muted slate-blue palette |
| Heavy filled buttons | Outlined primary buttons |
| Tight spacing (4, 8, 16) | Generous spacing (6, 12, 20) |
