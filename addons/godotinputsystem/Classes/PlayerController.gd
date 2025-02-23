class_name PlayerController extends Node

signal on_action_triggered(action : InputAction)

@export var mapping_context : InputMappingContext:
	set(value):
		mapping_context = value
		#on_mapping_context_changed(mapping_context)
@export var jump : InputAction

var ongoing_actions : Array[InputAction] = []

func _ready() -> void:
	#mapping_context.parse_mappings()
	bind_action(jump, InputAction.TriggerState.COMPLETED, on_jump)

func set_mapping_context(p_context : InputMappingContext):
	mapping_context = p_context

func get_mapping_context() -> InputMappingContext:
	return mapping_context

func bind_action(p_action : InputAction, p_event: InputAction.TriggerState,  p_function: Callable) -> void:
	p_action.bind_action(p_event, p_function)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pass
	else:
		for action in mapping_context.mappings:
			if not event.is_action(action.name):
				continue
			handle_event(event, action)

func handle_event(event: InputEvent, action: InputAction) -> void:
	if Input.is_action_just_pressed(action.name):
		ongoing_actions.append(action)
		action.next_state = InputAction.State.PRESS
		action.on_event_fired.connect(on_event_fired)
		
	elif Input.is_action_just_released(action.name):
		action.next_state = InputAction.State.RELEASE


func on_event_fired(trigger: InputAction.TriggerState) -> void:
	match trigger:
		InputAction.TriggerState.TRIGGERED:
			print("TRIGGERED")
		InputAction.TriggerState.STARTED:
			print("STARTED")
		InputAction.TriggerState.COMPLETED:
			print("COMPLETED")
		InputAction.TriggerState.CANCELLED:
			print("CANCELLED")
		InputAction.TriggerState.ONGOING:
			print("ONGOING")

func _process(delta: float) -> void:
	for action in ongoing_actions:
		action.update()
		if not action.is_being_processed():
			call_deferred("clear_ongoing_action", action)
			action.on_event_fired.disconnect(on_event_fired)
			

func clear_ongoing_action(action: InputAction) -> void:
	ongoing_actions.erase(action)

func on_jump():
	print("jumped")
