# 📱 Task Manager — Flutter Client Application

A cross-platform **Flutter** task management application built using the **BLoC (Business Logic Component)** state management architecture, **Dio** HTTP client with queued token refresh interceptors, **GoRouter** declarative routing, and a modern Material 3 design system.

---

## 🏛️ Architecture & Directory Structure

The application strictly adheres to Clean Architecture layers separating Data, Core, and Presentation:

```
task_manager_app/
├── lib/
│   ├── core/
│   │   ├── constants/        # API endpoints, string constants, pagination limits
│   │   ├── network/          # Dio client, token refresh interceptors, error mapping
│   │   ├── storage/          # flutter_secure_storage wrapper for encrypted tokens
│   │   ├── theme/            # AppColors, AppSpacing, AppTheme (Material 3)
│   │   └── utils/            # Validators, date formatters, responsive breakpoints
│   ├── data/
│   │   ├── models/           # UserModel, TaskModel, AuthResponseModel, PaginationModel
│   │   └── repositories/     # AuthRepository, TaskRepository, UserRepository
│   ├── presentation/
│   │   ├── blocs/            # AuthBloc, TaskBloc, TeamBloc (Events, States, Blocs)
│   │   ├── screens/          # Login, Signup, TaskList, TaskDetail, TaskForm, Team
│   │   └── widgets/          # AppButton, AppTextField, Shimmer, TaskCard, ConfirmDialog
│   └── main.dart             # App initialization, RepositoryProviders & MultiBlocProviders
├── test/
│   ├── models_test.dart      # JSON deserialization & pagination tests
│   ├── validators_test.dart  # Form validation logic tests
│   └── widget_test.dart      # UI widget & interaction tests
├── pubspec.yaml
└── README.md
```

---

## 🧠 Why BLoC for State Management?

1. **Separation of Concerns:** Business logic and network API interactions are completely isolated from widget trees.
2. **Predictable State Transitions:** Every state update is the direct result of a strongly typed event (`Event ➔ BLoC ➔ State`).
3. **Streamlined UI Updates:** Widgets selectively rebuild only when their relevant sub-state changes via `BlocBuilder` and `BlocConsumer`.
4. **Independent Unit Testing:** Testing BLoCs does not require launching UI or rendering widgets.

---

## ✨ Key Features & UX Highlights

* 🔐 **Authentication & Persistent Login:** Secure token storage with `flutter_secure_storage`.
* 🔄 **Transparent Token Refresh:** Dio interceptor catches `401 Unauthorized`, calls `/api/auth/refresh`, and retries the original request seamlessly.
* 📋 **Task CRUD & Live Filtering:** Status tabs (`All`, `Todo`, `In Progress`, `Done`) and 300ms debounced search bar.
* 👥 **Team Assignment:** Real-time team member directory with initials avatars and assignee dropdown in task creation/editing.
* 📅 **Timezone-Safe Due Dates:** Date strings are parsed using calendar date components without UTC timezone drift.
* 🎨 **Skeleton Shimmer Loading:** Dynamic linear shader shimmer loading effects on lists and detail views.
* ⚠️ **Automatic Scroll to Error:** Invalid form fields automatically scroll into view and request focus upon submission.
* 🛡️ **Double-Click & Multi-Navigation Guards:** `_isNavigating` and `isLoading` locks prevent duplicate form submissions and multiple screen pushes.

---

## 🚀 Setup & Execution

### 1. Prerequisites
* Flutter SDK v3.19+ or higher (Dart 3.3+)
* Android Studio / VS Code / Connected Device or Chrome

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App

#### On Connected Android Device / Emulator:
```bash
# If using a physical Android device over USB, forward the backend port:
adb reverse tcp:3000 tcp:3000

# Run on connected device
flutter run
```

#### On Chrome (Web):
```bash
flutter run -d chrome
```

---

## 📸 Application Screenshots

| 01. Welcome Back (Login) | 02. Create Account (Signup) |
|:---:|:---:|
| <img src="../screenshots/01_login.png" width="300" alt="Login Screen"/> | <img src="../screenshots/02_signup.png" width="300" alt="Signup Screen"/> |

| 03. Task List & Live Badges | 04. Create Task |
|:---:|:---:|
| <img src="../screenshots/03_task_list.png" width="300" alt="Task List Screen"/> | <img src="../screenshots/04_create_task.png" width="300" alt="Create Task Screen"/> |

| 05. Edit Task Form | 06. Team Members Directory |
|:---:|:---:|
| <img src="../screenshots/05_edit_task.png" width="300" alt="Edit Task Screen"/> | <img src="../screenshots/06_team_members.png" width="300" alt="Team Members Screen"/> |

| 07. Sorting & Filtering Options |
|:---:|
| <img src="../screenshots/07_sort_and_filter.png" width="300" alt="Sorting & Filtering Options"/> |



---

## 🧪 Testing & Analysis

```bash
# Run static code analysis
flutter analyze

# Run all unit and widget tests
flutter test
```
*All 16 unit and widget test suites pass with 0 issues.*

