<p align="center">
  <img src="app_assets/vmlogo.png" alt="Vahan Mitra Logo" width="180"/>
</p>

<h1 align="center">Vahan Mitra</h1>

<p align="center">
  <b>Next-Generation Real-Time Campus & Fleet Transit Tracking System</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge"/>
  <img src="https://img.shields.io/badge/Riverpod-3.x-8A2BE2?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod Badge"/>
  <img src="https://img.shields.io/badge/HiveMQ_MQTT-TLS_8883-FF6600?style=for-the-badge&logo=hivemq&logoColor=white" alt="HiveMQ Badge"/>
  <img src="https://img.shields.io/badge/Supabase-Database_&_RLS-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase Badge"/>
</p>

---

## 🚀 Overview

**Vahan Mitra** is a state-of-the-art Flutter mobile application designed for real-time campus transit tracking, fleet telematics, and route navigation. Built with a signature **Neumorphic UI Design System**, the app offers sub-second GPS tracking powered by **HiveMQ Cloud MQTT**, seamless backend syncing with **Supabase**, and an intuitive user interface tailored for students, commuters, and fleet managers.

---

## ✨ Key Features

### 📍 1. Real-Time Interactive Live Map
- **Live Vehicle Telemetry:** Tracks dynamic bus positions over OpenStreetMap (`flutter_map`) with animated pulse markers.
- **Floating Speed Pill:** Calculates live speed in real time (`km/h`) and intelligently sets speed to `0 km/h` when stationary or when payload timestamps cease.
- **Top Bus Badge:** Round black indicator displaying the vehicle unit number.
- **1-Tap Focus Controls:** Floating action pills ("Bus Location" & "My Location") to smoothly re-center the map view.
- **Payload Timestamp:** Real-time display of the latest MQTT packet timestamp formatted as `HH:MM AM/PM`.

### 🛣️ 2. Serpentine Campus Routes & Timelines
- **Interactive Route Selector:** Horizontal route chips that dynamically auto-scroll into view when swiping through routes.
- **Route Cards:** Displays route title, bus assignment, and full vehicle registration number (`KL 07 BD 2345`).
- **Serpentine Timeline:** Custom Canvas painter (`_SerpentinePathPainter`) visualizing multi-row bus stops, current position highlights, and destination endpoints.

### 🔔 3. Real-Time Alerts & Announcements
- **Notification Feed:** Categorized system alerts (General, Schedule, Delay, Route Updates).
- **Admin Metadata:** Displays post author name, admin role, and formatted release timestamp.
- **Subtle Pull-to-Refresh:** Integrated `RefreshIndicator` for pull-down feed updates.

### 🎨 4. Signature Neumorphic Design System
- Custom soft-shadow box decorations (`AppTheme.neuBoxDecoration`), inset input fields, and vibrant `AppTheme.redAccent` highlights.
- Modern typography integrated with `GoogleFonts.poppins` and `GoogleFonts.inter`.
- Optimized status bar visibility via `SystemChrome.setSystemUIOverlayStyle` and `AnnotatedRegion` for dark, high-contrast system icons.

---

## 🛠️ Technology Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Core Framework** | [Flutter](https://flutter.dev) | Cross-platform mobile development (SDK `^3.7.2`) |
| **State Management** | [Flutter Riverpod](https://riverpod.dev) | Reactive state management & provider dependency injection |
| **Routing** | [GoRouter](https://pub.dev/packages/go_router) | Declarative route management and smooth page transitions |
| **Live Telemetry** | [MQTT Client](https://pub.dev/packages/mqtt_client) | WSS & TLS 8883 connection to HiveMQ Cloud broker |
| **Backend & Auth** | [Supabase](https://supabase.com) | PostgreSQL relational database with Row-Level Security (RLS) |
| **Mapping Engine** | [Flutter Map](https://pub.dev/packages/flutter_map) | OpenStreetMap tile rendering & geospatial marker layers |
| **Typography** | [Google Fonts](https://pub.dev/packages/google_fonts) | Poppins & Inter modern font families |

---

## 📁 Repository Architecture

```
d:\Works\Vahan_Mitra\lib\
├── main.dart                   # Application entry point & SystemChrome initialization
├── core/
│   ├── routes.dart             # GoRouter configuration & screen transitions
│   └── theme.dart              # Neumorphic design tokens, color palette & AppBarTheme
├── controllers/
│   ├── mock_data_provider.dart # Static & merged bus location Riverpod providers
│   └── mqtt_service.dart       # HiveMQ Cloud MQTT client & telemetry stream parser
└── ui/
    ├── components/             # Reusable UI widgets
    └── screens/
        ├── splash_screen.dart  # Optimized high-performance animated splash screen
        ├── login_screen.dart   # Neumorphic authentication interface
        ├── main_layout.dart    # Bottom navigation bar container
        ├── home_screen.dart    # Dashboard overview, quick actions & status cards
        ├── buses_screen.dart   # Bus fleet directory & live operational status
        ├── map_screen.dart     # Real-time interactive map, speed pill & floating panel
        ├── routes_screen.dart  # Swappable campus route cards & serpentine timeline
        ├── notifications_screen.dart # System notifications feed with pull-to-refresh
        └── profile_screen.dart # User profile settings & account details
```

---

## ⚙️ Environment Configuration

Create a `.env` file in the project root directory with the following configuration keys:

```env
# Supabase Database Configuration
SUPABASE_URL=https://<your-supabase-project>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>

# HiveMQ Cloud MQTT Telemetry Broker Configuration
MQTT_BROKER=<your-hivemq-cluster>.s1.eu.hivemq.cloud
MQTT_PORT=8883
MQTT_USER=<your-mqtt-username>
MQTT_PASSWORD=<your-mqtt-password>
MQTT_TOPIC=vahan_mitra/buses/+/location

# Dynamic Bus Topic-to-BusNo Mapping (JSON string)
MQTT_BUS_CONFIG={"bus_01":{"topic":"tracker/bus_01/location","bus_no":"3"}}
```

---

## 🚦 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.7.2`)
- Android Studio / VS Code with Flutter extension
- Physical Android/iOS device or Emulator

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/LUNAxKRISHNA/Vahan_Mitra.git
   cd Vahan_Mitra
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Ensure your `.env` file is populated in the root directory.

4. **Run the Application:**
   ```bash
   flutter run --dart-define-from-file=.env
   ```

5. **Generate App Launcher Icons (Optional):**
   ```bash
   dart run flutter_launcher_icons
   ```

---

## 🔒 Database & RLS Policy Notes

For relational joins (such as fetching admin credentials in notification alerts), ensure your Supabase `public.admin` table has a SELECT RLS policy enabled for authenticated and anonymous users:

```sql
CREATE POLICY "Allow public read access to admin profile" 
ON "public"."admin" 
FOR SELECT 
USING (true);
```

---

<p align="center">
  Developed with ❤️ by <b>Vahan Mitra Engineering Team</b>
</p>
