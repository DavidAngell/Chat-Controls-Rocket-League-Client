#NoEnv
#UseHook
#InstallMouseHook
#InstallKeybdHook
SendMode Input
SetWorkingDir %A_ScriptDir% 
CoordMode ToolTip
#Persistent
#SingleInstance Force

Run %ComSpec% /c "node VotingServerWatcher.js", %A_ScriptDir%/NetworkClient/
Run, "Controller.ahk"
#Include <KeyBinds>

global OldCommand = ""

RunCommand(Command) {
	if (Command != OldCommand) { ; there will be a bug if the same command is sent twice but i am lazy :)
		ToolTip % "Penis: " OldCommand, 150, 400
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
			case "Force_Drive_Backwards": PressKey("Drive BackwaDrds")
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
			; case "Text_Chat_Random_From_List":
			; case "Text_Chat_Custom":
			; case "Southpaw":
		}

		OldCommand := Command

	}

	ToolTip % "Ran command", 150, 400
}

PressKey(BindName, ms = 10000) {
	key := InGameBinds[BindName]
	Send, {%key% Down}
	Sleep ms
	Send, {%key% Up}
}

DisableKey(BindName, ms = 10000) {
	key := InGameBinds[BindName]
	ToolTip % "Key: " key, 150, 400
	Hotkey, %key%, Disable_Return
	Sleep, %ms%
	Hotkey, %key%, Off

	Disable_Return:
		return
}

ArrayContains(arr, val) {
	if !(IsObject(arr)) || (arr.Length() = 0) {
		for i, e in arr
			if (e == val)
				return i
	} else {
		return 0
	}
}

SendQuickChat(Category = "none", Chat = 0) {
	Categories := ["Quick Chat_Information", "Quick Chat_Compliments", "Quick Chat_Reactions", "Quick Chat_Apologies"]
	if (ArrayContains(Categories, Category) == 0) {
		Random, CatNum, 1, 4
		NewCategory := Categories[CatNum]
		PressKey(NewCategory, 80)
	} else {
		PressKey(Category, 80)
	}

	Sleep, 200

	if (Chat == 0) {
		Random, MsgNum, 1, 4
		MsgKeyCategory := Categories[MsgNum]
		PressKey(MsgKeyCategory, 80)
	} else {
		MsgKeyCategory := Categories[Chat]
		PressKey(MsgKeyCategory, 80)
	}
}

ChangeCamera() {
	PressKey("Focus On Ball", 100)
	DisableKey("Focus On Ball", 9900)
}

ConstantJump(ms = 10000) {
	DelayBetweenJumps := 100
	i := 0
	while (i < ms / DelayBetweenJumps) {
		PressKey("Jump", DelayBetweenJumps)
		i := i + 1
	}
}

SetTimer, WatchCommandsFile, 100

WatchCommandsFile:
	FileRead, Command, %A_ScriptDir%\NetworkClient\janky_commands.txt
	RunCommand(Command)
	OldCommand := Command
return

#x::ExitApp ; Win+X