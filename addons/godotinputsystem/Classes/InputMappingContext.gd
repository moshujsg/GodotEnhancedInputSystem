class_name InputMappingContext extends Resource

@export var mappings : Array[InputAction]
@export var mappings_dict : Dictionary

func parse_mappings():
	if not mappings_dict.is_empty():
		return
	for map in mappings:
		for event in map.events:
			if event in mappings_dict:
				push_error("Repeated events in the same InputMappingContext")
			mappings_dict[event.keycode] = map.action

func has_key_event(p_event: InputEvent) -> bool:
	if mappings_dict.has(p_event.keycode):
		return true
	return false

func get_action(p_event: InputEvent) -> InputAction:
	return mappings_dict.get(p_event.keycode)
