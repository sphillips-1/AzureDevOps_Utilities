$personalToken = ""
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalToken)"))
$header = @{authorization = "Basic $token"}

$organization = ""
$project = ""
$buildName = ""

 
#all build definitions
$url = "https://dev.azure.com/$organization/$project/_apis/build/definitions?api-version=6.0-preview.7"
$builddefinitions = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers $header
 
$builddefinitions.value | where {$_.name -eq "$buildName"}|Sort-Object id|ForEach-Object {
 
    #all builds for a definition
    $url = "https://dev.azure.com/$organization/$project/_apis/build/builds?definitions=" + $_.id + "&api-version=6.0-preview.5"
    $builds = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers $header    
    
    
    $builds.value | where {$_.retainedByRelease -eq "True"} | Sort-Object id|ForEach-Object {
        #report on retain status
        Write-Host " BuildId:" $_.id " retainedByRelease:" $_.retainedByRelease

        #api call for a build
        $url = "https://dev.azure.com/$organization/$project/_apis/build/builds/" + $_.id + "?api-version=6.1-preview.7"

        #Get All leases for the current build

        $leaseurl = "https://dev.azure.com/$organization/$project/_apis/build/builds/" + $_.id + "/leases?api-version=6.1-preview.1"
        $result = Invoke-RestMethod -Uri $leaseurl -Method Get -Headers $header
         
        if ($result.count -gt 0){
            $result.value | ForEach-Object {
                $deleteLeaseUrl =  "https://dev.azure.com/$organization/$project/_apis/build/retention/leases?ids=" + $_.leaseId + "&api-version=6.1-preview.2"
                Invoke-RestMethod -Uri $deleteLeaseUrl -Method DELETE -Body "{}"  -ContentType "application/json"  -Headers $header
            }
        }
     

        Invoke-RestMethod -Uri $url -Method Get -Headers $header
        Invoke-RestMethod -Uri $url -Method DELETE  -Headers $header
    }

}
