# Gets the info required for the DLP waiver at lease in the AF and USSF

Get-PnpDevice -class CDROM -PresentOnly  -ErrorAction SilentlyContinue| Select-Object InstanceID,"Blank1","Blank2","Blank3",FriendlyName | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation | Select-Object -Skip 1
Get-PnpDevice -class DiskDrive -PresentOnly -ErrorAction SilentlyContinue| Select-Object InstanceID,"Blank1","Blank2","Blank3",FriendlyName | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation | Select-Object -Skip 1

$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.Filter = "(samaccountname=$env:USERNAME)"
$user = $searcher.FindOne()
$user.Properties["givenname"]
$user.Properties["sn"]
$user.Properties["mail"]
$user.Properties["employeeid"]
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer, Model
Get-CimInstance -ClassName Win32_CDROMDrive | Select-Object Manufacturer, Model
Get-CimInstance -ClassName Win32_DiskDrive | Select-Object Manufacturer, Model
