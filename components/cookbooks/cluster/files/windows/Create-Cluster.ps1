param(
    [parameter(Mandatory=$true)]
    [string]$cluster_name,
    [parameter(Mandatory=$true)]
    [string]$node,
    [parameter(Mandatory=$true)]
    [string]$static_ip,
    [parameter(Mandatory=$true)]
    [string]$ou
)

$nodes = new-object System.Collections.Specialized.StringCollection
foreach ($n in ($node -split ",")) { $nodes.add($n) }

$static_ips = new-object System.Collections.Specialized.StringCollection
foreach ($ip in ($static_ip -split ",")) { $static_ips.add($ip) }

New-Cluster -Name $cluster_name -Node $nodes -StaticAddress $static_ips -NoStorage

$domain = (gwmi win32_computersystem).Domain
$oupath = "OU=$ou"
foreach ($item in $domain.Split('.')) { $oupath += ",DC=$item" }
$LDAPName = "LDAP://CN=$cluster_name,$oupath"

#Cluster Object Permissions
$ADSI = [ADSI]$LDAPName
$ActiveDirectoryRights = [System.DirectoryServices.ActiveDirectoryRights]"GenericAll"
$AccessControlType = [System.Security.AccessControl.AccessControlType]"Allow"

#Granting permissions to access cluster AD object to all nodes 
foreach ($DnsName in ($node -split ",")) 
{
  $FullName = "CN=$($DnsName.Split('.')[0]),$oupath"
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
