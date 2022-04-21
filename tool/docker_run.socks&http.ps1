[CmdletBinding()]
param (
    [Parameter()]
    [string]$tag="pillarszhang/openvpn-client-xray"
)

docker run --rm -it `
    --mount type=bind,source=$(Get-Location)/config,target=/root/config,readonly `
    --mount type=volume,source=openvpn-client-xray_xray-asset,target=/usr/share/xray `
    --device=/dev/net/tun --cap-add=NET_ADMIN `
    -p 127.0.0.1:14851:14851 `
    -p 127.0.0.1:14852:14852 `
    $tag start-openvpn-xray `
    --xray-config-file "/root/config/xray.socks&http.json"