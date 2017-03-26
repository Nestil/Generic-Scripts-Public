<#
  .Synopsis
    Logs off ALL users (including yourself) from a RDP Server

  .Notes
    Author: Nigel Stuke  .LINK    http://poshcode.org/3285    http://www.nestil.se      https://github.com/Nestil/#>

function RemoveSpace([string]$text) {  
    $private:array = $text.Split(" ", `
    [StringSplitOptions]::RemoveEmptyEntries)
    [string]::Join(" ", $array) }

$quser = quser
foreach ($sessionString in $quser) {
    $sessionString = RemoveSpace($sessionString)
    $session = $sessionString.split()
    
    if ($session[0].Equals(">nistuke")) {
    continue }
    if ($session[0].Equals("USERNAME")) {
    continue }
    # Use [1] for disconnected users since they have no session ID. 
    $result = logoff $session[1] }