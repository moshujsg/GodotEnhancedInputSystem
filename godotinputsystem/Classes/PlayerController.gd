class_name PlayerController extends Node

signal on_action_triggered(action : InputAction)

@export var preset_mapping_contexts : Array[InputMappingContext]

@export var mapping_contexts : Array[InputMappingContext]

@export var jump : InputAction
@export var move_left : InputAction
@export var move_up : InputAction
@export var move_down : InputAction
@export var move_right : InputAction
@export var crouch : InputAction
@export var weapon_one : InputAction
@export var weapon_two : InputAction
@export var crouch_overwrite : InputAction

var ongoing_actions : Array[InputAction] = []


func _ready() -> void:
	bind_action(jump, InputAction.TriggerState.TRIGGERED, on_action.bind(jump))
	bind_action(move_left, InputAction.TriggerState.TRIGGERED, on_action.bind(move_left))
	bind_action(move_up, InputAction.TriggerState.TRIGGERED, on_action.bind(move_up))
	bind_action(move_down, InputAction.TriggerState.TRIGGERED, on_action.bind(move_down))
	bind_action(move_right, InputAction.TriggerState.TRIGGERED, on_action.bind(move_right))
	bind_action(crouch, InputAction.TriggerState.TRIGGERED, on_action.bind(crouch))
	bind_action(weapon_one, InputAction.TriggerState.TRIGGERED, on_action.bind(weapon_one))
	bind_action(weapon_two, InputAction.TriggerState.TRIGGERED, on_action.bind(weapon_two))
	bind_action(crouch_overwrite, InputAction.TriggerState.TRIGGERED, on_action.bind(crouch_overwrite))
	for context in preset_mapping_contexts:
		push_mapping_context(context)
func bind_action(p_action : InputAction, p_event: InputAction.TriggerState,  p_function: Callable) -> void:
	p_action.bind_action(p_event, p_function)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pass
	else:
		if event.is_echo():
			return
		var flag := false
		for mapping_context in mapping_contexts:
			for action in mapping_context.mappings:
				if not event.is_action(action.name):
					continue
				handle_event(action)
				return

func handle_event(action: InputAction) -> void:
	#if action.overwritten:
		#return
	if Input.is_action_just_pressed(action.name):
		ongoing_actions.append(action)
		action.next_state = InputAction.State.PRESS
		action.on_event_fired.connect(on_event_fired)
	elif Input.is_action_just_released(action.name):
		action.next_state = InputAction.State.RELEASE

func on_event_fired(trigger: InputAction.TriggerState) -> void:
	#match trigger:
		#InputAction.TriggerState.TRIGGERED:
			#print("TRIGGERED")
		#InputAction.TriggerState.STARTED:
			#print("STARTED")
		#InputAction.TriggerState.COMPLETED:
			#print("COMPLETED")
		#InputAction.TriggerState.CANCELLED:
			#print("CANCELLED")
		#InputAction.TriggerState.ONGOING:
			#print("ONGOING")
	pass

func _process(delta: float) -> void:
	for action in ongoing_actions:
		action.update()
		if not action.is_being_processed():
			call_deferred("clear_ongoing_action", action)
			action.on_event_fired.disconnect(on_event_fired)

func clear_ongoing_action(action: InputAction) -> void:
	ongoing_actions.erase(action)

func on_action(action: InputAction):
	print(action.name)
	pass

func push_mapping_context(p_mapping_context: InputMappingContext) -> void:
	mapping_contexts.push_front(p_mapping_context)
	# Update stack_index for all contexts
	for i in range(mapping_contexts.size()):
		mapping_contexts[i].stack_index = i

func remove_mapping_context(p_mapping_context: InputMappingContext) -> void:
	var index := p_mapping_context.stack_index
	if not (index >= 0 and index < mapping_contexts.size()):
		return
	mapping_contexts.remove_at(index)
	
	# Update stack_index for remaining contexts
	for i in range(index, mapping_contexts.size()):
		mapping_contexts[i].stack_index -= 1

func _on_button_button_up() -> void:
	var start_time := Time.get_ticks_usec()
	push_mapping_context(preset_mapping_contexts.pick_random())
	var end_time := Time.get_ticks_usec()
	var duration := end_time - start_time
	print("100 loop Execution time: ", duration, " µs (", duration / 1000.0, " ms)")
	start_time = Time.get_ticks_usec()
