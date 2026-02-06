# Android Kotlin Stack Rules

> Core conventions and patterns for Android development with Kotlin and Jetpack Compose.

## Research Before Implementing

All agents have **unfettered documentation access**. Before implementing any feature:
1. Consult Android documentation at developer.android.com
2. Check Material Design 3 guidelines
3. Verify API level compatibility

## Framework Versions

| Technology | Version | Notes |
|------------|---------|-------|
| Kotlin | 2.0 | K2 compiler |
| Jetpack Compose | Latest BOM | Compose BOM |
| Android Target | API 26+ | Android 8.0+ |
| Gradle | 8.x | Kotlin DSL |

## Project Structure

```
app/
├── src/main/kotlin/com/siquora/{app}/
│   ├── MainActivity.kt
│   ├── ui/
│   │   ├── screens/        # Compose screens
│   │   ├── components/     # Reusable composables
│   │   └── theme/          # Material theme
│   ├── viewmodel/          # ViewModels
│   ├── data/
│   │   ├── repository/     # Repositories
│   │   ├── remote/         # API clients
│   │   └── local/          # Room database
│   ├── domain/
│   │   ├── model/          # Domain models
│   │   └── usecase/        # Use cases
│   └── di/                 # Hilt modules
├── src/test/               # Unit tests
└── src/androidTest/        # Instrumented tests
```

---

## Mandatory Rules

### 1. Use Immutable State

**ALWAYS use immutable StateFlow** for UI state. Expose immutable flow, keep mutable private.

### 2. Use Sealed Interfaces for State

**ALWAYS use sealed interfaces** for UI state types instead of data classes with nullable fields.

### 3. Separate Stateful and Stateless Composables

**Split screens into stateful container and stateless content** for testability.

### 4. Use Lifecycle-Aware Collection

**ALWAYS use collectAsStateWithLifecycle** for flows in Compose.

### 5. Handle Errors with Result Type

**Use Kotlin Result or custom Result type** for operations that can fail.

### 6. Use Dependency Injection

**ALWAYS use Hilt** for dependency injection.

### 7. Use Proper Coroutine Scopes

**Match scope to lifecycle:**
- `viewModelScope` for ViewModels
- `lifecycleScope` for Activities/Fragments

### 8. Keep Composables Small

**Extract composables into focused, reusable components.**

---

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| New screen created | Create stateful Screen + stateless Content composables |
| New ViewModel created | Use Hilt injection, expose immutable StateFlow |
| New repository created | Implement interface, use Result type |
| New model from API | Create Codable data class with proper naming |

## Validation Commands

```bash
./gradlew assembleDebug    # Build
./gradlew test             # Unit tests
./gradlew lint             # Lint checks
./gradlew check            # All checks
```

---

## Reference Documentation

For detailed code patterns, examples, and best practices:
- Read `.claude/rules/kotlin/reference.md` when implementing complex features
- Read `.claude/references/README.md` for official Android documentation
