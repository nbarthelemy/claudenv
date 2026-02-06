---
name: navigation-generator
description: Generate Navigation Compose patterns with type-safe navigation
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Navigation Generator

Generate Navigation Compose patterns with type-safe routes.

## Triggers

- "create navigation"
- "add navigation"
- "navigation flow"
- "navigation graph"

## Documentation Access

**Research before implementing.** Consult:
- https://developer.android.com/jetpack/compose/navigation - Navigation Compose

## Process

1. **Define Routes**
   - Create sealed interface for destinations
   - Define route parameters

2. **Create NavHost**
   - Set up navigation graph
   - Configure transitions

3. **Integrate with ViewModel**
   - Handle navigation events
   - Pass arguments

## Output

Creates:
- `navigation/AppNavigation.kt` - NavHost and routes
- `navigation/Destinations.kt` - Type-safe destinations

## Templates

### Type-Safe Destinations
```kotlin
@Serializable
sealed interface Destination {
    @Serializable
    data object Home : Destination

    @Serializable
    data object Products : Destination

    @Serializable
    data class ProductDetail(val productId: String) : Destination

    @Serializable
    data object Cart : Destination

    @Serializable
    data class Checkout(val cartId: String) : Destination
}
```

### Navigation Host
```kotlin
@Composable
fun AppNavHost(
    navController: NavHostController = rememberNavController(),
    modifier: Modifier = Modifier
) {
    NavHost(
        navController = navController,
        startDestination = Destination.Home,
        modifier = modifier
    ) {
        composable<Destination.Home> {
            HomeScreen(
                onNavigateToProducts = {
                    navController.navigate(Destination.Products)
                }
            )
        }

        composable<Destination.Products> {
            ProductsScreen(
                onProductClick = { productId ->
                    navController.navigate(Destination.ProductDetail(productId))
                }
            )
        }

        composable<Destination.ProductDetail> { backStackEntry ->
            val destination = backStackEntry.toRoute<Destination.ProductDetail>()
            ProductDetailScreen(
                productId = destination.productId,
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable<Destination.Cart> {
            CartScreen(
                onCheckout = { cartId ->
                    navController.navigate(Destination.Checkout(cartId))
                }
            )
        }
    }
}
```

### Bottom Navigation
```kotlin
@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val currentDestination by navController.currentBackStackEntryAsState()

    Scaffold(
        bottomBar = {
            NavigationBar {
                bottomNavItems.forEach { item ->
                    NavigationBarItem(
                        icon = { Icon(item.icon, contentDescription = item.label) },
                        label = { Text(item.label) },
                        selected = currentDestination?.destination?.route == item.route,
                        onClick = {
                            navController.navigate(item.destination) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { padding ->
        AppNavHost(
            navController = navController,
            modifier = Modifier.padding(padding)
        )
    }
}
```

## Best Practices

- Use type-safe navigation with @Serializable
- Handle deep links with NavDeepLink
- Use popUpTo for proper back stack management
- Save/restore state for bottom navigation
- Pass minimal data between screens
