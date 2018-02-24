param (
      $Username,
      $Password,
      $Credentials,
      $OperationType,
      $UsePagedImport,
      $PageSize

    )

$DebugFilePath = "D:\PSMA_UserCreation\ImportDebug.txt"
$M3User = @{}

$users = Import-Csv D:\Payroll_Export\Active-Directory.csv
$perposition = Import-Csv D:\Payroll_Export\M3Matrix_perposition.csv
$percompanydivision = Import-Csv D:\Payroll_Export\M3Matrix_percompanydivision.csv
$perpositionperrole = Import-Csv D:\Payroll_Export\M3Matrix_perpositionperrole.csv
$warehousefacility = Import-Csv D:\Payroll_Export\M3Matrix_warehousefacility.csv

foreach($user in $users)
{
    if(!$user.Company -or !$user.Department)
    {
    }
    else
    {
        $wcJobDescription = "*"+$user.CompanyName+"*"
        
        $companies = $percompanydivision |where {$_.Company -eq $user.Company -and $_.Departments -like $wcJobDescription}
        $jobPosition = $perposition |where {$_.'Position/Description' -eq $user.JobDescription}
        $positionrole = $perpositionperrole |where {$_.'Position/Description' -eq $user.Position}
        $warehouse = $warehousefacility |where {$_.Location -eq $user.Department}
        if($warehouse -and $companies -and $jobPosition -and $positionrole)
        {
            $user
        }
        else
        {
            # Write-Host "Match NOT found for "+$username
        }
    }
}

