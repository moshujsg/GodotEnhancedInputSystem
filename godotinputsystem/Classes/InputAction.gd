class_name InputAction extends Resource

# This is the event types that objects can connect to
enum TriggerState {
	TRIGGERED, # Condition was met
	STARTED, # On key down no matter what
	COMPLETED, # Mostly on key up
	CANCELLED, # Condition wasn't met
	ONGOING # Event is still going but condition to trigger was not met
}

# This is an internal state that determines  
enum State {
	PRESS,
	ONGOING,
	SUCCEED,
	RELEASE,
	FAILED,
	NONE
}

# This state determines the condition to fire triggered
enum Trigger {
	DOWN,
	HOLD,
	HOLD_AND_RELEASE, # Not implemented
	PRESSED,
	PULSE, # Not implemented
	RELEASED,
	TAP
}	

signal on_button_state_reset(action: InputAction)
signal on_event_fired(trigger_state : TriggerState)

@export var name : String
@export var description : String

@export var trigger : Trigger = Trigger.DOWN
var met_trigger_condition := false

@export var hold_threshold_ms := 300
@export var tap_threshold_ms := 150

@export var one_shot : bool = false
var one_shot_triggered := false

var current_state : State = State.NONE
var next_state : State = State.NONE

var press_time : int

var state_trigger_map : Dictionary = {
	Trigger.DOWN: {
		State.PRESS: [TriggerState.STARTED, TriggerState.TRIGGERED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerState.COMPLETED],
		State.FAILED: [],
		State.NONE: []
	},
	Trigger.HOLD: {
		State.PRESS: [TriggerState.STARTED],
		State.ONGOING: [TriggerState.ONGOING],
		State.SUCCEED: [TriggerState.TRIGGERED], 
		State.RELEASE: [TriggerState.COMPLETED],  
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: [] 
	},
	Trigger.HOLD_AND_RELEASE: {
		State.PRESS: [TriggerState.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerState.COMPLETED],
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []
	},
	Trigger.PRESSED: {
		State.PRESS: [TriggerState.STARTED],
		State.ONGOING: [TriggerState.TRIGGERED],
		State.SUCCEED: [TriggerState.TRIGGERED],
		State.RELEASE: [TriggerState.COMPLETED],
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: [] 
	},
	Trigger.PULSE: {
		State.PRESS: [TriggerState.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerState.COMPLETED],
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []
	},
	Trigger.RELEASED: {
		State.PRESS: [TriggerState.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerState.TRIGGERED, TriggerState.COMPLETED],
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []
	},
	Trigger.TAP: {
		State.PRESS: [TriggerState.STARTED],
		State.ONGOING: [],
		State.SUCCEED: [],
		State.RELEASE: [TriggerState.TRIGGERED, TriggerState.COMPLETED],
		State.FAILED: [TriggerState.CANCELLED],
		State.NONE: []
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

# Gets called every frame from playercontroller if it's active
# Can be made for each input action to keep track of itself instead.
func update():
	var delta_time := Time.get_ticks_msec() - press_time
	if trigger == Trigger.HOLD and delta_time > hold_threshold_ms:
		met_trigger_condition = true
	if trigger == Trigger.TAP and delta_time > tap_threshold_ms:
		met_trigger_condition = false

	current_state = next_state
	

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
