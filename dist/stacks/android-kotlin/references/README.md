# Android Kotlin Documentation References

This directory contains curated documentation references for the android-kotlin stack.

## Official Documentation

All agents and skills in this stack have **permission to research before asking**. When implementing features, consult these authoritative sources:

### Core Framework
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| Kotlin | https://kotlinlang.org/docs | Language reference |
| Android | https://developer.android.com/docs | Platform docs |
| Jetpack | https://developer.android.com/jetpack | Jetpack libraries |

### UI
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| Jetpack Compose | https://developer.android.com/jetpack/compose | UI framework |
| Material 3 | https://m3.material.io | Design system |
| Navigation Compose | https://developer.android.com/jetpack/compose/navigation | Navigation |

### Data
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| Room | https://developer.android.com/training/data-storage/room | Database |
| DataStore | https://developer.android.com/topic/libraries/architecture/datastore | Preferences |
| Retrofit | https://square.github.io/retrofit | HTTP client |

### Architecture
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| ViewModel | https://developer.android.com/topic/libraries/architecture/viewmodel | Lifecycle |
| Hilt | https://developer.android.com/training/dependency-injection/hilt-android | DI |
| Coroutines | https://kotlinlang.org/docs/coroutines-overview.html | Async |
| Flow | https://developer.android.com/kotlin/flow | Reactive |

### Testing
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| Testing Guide | https://developer.android.com/training/testing | Overview |
| Compose Testing | https://developer.android.com/jetpack/compose/testing | UI testing |
| MockK | https://mockk.io | Mocking |

### Distribution
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| Play Store | https://developer.android.com/distribute/google-play | Publishing |
| App Bundle | https://developer.android.com/guide/app-bundle | Distribution format |
| Play Console | https://play.google.com/console/about | Store management |

## Research Protocol

When implementing any feature:

1. **Check Android docs first** - Use the URLs above
2. **Verify API level** - Check minSdk compatibility
3. **Follow Material Design** - Match Google's patterns
4. **Check Jetpack releases** - For latest features

## Key Documentation Sections

### Jetpack Compose
- State: https://developer.android.com/jetpack/compose/state
- Lifecycle: https://developer.android.com/jetpack/compose/lifecycle
- Side Effects: https://developer.android.com/jetpack/compose/side-effects
- Performance: https://developer.android.com/jetpack/compose/performance

### Architecture Components
- UI Layer: https://developer.android.com/topic/architecture/ui-layer
- Data Layer: https://developer.android.com/topic/architecture/data-layer
- Domain Layer: https://developer.android.com/topic/architecture/domain-layer

### Kotlin
- Coroutines: https://kotlinlang.org/docs/coroutines-guide.html
- Flow: https://kotlinlang.org/docs/flow.html
- Serialization: https://kotlinlang.org/docs/serialization.html
