<# Created by Andrew Harkins
    Script to get all Azure Admin Roles and their members.
#>

# Install packages if needed:
#Install-Module Microsoft.Graph -Scope CurrentUser

# Connects to Microsoft Account on Web
Connect-MgGraph -Scopes "RoleManagement.Read.Directory","Directory.Read.All"

$roles = Get-MgDirectoryRole

# loops through each role and spits out each admin for it
foreach ($role in $roles) {
    Write-Host "`nRole:" $role.DisplayName -ForegroundColor Cyan
    
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
    
    foreach ($member in $members) {
        
        switch ($member.AdditionalProperties.'@odata.type') {

            "#microsoft.graph.user" {
                $user = Get-MgUser -UserId $member.Id
                [PSCustomObject]@{
                    Role = $role.DisplayName
                    Type = "User"
                    DisplayName = $user.DisplayName
                    UserPrincipalName = $user.UserPrincipalName
                }
            }

            "#microsoft.graph.servicePrincipal" {
                $sp = Get-MgServicePrincipal -ServicePrincipalId $member.Id
                [PSCustomObject]@{
                    Role = $role.DisplayName
                    Type = "ServicePrincipal"
                    DisplayName = $sp.DisplayName
                    UserPrincipalName = "N/A"
                }
            }

            "#microsoft.graph.group" {
                $group = Get-MgGroup -GroupId $member.Id
                [PSCustomObject]@{
                    Role = $role.DisplayName
                    Type = "Group"
                    DisplayName = $group.DisplayName
                    UserPrincipalName = "N/A"
                }
            }
        }
    }
}