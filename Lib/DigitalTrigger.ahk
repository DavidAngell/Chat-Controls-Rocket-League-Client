global TRIGGER_MAX = 256
global DigitalTrigger_Duty_Cycle := 20 ; ms
global DigitalTrigger_OnTimeTiers := [0, 0.5, 1.0, 1.5, 2] ; on-time in ms
global DigitalTrigger_msThroughCycle := { "bLeftTrigger": 0, "bRightTrigger": 0 }

/*
    Function: DigitalTrigger_MapTrigger
    
    Maps the analog trigger position onto a series of digital key presses

    Parameters:
        [in] TriggerName: Either "bLeftTrigger", "bRightTrigger"
		[in] threshold: The trigger threshold that must be met before the input is considered
		[in] AirRollKey: Keyboard key for air rolling. Only mapped for left trigger

*/
DigitalTrigger_MapTrigger(TriggerName, threshold, AirRollKey = "") {
	global
	TriggerKey := ControllerBinds[TriggerName]
	if (State[TriggerName] > threshold) { 
		_DigitalTrigger_AnalogToDigital(TriggerName, TriggerKey)
		if (AirRollKey != "") {
			Send, {%AirRollKey% Down}
		}
	} else if (State[TriggerName] <= threshold) && (OldState[TriggerName] > threshold) {
		Send, {%TriggerKey% Up}
		if (AirRollKey != "") {
			Send, {%AirRollKey% Up}
		}
	}

	DigitalTrigger_msThroughCycle[TriggerName] := DigitalTrigger_msThroughCycle[TriggerName] + POLL_RATE
}

/*
    Function: _DigitalTrigger_AnalogToDigital
    
	Converts the stick trigger value into a series of keystrokes

    Parameters:
        [in] TriggerName: Either "bLeftTrigger", "bRightTrigger"
        [in] TriggerKey: The keyboard key associated with the trigger

*/
_DigitalTrigger_AnalogToDigital(TriggerName, TriggerKey) {
	global
	OldIntervalTier := Ceil(OldState[TriggerName] / (TRIGGER_MAX / DigitalTrigger_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
	IntervalTier := Ceil(State[TriggerName] / (TRIGGER_MAX / DigitalTrigger_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
	IntervalTierVal := DigitalTrigger_OnTimeTiers[IntervalTier]

	if (OldIntervalTier == IntervalTier) {
		if (DigitalTrigger_msThroughCycle[TriggerName] > DigitalTrigger_Duty_Cycle - IntervalTierVal) {
			; ToolTip, % "Down", 600, 600
			Send, {%TriggerKey% Down}
		} else {
			; ToolTip, % "Up", 600, 600
			Send, {%TriggerKey% Up}
		}

		if (DigitalTrigger_msThroughCycle[TriggerName] > DigitalTrigger_Duty_Cycle) {
			DigitalTrigger_msThroughCycle[TriggerName] := 0
		}

	} else {
		DigitalTrigger_msThroughCycle[TriggerName] := 0
	}
}
