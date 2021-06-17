Param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true, Position=0, HelpMessage="oneagentctl command to run")][String[]] $oneagentParamList
)

# HashSet to remove duplicates from the Host list
$hostSet = [System.Collections.Generic.HashSet[String]]@()
$hostFile = '.\example_hosts.txt'
foreach ($line in Get-Content $hostFile) {
    $hostSet.add($line) | Out-Null
}

$oneagentctl = "$($env:Programfiles)\dynatrace\oneagent\agent\tools\oneagentctl"
$oneagentParams = $oneagentParamList -Join ' '
# & + Invoke-Expression required to handle multiple paramas + spaces in the path
# & "C:\Program Files\dynatrace\oneagent\agent\tools\oneagentctl" --get-host-tags
$oneagentCmd = "& `"$oneagentctl`" $oneagentParams"

$oneagentctlResults = @()

Write-Host -ForegroundColor Green "COMMAND:"
Write-Host $oneagentCmd

Write-Host -ForegroundColor Green "`nHOST LIST"
Write-Host $hostSet

# Set will fail with 'One or more computer name are not valid. - All or Nothing
# Array will try seperately for each host: failing hosts will be displayed with Output = {} and Error = {}
$hostArray = New-Object string[] $hostSet.Count
$hostSet.CopyTo($hostArray)

# Remotely run oneagentctl on each host in our list
$j = Invoke-Command -ComputerName $hostArray -ScriptBlock {
    Invoke-Expression $using:oneagentCmd
} -AsJob

# Wait for all remote jobs to finish and then receive the results
$j.ChildJobs | Wait-Job | Out-Null

foreach ($job in $j.ChildJobs) {
    $location = $job.Location
    $command = $job.Command
    $jobError = $job.Error
    $output = $job.Output

    try { 
        $output = Receive-Job -Job $job -ErrorAction Stop
    } catch { 
        # Supress Exception - We are logging it in results
    }

    if ($jobError) {
        $jobError = $job.Error.Exception.Message
    }

    if (-Not $jobError -And -Not $output) {
        # Host connection failed so update the error
        $jobError = "Invoke-Command: Could not connect to Host $location"
    }

    $oneagentctlResults += @{Host=$location; Output=$output; Error=$jobError; Command=$command}
}

Write-Host -ForegroundColor Green "`nRESULT"
$oneagentctlResults | ForEach-Object {[PSCustomObject]$_} | Format-Table Host, Output, Error -AutoSize