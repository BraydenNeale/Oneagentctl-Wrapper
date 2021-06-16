Param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true, Position=0, HelpMessage="oneagentctl command to run")][String[]] $oneagentParamList
)

<#
Oneagentctl Commands to Wrap:
https://www.dynatrace.com/support/help/setup-and-configuration/dynatrace-oneagent/oneagent-configuration-via-command-line-interface/

Default path = %PROGRAMFILES%\dynatrace\oneagent\agent\tools\oneagentctl

HOST GROUP
./oneagentctl --set-host-group=MyHostGroup

PROPERTIES
./oneagentctl --set-host-property=AppName --set-host-property=Environment=Dev

TAGS
./oneagentctl --set-host-tag=TestHost --set-host-tag=role=fallback

FULL STACK
./oneagentctl --set-infra-only=false

RESTART AGENT SERVICE
./oneagentctl --restart-service

NETWORK ZONE
./oneagentctl --set-network-zone=<your.network.zone>

PROXY
./oneagentctl --set-proxy=my-proxy.com

GET EVERYTHING
./oneagentctl --get-server --get-tenant -get-tenant-token --get-proxy --get-watchdog-portrange --get-auto-update-enabled --get-app-log-content-access
--get -system-logs-access-enabled --get-host-id --get-host-id-source --get-host-group --get-host-name --get-host-properties --get-host-tags --get-infra-only
--get-auto-injection-enabled --get-extensions-ingest-port --get-extensions-statsd-port --get-network-zone

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
    $location = $job.Location.toString()
    $command = $job.Command.toString()
    $output = Receive-Job -Job $job
    $oneagentctlResults += @{Host="$location"; Output="$output"; Command="$command"}
}

Write-Host -ForegroundColor Green "`nRESULT"
$oneagentctlResults | ForEach-Object {[PSCustomObject]$_} | Format-Table Host, Output -AutoSize