; KeyBinds needs to be in this exact format bc AutoHotkey is garbage and can't do multi-line objects

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
	, "Party Text Chat" : "U" ; The next few things after this don't matter at all bc who actually spectates??? 
	, "Use Item" : "R" 
	, "Next Item" : "C" }

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
