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