param(
  [parameter(Mandatory=$true)]
  [string]$ou
)

#Get Cluster name
$name = (Get-Cluster).Name
$domain = (gwmi win32_computersystem).Domain
$DistinguishedName = "CN=$name,OU=$ou"
foreach ($item in $domain.Split('.')) { $DistinguishedName += ",DC=$item" }

#Destroy cluster
Remove-Cluster -Confirm:$false -Force

#Remove AD object
Remove-ADObject $DistinguishedName -Confirm:$false
