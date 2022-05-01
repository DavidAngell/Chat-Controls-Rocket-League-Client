#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir% 
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
	}
return

#x::ExitApp ; Win+X