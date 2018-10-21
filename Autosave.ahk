#MaxThreadsPerHotkey, 2
#SingleInstance force
SetBatchLines -1
SendMode Input
#Persistent
#NoEnv

; -------------------------
; Getting the name of the config file and setting default values

SplitPath, A_ScriptName,,,, fileName
configFile := fileName . "_config.ini"
firstParam = %1%

defApp			:= "sai2.exe"
defSeconds		:= "300"
defUseHotkeys		:= "0"
defKeySequence		:= "{Ctrl down}{vk53}{Ctrl up}"
defAutorun		:= "1"
defAutocloseScript	:= "1"
defMessage		:= "0x111"
defWParam		:= "0x20056"
defLParam		:= "0"

version			:= "1.1"
editDate		:= "Jan 09, 2017"
getIniArg		:= "-ini"

; -------------------------
; If the first param is '-ini', generate the config file

if (firstParam == getIniArg)
{

IfExist, %configFile%
{
MsgBox, 52, Warning, You're going to generate the config file but “%configFile%” already exists. Do you want to overwrite it?
IfMsgBox No
ExitApp
}

FileDelete %configFile%

FileAppend,
(
[Main]
App = %defApp%
Seconds = %defSeconds%

[Auto]
AutorunApp = %defAutorun%
# AutorunFolder = %A_ScriptDir%
# Uncomment (remove the first character) the line above to set the custom path for autorun
CloseScriptWhenAppIsClosed = %defAutocloseScript%

[Keys]
UseHotkeysInsteadOfCommands = %defUseHotkeys%
KeySequence = %defKeySequence%
# {vk53} - Code (Virtual Key) of “S”

[WM_COMMAND]
Message = %defMessage%
wParam = %defWParam%
lParam = %defLParam%
), %configFile%

MsgBox, 64, Done, The config with default values has been created (%configFile%)
ExitApp
}

; -------------------------

IniRead, appName, %configFile%, Main, App, %defApp%
IniRead, seconds, %configFile%, Main, Seconds, %defSeconds%

IniRead, autorun, %configFile%, Auto, AutorunApp, %defAutorun%
IniRead, appPath, %configFile%, Auto, AutorunFolder, %A_ScriptDir%
IniRead, autoClose, %configFile%, Auto, CloseScriptWhenAppIsClosed, %defAutocloseScript%

IniRead, useHotkeys, %configFile%, Keys, UseHotkeysInsteadOfCommands, %defUseHotkeys%
IniRead, keySequence, %configFile%, Keys, KeySequence, %defKeySequence%

IniRead, wm_Message, %configFile%, WM_COMMAND, Message, %defMessage%
IniRead, wParam, %configFile%, WM_COMMAND, wParam, %defWParam%
IniRead, lParam, %configFile%, WM_COMMAND, lParam, %defLParam%

; TrayTip, %A_Space%%A_Space%%fileName% is working%A_Space%%A_Space%, %A_Space%, , 33

Menu, Tray, NoStandard
Menu, Tray, Add, &Info, ShowInfo
Menu, Tray, Default, &Info
Menu, Tray, Click, 1
Menu, Tray, Add, Exit, ExitApp

app := "ahk_exe " . appName
seconds := seconds*1000
wasActive := 0

; TrayTip, %A_Space%%A_Space%Launching %appName%…%A_Space%%A_Space%, %A_Space%, , 33

if (autorun = 1)
{
  IfWinNotExist %app%
  {
    lastPathChar := substr(appPath, 1, 1)
    if (lastPathChar != "\")
      appPath := appPath . "\"

    IfExist, %appPath%%appName%
    {
      run, %appPath%%appName% %1%,,, process_id
      WinWait, ahk_pid %process_id%,, 5
      if not ErrorLevel
      {
        app := "ahk_pid " . process_id
        WinActivate, %app%
      }
    }
    else
    {
      TrayTip, Autorun failed, Can't find the following file:`n%appPath%%appName%, , 34
    }
  }
  else
  {
    WinGet, process_id, PID, %app%
    app := "ahk_pid " . process_id
  }
}

goto WaitForApp

; -------------------------

CheckApp:
  IfWinActive, %app%
  {
    wasActive := 1
    gosub SendDataToApp
    gosub SetTimer
  }
  else if (wasActive = 1)
  {
    wasActive := 0
    gosub SendDataToApp
    gosub WaitForApp
  }

return

SendDataToApp:
  if (useHotkeys = 1)
  {
    ControlSend, ahk_parent, %keySequence%, %app%
  }
  else
  {
    PostMessage, %wm_Message%, %wParam%, %lParam%, , %app%
  }
return

WaitForApp:
  SetTrayName(fileName, "Doing nothing, waiting for " . appName)
;  WinWaitActive, %app%,, 60
;    TrayTip, Waiting… %A_TickCount%, %A_Space%, , 33
  WinWaitActive, %app%,, 10
  
  if ErrorLevel
  {
    IfWinNotExist, %app%
      if (autoclose = 1)
        ExitApp

    goto WaitForApp
  }
  SetTrayName(fileName, "Working")
  wasActive := 1
  goto SetTimer
return

SetTimer:
  SetTimer, CheckApp, -%seconds%
return

SetTrayName(first, second)
{
  Menu, Tray, Tip, %first% – %second%
}

ExitApp:
  ExitApp
return

ShowInfo:
time := Round(defSeconds / 60, 0)
  MsgBox, 64, %A_Space%%A_Space%Autosave v%version% (%editDate%)%A_Space%%A_Space%,
(
A script that sends keys or system messages to some app.
By default it sends save command to %defApp% every %time% minutes.

Launch script with “%getIniArg%” argument to generate configurable .ini file.

Made by Jesse Orange special for Taiketshin Ionak.
)
return