<p align="center">
  <img src="docs/app-logo.svg" alt="Nudge List logo" width="180" />
</p>

<h1 align="center">Nudge List</h1>

<p align="center">
  <strong>Remember the little things.</strong>
</p>

<p align="center">
  A lightweight reminder app for <strong>iPhone</strong> and <strong>Mac</strong>.<br>
  Fast, native, local-first, and intentionally simple.
</p>

<p align="center">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-17%2B-black?logo=apple">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-14%2B-black?logo=apple">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5-orange?logo=swift">
  <img alt="SwiftUI" src="https://img.shields.io/badge/UI-SwiftUI-blue">
  <img alt="SwiftData" src="https://img.shields.io/badge/Storage-SwiftData-6f42c1">
  <img alt="CloudKit" src="https://img.shields.io/badge/Sync-CloudKit-0a84ff">
</p>

---

## Why Nudge List?

Most reminder apps become too much.

Nudge List goes the opposite direction.

It is made for the quick things you do not want to forget:

- Bring charger
- Call Mom
- Return library book
- Buy dog food
- Pack passport
- Cancel subscription

Open the app, add the thought, set a reminder if you need one, and move on.

> **Add it. Nudge it. Done.**

---

## Features

- Fast nudge creation
- Optional note for extra context
- Optional reminder date and time
- Native Apple notifications
- Active and completed views
- Edit, complete, reopen, and delete nudges
- Shared SwiftUI codebase for iPhone and Mac
- Local-first storage with SwiftData
- Designed for iCloud / CloudKit sync
- No separate backend required for the core app

---

## Platforms

| Platform | Minimum Version |
| --- | --- |
| iPhone | iOS 17.0 |
| Mac | macOS 14.0 |

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Language | Swift |
| UI | SwiftUI |
| Persistence | SwiftData |
| Notifications | UserNotifications |
| Sync | CloudKit / iCloud |
| Project Generation | XcodeGen |
| Testing | XCTest / XCUITest |

---

## Project Structure

```text
NudgList/
├── NudgeList/
│   ├── App/
│   ├── Models/
│   ├── Services/
│   ├── Utilities/
│   ├── Views/
│   └── Resources/
├── NudgeListTests/
├── NudgeListUITests/
├── scripts/
├── project.yml
└── README.md
