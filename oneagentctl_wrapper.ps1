Param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true, Position=0, HelpMessage="oneagentctl command to run")][String[]] $oneagentParamList
)

$hostSet = [System.Collections.Generic.HashSet[String]]@()
$hostFile = '.\example_hosts.txt'
foreach ($line in Get-Content $hostFile) {
    $hostSet.add($line) | Out-Null
}

$oneagentctl = "$($env:Programfiles)\dynatrace\oneagent\agent\tools\oneagentctl"
$oneagentParams = $oneagentParamList -Join ' '
$oneagentCmd = "& `"$oneagentctl`" $oneagentParams"

$oneagentctlResults = @()

Write-Host -ForegroundColor Green "COMMAND:"
Write-Host $oneagentCmd

Write-Host -ForegroundColor Green "`nHOST LIST"
Write-Host $hostSet

$j = Invoke-Command -ComputerName $hostSet -ScriptBlock {
    Invoke-Expression $using:oneagentCmd
} -AsJob

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

    $oneagentctlResults += @{Host=$location; Output=$output; Error=$jobError; Command=$command}
}

Write-Host -ForegroundColor Green "`nRESULT"
$oneagentctlResults | ForEach-Object {[PSCustomObject]$_} | Format-Table Host, Output, Error -AutoSize