﻿$obj = New-Object -Type PSCustomObject
$obj | Add-Member -Type NoteProperty -Name "Anchor-EmployeeID|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "objectClass|String" -Value "user"
$obj | Add-Member -Type NoteProperty -Name "FirstName|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "LastName|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "EmployeeCode|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "JobDescription|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "EndDate|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "CompanyName|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "Department|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "OfficeName|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "OfficeStreetAddress|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "OfficePOBox|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "OfficePostCode|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "TelephoneNumber|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "Fax|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "email|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "Manager|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "ManagerID|Reference" -Value ""
$obj | Add-Member -Type NoteProperty -Name "StartDate|String" -Value ""
$obj | Add-Member -Type NoteProperty -Name "accountName|String" -Value ""

$obj