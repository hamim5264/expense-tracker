# 🚀 Onyx - Clean Architecture Flutter Project

A premium, scalable personal finance and Expense Tracker application built with Flutter, following **Clean Architecture** principles and powered by **Supabase**.

---

## 🌟 Features & Current Progress

We have successfully completed the core foundation, security configurations, and advanced user profiles modules. The application follows strict clean architecture separation (Data, Domain, and Presentation).

### 🎨 Premium UI/UX & Native Polish
- **Natively Renamed to "Onyx"**: Configured Android Label and iOS Bundle Names natively to "Onyx".
- **Custom Brand Identity**: Integrated native app launcher icons (`app_final_native_logo.png` with background) and removed-background assets (`app_final_splash_logo.png`) for splash frames.
- **Animated Splash Screen**: Custom entrance controller with a spring scale curve (`Curves.easeOutBack`) and looping custom-painted wave ripple effects.
- **Glass-morphism Sheets**: Frosted glass dialogs (`BackdropFilter`) used for profile photo picker and invite friends actions.
- **Dynamic Theming**: Full **Light and Dark mode** support using a centralized `AppTheme`.

### 🔒 Core Features & Security
- **In-App Password Recovery**: A custom, secure **Security Question** system allowing users to reset passwords within the app.
- **Login and Security Screen**: Separate extracted forms for updating account passwords and configuring/saving security questions.
- **Data and Privacy Screen**:
    - **Export Statements**: Directly maps transaction states and exports full statements to the system clipboard in **CSV** or **JSON** formats.
    - **Danger Zone (Delete Account)**: Confirms with a typing verification trigger, then calls a PostgreSQL RPC function (`delete_user_account`) to securely delete the user and clear all database rows.
- **Invite Friends**: Displays a glass-morphic sheet triggering native URIs (`url_launcher`) to share Onyx download templates via **WhatsApp**, **Messenger**, **SMS**, or **Email**.
- **Session Persistence**: App remembers user login state across restarts.
- **Google Sign-In**: Fully integrated with Google Identity Services.

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
 │    ├── auth/         # Authentication and Profile Modules
 │    │    ├── data/    # Repositories and DataSources (Supabase)
 │    │    ├── domain/  # Entities and UseCases (SignUp, Login, Security, Delete)
 │    │    └── presentation/ # BLoC and UI Pages/Widgets
 │    └── expense/      # Expense Module
 └── init_dependencies.dart # Dependency Injection (GetIt)
```

---

## 🛠️ Tech Stack
- **State Management**: Flutter BLoC
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **DI**: GetIt
- **External Launcher**: url_launcher
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
   Run the SQL scripts provided in `supabase_setup.sql` to set up profiles, triggers, and the delete account RPC functions.
4. **Run the App**:
   ```bash
   flutter pub get
   flutter run
   ```

---

**Developed with ❤️ by Hamim Leon**
