#Persistent
#SingleInstance Force
#NoEnv
#NoTrayIcon

log(msg) {
    FileRead, logData, %A_ScriptDir%\..\log.txt
    FileDelete, %A_ScriptDir%\..\log.txt
    FileAppend, [%A_Hour%:%A_Min%] %msg%`n%logData%, %A_ScriptDir%\..\log.txt
}
log("Starting FixedFarm")
; Check if Roblox is running
WinGet, RobloxID, ID, ahk_exe robloxplayerbeta.exe
if (!RobloxID) {
	log("Roblox is not running, please use the windows version")
    ExitApp
}

; Set Roblox position and activate
Roblox_X := 159
Roblox_Y := 117
Roblox_Width := 816
Roblox_Height := 638

WinMove, ahk_id %RobloxID%, , Roblox_X, Roblox_Y, Roblox_Width, Roblox_Height
WinActivate, ahk_id %RobloxID%

; Ensure the window is active
if !WinActive("ahk_id " . RobloxID) {
    log("Roblox is not running | ERROR 104")
    ExitApp
}

global hybrid := []  ; Stores line numbers of units with value 0
global hill := []    ; Stores line numbers of units with value 1
global ground := []  ; Stores line numbers of units with value 2
global ceo := 0      ; Stores line number of Unit with value 26 (0 if not found)
global bulba := 0    ; Stores line number of Unit with value 25 (0 if not found)

wuhasdu893huiqasd() {
    FilePath := A_ScriptDir . "\..\Bin\statsinfo.cfg" ; Move up one folder and enter Bin

    if !FileExist(FilePath) {
        log("File not found")
        return
    }

    FileRead, Content, %FilePath%
    
    if (ErrorLevel) {
        ;MsgBox, Failed to read file.
		log("Failed to read file | ERROR 256")
        return
    }

    LineNumber := 0
    Loop, Parse, Content, `n, `r  ; Loop through each line
    {
        LineNumber++
        if RegExMatch(A_LoopField, "i)^X") ; Ignore lines starting with "X"
            continue

        if RegExMatch(A_LoopField, "Unit\d+: (\d+)", Match) {
            Value := Match1

            if (Value = 0)
                hybrid.push(LineNumber)  ; Store line number in hybrid array
            else if (Value = 1)
                hill.push(LineNumber)  ; Store line number in hill array
            else if (Value = 2)
                ground.push(LineNumber)  ; Store line number in ground array
            else if (Value = 26)
                ceo := LineNumber  ; Store line number in ceo
            else if (Value = 25)
                bulba := LineNumber  ; Store line number in bulba
        }
    }
}

wuhasdu893huiqasd()  ; Call function to process the file




CoordMode, Pixel, Client
CheckPixelColor(x, y, expectedRGB, tolerance := 10) {
    PixelGetColor, color, %x%, %y%, RGB
    return (Abs((color & 0xFF) - (expectedRGB & 0xFF)) <= tolerance   ; Blue
        && Abs(((color >> 8) & 0xFF) - ((expectedRGB >> 8) & 0xFF)) <= tolerance ; Green
        && Abs(((color >> 16) & 0xFF) - ((expectedRGB >> 16) & 0xFF)) <= tolerance) ; Red
}


; ---------------------------------------------------------------------------------------------------------------------------

;go to fixed position
goToBestPosition()

;start match
click, 396, 136
sleep, 500


global ihybrid := 1
global ihill := 1
global iground := 1


if (isFarm() == 51) {
log("Both farms are enabled")


;wave 1
placeCeo()
sleep, 4000
waitForRound()

;wave 2
placeCeo() 
placeCeo() 
placeBulba()
upgradeFarmCeo(1)
upgradeFarmCeo(2)
waitForRound()

;wave 3
upgradeFarmCeo(3)
upgradeFarmBulba()
upgradeFarmBulba()
waitForRound()

;wave 4
upgradeFarmCeo(1)
upgradeFarmCeo(2)
upgradeFarmCeo(3)
waitForRound()

;wave 5 (10219)
placeUnit()
upgradeFarmCeo(1)
upgradeFarmCeo(2)
upgradeFarmCeo(3)
waitForRound()

;wave 6 (11850)
;placeUnit()
placeUnit()
upgradeFarmBulba() 
waitForRound()

;wave 7
upgradeFarmBulba()
upgradeFarmBulba()
waitForRound()

;wave 8
upgradeFarmCeo(1)
upgradeFarmCeo(2)
upgradeFarmCeo(3)
placeUnit()
upgradeUnit()
waitForRound()

;wave 9
upgradeFarmCeo(3)







} else if(isFarm() == 26) { ; ---- 26 for C.E.O
;MsgBox, C.E.O
log("Only C.E.O has been detected as farm")


;wave 1
placeCeo()
sleep, 4000
waitForRound()

;wave 2
placeCeo() 
placeCeo() 
upgradeFarmCeo(1)
upgradeFarmCeo(2)
upgradeFarmCeo(3)
waitForRound()

;wave 3
upgradeFarmCeo(1)
upgradeFarmCeo(2)
upgradeFarmCeo(3)
waitForRound()

;wave 4
upgradeFarmCeo(1)
upgradeFarmCeo(2)
placeUnit()


;wave 5
upgradeFarmCeo(3)
upgradeFarmCeo(1)
upgradeFarmCeo(2)

;wave 6
upgradeFarmCeo(3)



} else if(isFarm() == 25) { ; ---- 25 for Bulba
;MsgBox, Bulba
log("Only bulba has been detected as farm")

;wave 1
sleep, 4500
waitForRound()

;wave 2
placeBulba()
upgradeFarmBulba()

;wave 3
upgradeFarmBulba()

;wave 4
upgradeFarmBulba()
placeUnit()

; wave 5
upgradeFarmBulba()
placeUnit()

;wave 6
placeUnit()
placeUnit()
placeUnit()

;wave 7 
upgradeFarmBulba()


}

else if (!(isFarm())) {
log("No farm has been detected")
sleep, 4500
waitForRound()
}







ilash := 0  ; Start at 0 to ensure first iteration behaves correctly

while (true) {
sleep, 1000
isGameDone()

    placeUnit()

    ilash++  ; Increase the counter

    if (Mod(ilash, 3) == 0) {  ; Runs every third iteration
        upgradeUnit()
    }
}








; ---------------------------------------------------------------------------------------------------------------------------


goToBestPosition() {
    ; Path to typeworld.cfg (where the world name is stored)
    typeWorldPath := A_ScriptDir "\..\Bin\typeworld.cfg"

    ; Debugging: Check if typeworld.cfg exists
    
    if !FileExist(typeWorldPath) {
        log("❌ ERROR 230 | NOT found at: " typeWorldPath)
        ExitApp
		return
    }

    ; Read the world name from the first line of typeworld.cfg
    FileReadLine, worldName, %typeWorldPath%, 1
    worldName := Trim(worldName)  ; Remove spaces/newlines

    ; Debugging: Check if world name was read
    log("🌍 Read world name: " worldName)

    if (worldName = "") {
        log("❌ ERROR 231: World name is empty")
        return
    }

    ; Path to the actual world file (same folder as script)
    worldFilePath := A_ScriptDir "\" worldName ".cfg"

    ; Debugging: Check if world file exists
    if !FileExist(worldFilePath) {
        log("❌ ERROR 232: World file NOT found at: " worldFilePath)
		ExitApp
        return
    }


    ; Read file content
    FileRead, fileContent, %worldFilePath%

    if (fileContent = "") {
        log("❌ ERROR 233: Failed to read file! | FilePath: " worldFilePath)
        return
    }

    Send, {Shift Down}
    

    for index, line in StrSplit(fileContent, "`n", "`r") {
        Sleep, 100
        log("🔹 Processing line " index ": " line) ; Show each line being processed
        
        if (index < 3) {
            log("↪️ Skipping line " index " (first 3 lines ignored)")
            Continue
        }

        if (Trim(line) = "-") {
            log("🛑 Found '-' separator, stopping...")
            Break
        }

        ; Try to match coordinates (e.g., "47, 406 (2)")
        if RegExMatch(line, "(\d+),\s*(\d+)\s*\((\d+)\)", coords) { 
            log("✅ Matched coordinates: X=" coords2 ", Y=" coords1 ", Delay=" coords3 " sec")
            MouseClick, right, %coords1%, %coords2%
            Sleep, % (coords3 * 1000)
        } else {
            log("⚠️ No match found in line: " line)
        }
    }
    
    Send, {Shift Up}
}




isFarm() {
    FilePath := A_ScriptDir . "\..\Bin\statsinfo.cfg" ; Move up one folder and enter Bin

    if !FileExist(FilePath) {
        
		log("File not found")
        return
    }

    FileRead, Content, %FilePath%
    
    if (ErrorLevel) {
        log("Failed to read file | ERROR 256")
        return
    }

    Total := 0
    Loop, Parse, Content, `n, `r  ; Loop through each line
    {
        if RegExMatch(A_LoopField, "i)^X") ; Ignore lines starting with "X"
            continue

        if RegExMatch(A_LoopField, ":\s*(\d+)", Match) { ; Extract numeric value
            Value := Match1 + 0 ; Convert to number
            if (Value = 26 || Value = 25)
                Total += Value
        }
    }

    return Total
}







isRoundOver() {
static roundCount := 1
roundCount++
    if (CheckPixelColor(631, 85 , 0xFFFFFF) && CheckPixelColor(633, 76 , 0xCFCFCF) && CheckPixelColor(627, 70 , 0xF9F9F9)) {
     ;   MsgBox, money probably heated
        return 1
    }
    return 0
}

waitForRound() {
  while (!(isRoundOver())) {
  isGameDone()
        ;MsgBox, Waiting for round to finish.. ; Debug: Notify while waiting
        Sleep, 50
    }
	sleep, 4500
   ; MsgBox, Round is over!
}

; BASED ON THE TEXT: ( THIS UNIT IS ALREADY MAX LEVEL)
isMaxUnit() {
if (CheckPixelColor(180, 464, 0xFF494C) && CheckPixelColor(225, 465, 0xFF494C) && CheckPixelColor(329, 467, 0xFF494C) && CheckPixelColor(420, 459, 0xFF494C) && CheckPixelColor(526, 460, 0xFF494C) && CheckPixelColor(593, 459, 0xFF494C) && CheckPixelColor(622, 467, 0xFF494C)) {
    return 1
}
if (CheckPixelColor(216, 467, 0xFF494C) && CheckPixelColor(264, 466 , 0xFF494C) && CheckPixelColor(380, 470, 0xFF494C) && CheckPixelColor(580, 467, 0xFF494C) && CheckPixelColor(379, 469, 0xFF494C)) { 
 return 1
}
; EDIT SOMETHING HERE23

return 0
}

; BASED ON THE UPGRADE TEXT (NOT ENOGUM MONEY)
noMoney() {
if (CheckPixelColor(344, 460, 0xFF494C) && CheckPixelColor(466, 458, 0xFF494C) && CheckPixelColor(538, 460, 0xFF494C) && CheckPixelColor(555, 465, 0xFF494C)) {
    return 1
}
return 0
}

isGameDone() {
sleep, 100
; check wether defeated or not.
if (checkPixelColor(360, 399, 0x17CA00) && checkPixelColor(361, 395, 0x1ED300) && checkPixelColor(350, 382, 0x39F500)) {
; Defeat, next room. or won, next button
click, 365, 424

sleep, 500

; won
if(checkPixelColor(566, 121, 0xFFBF00) && checkPixelColor(542, 123, 0xF1F1F1)) {
; next room
log("Round won, continuing...")
} 
; lost
if (checkPixelColor(566, 121, 0xFFBF00) && checkPixelColor(510, 128, 0xF1F1F1)) {
; retry
log("Round lost, retrying...")
}
click, 541, 152
sleep, 100
Run, % FileExist(A_ScriptDir "\..\Bin\MapIdentifier.ahk") 
    ? A_ScriptDir "\..\Bin\MapIdentifier.ahk" 
    : A_ScriptDir "\..\Bin\MapIdentifier.exe"
sleep, 3500


ExitApp

	}
	
	else if (checkPixelColor(566, 121, 0xFFBF00) && checkPixelColor(542, 123, 0xF1F1F1)) {
	log("Round won, continuing...")
sleep, 100
	click, 541, 152

Run, % FileExist(A_ScriptDir "\..\Bin\MapIdentifier.ahk") 
    ? A_ScriptDir "\..\Bin\MapIdentifier.ahk" 
    : A_ScriptDir "\..\Bin\MapIdentifier.exe"
sleep, 3500
	ExitApp
	}
	
	else if (checkPixelColor(566, 121, 0xFFBF00) && checkPixelColor(510, 128, 0xF1F1F1)) {
	log("Round lost, retrying...")
	sleep, 100
	click, 541, 152

Run, % FileExist(A_ScriptDir "\..\Bin\MapIdentifier.ahk") 
    ? A_ScriptDir "\..\Bin\MapIdentifier.ahk" 
    : A_ScriptDir "\..\Bin\MapIdentifier.exe"
sleep, 3500
ExitApp
}
	
	else {
	return 0
	}
}

grabLocation(operator, index) {
    ; Read the world name from typeworld.cfg
    FilePath := A_ScriptDir . "\..\Bin\typeworld.cfg"
    
    if !FileExist(FilePath) {
        log("typeworld.cfg couldn't be found! | ERROR 238")
        return
    }

    FileReadLine, worldName, %FilePath%, 1
    worldFile := A_ScriptDir . "\" . Trim(worldName) . ".cfg"

    ; Check if the world file exists
    if !FileExist(worldFile) {
        log("Couldn't find world name || ERROR 421")
        ExitApp
    }

    ; Read the world file content
    FileRead, fileContent, %worldFile%

    ; Find the section with the specified operator
    sectionFound := false
    coordinates := []  ; Use an array to store coordinates

    Loop, Parse, fileContent, `n, `r
    {
        line := Trim(A_LoopField)

        if (line = operator) {
            if (sectionFound)
                Break  ; Exit when reaching the second occurrence of the operator
            sectionFound := true
            Continue
        }

        if sectionFound && RegExMatch(line, "(\d+),\s*(\d+)", match) {
            coord := []  ; Create a new array for each coordinate pair
            coord.Insert(match1)
            coord.Insert(match2)
            coordinates.Insert(coord)  ; Store in the main array
        }
    }

    ; Validate index
    if (index > 0 && index <= coordinates.MaxIndex()) {
        chosenCoord := coordinates[index]
        x := chosenCoord[1]
        y := chosenCoord[2]
		click, %x%, %y%
        ;MsgBox, Coordinate: %x%, %y%
    } else {   
    return 22
	}
}






placeUnit() {

ChecKPoint325:

if (hybrid.MaxIndex() > 0) {

if (grabLocation("+", ihybrid) == 22) {

log("Location0 not found")

while(hybrid.MaxIndex() > 0) {
hybrid.Pop()
}
goto ChecKPoint325
}

Send, % hybrid[hybrid.MaxIndex()]
sleep, 300

grabLocation("+", ihybrid) ; place unit at location


sleep, 1000
Send, {q}
click, 18, 38

if (noMoney()) {

;save location, do not delete the unit from the stack
log("Not enough money to place the unit")

return
}


if (isMaxUnit()) {
; save location, delete from the stack by 1.
log("Placed max hybrid unit, trying again..")
hybrid.Pop()
goto ChecKPoint325
}



ihybrid++

return 

}


if (hill.MaxIndex() > 0) {


if (grabLocation("*", ihill) == 22) {
log("Location11 not found")
while(hill.MaxIndex() > 0) {
hill.Pop()
}

goto ChecKPoint325
}


Send, % hill[hill.MaxIndex()]
sleep, 300
grabLocation("*", ihill) ; place unit at location

sleep, 1000
Send, {q}
click, 18, 38
if (noMoney()) {
;save location, do not delete the unit from the stack
log("Not enough money to place unit")

return
}


if (isMaxUnit()) {
; save location, delete from the stack by 1.
log("Placed max hill unit, trying again..")
hill.Pop()
goto ChecKPoint325
}


ihill++

return 
}



if (ground.MaxIndex() > 0) {


; Checking if a valid coord is availble
; if not, pop the stack, and recall.
; No need to recall for ground.

if (grabLocation("=", iground) == 22) {
log("Location22 not found")

while(ground.MaxIndex() > 0) {
ground.Pop()
}

static iwasdd = 0
if (iwasdd == 2) 
log("All units placed")

iwasdd++
return
}


Send, % ground[ground.MaxIndex()]
sleep, 300
grabLocation("=", iground) ; place unit at location

sleep, 1000
Send, {q}
click, 18, 38

if (noMoney()) {
;save location, do not delete the unit from the stack
log("Not enough money to place unit")

return
}

if (isMaxUnit()) {
; save location, delete from the stack by 1.
log("Placed max ground unit, trying again..")
ground.Pop()
goto ChecKPoint325
}


iground++

return 

}

static i := 0
if (i == 1) {
log("All units or locations have been placed")
}
i++
return
}

upgradeUnit() {
    global ihill, ihybrid, iground

    ; Upgrade hill units
    if (ihill > 1) {
        Loop, % ihill - 1 {
            coord := grabLocation("*", A_Index)  ; Get placement coordinates
			
			if (checkPixelColor(353,235, 0x191919) && checkPixelColor(344,239, 0x191919)) {
			click, 380, 268
			}
			
            if (coord != 22) {
                MouseMove, % coord[1], % coord[2]  ; Move mouse to unit location
                Sleep, 300
                Send, {r}  ; Press R to upgrade
				Click, 18, 38

            }
        }
    }

    ; Upgrade hybrid units
    if (ihybrid > 1) {
        Loop, % ihybrid - 1 {
            coord := grabLocation("+", A_Index)  ; Get placement coordinates
			
			if (checkPixelColor(353,235, 0x191919) && checkPixelColor(344,239, 0x191919)) {
			click, 380, 268
			}
			
            if (coord != 22) {
                MouseMove, % coord[1], % coord[2]  ; Move mouse to unit location
                Sleep, 300
                Send, {r}  ; Press R to upgrade
				Click, 18, 38

            }
        }
    }

    ; Upgrade ground units
    if (iground > 1) {
        Loop, % iground - 1 {
            coord := grabLocation("=", A_Index)  ; Get placement coordinates
			
			if (checkPixelColor(353,235, 0x191919) && checkPixelColor(344,239, 0x191919)) {
			click, 380, 268
			}
			
            if (coord != 22) {
                MouseMove, % coord[1], % coord[2]  ; Move mouse to unit location
                Sleep, 300
                Send, {r}  ; Press R to upgrade
				 Click, 18, 38

            }
        }
    }
}

placeCeo() {
static i := 1

log("Placed ceo" i)

if (i > 3) {
log("Something has gone terribly wrong | ERROR ???")
ExitApp
}

Send, % ceo
sleep, 300
grabLocation("/", i)
Click, 18, 38
Send, {q}
i++
}


upgradeFarmCeo(unit) {
log("Upgraded ceo: " unit)
grabLocation("/", unit)
sleep, 300
Send, {r}
sleep, 300
Click, 18, 38
}


placeBulba() {
static i := 1
log("Placed bulba")
if (i > 1) {
log("Something has gone terribly wrong | ERROR ???")
ExitApp
}

Send, % bulba
sleep, 300
grabLocation(":", i)
Click, 18, 38
Send, {q}
i++
}

upgradeFarmBulba() {
log("Upgraded bulba")
grabLocation(":", 1)
sleep, 300
Send, {r}
sleep, 300
Click, 18, 38
}




ExitApp


