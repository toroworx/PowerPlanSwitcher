if WScript.Arguments.Count = 0 then
    WScript.Echo "Missing parameters"
Else
targetGUID = WScript.Arguments(0)
set ws = createobject("wscript.shell") 
scriptdir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
ws.run "cmd.exe /c powercfg -s " & targetGUID,vbhide
ws.run scriptdir & "\tools\atrofac-cli.exe fan --plan windows --cpu 30c:20%,40c:30%,50c:30%,60c:45%,70c:65%,80c:82%,90c:92%,100c:97% --gpu 30c:20%,40c:25%,50c:30%,60c:40%,70c:65%,80c:86%,90c:92%,100c:97%",vbhide
ws.run scriptdir & "\tools\ryzenadj-win64\ryzenadj.exe --stapm-limit=35000 --fast-limit=35000",vbhide
end if