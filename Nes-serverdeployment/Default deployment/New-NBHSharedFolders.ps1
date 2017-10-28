<#
  .Synopsis
    Script for NBH Deployments
    Run this one AFTER New-NBHADStructure.ps1
  
  .Description
    This script do the following: 

    1. Check if disk E: is brought online
    2. If not online, it brings it online and checks if there is a valid GPT partition. 
    3. If Partitiontype is RAW it will initialize the disk and create a volume named "LAGRA"
    4. Remove the ACL entry for BUILTIN\Users from the Root of E:
    5. Create all shares
    6. Sets ACL on all Shares. 
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se
    
  .LINK
    http://www.nestil.se  
    https://github.com/Nestil/
#>

# Check if disks are Online, if not bring them online
$Diskstatus = Get-Disk | Where-Object –FilterScript {$_.OperationalStatus -Eq "Offline"}|foreach{
    set-disk -Number $Diskstatus.Number -IsOffline $false
}

#Check if Disk is initialized, if not initialize and create volume

$Diskinitialize = Get-Disk | Where-Object –FilterScript {$_.PartitionStyle -Eq "RAW"}|foreach{
    Initialize-Disk 1 -PartitionStyle GPT 
    New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E | Format-Volume -FileSystem NTFS -NewFileSystemLabel "LAGRA" 
}

#Remove ACL for BUILTIN\Users from E: before creating the shares
$ACL = Get-Acl "E:\" 
$ACL.SetAccessRuleProtection($True, $True)
$Removal = New-Object System.Security.Principal.NTAccount ("Users")
$RemovalRights = [System.Security.AccessControl.FileSystemRights]"CreateFiles, AppendData" 
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::None 
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None  
$objType =[System.Security.AccessControl.AccessControlType]::Allow 
$RemoveACL = New-Object System.Security.AccessControl.FileSystemAccessRule($Removal, $RemovalRights, $InheritanceFlag, $PropagationFlag, $objType)
$ACL.RemoveAccessRuleAll($RemoveACL)          
Set-ACL "E:\" $ACL

#Add Domain Admins to all subfolders from E:
$ACLAdmins = Get-Acl "E:\" 
$ACLAdmins.SetAccessRuleProtection($True, $True)
$ARAdmins = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$ACLAdmins.AddAccessRule($ARAdmins)       
Set-ACL "E:\" $ACLAdmins

Start-Sleep 3

#Create folders
New-Item "E:\Gemensam$" -Type Directory
New-Item "E:\Ekonomi$" -Type Directory
New-Item "E:\Apps$" -Type Directory
New-Item "E:\Ledning$" -Type Directory
New-Item "E:\Users$" -Type Directory
New-Item "E:\Userprofiles$" -Type Directory

start-sleep 5
#Create the Shares
New-SmbShare -Name "Gemensam$" -Path "E:\Gemensam$" `
    -FullAccess "Everyone" 
New-SmbShare -Name "Ekonomi$" -Path "E:\Ekonomi$" `
    -FullAccess "Everyone" 
New-SmbShare -Name "Apps$" -Path "E:\Apps$" `
    -FullAccess "Everyone" 
    New-SmbShare -Name "Ledning$" -Path "E:\Ledning$" `
    -FullAccess "Everyone" 
New-SmbShare -Name "Users$" -Path "E:\Users$" `
    -FullAccess "Everyone" 
New-SmbShare -Name "Userprofiles$" -Path "E:\Userprofiles$" `
    -FullAccess "Everyone" 

#Set ACL for Apps$
$ACLApps = Get-Acl "E:\Apps$" 
$ACLApps.SetAccessRuleProtection($True, $True)
$ARApps = New-Object System.Security.AccessControl.FileSystemAccessRule("TS Users","Modify,DeleteSubDirectoriesAndFiles","ContainerInherit,ObjectInherit","None","Allow")
$ACLApps.AddAccessRule($ARApps)       
Set-ACL "E:\Apps$\" $ACLApps

#Set ACL for Gemensam$
$ACLGemensam = Get-Acl "E:\Gemensam$" 
$ACLGemensam.SetAccessRuleProtection($True, $True)
$ARGemensam = New-Object System.Security.AccessControl.FileSystemAccessRule("TS Users","Modify,DeleteSubDirectoriesAndFiles","ContainerInherit,ObjectInherit","None","Allow")
$ACLGemensam.AddAccessRule($ARGemensam)       
Set-ACL "E:\Gemensam$\" $ACLGemensam

#Set ACL for Ledning$
$ACLLedning = Get-Acl "E:\Ledning$" 
$ACLLedning.SetAccessRuleProtection($True, $True)
$ARLedning = New-Object System.Security.AccessControl.FileSystemAccessRule("Ledning","Modify,DeleteSubDirectoriesAndFiles","ContainerInherit,ObjectInherit","None","Allow")
$ACLLedning.AddAccessRule($ARLedning)      
Set-ACL "E:\Ledning$\" $ACLLedning

#Set ACL for Ekonomi$
$ACLEkonomi = Get-Acl "E:\Ekonomi$" 
$ACLEkonomi.SetAccessRuleProtection($True, $True)
$AREkonomi = New-Object System.Security.AccessControl.FileSystemAccessRule("Ekonomi","Modify,DeleteSubDirectoriesAndFiles","ContainerInherit,ObjectInherit","None","Allow")
$ACLEkonomi.AddAccessRule($AREkonomi)      
Set-ACL "E:\Ekonomi$\" $ACLEkonomi

#Set ACL for Users$
$ACLUsers = Get-Acl "E:\Users$" 
$ACLUsers.SetAccessRuleProtection($True, $True)
$ARUsers = New-Object System.Security.AccessControl.FileSystemAccessRule("TS Users","ReadAndExecute,ListDirectory,CreateDirectories,CreateFiles,Traverse","Allow")
$ACLUsers.AddAccessRule($ARUsers)      
Set-ACL "E:\Users$\" $ACLUsers

#Set ACL for Userprofiles$
$ACLUserprofiles = Get-Acl "E:\Userprofiles$" 
$ACLUserprofiles.SetAccessRuleProtection($True, $True)
$ARUserprofiles = New-Object System.Security.AccessControl.FileSystemAccessRule("TS Users","ReadAndExecute,ListDirectory,CreateDirectories,CreateFiles,Traverse","Allow")
$ACLUserprofiles.AddAccessRule($ARUserprofiles)      
Set-ACL "E:\Userprofiles$\" $ACLUserprofiles




#$ACL = $Apps.GetAccessControl('Access')
$TSUsers = Get-ADGroup "TS Users"
$Gemensam = Get-ADGroup "Gemensam"
$Ekonomi = Get-ADGroup "Ekonomi"
$Ledning = Get-ADGroup "Ledning"


<# This part is a work in Progress...

$HomeFolders = Get-ChildItem E:\Userprofiles -Directory
foreach ($HomeFolder in $HomeFolders) {
    $Path = $HomeFolder.FullName
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $HomeFolder.Name
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl
}

#>