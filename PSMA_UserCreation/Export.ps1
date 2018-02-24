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
   $samAccountName = $fname + $lname.subString(0,1)
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

# $_ | Out-File $DebugFile -Append

$startDate = ($users |where {$_.EmployeeCode -eq $objectGuid}).StartDate
#$_ | Out-File $DebugFile -Append

# only process this if the user actually has a start date. This cuts out a lot of errors discovered with no date problems
if($startDate.Length -ne 0)
{
    $startDate = Get-Date $startDate

    # check to see if the users start date is AFTER the current date. We process them if it is
    if((Get-Date) -lt $startDate)
    { 
        # check to see if the user already exists
        $adUser = get-adobject -Filter {employeenumber -eq $objectGuid }

        if($adUser.DistinguishedName.Length -eq 0) 
        { 

            <# possible options            
            Name
            AccountExpirationDate
            AccountNotDelegated
            AccountPassword
            AllowReversiblePasswordEncryption
            AuthType
            CannotChangePassword
            Certificates
            ChangePasswordAtLogon
            City
            Company
            Country
            Credential
            Department
            Description
            DisplayName
            Division
            EmailAddress
            EmployeeID
            EmployeeNumber
            Enabled
            Fax
            GivenName
            HomeDirectory
            HomeDrive
            HomePage
            HomePhone
            Initials
            Instance
            LogonWorkstations
            Manager
            MobilePhone
            Office
            OfficePhone
            Organization
            OtherAttributes
            OtherName
            PassThru
            PasswordNeverExpires
            PasswordNotRequired
            Path
            POBox
            PostalCode
            ProfilePath
            SamAccountName
            ScriptPath
            Server
            ServicePrincipalNames
            SmartcardLogonRequired
            State
            StreetAddress
            Surname
            Title
            TrustedForDelegation
            Type
            UserPrincipalName
            Confirm
            WhatIf

            #>

            $newUser = $users |where {$_.EmployeeCode -eq $objectGuid}

            "Processing User : " + ($objectGuid) | Out-File $DebugFile -Append
            $username = findUserName $_.FirstName $_.LastName
            "Found Username : " + ($username) | Out-File $DebugFile -Append
            $newUser | Out-File $DebugFile -Append
            New-ADUser $username -OtherAttributes @{employeeNumber=$newUser.EmployeeCode;Title=$newUser.JobDescription;EmployeeID=$newUser.EmployeeID;sn=$newUser.LastName;Givenname=$newUser.FirstName;DisplayName=$newUser.FirstName+" "+$newUser.LastName;UserPrincipalName=$username+"@hynds.co.nz";Description=$newUser.JobDescription}        
            Get-ADObject -Filter {samAccountName -eq $username} |Move-ADObject -TargetPath "OU=MIM Staged,OU=Users,,DC=co,DC=nz"
        }    
    }
}
$obj = @{}
$obj.Add("[Identifier]",$Identifier)
$obj.Add("[ErrorName]","success")
$obj.Add("userUpdate",$true)
$obj


} # END PROCESS HERE

END
{#Writing close tag in debugfile
"Ending Export : " + (Get-Date) | Out-File $DebugFile -Append
}