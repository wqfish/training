# Training Log

A small iOS app for logging a strength-and-climbing training program: a month
calendar with at-a-glance dots, plus per-day logging of strength work and
finger-strength (hangboard) sessions.

Built with **SwiftUI** and **SwiftData** for iOS 17+. Everything is stored
on-device — no account, no network.

## Features

- **Month calendar** with at-a-glance dots marking which kinds of training a day
  holds, so a whole month reads in a glance.
- **Strength logging** from a built-in exercise catalog, tracking sets, reps, and
  weight, with bodyweight movements supported and a running volume total per day.
- **Finger-training logging** tagged by protocol, recording the load for each
  grip position, with bodyweight hangs supported.
- Each day splits into independent **Strength** and **Finger Training** sections;
  within each you can add, edit, reorder, and delete entries.

## Requirements

- Xcode 16 or later
- iOS 17+ simulator or device
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (the `.xcodeproj` is
  generated from `project.yml`)

## Getting started

```sh
brew install xcodegen        # if you don't have it
xcodegen generate            # writes TrainingLog.xcodeproj from project.yml
open TrainingLog.xcodeproj
```

Build and run the **TrainingLog** scheme on a simulator or device. To run on a
device, set your own `DEVELOPMENT_TEAM` in `project.yml` and regenerate.

### Tests

```sh
xcodebuild test \
  -project TrainingLog.xcodeproj \
  -scheme TrainingLog \
  -destination 'platform=iOS Simulator,name=iPhone 17'   # any iOS 17+ sim
```

The suite covers the value types and volume math, the SwiftData store, the
exercise catalog, and the calendar month-grid logic.

## Project structure

```
TrainingLog/
  TrainingLogApp.swift     App entry; sets up the SwiftData container
  Theme.swift              Card styling, dot colors, weight/date helpers
  Models/
    WorkoutEntry.swift     A logged strength movement (sets, reps, weight, bodyweight flag)
    FingerEntry.swift      A logged grip (protocol, grip, weight) + grip/protocol enums
    Exercise.swift         The strength exercise catalog
    MonthGrid.swift        Turns a month into a grid of day cells
    Ordering.swift         Per-day reorder/delete position bookkeeping, shared by both entry types
  Views/
    ContentView.swift      Calendar on top, selected-day detail below
    CalendarView.swift     The month calendar with day dots
    DayDetailView.swift    Strength + Finger Training sections for a day
    EditDayView.swift      Add/edit strength entries
    EditFingerView.swift   Add/edit finger-training entries
TrainingLogTests/          Unit tests (models, store, calendar grid)
project.yml                XcodeGen project definition
```

## Notes on the data model

Entries are stored flat and grouped by `date` (normalized to the start of the
day) rather than through a parent "day" object — simple to query and plenty for
a personal log. Strength (`WorkoutEntry`) and finger training (`FingerEntry`)
are separate SwiftData models, which is why a day can carry either or both and
show the corresponding calendar dots.
