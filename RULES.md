# Anti Gravity Project: Golden Rules & Architecture

As a Senior Software Architect expert in Flutter and Dart, I adhere to the following strictly defined rules for the "Anti Gravity" mobile application.

## 1. Clean Architecture (Core Principle)
Every feature MUST be separated into three strictly isolated layers:

### Domain Layer (Purity)
- **Entities**: Pure Dart classes representing the business objects.
- **Use Cases**: Specific business logic for a single feature or action.
- **Repository Definitions**: Abstract interfaces representing the data contracts.
- **Dependencies**: No external library dependencies (strict purity).

### Data Layer (Implementation)
- **Repositories**: Concrete implementations of the Domain repositories.
- **Models (DTOs)**: Data Transfer Objects with serialization (from/to JSON/GraphQL).
- **Mappers**: Logic to convert Models to/from Entities.
- **Data Sources**: Interfaces and implementations for Remote (GraphQL) and Local (SQLite) storage.

### Presentation Layer (UI & State)
- **BLoC (Business Logic Component)**: Exclusively used for state management.
- **Widgets**: Flutter components.
- **Pages**: Top-level UI containers.

## 2. Technology Stack
- **State Management**: BLoC.
- **Networking**: GraphQL for all remote communications.
- **Persistence**: SQLite (via `sqflite`) for local caching and offline data.
- **Modularization**: Features are stored in `lib/features/` as independent modules (e.g., `auth`, `jobs`, `profile`).

## 3. SOLID & Scalability
- **S**ingle Responsibility: One class, one job.
- **O**pen/Closed: Features open for extension but closed for modification.
- **L**iskov Substitution: Subtypes must be substitutable for their base types.
- **I**nterface Segregation: Precise interfaces, not "fat" ones.
- **D**ependency Inversion: Depend on abstractions, not concretions (using `get_it`).

## 4. UI/UX Excellence
- **Atomic Components**: Highly reusable Flutter widgets.
- **Modern Aesthetics**: Vibrant colors, dark modes, glassmorphism, and dynamic animations.
- **Micro-interactions**: Hover effects, transitions, and polish.

## 5. Development Workflow
- **Code Generation**: Use `build_runner` for JSON serialization and DI.
- **Testing**: TDD (Test Driven Development) approach where possible, focusing on Use Cases and Repositories.

## 6. Theme Management (Black Mode)
- **Dark Mode First**: The design should prioritize a "True Black" (AMOLED) experience for Dark Mode.
- **Dynamic Switching**: The application MUST support dynamic switching between Light, Dark, and System themes using a global BLoC.
- **Color Consistency**: Use the defined `AppTheme` tokens. Avoid hardcoding colors in widgets.

## 7. Localization (i18n)
- **Centralized Text Management**: NO hardcoded strings are allowed in UI components. 
- **System**: Use Flutter's `AppLocalizations` (via `.arb` files).
- **Naming Convention**: Key names must be descriptive and categorized (e.g., `chatInputPlaceholder`, `authLoginButton`).
- **Dynamic Content**: Use placeholders in ARB files for dynamic values (e.g., `Hello, {name}`).
