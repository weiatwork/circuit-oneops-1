param(
    [parameter(Mandatory=$true)]
    [string]$listener_name,
    [parameter(Mandatory=$true)]
    [string]$ou
)

$domain = (gwmi win32_computersystem).Domain
$oupath = "OU=$ou"
foreach ($item in $domain.Split('.')) { $oupath += ",DC=$item" }

#Create AD object if necessary
$ListenerFullName = "CN=$listener_name,$oupath"

$ad_exists = $false
try 
  { Get-ADComputer $ListenerFullName 
    $ad_exists = $true}
catch 
  {write-host "Listener object already exists"}

if ($ad_exists) 
  {Remove-ADObject $ListenerFullName -Confirm:$false}
