#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetKeyDelay -1, 0
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

global MAX_STICK_COORDINATE = 32767
global DigitalThumbStick_Duty_Cycle := 2.5 ; ms
global DigitalThumbStick_OnTimeTiers := [0, 0.5, 1, 1.5, 2, 2.5] ; on-time in ms
global DigitalThumbStick_msThroughCycle := { "sThumbLX": 0, "sThumbLY": 0, "sThumbRX": 0, "sThumbRY": 0 }

/*
    Function: DigitalThumbStick_AnalogToDigital
    
    Presses key on keyboard if analog stick position is beyond the deadzone

    Parameters:
        [in] sThumbName: Either "sThumbLX", "sThumbLY", "sThumbRX", or "sThumbRY"
		[in] deadzone: Deadzone of thumb stick

*/
DigitalThumbStick_AnalogToDigital(sThumbName, deadzone) {
	global
	if (State[sThumbName] > deadzone) && (OldState[sThumbName] <= deadzone) {
		sThumb := ControllerBinds[sThumbName "+"]
		Send, {%sThumb% Down}
	} else if (State[sThumbName] <= deadzone) && (OldState[sThumbName] > deadzone) {
		sThumb := ControllerBinds[sThumbName "+"]
		Send, {%sThumb% Up}
	}

	if (State[sThumbName] < (-1) * deadzone) && (OldState[sThumbName] >= (-1) * deadzone) {
		sThumb := ControllerBinds[sThumbName "-"]
		Send, {%sThumb% Down}
	} else if (State[sThumbName] >= (-1) * deadzone) && (OldState[sThumbName] < (-1) * deadzone) {
		sThumb := ControllerBinds[sThumbName "-"]
		Send, {%sThumb% Up}
	}
}

/*
    Function: DigitalThumbStick_EstimateAnalogWithKeyPresses
    
    Maps the analog stick position onto a series of digital key presses

    Parameters:
        [in] sThumbName: Either "sThumbLX", "sThumbLY", "sThumbRX", or "sThumbRY"
		[in] deadzone: Deadzone of thumb stick

*/
DigitalThumbStick_EstimateAnalogWithKeyPresses(sThumbName, deadzone) {
	global
	OldThumbCoordinates := OldState[sThumbName]
	ThumbCoordinates := State[sThumbName]
	
	sThumbKey := ""
	sThumbKey_Air := ""
	if (ThumbCoordinates > 0) {
		sThumbKey := ControllerBinds[sThumbName "+"]
		sThumbKey_Air := ControllerBinds[sThumbName "_Air+"]
	} else {
		sThumbKey := ControllerBinds[sThumbName "-"]
		sThumbKey_Air := ControllerBinds[sThumbName "_Air-"]
	}

	_DigitalThumbStick_PreventOldStateStuck(sThumbName)

	if (Abs(ThumbCoordinates) > deadzone) {
		_DigitalThumbStick_AnalogToDigital(sThumbName, sThumbKey, sThumbKey_Air)

	} else if ((Abs(ThumbCoordinates) <= deadzone) && (Abs(OldThumbCoordinates) > deadzone)) {
		Send, {%sThumbKey% Up}
		Send, {%sThumbKey_Air% Up}
	}

	DigitalThumbStick_msThroughCycle[sThumbName] := DigitalThumbStick_msThroughCycle[sThumbName] + POLL_RATE
}

/*
    Function: _DigitalThumbStick_AnalogToDigital
    
	Converts the stick coordinates into a series of keystrokes

    Parameters:
        [in] sThumbName: Either "sThumbLX", "sThumbLY", "sThumbRX", or "sThumbRY"
        [in] sThumbKey: The keyboard key associated with the stick
        [in] sThumbKey_Air: The keyboard key associated with the stick while in the air

*/
_DigitalThumbStick_AnalogToDigital(sThumbName, sThumbKey, sThumbKey_Air) {
	global
	OldIntervalTier := Ceil(Abs(OldState[sThumbName]) / (MAX_STICK_COORDINATE / DigitalThumbStick_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
	IntervalTier := Ceil(Abs(State[sThumbName]) / (MAX_STICK_COORDINATE / DigitalThumbStick_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
	IntervalTierVal := DigitalThumbStick_OnTimeTiers[IntervalTier]

	if (OldIntervalTier == IntervalTier) {
		if (DigitalThumbStick_msThroughCycle[sThumbName] > DigitalThumbStick_Duty_Cycle - IntervalTierVal) {
			Send, {%sThumbKey% Down}
			Send, {%sThumbKey_Air% Down}
		} else {
			Send, {%sThumbKey% Up}
			Send, {%sThumbKey_Air% Up}
		}

		if (DigitalThumbStick_msThroughCycle[sThumbName] > DigitalThumbStick_Duty_Cycle) {
			DigitalThumbStick_msThroughCycle[sThumbName] := 0
		}
	} else {
		DigitalThumbStick_msThroughCycle[sThumbName] := 0
	}
}

/*
    Function: _DigitalThumbStick_PreventOldStateStuck
    
	Double checks to make sure previous key was actually unpressed when quickly switching stick directions 

    Parameters:
        [in] sThumbName: Either "sThumbLX", "sThumbLY", "sThumbRX", or "sThumbRY"

	Remarks:
		This function exists because I found that when I has the stick pushed to one side and then
		pushed it quickly the other, the car would continue going in the prior direction. This could be
		undone by movine this stick back to the prior direction and then slowly moving into the deadzone.
		This bug is caused by going through the deadzone before the "Up" command could be sent for the
		previous key and can jankily be solved by sneding the "Up" command for the revious key whenever
		the stick passes through 0.

*/
_DigitalThumbStick_PreventOldStateStuck(sThumbName) {
	global
	HaveSameSign := ((ThumbCoordinates < 0) == (OldThumbCoordinates < 0))
	if (!HaveSameSign) {
		sThumbOppositeKey := ""
		sThumbOppositeKey_Air := ""
		if (ThumbCoordinates < 0) {
			sThumbOppositeKey := ControllerBinds[sThumbName "+"]
			sThumbOppositeKey_Air := ControllerBinds[sThumbName "_Air+"]
		} else {
			sThumbOppositeKey := ControllerBinds[sThumbName "-"]
			sThumbOppositeKey_Air := ControllerBinds[sThumbName "_Air-"]
		}

		Send, {%sThumbOppositeKey% Up}
		Send, {%sThumbOppositeKey_Air% Up}
	}
}