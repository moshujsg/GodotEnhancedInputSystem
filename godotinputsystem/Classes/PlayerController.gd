class_name PlayerController extends Node

signal on_action_triggered(action : InputAction)

@export var preset_mapping_contexts : Array[InputMappingContext]

var mapping_contexts : Array[InputMappingContext]
var ongoing_actions : Array[InputAction] = []


func _ready() -> void:
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
	elif Input.is_action_just_released(action.name):
		action.next_state = InputAction.State.RELEASE

func _process(delta: float) -> void:
	for action in ongoing_actions:
		action.update()
		if not action.is_being_processed():
			call_deferred("clear_ongoing_action", action)

func clear_ongoing_action(action: InputAction) -> void:
	ongoing_actions.erase(action)

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
