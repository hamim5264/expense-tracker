# 🚀 Expense Tracker - Clean Architecture Flutter Project

A premium, scalable Expense Tracker application built with Flutter, following **Clean Architecture** principles and powered by **Supabase**.

---

## 🌟 Current Progress (Auth Phase Completed)

We have successfully completed the foundation and the entire Authentication module. The app is production-ready in terms of security, state management, and user onboarding.

### 🎨 Premium UI/UX
- **Animated Splash Screen**: Custom scale and fade animations with theme-aware logos.
- **Dynamic Theming**: Full **Light and Dark mode** support using a centralized `AppTheme`.
- **Glass-morphism Blur Loader**: A modern, premium blur overlay during network calls (Login/Register/Logout).
- **Shimmer Effects**: Premium skeleton loading for a smooth user experience.
- **Custom Toasts**: Brand-aligned notification messages (Purple for success, Red for failure).
- **Inter Font**: Integrated Google Fonts for a clean, modern look.

### 🔒 Core Features & Security
- **Clean Architecture**: Strictly separated into **Data, Domain, and Presentation** layers for maximum scalability and testability.
- **Supabase Integration**: 
    - Real-time authentication.
    - Automatic **Profile creation** via PostgreSQL Triggers.
    - **Row Level Security (RLS)** to protect user data.
- **Manual Authentication**: 
    - Secure registration with **Unique Usernames**.
    - Real-time form validation.
- **Google Sign-In**: Fully integrated with Google Identity Services.
- **In-App Password Recovery**: A custom, secure **Security Question** system allowing users to reset passwords without ever leaving the app or checking email.
- **Session Persistence**: App remembers user login state across restarts.
- **Environment Safety**: Sensitive keys (Supabase URL, API Keys, Client IDs) are secured in a `.env` file and hidden from version control.

---

## 🏗️ Project Structure

```text
lib/
 ├── core/              # Shared utilities, themes, routing, and errors
 │    ├── common/       # Reusable widgets (BlurLoader, Shimmer) and entities
 │    ├── theme/        # Light/Dark theme configurations
 │    ├── routing/      # App route management
 │    └── usecase/      # Base UseCase interface
 ├── features/          # Feature-based modules
 │    ├── auth/         # Authentication Module
 │    │    ├── data/    # Repositories and DataSources (Supabase)
 │    │    ├── domain/  # Entities and UseCases (SignUp, Login, Reset)
 │    │    └── presentation/ # BLoC and UI Pages/Widgets
 │    └── expense/      # Expense Module (Phase 2)
 └── init_dependencies.dart # Dependency Injection (GetIt)
```

---

## 🛠️ Tech Stack
- **State Management**: Flutter BLoC
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Networking**: Dio
- **DI**: GetIt
- **Local Caching**: Hive
- **Functional Programming**: fpdart (Either for error handling)

---

## 🚀 Getting Started

1. **Clone the project**
2. **Environment Variables**:
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_url
   SUPABASE_PUBLISHABLE_KEY=your_key
   GOOGLE_WEB_CLIENT_ID=your_id
   GOOGLE_ANDROID_CLIENT_ID=your_id
   ```
3. **Supabase Setup**:
   Run the SQL scripts provided in the documentation to set up the `profiles` table, PostgreSQL Triggers, and the `reset_password_with_answer` RPC function.
4. **Run the App**:
   ```bash
   flutter pub get
   flutter run
   ```

---

## 📅 Next Phase (Starting Tomorrow)
- **Profile Management**: Viewing and updating user details.
- **Expense Tracking**: Add, edit, and delete transactions.
- **Dashboard**: Visualizing expenses with charts.
- **Bank & Card Management**: Tracking multiple accounts.

---
**Developed with ❤️ by Hamim Leon**
