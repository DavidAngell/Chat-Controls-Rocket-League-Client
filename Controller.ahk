#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode ToolTip
#Persistent
#SingleInstance Force

#Include <XINPUT>
XInput_Init()
#Include <KeyBinds>

global POLL_RATE := 0.5 ; ms
#Include <DigitalThumbStick>
#Include <DigitalTrigger>

SetTimer WatchController, %POLL_RATE%

WatchController:
	; StartTime := A_TickCount
	State := XInput_GetState(0) ; presumably one would only use gamepad 0 for this but it can be changed
	if State {
		if !OldState {
			OldState := State
		}

		; All the digital buttons
		for GamepadButton, KeyboardKey in ControllerBinds["xiBtns"] {
			if ((OldState.wButtons&GamepadButton) && !(State.wButtons&GamepadButton)) {
				Send {%KeyboardKey% Up}
			} else if ((State.wButtons&GamepadButton) && !(OldState.wButtons&GamepadButton)) {
				Send {%KeyboardKey% Down}
			}
		}

		; Left Trigger
		DigitalTrigger_MapTrigger("bLeftTrigger", XINPUT_GAMEPAD_TRIGGER_THRESHOLD, InGameBinds["Air Roll"])

		; Right Trigger
		DigitalTrigger_MapTrigger("bRightTrigger", XINPUT_GAMEPAD_TRIGGER_THRESHOLD)

		; Left Stick
		DigitalThumbStick_EstimateAnalogWithKeyPresses("sThumbLX", XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)
		DigitalThumbStick_EstimateAnalogWithKeyPresses("sThumbLY", XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)

		; Right Stick
		DigitalThumbStick_AnalogToDigital("sThumbRX", XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE)
		DigitalThumbStick_AnalogToDigital("sThumbRY", XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE)

		OldState := State
		; ExecutionTime := A_TickCount - StartTime
		; OldIntervalTier := Ceil(Abs(OldState[sThumbName]) / (32767 / DigitalThumbStick_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
		; IntervalTier := Ceil(Abs(State[sThumbName]) / (32767 / DigitalThumbStick_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
		; IntervalTierVal := DigitalThumbStick_OnTimeTiers[IntervalTier]
		; NewIntervalTierVal := onTimes[NewIntervalTier]
		; yeet := State.bLeftTrigger
		; ToolTip % " Old Left Stick Tier X: " OldIntervalTierVal "`n New Left Stick Tier Y: " NewIntervalTierVal "`n yeet: " "`n Execution Time: " ExecutionTime "ms", 200, 500
	}
return

#x::ExitApp ; Win+X