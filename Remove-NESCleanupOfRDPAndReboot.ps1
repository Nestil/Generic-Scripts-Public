﻿<#
  .Synopsis
    Logs out all users from Remote Desktop and then cleans registry from Client Side Rendering entries, then restarts server.
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Printers\CSR|*' -Force -Recurse
Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Print\Providers\Client Side Rendering Print Provider' -Force -Recurse
Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Print\Printers\CSR|*' -Force -Recurse
