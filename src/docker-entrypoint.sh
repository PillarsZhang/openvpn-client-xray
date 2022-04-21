#!/bin/sh
set -e

case $1 in

start-openvpn-xray)
    echo "> start-openvpn-xray ..."

    openvpn_config_file="/root/config/openvpn.ovpn"
    openvpn_args="--script-security 2 --up /etc/openvpn/up.sh --down /etc/openvpn/down.sh --config /dev/stdin"
    openvpn_args_append=""

    xray_config_file="/root/config/xray.json"
    xray_args="--config /dev/stdin --format json"
    xray_args_append=""

    disable_replace=false

    shift
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --openvpn-config-file) openvpn_config_file="$2"; shift ;;
            --openvpn-args) openvpn_args="$2"; shift ;;
            --openvpn-args-append) openvpn_args_append="$2"; shift ;;
            --xray-config-file) xray_config_file="$2"; shift ;;
            --xray-args) xray_args="$2" shift;;
            --xray-args-append) xray_args_append="$2" shift;;
            --disable-replace) disable_replace=true ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
        shift
    done

    # Read config file
    if [ -f "$openvpn_config_file" ]; then
        openvpn_config=$(cat $openvpn_config_file)

        # Check whether the OpenVPN configuration file has been overwritten
        # Find identifier: ${FLAG_FOR_UNCONFIGURED}
        openvpn_unconfigured_identifier='${FLAG_FOR_UNCONFIGURED}'
        if [ -n "$( echo "$openvpn_config" | sed -n "/$openvpn_unconfigured_identifier/p")" ]; then
            echo "> You haven't configured OpenVPN in $openvpn_config_file yet"
            exit 1
        fi
    else
        openvpn_config=""
        echo "> --openvpn-config-file does not exist. Please make sure you specify the path in --openvpn-args"
    fi
    
    if [ -f "$xray_config_file" ]; then
        xray_config=$(cat $xray_config_file)

        # Replace listen address in Xray config for safety (${DOCKER_IP})
        # https://stackoverflow.com/questions/27670495/can-i-get-ip-address-inside-my-docker-container
        if ! $disable_replace; then
            docker_ip=$(hostname -i)
            docker_ip_place_holder='${DOCKER_IP}'
            echo "> Replace '$docker_ip_place_holder' to '$docker_ip' in $xray_config_file ..."
            xray_config=$(echo "$xray_config" | sed -e "s/$docker_ip_place_holder/$docker_ip/g")
            echo "< Replace done"
        fi
    else
        xray_config=""
        echo "> --xray-config-file does not exist. Please make sure you specify the path in --xray-args"
    fi

    # https://docs.docker.com/config/containers/multi-service_container/
    echo "> Launch OpenVPN ..."
    (echo "$openvpn_config" | openvpn $openvpn_args $openvpn_args_append) &
    echo "> Launch Xray ..."
    (echo "$xray_config" | xray $xray_args $xray_args_append) &

    echo "< Wait OpenVPN or Xray exit ..."
    wait -n
    exit $?
    ;;

update-geo-data)
    echo "> update-geo-data ..."

    from_cdn=false

    geosite_uri_github="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
    geoip_uri_github="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"

    geosite_uri_jsdelivr="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
    geoip_uri_jsdelivr="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"

    shift
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --from-cdn) from_cdn=true ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
        shift
    done

    if $from_cdn; then
        geosite_uri=$geosite_uri_jsdelivr
        geoip_uri=$geoip_uri_jsdelivr
    else
        geosite_uri=$geosite_uri_github
        geoip_uri=$geoip_uri_github
    fi

    echo "> Update geosite.dat from $geosite_uri"
    wget -O /usr/share/xray/geosite.dat $geosite_uri \
    && echo "< Update geosite.dat done"
    echo "> Update geoip.dat from $geoip_uri"
    wget -O /usr/share/xray/geoip.dat $geoip_uri \
    && echo "< Update geoip.dat done"
    ;;

*)
    echo "> common-sh-command ..."
    exec "$@"
    ;;
esac