<#
  .Synopsis
    Expands the selected disk to max-size
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se      .LINK    http://www.nestil.se      https://github.com/Nestil/#>
$Driveletter = Write-Host "Enter driveletter without the colon sign"
$MaxSize = (Get-PartitionSupportedSize -DriveLetter $Driveletter).sizeMax
Resize-Partition -DriveLetter $Driveletter -Size $MaxSize