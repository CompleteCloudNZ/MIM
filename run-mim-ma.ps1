if ( (Get-PSSnapin -Name FIMAutomation -ErrorAction SilentlyContinue) -eq $null ) { Add-PsSnapin FIMAutomation } 
$ProfilesAllowed = @("FULL IMPORT","FULL SYNCHRONISATION","DELTA IMPORT","DELTA SYNC","EXPORT")

function Check-IfMAisRunning ()
{
     $MIMHistory = get-wmiobject -Class 'MIIS_RunHistory' -namespace “root\MicrosoftIdentityIntegrationServer”
     [bool]$MaRunning = $false
 
     foreach ($object in $MIMHistory)
     {
         if ($object.RunStatus -eq "in-progress" -or $object.RunStatus -eq "stopping" ) 
         {
         $MaRunning = $true
         Break
         }
     }

     return $MaRunning
}

function Launch-ManagementAgent ()
{
     param(
     [parameter(mandatory=$true)]
     [string]$AskedManagementAgent,
 
     [parameter(mandatory=$true)]
     [string]$Profile
     )

     # Check if no MA is currently running - Otherwise, we break
     $isMARunning = Check-IfMAisRunning
     if ($isMARunning -eq $true)
     {
         Write-Host "[ERROR] - One MA is currently running - Please wait every MA are stopped before trying to launch another - Exiting"
         Break
     }
 
     # Check if the Profil requested exist - Otherwise, we break
     $isThisProfileExist = $ProfilesAllowed.Contains($Profile)
     if ($isThisProfileExist -ne $true) 
     {
         Write-Host "[ERROR] - Only the following Profiles are supported : FULL IMPORT, FULL SYNCRONISATION, DELTA IMPORT, DELTA SYNC, EXPORT"
         Break
     }

     # Getting the object MA requested
     $MA = get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername HSCVSMIM01 | where { $_.Name -eq $AskedManagementAgent }

     # Check if Management Agent exist
     if (!$MA)
     {
         Write-Host "[ERROR] - The Management Agent you request does not exist in MIM ! - Exiting"
         Break
     }

 # If all the previous requirements are respected and the script hasn't been break
 # We can lauch our Management Agent with requested Profile
 
     try
     {
         # Launching the Management Agent with the Action Required
         $dateStart = date
         Write-Host ("[DEBUG] - Starting " + $Profile + " for : " + $MA.Name)
         $tempResult = $MA.Execute($Profile) # Execute Management Agent with Requested Profile Type
         $dateEnd = date
         $duration = $dateEnd - $dateStart # Get the duration
         Write-Host ("[DEBUG] - Ending " + $Profile + " for : " + $MA.Name + " - Status : " + $tempResult.ReturnValue + " - Duration : " + $Duration)
     }

     catch
     {
         # Problem : displaying the Exception and Breaking the execution
         Write-Host $($_.Exception.Message)
         Break
     }

     return $ExecutionResult = @{
     'MAName' = $MA.Name
     'Type' = $MA.Type
     'ReturnValue' = $tempResult.ReturnValue;
     'Profile' = $Profile;
     'dateStart' = $dateStart;
     'dateEnd' = $dateEnd; 
     'Duration' = $duration;
     }
}


Launch-ManagementAgent -AskedManagementAgent "CSV" -Profile "FULL IMPORT"
Launch-ManagementAgent -AskedManagementAgent "CSV" -Profile "FULL SYNCHRONISATION"
Launch-ManagementAgent -AskedManagementAgent "MIM" -Profile "FULL IMPORT"
Launch-ManagementAgent -AskedManagementAgent "MIM" -Profile "FULL SYNCHRONISATION"
Launch-ManagementAgent -AskedManagementAgent "MIM" -Profile "EXPORT"
Launch-ManagementAgent -AskedManagementAgent "MIM" -Profile "DELTA IMPORT"
Launch-ManagementAgent -AskedManagementAgent "ADMA" -Profile "FULL IMPORT"
Launch-ManagementAgent -AskedManagementAgent "ADMA" -Profile "FULL SYNCHRONISATION"
Launch-ManagementAgent -AskedManagementAgent "ADMA" -Profile "EXPORT"
Launch-ManagementAgent -AskedManagementAgent "ADMA" -Profile "DELTA IMPORT"

