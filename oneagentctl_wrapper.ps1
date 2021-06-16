Param(
    [Parameter(Mandatory=$true, HelpMessage="oneagentctl commands to run")][String] $oneagentParams
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
    $hostSet.add($line)
}

$oneagentctl = "$($env:Programfiles)\dynatrace\oneagent\agent\tools\oneagentctl"
$oneagentCmd = "$oneagentctl $oneagentParams"

$oneagentctlResults = @()

write-host "$oneagentCmd"
write-host "$hostSet"

$j = Invoke-Command -ComputerName $hostSet -ScriptBlock {
    & "$using:oneagentctl" "$using:oneagentParams"
} -AsJob

$j.ChildJobs | Wait-Job 

foreach ($job in $j.ChildJobs) {
    $oneagentctlResults += @{Host="$job.Location"; Output="$job.Output"; Command="$job.Command"}
    Write-Host $job.Command
}

$oneagentctlResults | ForEach-Object {[PSCustomObject]$_} | Format-Table Host, Command, Output -AutoSize
# $oneagentctlResults | Format-Table