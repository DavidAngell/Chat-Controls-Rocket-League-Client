# Chat-Controls-Rocket-League-Client
The local client (game-side) for a program that we have been working on for a livestream chat to control Rocket League. Server script coming soon...

# Overview of Code Explanation

The local client is split up into two distinct sections: the Controller Handler (Controller.ahk) converts the inputs from an Xbox controller into keys on a keyboard; the Command Runner (RocketLeague.ahk) watchers for commands from the voting server, then interrupts keys or presses keys accordingly.

The Command Runner script starts the Controller Watcher script. Then, these two processes run parallel to one another:

![Local Client Overview.png](https://github.com/DavidAngell/Chat-Controls-Rocket-League-Client/blob/565294ebcd9077b6c5a16b737988267298aac9b9/ReadMeImages/Local_Client_Overview.png)

# Xinput.dll and Global Variables

These are the variables and functions used by other scripts to get the raw controller inputs and write them to in-game key binds.

## Xinput.dll with AutoHotkey

For context, xinput.dll is what Windows uses to understand Xbox controller inputs. because I am quite lazy, and my knowledge of AutoHotkey is lackluster at best, I have chosen to use a [script created by Lexikos on the AutoHotkey forums](https://www.autohotkey.com/boards/viewtopic.php?t=29659). There are two important functions that I used from it:

1. XInput_Init which sets all of the global variables for Xinput
    
    ```ahk
    ;  XInput by Lexikos
    ;  Requires AutoHotkey 1.1+.
    
    ;======== CONSTANTS DEFINED IN XINPUT.H ========
    
    ; Device types available in XINPUT_CAPABILITIES
    XINPUT_DEVTYPE_GAMEPAD          := 0x01
    
    ; Device subtypes available in XINPUT_CAPABILITIES
    XINPUT_DEVSUBTYPE_GAMEPAD       := 0x01
    
    ; Flags for XINPUT_CAPABILITIES
    XINPUT_CAPS_VOICE_SUPPORTED     := 0x0004
    
    ; Constants for gamepad buttons
    XINPUT_GAMEPAD_DPAD_UP          := 0x0001
    XINPUT_GAMEPAD_DPAD_DOWN        := 0x0002
    XINPUT_GAMEPAD_DPAD_LEFT        := 0x0004
    XINPUT_GAMEPAD_DPAD_RIGHT       := 0x0008
    XINPUT_GAMEPAD_START            := 0x0010
    XINPUT_GAMEPAD_BACK             := 0x0020
    XINPUT_GAMEPAD_LEFT_THUMB       := 0x0040
    XINPUT_GAMEPAD_RIGHT_THUMB      := 0x0080
    XINPUT_GAMEPAD_LEFT_SHOULDER    := 0x0100
    XINPUT_GAMEPAD_RIGHT_SHOULDER   := 0x0200
    XINPUT_GAMEPAD_GUIDE            := 0x0400
    XINPUT_GAMEPAD_A                := 0x1000
    XINPUT_GAMEPAD_B                := 0x2000
    XINPUT_GAMEPAD_X                := 0x4000
    XINPUT_GAMEPAD_Y                := 0x8000
    
    ; Gamepad thresholds
    XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  := 7849
    XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE := 8689
    XINPUT_GAMEPAD_TRIGGER_THRESHOLD    := 30
    
    ; Flags to pass to XInputGetCapabilities
    XINPUT_FLAG_GAMEPAD             := 0x00000001
    ```
    
2. XInput_GetState which gets the current state of the controller
    
    ```ahk
    ;  XInput by Lexikos
    ;  Requires AutoHotkey 1.1+.
    
    XInput_GetState(UserIndex)
    {
        global _XInput_GetState
        
        VarSetCapacity(xiState,16)
    
        if ErrorLevel := DllCall(_XInput_GetState ,"uint",UserIndex ,"uint",&xiState)
            return 0
        
        return {
        (Join,
            dwPacketNumber: NumGet(xiState,  0, "UInt")
            wButtons:       NumGet(xiState,  4, "UShort")
            bLeftTrigger:   NumGet(xiState,  6, "UChar")
            bRightTrigger:  NumGet(xiState,  7, "UChar")
            sThumbLX:       NumGet(xiState,  8, "Short")
            sThumbLY:       NumGet(xiState, 10, "Short")
            sThumbRX:       NumGet(xiState, 12, "Short")
            sThumbRY:       NumGet(xiState, 14, "Short")
        )}
    }
    ```
    

## Key Binds

There are two types of “Key Binds” in the client which, when put together, map a controller input onto a keyboard input for the game:

1. The binds which map an in-game action onto a keyboard key
    
    ```ahk
    global InGameBinds := {"Drive Forward" : "W"
    	, "Drive Backwards" : "S"
    	, "Steer Right" : "D" 
    	, "Steer Left" : "A" 
    	, "Jump" : "H" 
    	, "Boost" : "G" 
    	, "Powerslide" : "LShift" 
    	, "Air Roll" : "O" ; this is the letter "O" not the number zero 
    	, "Focus On Ball" : "Space" 
    	, "Rear View" : "P"
    	, "Air Steer Right" : "L" 
    	, "Air Steer Left" : "J" 
    	, "Air Pitch Up" : "I" 
    	, "Air Pitch Down" : "K" 
    	, "Air Roll Right" : "E" 
    	, "Air Roll Left" : "Q" 
    	, "Skip Replay" : "____" ; I recomend just using the default controller input
    	, "Camera Swivel Up" : "8" 
    	, "Camera Swivel Down" : "9" 
    	, "Camera Swivel Right" : "7" 
    	, "Camera Swivel Left" : "6" 
    	, "Scoreboard" : "Tab" 
    	, "Skip Music Track" : "N" 
    	, "Play Again" : "Tab"
    	, "Select Music Playlists" : "N" 
    	, "Quick Chat_Information" : "1"
    	, "Quick Chat_Compliments" : "2"
    	, "Quick Chat_Reactions" : "3"
    	, "Quick Chat_Apologies" : "4"
    	, "Text Chat" : "T"
    	, "Team Text Chat" : "Y"
    	, "Party Text Chat" : "U" ; The next few things 
      this don't matter at all bc who actually spectates??? 
    	, "Use Item" : "R" 
    	, "Next Item" : "C" }
    ```
    
2. And the binds which map a Xbox controller button onto an in-game action
    
    ```ahk
    global ControllerBinds := { "bLeftTrigger" : InGameBinds["Drive Backwards"]
    	, "bRightTrigger" : InGameBinds["Drive Forward"]
    	, "sThumbLX+" : InGameBinds["Steer Right"]
    	, "sThumbLX-" : InGameBinds["Steer Left"]
    	, "sThumbLX_Air+" : InGameBinds["Air Steer Right"] ; binding when the car is in the air
    	, "sThumbLX_Air-" : InGameBinds["Air Steer Left"] ; binding when the car is in the air
    	, "sThumbLY+" : InGameBinds["Air Pitch Down"]
    	, "sThumbLY-" : InGameBinds["Air Pitch Up"]
    	, "sThumbRX+" : InGameBinds["Camera Swivel Right"]
    	, "sThumbRX-" : InGameBinds["Camera Swivel Left"]
    	, "sThumbRY+" : InGameBinds["Camera Swivel Up"]
    	, "sThumbRY-" : InGameBinds["Camera Swivel Down"]
    	, "xiBtns": { (XINPUT_GAMEPAD_A) : InGameBinds["Jump"]
    		, (XINPUT_GAMEPAD_B) : ""
    		, (XINPUT_GAMEPAD_X) : InGameBinds["Boost"]
    		, (XINPUT_GAMEPAD_Y) : InGameBinds["Focus On Ball"]
    		, (XINPUT_GAMEPAD_DPAD_UP) : InGameBinds["Quick Chat_Information"]
    		, (XINPUT_GAMEPAD_DPAD_DOWN) : InGameBinds["Quick Chat_Reactions"]
    		, (XINPUT_GAMEPAD_DPAD_LEFT) : InGameBinds["Quick Chat_Compliments"]
    		, (XINPUT_GAMEPAD_DPAD_RIGHT) : InGameBinds["Quick Chat_Apologies"]
    		, (XINPUT_GAMEPAD_START) : ""
    		, (XINPUT_GAMEPAD_BACK) : ""
    		, (XINPUT_GAMEPAD_LEFT_THUMB) : InGameBinds["Use Item"]
    		, (XINPUT_GAMEPAD_RIGHT_THUMB) : InGameBinds["Rear View"]
    		, (XINPUT_GAMEPAD_LEFT_SHOULDER) : InGameBinds["Next Item"]
    		, (XINPUT_GAMEPAD_RIGHT_SHOULDER) : InGameBinds["Powerslide"] } }
    ```
    

So, to use the script, one must make their in-game bind match InGameBinds, and if they want to switch around which buttons do what on the controller, they should change which InGameBind it is mapped onto instead of the keyboard key. For example if I wanted the “X” button on the controller to be Power Slide and the “B” button to be Boost, I would do the following:

```ahk
; before
, (XINPUT_GAMEPAD_B) : ""
, (XINPUT_GAMEPAD_X) : InGameBinds["Boost"]
...
, (XINPUT_GAMEPAD_RIGHT_SHOULDER) : InGameBinds["Powerslide"]

; after
, (XINPUT_GAMEPAD_B) : InGameBinds["Boost"]
, (XINPUT_GAMEPAD_X) : InGameBinds["Powerslide"]
...
, (XINPUT_GAMEPAD_RIGHT_SHOULDER) : ""
```

# Command Runner (RocketLeague.ahk)

The script starts by initializing Controller Watcher and the Voting Server Watcher...

```ahk
Run %ComSpec% /c "node VotingServerWatcher.js", %A_ScriptDir%/NetworkClient/, Hide
Run, "Controller.ahk"
```

## Voting Server Watcher

Because Auto Hotkey does not, to my knowledge at least, have an easy method for sending network requests, I opted to use a simple Node.js script for the task. Every second, the script checks what second of the current minute it currently is. Then, if it is the 2nd second of the minute, then it makes a GET request to the voting server asking what the current command it. When it receives said request, it writes the current command to janky_commands.txt 

```jsx
const request = require('request-promise');
const fs = require("fs");

SERVER_DOMAIN = "http://localhost:8000";

async function getCurrentCommand() {
	if (new Date().getSeconds() == 1) {
		const command = JSON.parse(await request.get(SERVER_DOMAIN + "/currentCommand"));
		if (!command.error) {
			fs.writeFile('janky_commands.txt', command.content, err => {
				if (err) console.error(err)
				else console.log("Current Command: " + command.content)
			})
		} else {
			console.error(command.errorContent);
		}
	}
}

setInterval(getCurrentCommand, 1000);
```

## Executing Commands

There exist various different commands that the livestream chat can preform, but these can be broadly split up into two different categories of commands:

1. Commands which require keystrokes...
    
    ```ahk
    PressKey(BindName, ms = 10000) {
    	key := InGameBinds[BindName]
    	Send, {%key% Down}
    	Sleep ms
    	Send, {%key% Up}
    }
    ```
    
2. Commands which prevent keystrokes...
    
    ```ahk
    DisableKey(BindName, ms = 10000) {
    	key := InGameBinds[BindName]
    	Hotkey, %key%, Disable_Return
    	Sleep, %ms%
    	Hotkey, %key%, Off
    
    	Disable_Return:
    	return
    }
    ```
    

So, we use a switch statement to parse commands, and each command falls into a simpler or more complicated version of something in this category. Every 100ms, the script checks for a command in janky_commands.txt, and if there is a new one, then it will run that command.

```ahk
#Include <KeyBinds>

OldCommand = ""
SetTimer, WatchCommandsFile, 100

WatchCommandsFile:
 	FileRead, Command, %A_ScriptDir%\NetworkClient\janky_commands.txt
 	RunCommand(Command)
return

RunCommand(Command) {
	if (Command != OldCommand) { ; there will be a bug if the same command is sent twice but i am lazy :)
		ToolTip % "Penis: " Command, 150, 400
		switch Command {
			case "Change_Camera": ChangeCamera()
			case "Disable_Air_Roll": DisableKey("Air Roll")
			case "Disable_Air_Steer_Right": DisableKey("Air Steer Right")
			case "Disable_Air_Steer_Left": DisableKey("Air Steer Left")
			case "Disable_Air_Pitch_Up": DisableKey("Air Pitch Up")
			case "Disable_Air_Pitch_Down": DisableKey("Air Pitch Down")
			case "Disable_Boost": DisableKey("Boost")
			case "Disable_Drive_Forward": DisableKey("Drive Forward")
			case "Disable_Drive_Backwards": DisableKey("Drive Backwards")
			case "Disable_Steer_Right": DisableKey("Steer Right")
			case "Disable_Steer_Left": DisableKey("Steer Left")
			case "Disable_Jump": DisableKey("Jump")
			case "Force_Boost": PressKey("Boost")
			case "Force_Drive_Forward": PressKey("Drive Forward")
			case "Force_Drive_Backwards": PressKey("Drive Backwards")
			case "Force_Steer_Right": PressKey("Steer Right")
			case "Force_Steer_Left": PressKey("Steer Left")
			case "Force_Constant_Jump": ConstantJump()
			case "Force_Rear_View": PressKey("Rear View", 10000)
			case "Quick_Chat_Random": SendQuickChat()
			case "Quick_Chat_Random_Information": SendQuickChat("Quick Chat_Information")
			case "Quick_Chat_Random_Compliments": SendQuickChat("Quick Chat_Compliments")
			case "Quick_Chat_Random_Reactions": SendQuickChat("Quick Chat_Reactions")
			case "Quick_Chat_Random_Apologies": SendQuickChat("Quick Chat_Apologies")
			case "Quick_Chat_WhatASave": SendQuickChat("Quick Chat_Compliments", 4)
			case "Quick_Chat_NiceOne": SendQuickChat("Quick Chat_Reactions", 1)
		}

		OldCommand := Command
	}
}
```

---

# Controller Handler (Controller.ahk)

The job of the controller handler is to map Xbox controller inputs onto keyboard key presses.  If you are asking why I would need to map controller inputs onto key presses when Rocket League already has controller support, well... it’s because I wanted to be able to disable certain inputs and couldn’t find an easy way to do that on controller. I could have just given up on disabling keys and made my life a whole lot easier, but where’s the fun in that? (send help)

## Xbox Button Inputs

It was fairly trivial to map the Xbox buttons onto key presses because they are both analog. All I did was store the previous state of the controller, and if it changed then I would loop through all of the buttons (ControllerBinds["xiBtns"]) and update all of the buttons accordingly; if the Xbox button was down when it was previously up, I would set the keyboard key to down and vice versa.

```ahk
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

	OldState := State

}
```

## Xbox Analog Inputs

This is the point where I began to really regret my chosen methodology, but I pushed on anyway. Because the triggers and sticks can’t merely be directly translated into an “up” or “down” keystroke, I decided that spamming keys was the best choice. Every few milliseconds, a cycle is repeated in which a key is pressed down for some time and unpressed for some time such that the inputs are averaged out into an analog input.

![Local Client Overview - Analog Inputs.png](https://github.com/DavidAngell/Chat-Controls-Rocket-League-Client/blob/565294ebcd9077b6c5a16b737988267298aac9b9/ReadMeImages/Local_Client_Overview_-_Analog_Inputs.png)

### Triggers

The triggers are each split up into five intervals which each have their own distinct on-times —0, 0.5, 1.0, 1.5, and 2 milliseconds respectively. The program loops every 0.5 milliseconds and checks whether the interval of the stick position has changed; if it has, it resets the counters for milliseconds through the duty cycle; if it hasn’t the program checks whether the current count for milliseconds through the duty cycle is above or below the on-time and sets the key to up or down accordingly.

```ahk
global TRIGGER_MAX = 256 ; max analog value of the trigger 0-255
global DigitalTrigger_Duty_Cycle := 2 ; ms
global DigitalTrigger_OnTimeTiers := [0, 0.5, 1.0, 1.5, 2] ; on-time in ms
global DigitalTrigger_msThroughCycle := { "bLeftTrigger": 0, "bRightTrigger": 0 }

; ...

; Parameters:
;     [in] TriggerName: Either "bLeftTrigger", "bRightTrigger"
;     [in] TriggerKey: The keyboard key associated with the trigger

_DigitalTrigger_AnalogToDigital(TriggerName, TriggerKey) {
	global
	OldIntervalTier := Ceil(OldState[TriggerName] / (TRIGGER_MAX / DigitalTrigger_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
	IntervalTier := Ceil(State[TriggerName] / (TRIGGER_MAX / DigitalTrigger_OnTimeTiers.MaxIndex())) ; converting coorinates into a number 1-5
	IntervalTierVal := DigitalTrigger_OnTimeTiers[IntervalTier]

	if (OldIntervalTier == IntervalTier) {
		if (DigitalTrigger_msThroughCycle[TriggerName] > DigitalTrigger_Duty_Cycle - IntervalTierVal) {
			Send, {%TriggerKey% Down}
		} else {
			Send, {%TriggerKey% Up}
		}

		if (DigitalTrigger_msThroughCycle[TriggerName] > DigitalTrigger_Duty_Cycle) {
			DigitalTrigger_msThroughCycle[TriggerName] := 0
		}

	} else {
		DigitalTrigger_msThroughCycle[TriggerName] := 0
	}
}
```

### Sticks

The analog sticks are estimated by digital keystrokes in a similar fashion. The positive and negative coordinates of each stick axis are split up into six levels; each level has an on-time of 0, 0.5, 1, 1.5, 2, and 2.5 milliseconds respectively. This, combined with the low duty cycle of 2.5 milliseconds, creates varying average turn radii which feel similar to normal analog turning for the player. 

```ahk
global MAX_STICK_COORDINATE = 32767
global DigitalThumbStick_Duty_Cycle := 2.5 ; ms
global DigitalThumbStick_OnTimeTiers := [0, 0.5, 1, 1.5, 2, 2.5] ; on-time in ms
global DigitalThumbStick_msThroughCycle := { "sThumbLX": 0, "sThumbLY": 0, "sThumbRX": 0, "sThumbRY": 0 }

; ...

; Parameters:
;		[in] sThumbName: Either "sThumbLX", "sThumbLY", "sThumbRX", or "sThumbRY"
;		[in] sThumbKey: The keyboard key associated with the stick
;   [in] sThumbKey_Air: The keyboard key associated with the stick while in the air

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
```
