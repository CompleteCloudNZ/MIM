# CSV file that has the criterias
$Criterias = Import-Csv ".\Custom-Expression.csv"

# Name of the source attribute
$AttrName = "Campus"

# CSV Column header names
$CSVColumn1Name = "company"
$CSVColumn2Name = "path"

# Default value if none of the criteria's are met
$defaultValue = ""

$CustomExp = ""

Function Global:GenerateCustomExp($values) {
    if ($values.Length -le 0) {
        return "`"$defaultValue`""
        write-host "end Reached!"
    }
    $condition = $values[0].$CSVColumn1Name
    $value = $values[0].$CSVColumn2Name
    $newvalues = $values[1..$values.length]
    $innerExpression = GenerateCustomExp $newvalues
    #write-host "IIF(Eq($AttrName,`"$condition`"),`"$value`",$innerExpression)"
    return "IIF(Eq($AttrName,`"$condition`"),`"$value`",$innerExpression)"
    
}

# Generate the Custom Expression
$EndExpression = GenerateCustomExp $Criterias

# Print the final Custom Expression
Write-Host -ForegroundColor Green $EndExpression 