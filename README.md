# Teyzix Workforce Management Platform

An enterprise-grade mobile and web-responsive application designed for managing field employees, monitoring real-time task assignments, tracking live location-based attendance, and providing dynamic performance analytics for organizations.

## 🚀 Overview

The **Teyzix Workforce Management** system bridges the gap between field teams and management. By utilizing strict role-based access controls, biometric authentication, and offline-first synchronization, the platform ensures that daily field operations run securely and seamlessly.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **State Management:** GetX
- **Backend & Database:** Supabase (PostgreSQL, Auth, Storage, Realtime)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Local Storage:** SharedPreferences & Hive
- **UI Components:** FL Chart (Analytics), Google Maps (Tracking)

## 🔑 Key Features

- **Role-Based Routing:** Secure and automated app routing depending on the user's role (`Field Employee`, `Field Supervisor`, or `Admin`).
- **Biometric Attendance:** Mandatory FaceID/Fingerprint scans required for Check-in and Check-out, ensuring authentic attendance marking.
- **Geolocation Tracking:** Captures device details and precise Lat/Lng coordinates upon attendance marking.
- **Offline Sync Capabilities:** An intelligent background `SyncController` queues attendance records locally if the device loses internet connection, syncing them automatically once back online.
- **Real-Time Task Dispatch:** Managers can assign tasks to active employees. Employees receive instant push notifications and can update task progress (Pending -> In Progress -> Completed).
- **Responsive Admin Dashboard:** A premium, fully responsive Admin Shell that adapts flawlessly across Mobile, Tablet, and Desktop screens. Features real-time stat cards, dynamic Pie Charts, and Weekly Attendance Bar Charts.

---

## 📱 Application Flow & Modules

### 1. Authentication Module
- **Splash Screen:** Intelligently checks active sessions and locally cached roles to instantly route users to their respective dashboards.
- **Signup/Login:** Users register with an Email, Phone Number, and Profile Picture. Data is securely stored in Supabase Auth and the `profiles` table.

### 2. Field Employee Flow
- **Dashboard:** Employees view their pending and active tasks.
- **Task Execution:** Employees can start tasks, upload completion proofs (images), and mark them as completed.
- **Attendance:** A dedicated screen to punch in/out. The system validates location services and triggers the native Biometric prompt before updating the Supabase Database.

### 3. Field Supervisor (Manager) Flow
- **Manager Dashboard:** Real-time listeners automatically update the dashboard when new employees join or when tasks are completed.
- **Task Creation:** Managers can dispatch tasks specifically to active employees.
- **Task Verification:** Managers review the completion proofs submitted by employees and can either **Verify** or **Reject** the task.

### 4. Admin Flow
- **Global Dashboard:** A high-level overview featuring total active staff, pending tasks, and recent live activities.
- **User Management:** Admins can view the entire workforce directory and instantly promote or demote user roles.
- **Global Tasks Report:** An interactive Pie Chart dividing the organization's tasks into 'Running' and 'Completed' segments, integrated with tabbed lists.
- **Attendance Analytics:** Admins can select any user from a dropdown to instantly generate a Weekly Working Hours Bar Chart along with their exact punch-in/out timestamps.

---

## ⚙️ Project Setup & Installation

1. **Clone the Repository:**
   ```bash
   git clone <repository_url>
   cd tryzx_workfoce_mangment
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   - Ensure your `Supabase` URL and Anon Key are correctly initialized in `main.dart`.
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files in their respective directories for Firebase Push Notifications.

4. **Run the App:**
   ```bash
   flutter run
   ```

---

## 🔒 Security & Performance Highlights
- Zero **RenderOverflow** errors on Admin Desktop/Tablet Views due to custom `Responsive.aw()` handling.
- `fl_chart` anomalies (e.g., infinite bar heights due to missing checkout data) are safely clamped and clipped.
- Native device restrictions ensure GPS must be enabled before checking in.

> **Designed & Developed for Teyzix Core Internship (June Batch).**
