# Baubles of the Bale

An Adventure/RPG Roblox game built with Rojo.

## Build System

- Use **Rojo** to sync code to Roblox Studio
- Commit and push after every change with detailed commit messages explaining what changed and why

## Code Style

- Write all code in **Luau with strict type annotations**
- Add comprehensive comments to functions and complex logic
- Use assertions and fail-fast error handling — let errors surface quickly for debugging

## Architecture

### Folder Structure
Use type-based folders at the top level with feature-based organization within:
```
src/
  Client/
    Combat/
    Inventory/
    UI/
  Server/
    Combat/
    DataManager/
    Quests/
  Shared/
    Types/
    Utils/
```

### Frameworks & Libraries
- **Knit** for networking (services and controllers)
- **Roact** (or react-lua) for UI components
- **ProfileService** for player data persistence
- **Promise** for async operations
- **Maid** or **Trove** for cleanup and memory management

## Testing

- Write unit tests using **TestEZ** for all systems
- Test critical paths thoroughly (data, combat, progression)

## Important Rules

- **Never remove anything** unless I explicitly say to remove it
- When I ask for something, assume I want an **addition or expansion** to the game
- Only remove features if I make it very clear that's what I want
