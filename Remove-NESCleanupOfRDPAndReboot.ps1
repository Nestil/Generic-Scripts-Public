<#
  .Synopsis
    Logs out all users from Remote Desktop and then cleans registry from Client Side Rendering entries, then restarts server.
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se    Dependent on the script: C:\Repo\Generic-Scripts-Public\Disconnect-AndLogOffAllUsersFromRDP.ps1     Which is used to log off all users from the remote desktop before continuing.      .LINK    http://www.nestil.se      https://github.com/Nestil/#>#Let any logged on users know that the server will restart in 10 minutesMSG * "The server will restart for update and cleanup within 10 minutes."#Wait for 10 minutesStart-Sleep -Seconds 600#Log off all users from Remote DesktopC:\Repo\Generic-Scripts-Public\Disconnect-AndLogOffAllUsersFromRDP.ps1Start-Sleep -Seconds 10#Stop the Print spoolerStop-Service SpoolerStart-Sleep -Seconds 10#Remove Reg-values for Client Side RenderingRemove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\Client Side Rendering Print Provider' -Force -Recurse
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Printers\CSR|*' -Force -Recurse
Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Print\Providers\Client Side Rendering Print Provider' -Force -Recurse
Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Print\Printers\CSR|*' -Force -Recurse
#Start SpoolerStart-Service Spooler Start-Sleep -Seconds 10#Restart ComputerRestart-Computer -Force