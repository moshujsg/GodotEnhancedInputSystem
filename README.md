# Godot Input System

A flexible input handling system for Godot that allows managing multiple input contexts dynamically. This system lets you group input actions into contexts and control which context is active at any given time.

## Features
- Organize input actions into separate **mapping contexts**.
- Dynamically activate and deactivate contexts using `push_mapping_context` and `remove_mapping_context`.
- Ensures that when multiple contexts are active, **only the most recent context** takes priority for overlapping actions.

---

## Installation
1. Copy the input system script(s) into your Godot project.
2. Ensure that all input actions are registered in **Input Map** (found in **Project Settings > Input Map**).
3. Use the provided API to manage input contexts in your game.

---

## Usage

### 1. **Creating a Mapping Context**
A **mapping context** is a collection of input actions. Each action in the context should have the same name as an `InputEventAction` in the **Input Map**.

Example:
```gdscript
var movement_context = InputMappingContext.new()
movement_context.mappings = ["move_left", "move_right", "jump"]
```

### 2. **Activating a Context**
Use `push_mapping_context(context)` to activate a context. If multiple contexts are active, the most recently added one takes priority for conflicting actions.

Example:
```gdscript
input_system.push_mapping_context(movement_context)
```

### 3. **Removing a Context**
Use `remove_mapping_context(context)` to deactivate a context. This restores priority to the previous context if it exists.

Example:
```gdscript
input_system.remove_mapping_context(movement_context)
```

### 4. **Handling Input Conflicts**
If multiple contexts are active and **a key is bound to multiple actions**, only the most recent context’s action will be triggered. This ensures that higher-priority actions are handled first.

Example scenario:
- `Context A` and `Context B` both have an action bound to `Space`.
- If `Context B` was activated **after** `Context A`, then pressing `Space` will trigger only `Context B`'s action.

---

## Binding Actions to Events
You can connect to any event from the `PlayerController` class by using the `bind_action` method. You can bind to any of these events:

### **Event Types That Objects Can Connect To**
```gdscript
enum TriggerState {
    TRIGGERED, # Condition was met
    STARTED, # On key down no matter what
    COMPLETED, # Mostly on key up
    CANCELLED, # Condition wasn't met
    ONGOING # Event is still going but condition to trigger was not met
}
```

### **Modifying Input Actions to Trigger Different States**
Input actions can be modified to trigger different states via:
```gdscript
enum Trigger {
    DOWN,
    HOLD,
    HOLD_AND_RELEASE,
    PRESSED,
    PULSE,
    RELEASED,
    TAP
}
```

---

## Example
```gdscript
# Create and configure contexts
var gameplay_context = InputMappingContext.new()
gameplay_context.mappings = ["move", "jump", "attack"]

var menu_context = InputMappingContext.new()
menu_context.mappings = ["confirm", "cancel"]

# Activate gameplay context
input_system.push_mapping_context(gameplay_context)

# Later, activate menu context (this takes priority over gameplay)
input_system.push_mapping_context(menu_context)

# Remove menu context to restore gameplay controls
input_system.remove_mapping_context(menu_context)
```

---

## License
[MIT License](LICENSE)

---

## Contributing
Feel free to submit issues or pull requests to improve the system!

---

## Contact
If you have any questions or suggestions, open an issue on GitHub!

