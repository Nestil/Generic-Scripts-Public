<#
  .Synopsis
    Expands the selected disk to max-size
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se
$Driveletter = Write-Host "Enter driveletter without the colon sign"
$MaxSize = (Get-PartitionSupportedSize -DriveLetter $Driveletter).sizeMax
Resize-Partition -DriveLetter $Driveletter -Size $MaxSize