#----------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://server:5725/resourcemanagementservice' "
 set-variable -name ADMINGUID -value "7fb2b853-24f0-4498-9534-4e10589723c4"
 set-variable -name SYNCGUID -value "fb89aefa-5ea1-47f1-8890-abe7797d6497"
#----------------------------------------------------------------------------------------------------------
 function DeleteObject
 {
    PARAM($transfer)
    END
    {
        $obj = @()

        foreach($objectId in $transfer)
        {
               $importObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
               $importObject.ObjectType = "Person"
               $importObject.TargetObjectIdentifier = $objectId
               $importObject.SourceObjectIdentifier = $objectId
               $importObject.State = 2 
               $obj += $importObject
        }
       $obj | Import-FIMConfig -uri $URI
     } 
 }
#----------------------------------------------------------------------------------------------------------
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $allobjects = export-fimconfig -uri $URI `
                                –onlyBaseResources `
                                -customconfig "/Person"

$transfer = @()

 $allobjects | Foreach-Object {
    $objectID = (($_.ResourceManagementObject.ObjectIdentifier).split(":"))[2]
    if($objectID -eq $ADMINGUID)
    {
        write-host "Administrator NOT deleted"
        $_ |fl
    }
    elseif($objectID -eq $SYNCGUID)
    {write-host "Built-in Synchronization Account NOT deleted"}
    elseif($objectID -eq "4ea0abb3-f7ae-4489-8798-7a73a9d143f4")
    {write-host "Not deleteing"}
    else { 
      $transfer += $objectID
 }

 DeleteObject -transfer $transfer