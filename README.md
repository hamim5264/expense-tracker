# 🚀 Onyx - Clean Architecture Personal Finance App

Onyx is a premium, state-of-the-art personal finance and Expense Tracker application built with Flutter following strict **Clean Architecture** principles and powered by **Supabase**.

---

## 🌟 Key Features & Advanced Polish

Onyx divides its features cleanly across data layers, business logic use-cases, and premium presentation layers.

### 🎨 Premium UI/UX & Native Aesthetics
- **Natively Branded as "Onyx"**: Configured Android Label and iOS Bundle Names natively to "Onyx".
- **Custom Brand Identity**: Integrated native app launcher icons (`app_final_native_logo.png` with background) and removed-background assets (`app_final_splash_logo.png`) for splash frames.
- **Animated Splash Screen**: Custom entrance controller with a spring scale curve (`Curves.easeOutBack`) and looping custom-painted wave ripple effects.
- **Glass-morphism Sheets**: Frosted glass dialogs (`BackdropFilter`) used for profile photo picker and invite friends actions.
- **Dynamic Theming**: Full **Light and Dark mode** support using a centralized `AppTheme`.
- **Shimmer Effects & Shimmer Loading**: Integrated shimmer animations (`StatisticsShimmerLoading`, `HomeShimmerLoading`) to make the interface feel responsive and alive during asynchronous API loading.

### 📊 Beautiful Premium Statistics & Financial Ledger Sheet
- **Beautiful Graph Design**: Uses a custom-styled line chart widget (`fl_chart`) with double vertical grid lines hidden, dynamic y-axis ceiling, interactive tap tooltips, and dynamic intervals preventing label overlapping.
- **Current Week & Month Filtering**: Built-in boundary logic in `_filterByPeriod` to correctly filter transactions by:
  - **Day**: Grouped by 4-hour intervals.
  - **Week**: Aggregated specifically for the current calendar week (Sunday to Saturday).
  - **Month**: Aggregated for the current calendar month.
  - **Year**: Grouped by month labels (Jan, Mar, May, etc.).
- **Branded PDF Statements**: Clicking the export button in the header opens a confirmation dialog (red-styled Cancel option) allowing the user to select their desired path in their phone's native file manager (`file_picker`). The PDF statement is cleanly structured with the Onyx brand logo, total income/expense cards, transaction ledger tables, and ISO currency representation (e.g. BDT/USD) preventing glyph block formatting errors.

### 🔒 Core Features & Security
- **In-App Password Recovery**: A custom, secure **Security Question** system allowing users to reset passwords within the app.
- **Login and Security Screen**: Separate extracted forms for updating account passwords and configuring/saving security questions.
- **Data and Privacy Screen**:
    - **Export Statements**: Directly maps transaction states and exports full statements to the system clipboard in **CSV** or **JSON** formats.
    - **Danger Zone (Delete Account)**: Confirms with a typing verification trigger, then calls a PostgreSQL RPC function (`delete_user_account`) to securely delete the user and clear all database rows.
- **Invite Friends**: Displays a glass-morphic sheet triggering native URIs (`url_launcher`) to share Onyx download templates via **WhatsApp**, **Messenger**, **SMS**, or **Email**.
- **Session Persistence**: App remembers user login state across restarts.
- **Google Sign-In**: Fully integrated with Google Identity Services.
- **Sound & Vibration Feedback**: Dynamically triggers native sound effects (`success_sound.mp3`, `failed_sound.mp3`) and custom haptic vibration feedback for wallets/transactions operations, controllable by toggles in the Profile settings.

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
- **Local Caching**: Hive / Shared Preferences
- **Functional Programming**: fpdart (Either for error handling)
- **Interactive Graphs**: fl_chart
- **Document Export**: pdf
- **File Manager Integration**: file_picker
- **Vibration & Audio**: audioplayers / HapticFeedback

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
