# Godot Input System

A flexible input handling system for Godot that allows managing multiple input contexts dynamically. This system lets you group input actions into contexts and control which context is active at any given time.

## Features
- Organize input actions into separate **mapping contexts**.
- Dynamically activate and deactivate contexts using `push_mapping_context` and `remove_mapping_context`.
- Ensures that when multiple contexts are active, **only the most recent context** takes priority for overlapping actions.

---

## Installation
1. Copy the input system script(s) into your Godot project.
---

## Usage  

### 1. **Creating an Input Action**  
1. Create a new resource → **InputAction**.  
2. In the resource editor, assign it a name (e.g., `"Dash"`).  
3. Navigate to **Project Settings → Input Map** and create an action with the same name (`"Dash"`).  
4. Assign input events to the action (e.g., `Shift`).  

### 2. **Creating a Mapping Context**  
A **Mapping Context** is a resource that defines a collection of input actions. Each action in the context must match the name of an `InputEventAction` in the **Input Map** (found in **Project Settings**).  

1. Create a new resource → **InputMappingContext**.  
2. Under **Actions**, add `"Dash.tres"` and any additional **InputActions** needed.  

### 3. **Creating a PlayerController**  
The `PlayerController` class manages **Mapping Contexts** and their associated input actions.  

1. Create a new script and extend **PlayerController**.  
2. Define `@export` variables for each **InputAction**.  
3. Call `super._ready()` within `_ready()`.  
4. Use `bind_action` to associate each action with a method.  
5. Specify a `TriggerPhase` when binding (e.g., `"InputAction.TriggerPhase.TRIGGERED"`).  

### 4. **Activating and Removing a Mapping Context**  

- **Activate a context:** `push_mapping_context(InputMappingContext)`  
- **Remove a context:** `remove_mapping_context(InputMappingContext)`
  
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
enum TriggerPhase {
    TRIGGERED, # Condition was met
    STARTED, # On key down no matter what
    COMPLETED, # After event was completed
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
## Example
A "hold" trigger follows these phases:
```
TriggerPhase.STARTED – Fired when the key is pressed down.
TriggerPhase.ONGOING – Active until the hold threshold is reached (300 ms by default).
TriggerPhase.TRIGGERED – Fires once the hold threshold is exceeded.
TriggerPhase.COMPLETED – Fires on release if the trigger was activated.
TriggerPhase.CANCELLED – Fires on release if the trigger was not activated.
```
---

## License
[MIT License]([LICENSE](https://mit-license.org/))

---

## Contributing
Feel free to submit issues or pull requests to improve the system!

---

## Contact
If you have any questions or suggestions, open an issue on GitHub!

