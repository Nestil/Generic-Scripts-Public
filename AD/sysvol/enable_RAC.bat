@Echo off
REM Enabling Reliability Monitor Data Collection
REM Reboot is needed to take effect. 

schtasks.exe /change /enable /tn \Microsoft\Windows\RAC\RacTask
reg add "HKLM\SOFTWARE\Microsoft\Reliability Analysis\WMI" /v WMIEnable /t REG_DWORD /d 1 /F

REM  2013-11-11
REM  // Markus Lassfolk 


