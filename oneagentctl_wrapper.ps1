Param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true, Position=0, HelpMessage="oneagentctl command to run")][String[]] $oneagentParamList
)

<#
Oneagentctl Commands to Wrap:
https://www.dynatrace.com/support/help/setup-and-configuration/dynatrace-oneagent/oneagent-configuration-via-command-line-interface/

Default path = %PROGRAMFILES%\dynatrace\oneagent\agent\tools\oneagentctl

*** SETTERS *** 

HOST GROUP
.\oneagentctl --set-host-group=MyHostGroup
.\oneagentctl --get-host-group

PROPERTIES
.\oneagentctl --set-host-property=AppName --set-host-property=Environment=Dev
.\oneagentctl --get-host-properties 

TAGS
.\oneagentctl --set-host-tag=TestHost --set-host-tag=role=fallback
.\oneagentctl --get-host-tags

FULL STACK
.\oneagentctl --set-infra-only=false
.\oneagentctl --get-infra-only

NETWORK ZONE
.\oneagentctl --set-network-zone=<your.network.zone>
.\oneagentctl --get-network-zone
PROXY
.\oneagentctl --set-proxy=my-proxy.com
.\oneagentctl --get-proxy

RESTART AGENT SERVICE
.\oneagentctl --restart-service
#>

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
    } catch { "err $_" }

    if ($jobError) {
        $jobError = $job.Error.Exception.Message
    }

    $oneagentctlResults += @{Host=$location; Output=$output; Error=$jobError; Command=$command}
    Write-Host $thiserror
}

Write-Host -ForegroundColor Green "`nRESULT"
$oneagentctlResults | ForEach-Object {[PSCustomObject]$_} | Format-Table Host, Output, Error -AutoSize