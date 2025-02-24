class_name MyPlayerController extends PlayerController

@export var jump : InputAction
@export var move_left : InputAction
@export var move_up : InputAction
@export var move_down : InputAction
@export var move_right : InputAction
@export var crouch : InputAction
@export var weapon_one : InputAction
@export var weapon_two : InputAction
@export var crouch_overwrite : InputAction
@export var extra_context : InputMappingContext

func _ready() -> void:
	super._ready()
	bind_action(jump, InputAction.TriggerState.TRIGGERED, on_action.bind(jump))
	bind_action(move_left, InputAction.TriggerState.TRIGGERED, on_action.bind(move_left))
	bind_action(move_up, InputAction.TriggerState.TRIGGERED, on_action.bind(move_up))
	bind_action(move_down, InputAction.TriggerState.TRIGGERED, on_action.bind(move_down))
	bind_action(move_right, InputAction.TriggerState.TRIGGERED, on_action.bind(move_right))
	bind_action(crouch, InputAction.TriggerState.TRIGGERED, on_action.bind(crouch))
	bind_action(weapon_one, InputAction.TriggerState.TRIGGERED, on_action.bind(weapon_one))
	bind_action(weapon_two, InputAction.TriggerState.TRIGGERED, on_action.bind(weapon_two))
	bind_action(crouch_overwrite, InputAction.TriggerState.TRIGGERED, on_action.bind(crouch_overwrite))

func on_action(action: InputAction):
	print(action.name)
	pass


func _on_add_context_button_up() -> void:
	var start_time := Time.get_ticks_usec()
	push_mapping_context(extra_context)
	var end_time := Time.get_ticks_usec()
	var duration := end_time - start_time
	print("Extra context pushed Execution time: ", duration, " µs (", duration / 1000.0, " ms)")
	start_time = Time.get_ticks_usec()


func _on_remove_context_button_up() -> void:
	var start_time := Time.get_ticks_usec()
	remove_mapping_context(extra_context)
	var end_time := Time.get_ticks_usec()
	var duration := end_time - start_time
	print("Extra context removed Execution time: ", duration, " µs (", duration / 1000.0, " ms)")
	start_time = Time.get_ticks_usec()
