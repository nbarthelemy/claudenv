---
name: repository-generator
description: Generate repository pattern with offline-first caching
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Repository Generator

Generate repository pattern for data access with caching.

## Triggers

- "create repository"
- "add repository"
- "data layer"
- "offline first"

## Documentation Access

**Research before implementing.** Consult:
- https://developer.android.com/topic/architecture/data-layer - Data layer guide

## Process

1. **Define Interface**
   - Create repository interface
   - Define operations

2. **Implement Repository**
   - Add caching strategy
   - Handle network/local data

3. **Setup DI**
   - Create Hilt module
   - Bind implementation

## Output

Creates:
- `domain/repository/{Name}Repository.kt` - Interface
- `data/repository/{Name}RepositoryImpl.kt` - Implementation
- `di/{Name}Module.kt` - Hilt binding

## Templates

### Repository Interface
```kotlin
interface {Name}Repository {
    fun getAll(): Flow<List<{Name}>>

    fun getById(id: String): Flow<{Name}?>

    suspend fun create(request: Create{Name}Request): Result<{Name}>

    suspend fun update(id: String, request: Update{Name}Request): Result<{Name}>

    suspend fun delete(id: String): Result<Unit>

    suspend fun refresh(): Result<Unit>
}
```

### Repository Implementation
```kotlin
class {Name}RepositoryImpl @Inject constructor(
    private val api: {Name}Api,
    private val dao: {Name}Dao,
    @IoDispatcher private val dispatcher: CoroutineDispatcher
) : {Name}Repository {

    override fun getAll(): Flow<List<{Name}>> = dao.getAll()
        .map { entities -> entities.map { it.toDomain() } }
        .flowOn(dispatcher)

    override fun getById(id: String): Flow<{Name}?> = dao.observeById(id)
        .map { it?.toDomain() }
        .flowOn(dispatcher)

    override suspend fun create(request: Create{Name}Request): Result<{Name}> =
        withContext(dispatcher) {
            runCatching {
                val response = api.create(request.toDto())
                dao.insert(response.toEntity())
                response.toDomain()
            }
        }

    override suspend fun update(id: String, request: Update{Name}Request): Result<{Name}> =
        withContext(dispatcher) {
            runCatching {
                val response = api.update(id, request.toDto())
                dao.update(response.toEntity())
                response.toDomain()
            }
        }

    override suspend fun delete(id: String): Result<Unit> =
        withContext(dispatcher) {
            runCatching {
                api.delete(id)
                dao.deleteById(id)
            }
        }

    override suspend fun refresh(): Result<Unit> =
        withContext(dispatcher) {
            runCatching {
                val response = api.getAll()
                dao.replaceAll(response.map { it.toEntity() })
            }
        }
}
```

### Offline-First Strategy
```kotlin
class {Name}RepositoryImpl @Inject constructor(
    private val api: {Name}Api,
    private val dao: {Name}Dao,
    private val networkMonitor: NetworkMonitor,
    @IoDispatcher private val dispatcher: CoroutineDispatcher
) : {Name}Repository {

    override fun getAll(): Flow<List<{Name}>> = channelFlow {
        // Emit cached data immediately
        val cached = dao.getAll().first()
        send(cached.map { it.toDomain() })

        // Refresh from network if online
        if (networkMonitor.isOnline.first()) {
            try {
                val fresh = api.getAll()
                dao.replaceAll(fresh.map { it.toEntity() })
                // Room Flow will emit new data automatically
            } catch (e: Exception) {
                // Log error, cached data already emitted
                Timber.w(e, "Failed to refresh, using cached data")
            }
        }

        // Continue observing local changes
        dao.getAll().collect { entities ->
            send(entities.map { it.toDomain() })
        }
    }.flowOn(dispatcher)
}
```

### Hilt Module
```kotlin
@Module
@InstallIn(SingletonComponent::class)
abstract class {Name}Module {

    @Binds
    @Singleton
    abstract fun bind{Name}Repository(
        impl: {Name}RepositoryImpl
    ): {Name}Repository
}
```

## Best Practices

- Use Flow for reactive data
- Implement offline-first for critical data
- Handle errors with Result type
- Use dependency injection
- Separate network and local concerns
- Test with fake implementations
