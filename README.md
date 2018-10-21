# Autosave
Simple autosave for SAI 2 (and probably for other apps)

## What
This script can be used as a simple launcher or just stay launched in system tray.  
Every 5 minutes it sends a special system message to SAI that triggers `File => Save` menu item. Antiviruses can treat that as a suspicious activity, so alternatively it can emulate `Ctrl+S` hotkey. Note that both methods work even when SAI window is not focused.

## Why
Once a friend of mine lost his progress in SAI 2 so this thing became something that could help to avoid such cases in the future.

## How to use?
In the perfect case, just put the `Autosave.exe` file in the `sai2.exe` folder and use it instead of `sai2.exe` (more info below).  
If you have AutoHotkey installed, use `Autosave.ahk` file instead. Not that it's a quite old script so it may not work with nevest versions of AutoHotkey.  
Alternatively you can create a config file (`Autosave_config.ini`) with the following content and have script constantly be launched and be ready in autosave in every further `sai2.exe` app:
```ini
[Auto]
AutorunApp = 0
CloseScriptWhenAppIsClosed = 0
```
This script is not perfect but it did its job well. I decided to upload it just because why not?

## Replace SAI with this script
Rename `sai2.exe` into `sai2_original.exe`, and `Autosave.exe` into `sai2.exe`. Then create `sai2_config.ini` with the following content:
```ini
[Main]
App = sai2_original.exe
```
Now everytime you open SAI (either directly or by opening `.sai / .sai2` files), it will start this script that starts SAI. When SAI is closed, the script will be terminated as well. Note that the script will be terminated not instantly, but in `<= 5` minutes. It doesn't affect its work though.  
Another note: in this case the config file is named `sai2_config.ini`, not `Autosave_config.ini`. This script uses its own filename to compute a config name.

# Config

The script is configurable. Every option can be ommited, including the whole `Autosave_config.ini` file. This are default config values:
```ini
[Main]
App = sai2.exe
Seconds = 300

[Auto]
AutorunApp = 1
CloseScriptWhenAppIsClosed = 1

[Keys]
UseHotkeysInsteadOfCommands = 0
KeySequence = {Ctrl down}{vk53}{Ctrl up}
# {vk53} - Code (Virtual Key) of “S”

[WM_COMMAND]
Message = 0x111
wParam = 0x20056
lParam = 0
```

### [Main]
##### App
The name of app that will be watched. If autorun is enabled, it will try to launch the same named file. Default value is `sai2.exe`

##### Seconds
How often send signals to app. Default value is `300` (`5 mins, 60 * 5`)

### [Auto]
##### AutorunApp
If is `1`, it tried to find `sai2.exe` and run it rught after script is launched. To turn off, set it to `0`. Default value is `1`

##### AutorunFolder
Path to folder where `sai2.exe` is placed. Can have such value as `C:\Program Files\SAI 2`. Default value is folder from where the script is launched.

##### CloseScriptWhenAppIsClosed
If is `1`, script terminates when `sai2.exe` is closed. Default value is `1`

### [Keys]
##### UseHotkeysInsteadOfCommands
If is `1`, the script will send `Ctrl+S` instead of windows message `0x200E1`. Should be set to `1` if windows messages don't work for you. Default value is `0`

##### KeySequence
AutoHotkey's key sequence that will be send to `sai2.exe` if `UseHotkeysInsteadOfCommands` is set to `1`. Default value is `{Ctrl down}{vk53}{Ctrl up}` (`{vk53}` is a layout-independent value for the `S` key)  
Details are available in the [AutoHokey's docs (Send section)](https://www.autohotkey.com/docs/commands/Send.htm)

### [WM_COMMAND]
##### Message
Windows message type. Usually it should always be `0x111`. Details are available in the [AutoHokey's docs (SendMessage section)](https://www.autohotkey.com/docs/misc/SendMessage.htm)

##### wParam
Hex value to be sent. SAI's value for `File => Save` menu item is `0x20056` (it's the same value for both SAI 1 and SAI 2). Can be found with some app like Winspector (this is also described in the docs that linked above)

##### lParam
Additional value to be sent. Usually it should always be `0`