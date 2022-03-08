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
    -Error Checking
    -input validation
    -Command help
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
        [PSDefaultValue(Help = 100)]
        $Resolution = 100,
        [PSDefaultValue(Help = 50)]
        $Range = 50,
        [PSDefaultValue(Help = 'C:\Radio_Mobile\Geodata\strm3\')]
        [string]$SRTMPath = "C:\Radio_Mobile\Geodata\strm3\",
        [PSDefaultValue(Help = 'C:\Radio_Mobile\rmweng.exe')]
        [string]$RMPath = "C:\Radio_Mobile\rmweng.exe",
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
        Level = 'Optimistic'
        Value = $BaseGain + 5
        Colour = "00ff00" #Green
    }

    [PSCustomObject]@{
        Level = 'Baseline'
        Value = $BaseGain
        Colour = "0000ff" #Blue
    }

    [PSCustomObject]@{
        Level = 'Realistic'
        Value = $BaseGain - 5
        Colour = "ff8000" #Orange
    }
    
    [PSCustomObject]@{
        Level = 'Pessimistic'
        Value = $BaseGain - 10
        Colour = "ff0000" #Red
    }
)

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
    
    New-Object  -TypeName PSCustomObject -Property $Record | Export-Csv -Delimiter "`t" -Path "$WorkingFolder$JobName.txt" -Append -usequotes never
}
ForEach($Gain in $GainLevels){
Start-Process -FilePath $RMPath -WorkingDirectory "C:\Radio_Mobile\" -ArgumentList "$TXTPath"
}

} 
