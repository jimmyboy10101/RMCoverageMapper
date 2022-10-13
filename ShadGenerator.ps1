<# 
.SYNOPSIS
    This function is intended for use with Radio Mobile to create batch files to generate coverage maps. 
.DESCRIPTION
    Mandatory Fields 
    Long
    Lat
    WorkingFolder
    JobName

    Optional Fields
    BaseGain - Default 171 approx for 20w repeater to vehicle)
    RepeaterAntennaHeight - Default 12
    MobileAntennaHeight - Default 2
    Freq - Default 174 (VHF)
    Resolution - 100 ( 1 Pixels per n meters, Lower number eq more detailed)
    Range - 50 (range 50km)
    SRTMPath = "C:\Radio_Mobile\Geodata\strm3\" Location of SRTM Data

    Required Improvements
    -Work on building Automation 
.Notes
    Author: Jim Catelli
    Creation date: 08/03/2021
#>



function Invoke-RMShadGenerator {
    [CmdletBinding()]
    param (

        [PSDefaultValue(Help = 171)]
        $BaseGain = 171,
        [PSDefaultValue(Help = 12)]
        $RepeaterAntennaHeight = 12,
        [PSDefaultValue(Help = 2)]
        $MobileAntennaHeight = 2,
        [PSDefaultValue(Help = 174)]
        $Freq = 174,
        [PSDefaultValue(Help = 200)]
        $Resolution = 200,
        [PSDefaultValue(Help = 50)]
        $Range = 50,
        [PSDefaultValue(Help = 'C:\Radio_Mobile\Geodata\strm3\')]
        [string]$SRTMPath = "C:\Radio_Mobile\Geodata\strm3\",
        [PSDefaultValue(Help = 'C:\Radio_Mobile\rmweng.exe')]
        [string]$RMPath = "C:\Radio_Mobile\rmweng.exe",
        [PSDefaultValue(Help = 'False')]
        [string]$Optomistic = "False",
    [Parameter(Mandatory)]
        [string]$JobName,
    [Parameter(Mandatory)]
        [string]$WorkingFolder,
    [Parameter(Mandatory)]
        $Long,
    [Parameter(Mandatory)]
        $Lat
    )

    $GainLevels = @(

        [PSCustomObject]@{
            Level = '-Vehicle-Baseline'
            Value = $BaseGain
            Colour = "00ffff" #Yellow
        }
    
        [PSCustomObject]@{
            Level = '-Vehicle-Realistic'
            Value = $BaseGain - 5
            Colour = "0080ff" #Orange
        }
        
        [PSCustomObject]@{
            Level = '-Handheld'
            Value = $BaseGain - 10
            Colour = "0000ff" #Red
        }
    )
    
    if ($Optomistic -eq "True") {
    
    $GainLevels +=@( 
        
        [PSCustomObject]@{
        Level = '-Optimistic'
        Value = $BaseGain + 5
        Colour = "008000" #Pale Green
        }
    )
    }

$TXTPath = "$WorkingFolder$JobName.txt"

ForEach($Gain in $GainLevels){

        
$Record = [ordered] @{
    PictureFile = $WorkingFolder + $JobName + $Gain.Level +'.png'
    SystemGain = $Gain.Value
    AntennaFile = 'omni.ant'
    AntennaAzimuth = 0
    AntennaTilt = 0
    RepeaterAntennaHeight = $RepeaterAntennaHeight
    ElevationASL = 0
    MobileAntennaHeight = $MobileAntennaHeight
    Frequency = $Freq
    Latitude = $Lat
    Longitude = $Long
    MapResolution = $Resolution
    MaximumRange = $Range
    Colour = $Gain.Colour
    SRTMPath =  $SRTMPath
    LandcoverPath = ''
    TXPwr4SigFile = 0
    LandHeightDat = ''
    PercentageVariability = 100
    }
    
    New-Object  -TypeName PSCustomObject -Property $Record | Export-Csv -Delimiter "`t" -Path "$WorkingFolder$JobName.txt" -Append -NoTypeInformation
    
    #New-Object  -TypeName PSCustomObject -Property $Record | ConvertTo-Csv -notypeinformation -Delimiter "`t" | % {$_ -replace '"',''} | Out-File   -Path "$WorkingFolder$JobName.txt" -Append 
}
$OutputCSV = Get-Content "$WorkingFolder$JobName.txt"
$OutputCSV |  % {$_ -replace '"',''} | Out-File "$WorkingFolder$JobName.txt" -Force -Confirm:$false -Encoding utf8



ForEach($Gain in $GainLevels){
Start-Process -FilePath $RMPath -WorkingDirectory "C:\Radio_Mobile\" -ArgumentList "$TXTPath"
}

#KML Generator.

$KML = @"
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Placemark>
    <name>$JobName</name>
    <description>$JobName Repeater Located at $Long,$Lat</description>
    <Point>
      <coordinates>$Long,$Lat,0</coordinates>
    </Point>
  </Placemark>
</kml>
"@

New-Item  $WorkingFolder$JobName.kml
Set-Content -Path $WorkingFolder$JobName.kml -Value $KML

} 


Invoke-RMShadGenerator -WorkingFolder C:\local\ -Long $Longitude -Lat $Latitude -JobName $Job

Remove-Item .\ -Include "*$Jobname*" -Exclude "*.png, *.kml"
