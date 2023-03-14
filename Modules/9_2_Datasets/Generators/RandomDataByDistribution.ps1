$sexPropabilityDefinition = @{
    "male" = 52
    "female" = 48
}

$sexLookup = foreach ($entry in $sexPropabilityDefinition.GetEnumerator()) { 
    [System.Linq.Enumerable]::Repeat($entry.Key, $entry.Value)
}


$ethnicityPropabilityDefinition = @{
    "white" = 90
    "black" = 6
    "hispanic" = 2
    "asian/indian" = 1
    "multiracial" = 1
}

$ethnicityLookup = foreach ($entry in $ethnicityPropabilityDefinition.GetEnumerator()) { 
    [System.Linq.Enumerable]::Repeat($entry.Key, $entry.Value)
}

$ageGroupPropabilityDefinition = @{
    "teenager" = 29
    "adult" = 71
}

$ageGroupLookup = foreach ($entry in $ageGroupPropabilityDefinition.GetEnumerator()) { 
    [System.Linq.Enumerable]::Repeat($entry.Key, $entry.Value)
}

$bodyShapePropabilityDefinition = @{
    "slim" = 41
    "heavy" = 16
    "normal" = 38
    "muscular" = 5  
    
}

$bodyShapeLookup = foreach ($entry in $bodyShapePropabilityDefinition.GetEnumerator()) { 
    [System.Linq.Enumerable]::Repeat($entry.Key, $entry.Value)
}

$partnerPropabilityDefinition = @{
    "yes" = 62
    "no" = 38
}

$partnerLookup = foreach ($entry in $partnerPropabilityDefinition.GetEnumerator()) { 
    [System.Linq.Enumerable]::Repeat($entry.Key, $entry.Value)
}


# Build the datatable
$datasetDT = New-Object System.Data.DataTable
$datasetDT.Columns.Add("sex")
$datasetDT.Columns.Add("ethnicity")
$datasetDT.Columns.Add("agegroup")
$datasetDT.Columns.Add("bodyshape")
$datasetDT.Columns.Add("partner")

# Set the number of rows we want to generate
$rowCount = 1000

for ($i=1; $i -le $rowCount; $i++)
{

    # Generate the sex value
    $randomSex = Get-Random -Minimum 0 -Maximum $sexLookup.Count

    # Generate ethnicity
    $randomEthnicity = Get-Random -Minimum 0 -Maximum $ethnicityLookup.Count

    # Generate age group
    $randomAgeGroup = Get-Random -Minimum 0 -Maximum $ageGroupLookup.Count

    # Generate body shape
    $randomBodyShape = Get-Random -Minimum 0 -Maximum $bodyShapeLookup.Count

    # Generate partner
    $randomPartner = Get-Random -Minimum 0 -Maximum $partnerLookup.Count

    $newRow = $datasetDT.NewRow()
    $newRow.sex = $sexLookup[$randomSex]
    $newRow.ethnicity = $ethnicityLookup[$randomEthnicity]
    $newRow.agegroup = $ageGroupLookup[$randomAgeGroup]
    $newRow.bodyshape = $bodyShapeLookup[$randomBodyShape]
    $newRow.partner = $partnerLookup[$randomPartner]

    $datasetDT.Rows.Add($newRow)

}

# Return the generated datatable
$datasetDT | Format-Table

# Export the datatable to CSV
# $datasetDT | Export-Csv C:\Temp\horror_dataset.csv -NoTypeInformation


#### percentage values for dieing

# Male: 44%
# Female: 33%

# white: 40%
# black: 43%
# Hispanic: 50%
# Asian/Indian: 8%
# Multiracial: 65%

# adult: 50%
# teenager: 70%

# slim: 60%
# heavy: 50%
# normal: 40%
# muscular: 50%

# have a partner: 77%

<#
for instance, white adult male with normal body type and a partner


           100 people walk into the horror bar
         56  male         
     33  white
    16 adult
    10 normal
    2 partner
    2 people survive of the 100
#>
