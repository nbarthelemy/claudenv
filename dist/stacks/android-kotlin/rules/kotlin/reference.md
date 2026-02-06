# Android Kotlin Stack Reference

> Detailed code patterns, examples, and best practices for Android development with Kotlin and Jetpack Compose.

## Code Examples

### Immutable State

```kotlin
// ✅ Good - Immutable state
private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
val uiState: StateFlow<UiState> = _uiState.asStateFlow()

// ❌ Bad - Mutable exposed state
val uiState = MutableStateFlow<UiState>(UiState.Loading)
```

### Sealed Interfaces for State

```kotlin
// ✅ Good - Sealed interface
sealed interface ProductsUiState {
    data object Loading : ProductsUiState
    data class Success(val products: List<Product>) : ProductsUiState
    data class Error(val message: String) : ProductsUiState
}

// ❌ Bad - Data class with nullable fields
data class ProductsUiState(
    val isLoading: Boolean = false,
    val products: List<Product>? = null,
    val error: String? = null
)
```

### Separate Stateful and Stateless Composables

```kotlin
// ✅ Good - Separation of concerns
@Composable
fun ProductsScreen(
    viewModel: ProductsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    ProductsContent(uiState = uiState, onRefresh = viewModel::refresh)
}

@Composable
private fun ProductsContent(
    uiState: ProductsUiState,
    onRefresh: () -> Unit
) {
    // Pure UI - no ViewModel reference
}
```

### Lifecycle-Aware Collection

```kotlin
// ✅ Good - Lifecycle-aware
val uiState by viewModel.uiState.collectAsStateWithLifecycle()

// ❌ Bad - Not lifecycle-aware
val uiState by viewModel.uiState.collectAsState()
```

### Result Type

```kotlin
// ✅ Good - Result type
override suspend fun getProducts(): Result<List<Product>> = runCatching {
    api.getProducts().map { it.toDomain() }
}

// In ViewModel
viewModelScope.launch {
    repository.getProducts()
        .onSuccess { _uiState.value = UiState.Success(it) }
        .onFailure { _uiState.value = UiState.Error(it.message) }
}
```

### Dependency Injection

```kotlin
// ✅ Good - Hilt injection
@HiltViewModel
class ProductsViewModel @Inject constructor(
    private val repository: ProductRepository
) : ViewModel()

// ❌ Bad - Manual instantiation
class ProductsViewModel(
    private val repository: ProductRepository = ProductRepositoryImpl()
)
```

### Coroutine Scopes

```kotlin
// ✅ Good - viewModelScope for ViewModels
viewModelScope.launch {
    val products = repository.getProducts()
}

// ✅ Good - lifecycleScope for Activities/Fragments
lifecycleScope.launch {
    viewModel.events.collect { handleEvent(it) }
}
```

### Small Composables

```kotlin
// ✅ Good - Small, focused composables
@Composable
private fun ProductCard(product: Product, onClick: () -> Unit) {
    Card(onClick = onClick) {
        ProductImage(product.imageUrl)
        ProductInfo(product.name, product.price)
    }
}

@Composable
private fun ProductImage(url: String) { /* ... */ }

@Composable
private fun ProductInfo(name: String, price: Money) { /* ... */ }
```

---

## Code Patterns

### Compose Screen Pattern

```kotlin
@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel = hiltViewModel(),
    onNavigateBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    ProfileContent(
        uiState = uiState,
        onRefresh = viewModel::refresh,
        onNavigateBack = onNavigateBack
    )
}

@Composable
private fun ProfileContent(
    uiState: ProfileUiState,
    onRefresh: () -> Unit,
    onNavigateBack: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Profile") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { padding ->
        when (uiState) {
            is ProfileUiState.Loading -> LoadingIndicator()
            is ProfileUiState.Success -> ProfileDetails(
                user = uiState.user,
                modifier = Modifier.padding(padding)
            )
            is ProfileUiState.Error -> ErrorMessage(uiState.message)
        }
    }
}
```

### ViewModel Pattern

```kotlin
@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<ProfileUiState>(ProfileUiState.Loading)
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        loadUser()
    }

    private fun loadUser() {
        viewModelScope.launch {
            repository.getUser()
                .onSuccess { _uiState.value = ProfileUiState.Success(it) }
                .onFailure { _uiState.value = ProfileUiState.Error(it.message ?: "Error") }
        }
    }

    fun refresh() {
        _uiState.value = ProfileUiState.Loading
        loadUser()
    }
}
```

### Repository Pattern

```kotlin
interface UserRepository {
    fun observeUser(): Flow<User?>
    suspend fun getUser(): Result<User>
    suspend fun updateUser(user: User): Result<Unit>
}

class UserRepositoryImpl @Inject constructor(
    private val api: UserApi,
    private val dao: UserDao,
    @IoDispatcher private val dispatcher: CoroutineDispatcher
) : UserRepository {

    override fun observeUser(): Flow<User?> =
        dao.observeUser().map { it?.toDomain() }.flowOn(dispatcher)

    override suspend fun getUser(): Result<User> = withContext(dispatcher) {
        runCatching {
            val user = api.getUser()
            dao.insert(user.toEntity())
            user.toDomain()
        }
    }
}
```

---

## Security Patterns

### Never Hardcode Secrets

```kotlin
// ❌ NEVER
const val API_KEY = "sk_live_abc123"

// ✅ Use BuildConfig or Secrets Gradle Plugin
val apiKey = BuildConfig.API_KEY
```

### Use ProGuard/R8

Always enable minification for release builds.

---

## Performance Patterns

### Use LazyColumn for Lists

```kotlin
LazyColumn {
    items(
        items = products,
        key = { it.id }
    ) { product ->
        ProductRow(product = product)
    }
}
```

### Remember Expensive Calculations

```kotlin
val sortedProducts = remember(products) {
    products.sortedBy { it.name }
}
```
