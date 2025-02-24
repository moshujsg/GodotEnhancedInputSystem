class_name InputAction extends Resource

enum TriggerState {
	TRIGGERED,
	STARTED,
	COMPLETED,
	CANCELLED,
	ONGOING
}

enum State {
	PRESS,
	ONGOING,
	SUCCEED,
	RELEASE,
	FAILED,
	NONE
}

enum Trigger {
	DOWN,
	HOLD,
	HOLD_AND_RELEASE,
	PRESSED,
	PULSE,
	RELEASED,
	TAP
}

signal on_button_state_reset(action: InputAction)
signal on_event_fired(trigger_state : TriggerState)

@export var name : String
@export var description : String
@export var trigger : Trigger = Trigger.DOWN
@export var one_shot : bool = false
@export var hold_threshold_ms := 300
@export var tap_threshold_ms := 150
var overwritten := false
var one_shot_triggered := false
var met_trigger_condition := false
var current_state : State = State.NONE
var next_state : State = State.NONE
var press_time : int
var state_trigger_map : Dictionary = {
	Trigger.DOWN: {
		State.PRESS: [TriggerState.STARTED, TriggerState.TRIGGERED],  # Fires when the button is first pressed.
		State.ONGOING: [],  # No ongoing action since DOWN is a one-time event.
		State.SUCCEED: [],     # No echo for DOWN.
		State.RELEASE: [TriggerState.COMPLETED],  # Completes when released.
		State.FAILED: [],
		State.NONE: []  # No action for NONE.
	},
	Trigger.HOLD: {
		State.PRESS: [TriggerState.STARTED],   # Fires when the button is pressed.
		State.ONGOING: [TriggerState.ONGOING], # Continues as long as the button is held down.
		State.SUCCEED: [TriggerState.TRIGGERED],  # Echo triggered while holding.
		State.RELEASE: [TriggerState.COMPLETED],  # Completes when the button is released.
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []  # No action for NONE.
	},
	Trigger.HOLD_AND_RELEASE: {
		State.PRESS: [TriggerState.STARTED],  # Fires when the button is first pressed.
		State.ONGOING: [],   # No ongoing action while holding AND releasing.
		State.SUCCEED: [],      # No echo while holding and releasing.
		State.RELEASE: [TriggerState.COMPLETED],  # Completes when the button is released.
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []  # No action for NONE.
	},
	Trigger.PRESSED: {
		State.PRESS: [TriggerState.STARTED],  # Fires when the button is first pressed.
		State.ONGOING: [TriggerState.TRIGGERED],   # No ongoing action for PRESSED.
		State.SUCCEED: [TriggerState.TRIGGERED],      # No echo for PRESSED.
		State.RELEASE: [TriggerState.COMPLETED],  # Completes when released.
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []  # No action for NONE.
	},
	Trigger.PULSE: {
		State.PRESS: [TriggerState.STARTED],  # Fires when the button is first pressed.
		State.ONGOING: [],   # No ongoing action for PULSE.
		State.SUCCEED: [],      # No echo for PULSE.
		State.RELEASE: [TriggerState.COMPLETED],  # Completes when released.
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []  # No action for NONE.
	},
	Trigger.RELEASED: {
		State.PRESS: [TriggerState.STARTED],  # Fires when the button is first pressed.
		State.ONGOING: [],   # No ongoing action for RELEASED.
		State.SUCCEED: [],      # No echo for RELEASED.
		State.RELEASE: [TriggerState.TRIGGERED, TriggerState.COMPLETED],  # Completes when released.
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []  # No action for NONE.
	},
	Trigger.TAP: {
		State.PRESS: [TriggerState.STARTED],  # Fires when the button is first pressed.
		State.ONGOING: [],   # No ongoing action for TAP.
		State.SUCCEED: [],      # No echo for TAP.
		State.RELEASE: [TriggerState.TRIGGERED, TriggerState.COMPLETED],  # Completes when released.
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []  # No action for NONE.
	}
}
var met_trigger_condition_initial_state : Dictionary[Trigger, bool] = {
	Trigger.DOWN: true,
	Trigger.HOLD: false,
	Trigger.HOLD_AND_RELEASE: false,
	Trigger.PRESSED: true,
	Trigger.PULSE: false,
	Trigger.RELEASED: true,
	Trigger.TAP: true
}

var bound_actions : Dictionary[TriggerState, Callable] = {
	TriggerState.TRIGGERED: Callable(),
	TriggerState.STARTED: Callable(),
	TriggerState.COMPLETED: Callable(),
	TriggerState.CANCELLED: Callable(),
	TriggerState.ONGOING: Callable()
}

func bind_action(p_event: InputAction.TriggerState,  p_function: Callable):
	bound_actions[p_event] = p_function

func call_bind(p_event: TriggerState):
	var target_callable := bound_actions[p_event]
	if target_callable.is_null():
		return
	target_callable.call()

func update():
	var delta_time := Time.get_ticks_msec() - press_time
	if trigger == Trigger.HOLD and delta_time > hold_threshold_ms:
		met_trigger_condition = true
	if trigger == Trigger.TAP and delta_time > tap_threshold_ms:
		met_trigger_condition = false

	current_state = next_state
	
	# 
	if current_state == State.PRESS:
		next_state = State.ONGOING
		press_time = Time.get_ticks_msec()
		met_trigger_condition = met_trigger_condition_initial_state[trigger]
	
	var events_to_fire : Array[TriggerState]
	var state_to_check : State = current_state

	if current_state == State.ONGOING and met_trigger_condition:
		state_to_check = State.SUCCEED

	elif current_state == State.RELEASE and not met_trigger_condition:
		state_to_check = State.FAILED

	events_to_fire.assign(state_trigger_map[trigger][state_to_check])
	if state_to_check == State.SUCCEED:
		if one_shot:
			if one_shot_triggered:
				events_to_fire = []
			else:
				one_shot_triggered = true
		
	if not events_to_fire.is_empty():
		for event in events_to_fire:
			call_bind(event)
			on_event_fired.emit(event)

	if current_state == State.RELEASE:
		reset()

func is_being_processed() -> bool:
	if current_state != State.NONE:
		return true
	return false

func reset() -> void:
	current_state = State.NONE
	next_state = State.NONE
	one_shot_triggered = false
