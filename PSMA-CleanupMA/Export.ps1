param (
    $Username, 
    $Password
    )

BEGIN
{ 
# import the AD module in order
Import-Module ActiveDirectory
$users = Import-Csv D:\Payroll_Export\Active-Directory.csv

$DebugFilePath = "D:\PSMA_UserCreation\DebugMA.txt"

if(!(Test-Path $DebugFilePath))
    {
        $DebugFile = New-Item -Path $DebugFilePath -ItemType File
    }
    else
    {
        $DebugFile = Get-Item -Path $DebugFilePath
    }
    
    "Starting Export : " + (Get-Date) | Out-File $DebugFile -Append
}

# functions here...

PROCESS
{

function findUserName($fname, $lname)
{
   $samAccountName = $fname + $lname.subString(1,1)
   $baseAccountName = $samAccountName
   "samaccountname" + ($samAccountName) | Out-File $DebugFile -Append
   $validuser = $false
   $count = 0

   while(!$validuser)
   {
       $adUser = get-adobject -Filter {samAccountName -eq $samAccountName}

        if($adUser.DistinguishedName.Length -eq 0) 
        { 
            $validuser = $true
        }
        else
        {
            $count++
            $samAccountName = $baseAccountName + $count.ToString()
        }
    }

    return $samAccountName
}

#Initialize Parameters

$Identifier = $_.'[Identifier]'
$objectGuid = $_.'[DN]'
$ErrorName = "success"

$_ | Out-File $DebugFile -Append

$startDate = Get-Date $_.StartDate

# check to see if the users start date is AFTER the current date. We process them if it is
if((Get-Date) -lt $startDate) 
{ 
    # check to see if the user already exists
    $adUser = get-adobject -Filter {employeenumber -eq $objectGuid }

    if($adUser.DistinguishedName.Length -eq 0) 
    { 
        "Processing User : " + ($objectGuid) | Out-File $DebugFile -Append
        $username = findUserName $_.FirstName $_.LastName
        "Found Username : " + ($username) | Out-File $DebugFile -Append
        New-ADUser $username -OtherAttributes @{employeeNumber=$_.EmployeeCode}
    }
}

$obj = @{}
$obj.Add("[Identifier]",$Identifier)
$obj.Add("[ErrorName]",$ErrorName)
if($ErrorName -ne "success")
{
    $obj.Add("[ErrorDetail]", $errordetail)
}
$obj


} # END PROCESS HERE

END
{#Writing close tag in debugfile
"Ending Export : " + (Get-Date) | Out-File $DebugFile -Append
}