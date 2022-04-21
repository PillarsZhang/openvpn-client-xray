[CmdletBinding()]
param (
    [Parameter()]
    [string]$tag="pillarszhang/openvpn-client-xray"
)

docker run --rm -it `
    --mount type=bind,source=$(Get-Location)/config,target=/root/config,readonly `
    --mount type=volume,source=openvpn-client-xray_xray-asset,target=/usr/share/xray `
    $tag update-geo-data `
    --from-cdn