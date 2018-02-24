param (
      $Username,
      $Password,
      $Credentials,
      $OperationType,
      $UsePagedImport,
      $PageSize

    )


#https://blog.msresource.net/2013/10/24/bulk-registration-of-fim-sspr-question-and-answer-gate-qa-gate-answers/#comment-17130
#Record transcript for logging purposes

$users = Invoke-Sqlcmd -query "SELECT * FROM dbo.mms_metaverse WHERE accountName IS NULL" -ServerInstance "server\sqlexpress" -Database "FIMSynchronizationService " -Variable $param 


foreach($user in $users)
{    
    $user

    $obj = @{}
    
    $obj.Add("objectid",$user.object_id.toString())
    $obj.Add("objectClass","user")
    $obj.Add("totaldn","{"+$user.object_id.toString()+"}")

    $obj

}