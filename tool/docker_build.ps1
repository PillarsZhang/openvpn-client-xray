[CmdletBinding()]
param (
    [Parameter()]
    [string]$tag="pillarszhang/openvpn-client-xray"
)

docker build --rm -t $tag .