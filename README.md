# Oneagentctl - Remote Powershell Wrapper

# Documentation: [Oneagentctl](https://www.dynatrace.com/support/help/setup-and-configuration/dynatrace-oneagent/oneagent-configuration-via-command-line-interface/)

Oneagentctl is an offical Dynatrace utility that comes bundles with the Dynatrace Oneagent.

The default oneagentctl path on Windows is: `%PROGRAMFILES%\dynatrace\oneagent\agent\tools\oneagentctl`.

This script simply wraps `onegentctl` in powershell `Invoke-Command` to run it remotely on a list of hosts.

Refer to the Offical Dynatrace documentation for full details: https://www.dynatrace.com/support/help/shortlink/oneagentctl

# Usage

Run this script exactly how you would normally interact with `oneagentctl`

Define the lists of hosts, seperated by newlines in `hosts.txt`... or ingest the host list in some other way

Note: You can chain --set commands, but not --get commands. 

Note: Most --set commands require the agent to be stopped and started with `--restart-service`

e.g.
- Get the Host Group of the Dynatrace OneAgent<br>
    `.\oneagentctl_wrapper.ps1 --get-host-group`

- Set the Host Group to MY_HOST GROUP, Set the agent mode to Infra-only mode and restart the OneAgent service<br>
    `.\oneagentctl_wrapper.ps1 --set-host-group=MY_HOST_GROUP --set-infra-only=true --restart-service`

| Agent Property | Examples |
| --- | --- |
|HOST GROUP|`.\oneagentctl_wrapper.ps1 --get-host-group`<br>`.\oneagentctl_wrapper.ps --set-host-group=MyHostGroup`<br>|
|PROPERTIES|`.\oneagentctl_wrapper.ps1 --get-host-properties `<br>`.\oneagentctl_wrapper.ps1 --set-host-property=AppName --set-host-property=Environment=Dev`|
|TAGS|`.\oneagentctl_wrapper.ps1 --get-host-tags`<br>`.\oneagentctl_wrapper.ps1 --set-host-tag=TestHost --set-host-tag=role=fallback`|
|INFRA-ONLY MODE|`.\oneagentctl_wrapper.ps1 --get-infra-only`<br>`.\oneagentctl_wrapper.ps1 --set-infra-only=false`|
|NETWORK ZONE|`.\oneagentctl_wrapper.ps1 --get-network-zone`<br>`.\oneagentctl_wrapper.ps1 --set-network-zone=<your.network.zone>`|
|PROXY|`.\oneagentctl_wrapper.ps1 --get-proxy`<br>`.\oneagentctl_wrapper.ps1 --set-proxy=my-proxy.com`
|RESTART AGENT SERVICE|`.\oneagentctl_wrapper.ps1 --restart-service`|