---
name: room-generator
description: Generate Room database entities, DAOs, and database setup
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Room Generator

Generate Room database components with proper patterns.

## Triggers

- "create room entity"
- "add database"
- "room database"
- "add table"
- "create dao"

## Documentation Access

**Research before implementing.** Consult:
- https://developer.android.com/training/data-storage/room - Room guide

## Process

1. **Define Entity**
   - Create entity class
   - Set up relationships
   - Add indices

2. **Create DAO**
   - Define CRUD operations
   - Add Flow queries

3. **Update Database**
   - Add entity to schema
   - Create migration if needed

## Output

Creates:
- `data/local/entity/{Name}Entity.kt` - Room entity
- `data/local/dao/{Name}Dao.kt` - DAO interface
- Updates `data/local/AppDatabase.kt`

## Templates

### Entity
```kotlin
@Entity(
    tableName = "{table_name}",
    indices = [
        Index(value = ["{index_column}"])
    ]
)
data class {Name}Entity(
    @PrimaryKey
    val id: String,

    val name: String,

    val description: String?,

    @ColumnInfo(name = "created_at")
    val createdAt: Long = System.currentTimeMillis(),

    @ColumnInfo(name = "updated_at")
    val updatedAt: Long = System.currentTimeMillis()
)
```

### DAO
```kotlin
@Dao
interface {Name}Dao {
    @Query("SELECT * FROM {table_name} ORDER BY created_at DESC")
    fun getAll(): Flow<List<{Name}Entity>>

    @Query("SELECT * FROM {table_name} WHERE id = :id")
    suspend fun getById(id: String): {Name}Entity?

    @Query("SELECT * FROM {table_name} WHERE id IN (:ids)")
    suspend fun getByIds(ids: List<String>): List<{Name}Entity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entity: {Name}Entity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(entities: List<{Name}Entity>)

    @Update
    suspend fun update(entity: {Name}Entity)

    @Delete
    suspend fun delete(entity: {Name}Entity)

    @Query("DELETE FROM {table_name} WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM {table_name}")
    suspend fun deleteAll()
}
```

### Mapper Extension
```kotlin
fun {Name}Entity.toDomain(): {Name} = {Name}(
    id = id,
    name = name,
    description = description,
    createdAt = Instant.fromEpochMilliseconds(createdAt),
    updatedAt = Instant.fromEpochMilliseconds(updatedAt)
)

fun {Name}.toEntity(): {Name}Entity = {Name}Entity(
    id = id,
    name = name,
    description = description,
    createdAt = createdAt.toEpochMilliseconds(),
    updatedAt = updatedAt.toEpochMilliseconds()
)
```

### Migration
```kotlin
val MIGRATION_{X}_{Y} = object : Migration({X}, {Y}) {
    override fun migrate(database: SupportSQLiteDatabase) {
        database.execSQL("""
            CREATE TABLE IF NOT EXISTS `{table_name}` (
                `id` TEXT NOT NULL,
                `name` TEXT NOT NULL,
                `description` TEXT,
                `created_at` INTEGER NOT NULL,
                `updated_at` INTEGER NOT NULL,
                PRIMARY KEY(`id`)
            )
        """)
        database.execSQL("CREATE INDEX IF NOT EXISTS `index_{table_name}_{index_column}` ON `{table_name}` (`{index_column}`)")
    }
}
```

## Best Practices

- Use Flow for reactive queries
- Implement proper migrations
- Add indices for query performance
- Use transactions for batch operations
- Separate entities from domain models
