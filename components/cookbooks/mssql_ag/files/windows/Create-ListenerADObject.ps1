param(
    [parameter(Mandatory=$true)]
    [string]$listener_name,
    [parameter(Mandatory=$true)]
    [string]$cluster_name,
    [parameter(Mandatory=$true)]
    [string]$node,
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

if (!$ad_exists) 
  {New-ADComputer -Name $listener_name -Enabled $False -Path $oupath}


#Listener Object Permissions
$LDAPName = "LDAP://CN=$listener_name,$oupath"
$ADSI = [ADSI]$LDAPName
$ActiveDirectoryRights = [System.DirectoryServices.ActiveDirectoryRights]"GenericAll"
$AccessControlType = [System.Security.AccessControl.AccessControlType]"Allow"

#Granting permissions to access cluster AD object to all nodes and the cluster object
$nodes = ($node -split ',')
$ADobjects = $nodes += $cluster_name
foreach ($item in $ADobjects) 
{ 
  $FullName = "CN=$item,$oupath"
  $objAD = Get-ADComputer $FullName

  #Granting permissions to access cluster AD object
  $sid = [System.Security.Principal.SecurityIdentifier]$objAD.SID
  $identity = [System.Security.Principal.IdentityReference]$sid
  $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity,$ActiveDirectoryRights,$AccessControlType)
  $ADSI.psbase.ObjectSecurity.AddAccessRule($ACE)
  $ADSI.psbase.CommitChanges()  

  #Update SPN
  if ($objAD.ServicePrincipalNames -contains "MSServerClusterMgmtAPI/$n")
  { 
    Write-Host "SPN already exists"
    $objAD.ServicePrincipalNames
  }
  else
  {
    Write-Host "Adding SPN..."
    Set-ADComputer $FullName -ServicePrincipalNames @{Add="MSServerClusterMgmtAPI/$n"}
  }

}

