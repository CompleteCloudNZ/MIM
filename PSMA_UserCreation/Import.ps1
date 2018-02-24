param (
      $Username,
      $Password,
      $Credentials,
      $OperationType,
      $UsePagedImport,
      $PageSize

    )

$DebugFilePath = "D:\PSMA_UserCreation\ImportDebug.txt"

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
	    $obj = @{}

        $obj.Add("UserGUID", $user.EmployeeCode)
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
        $obj.Add("StartDate", $user.StartDate)
        $obj.Add("EndDate", $user.EndDate)
        if($user.StartDate.Length -gt 0)
        {
            if((Get-Date) -lt (Get-Date $user.StartDate))
            {
                $adUser = get-adobject -Filter {employeenumber -eq "$user.EmployeeCode" }
                if($adUser.DistinguishedName.Length -gt 0) { $obj.Add("userUpdate",$true) }
                else { $obj.Add("userUpdate",$false) }
                Write-Host $obj['userUpdate']
            }
            else
            {
                $obj.Add("userUpdate",$true)           
            }
        } 
        else
        {
            $obj.Add("userUpdate",$true)           
        }
        $obj 
}
