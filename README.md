<p align="center">
  <img src="app_assets/vmlogo.png" alt="Vahan Mitra Logo" width="220"/>
</p>
<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/Riverpod-3.x-8A2BE2?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod"/></a>
  <a href="https://www.hivemq.com"><img src="https://img.shields.io/badge/HiveMQ_MQTT-TLS_8883-FF6600?style=for-the-badge&logo=hivemq&logoColor=white" alt="HiveMQ"/></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-Database_&_Auth-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/></a>
  <a href="https://pub.dev/packages/go_router"><img src="https://img.shields.io/badge/GoRouter-Declarative_Routing-00599C?style=for-the-badge&logo=flutter&logoColor=white" alt="GoRouter"/></a>
</p>

---

## 📌 Overview

**Vahan Mitra** is a modern, high-performance mobile application engineered to solve campus transit tracking challenges. Built with a signature **Soft-Neumorphic UI Design System**, the application streams live vehicle coordinates with sub-second latency using **HiveMQ Cloud MQTT (WSS/TLS)** and integrates with **Supabase** for backend authentication, real-time database triggers, and route manifests.

Whether you are a student tracking your morning shuttle, a commuter checking bus arrival timelines, or a fleet manager supervising vehicle operational states, Vahan Mitra delivers an effortless and visually stunning experience.

---

## ✨ Key Features

### 🗺️ Real-Time Interactive Live Map
- **Live Vehicle Telemetry:** Tracks dynamic bus positions over Google Maps (`google_maps_flutter`) with default pins and hue differentiation.
- **Floating Speed Pill:** Calculates live speed in real time (`km/h`) and intelligently resets to `0 km/h` when stationary or when payload telemetry pings pause.
- **Top Bus Badge:** High-contrast round black unit indicator displaying the specific vehicle ID.
- **1-Tap Focus Controls:** Floating action pills ("Bus Location" & "My Location") to instantly center and zoom the map view.
- **Telemetry Payload Timestamp:** Displays the latest MQTT packet timestamp formatted cleanly as `HH:MM AM/PM`.

### 🚏 Serpentine Campus Routes & Timelines
- **Interactive Route Selector:** Horizontal route chips with smooth auto-scroll synchronization when swiping through routes.
- **Detailed Route Cards:** Visual summary of route name, designated vehicle unit, and full vehicle registration plate.
- **Serpentine Timeline Painter:** Custom Canvas painter (`_SerpentinePathPainter`) visualizing multi-row campus bus stops, intermediate arrival times, active vehicle highlights, and final destination endpoints.

### 🔔 System Announcements & Alerts
- **Categorized Notification Feed:** Real-time stream of broadcast alerts categorized by priority (General, Schedule Change, Delay Warning, Route Update).
- **Admin Metadata & Badges:** Displays post author identity, administrator role badge, and human-readable release timestamp.
- **Pull-to-Refresh:** Integrated `RefreshIndicator` for manual background feed synchronization.

### 🎨 Neumorphic Design System & Micro-Interactions
- **Custom Depth Tokens:** Custom soft-shadow box decorations (`AppTheme.neuBoxDecoration`), inset input fields, and vibrant `AppTheme.redAccent` highlights.
- **Modern Typography:** Integrated Google Fonts (`Poppins` for headings & titles, `Inter` for body copy and timestamps).
- **Adaptive System Overlays:** Dynamically configured `SystemChrome.setSystemUIOverlayStyle` for high-contrast dark status bar icons and translucent system navigation.

---

## 🛠️ Technology Stack

| Category | Component / Tool | Purpose & Usage |
| :--- | :--- | :--- |
| **Framework** | [Flutter 3.x](https://flutter.dev) | Cross-platform UI toolkit targeting iOS & Android |
| **Language** | [Dart 3.x](https://dart.dev) | Strongly-typed, asynchronous client programming |
| **State Management** | [Flutter Riverpod](https://riverpod.dev) | Reactive state management, provider caching & dependency injection |
| **Routing** | [GoRouter](https://pub.dev/packages/go_router) | Declarative URL-based route management & animated transitions |
| **Telemetry Transport** | [MQTT Client](https://pub.dev/packages/mqtt_client) | WSS & TLS 8883 connection to HiveMQ Cloud broker for live GPS feeds |
| **Backend & Database** | [Supabase](https://supabase.com) | Relational PostgreSQL backend, Row-Level Security & Auth sessions |
| **Mapping Engine** | [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter) | Native Google Maps SDK integration for rendering tiles, markers & polylines |
| **Typography** | [Google Fonts](https://pub.dev/packages/google_fonts) | Poppins & Inter font family loaded dynamically |

---
## 📁 Repository Architecture

```text
lib/
├── main.dart                   # Entry point, SystemChrome setup & ProviderScope initialization
├── core/
│   ├── routes.dart             # GoRouter path definitions & page route builders
│   └── theme.dart              # Neumorphic design tokens, color palette & AppTheme helpers
├── controllers/
│   ├── mock_data_provider.dart # Live bus status providers & state merge logic
│   └── mqtt_service.dart       # HiveMQ Cloud MQTT client, WSS listener & payload parsing
└── ui/
    ├── components/             # Reusable UI primitives (buttons, neu-cards, badges)
    └── screens/
        ├── splash_screen.dart  # High-performance animated logo entrance view
        ├── login_screen.dart   # Neumorphic Google OAuth authentication screen
        ├── main_layout.dart    # Bottom navigation container & persistent tab state
        ├── home_screen.dart    # Dashboard overview, fleet stats & operational cards
        ├── buses_screen.dart   # Bus directory, active run status & vehicle specs
        ├── map_screen.dart     # Live map view, speed indicator & floating focus controls
        ├── routes_screen.dart  # Swappable route cards & serpentine timeline canvas
        ├── notifications_screen.dart # System notifications feed with pull-to-refresh
        └── profile_screen.dart # User account preferences & profile management
```

---

## 🔒 Security & Best Practices

- **Row-Level Security (RLS):** Backend queries strictly adhere to Supabase Postgres RLS policies.
- **TLS Encryption:** MQTT telemetry communicates over secure WebSockets (WSS) and TLS Port 8883.

---

<p align="center">
  Crafted with ❤️ by the <b>School of STEM</b>
</p>
