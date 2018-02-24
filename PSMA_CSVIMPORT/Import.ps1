param (
      $Username,
      $Password,
      $Credentials,
      $OperationType,
      $UsePagedImport,
      $PageSize

    )

$DebugFilePath = "D:\PSMA_CSVIMPORT\out.txt"

if(!(Test-Path $DebugFilePath))
    {
        $DebugFile = New-Item -Path $DebugFilePath -ItemType File
    }
    else
    {
        $DebugFile = Get-Item -Path $DebugFilePath
    }
    
    "Starting of Import Script : " + $OperationType + " " + (Get-Date) | Out-File $DebugFile -Append


if ( (Get-PSSnapin -Name FIMAutomation -ErrorAction SilentlyContinue) -eq $null ) { Add-PsSnapin FIMAutomation } 
Import-Module ActiveDirectory

$users = Import-Csv D:\Payroll_Export\Active-Directory.csv
"Number of users in export file is " + $users.Count |Out-File -FilePath $DebugFile -Append

foreach($user in $users)
{    
    # we need to update the managers as we go.
    $mid = $user.ManagerID
    $uid = $user.EmployeeID
   
    if($mid.Length -ne 0)
    {
        $manager = Get-ADUser -Filter {EmployeeID -eq $mid} -ErrorAction SilentlyContinue
        Get-ADUser -Filter {EmployeeID -eq $uid} | Set-ADUser -Manager $manager.samAccountName
    }
    # set the right end date
    $startDate = Get-Date $user.startDate -Format s

    $ed = $user.EndDate.ToString()
    if($ed.Length -ne 0)
    {
        $ed=(Get-Date $ed).AddDays(1)
        $leaver = Get-ADUser -Filter {EmployeeId -eq $uid} 
        if($leaver.DistinguishedName.toString().Length -gt 5)
        {
          "The leaver who leaves " + $empEndDate + "still has an AD account : " + $leaver.DistinguishedName |Out-File -FilePath $DebugFile -Append
          $leaver |Set-ADAccountExpiration -DateTime $ed |Out-File -FilePath $DebugFile -Append
        }
    }
    else
    {
        # Generate account name
        $accountName = (Get-ADUser -Filter {EmployeeID -eq $uid}).samAccountName
        $empEndDate = (Get-Date $ed -Format s)

        if($accountName.Length -gt 0)
        {
            $obj = @{}
  
            $obj.Add("EmployeeID", $user.EmployeeID)
            $obj.Add("objectClass", "user")
            $obj.Add("FirstName", $user.FirstName)
            $obj.Add("LastName", $user.LastName)
            $obj.Add("EmployeeCode", $user.EmployeeCode)
            $obj.Add("JobDescription", $user.JobDescription)
            $obj.Add("CompanyName", $user.CompanyName)
            $obj.Add("Department", $user.Department)
            $obj.Add("OfficeName", $user.OfficeName)
            $obj.Add("OfficeStreetAddress", $user.OfficeStreetAddress)
            $obj.Add("OfficePOBox", $user.OfficePOBox)
            $obj.Add("OfficePostCode", $user.OfficePostCode)
            $obj.Add("TelephoneNumber", $user.TelephoneNumber)
            $obj.Add("Fax", $user.Fax)
            $obj.Add("email", $user.email)
            $obj.Add("Manager", $user.Manager)
            $obj.Add("ManagerID", $mid)
            $obj.Add("StartDate", $StartDate)
            $obj.Add("EndDate", $empEndDate)
            $obj.Add("accountName", $accountName)

            $obj   
        }
    }
}
