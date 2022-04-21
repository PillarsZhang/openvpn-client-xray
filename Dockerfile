# Dockerfile for OpenVPN Client Xray
# https://github.com/PillarsZhang/openvpn-client-xray
# https://hub.docker.com/r/pillarszhang/openvpn-client-xray

FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="PillarsZhang <z@pizyds.com>"

WORKDIR /root

# Use Tsinghua Alpine mirror
# https://mirrors.tuna.tsinghua.edu.cn/help/alpine/
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

## OpenVPN

# https://wiki.alpinelinux.org/wiki/Setting_up_a_OpenVPN_server
RUN set -ex \
    && apk add --no-cache openvpn openresolv


## Xray

# https://github.com/teddysun/across/tree/master/docker/xray
ARG TARGETPLATFORM
COPY ./src/get_xray.sh /root/get_xray.sh
RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates \
	&& mkdir -p /var/log/xray /usr/share/xray \
	&& chmod +x /root/get_xray.sh \
	&& /root/get_xray.sh "${TARGETPLATFORM}" \
	&& rm -fv /root/get_xray.sh


## Other

# OpenVPN config file: /root/config/openvpn.ovpn
# Xray config file: /root/config/xray.json
# Xray geo-data: /usr/share/xray/geosite.dat /usr/share/xray/geoip.dat
VOLUME ["/root/config", "/usr/share/xray/"]

EXPOSE 14850-14855

COPY ./src/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "start-openvpn-xray" ]