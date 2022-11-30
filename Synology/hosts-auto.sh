#!/bin/sh
# DOMAIN_HOST=1为启用0为关闭自定义域名hosts文件写入，GITHUB_HOST=1为启用0为关闭github域名hosts文件写入。
DOMAIN_HOST=1
GITHUB_HOST=1
# DOMAIN_LIST自定义域名列表，多域名以空格隔开，这里的域名会通过国外的DNS API返回正确的IP写入hosts文件以解决DNS污染问题。
DOMAIN_LIST=(api.themoviedb.org image.tmdb.org)
GITHUB_HOST_URL="https://hosts.gitcdn.top/hosts.txt"
DNS_API="https://networkcalc.com/api/dns/lookup"
REMOTE_GITHUB_HOST_AT=`curl -s $GITHUB_HOST_URL | grep -w "# last fetch time:"`
LOCAL_GITHUB_HOST_AT=`cat /etc/hosts | grep -w "# last fetch time:"`

check_domain_host(){
    for DOMAIN in ${DOMAIN_LIST[@]}; do
        DOMAIN_IP_LIST=`curl -X GET $DNS_API/$DOMAIN | jq -r '.records.A[].address'`
        if [ $DOMAIN_IP_LIST != "" ]; then
           for DOMAIN_IP in "$DOMAIN_IP_LIST"; do
               if [ `cat /etc/hosts | grep -wc $DOMAIN_IP` = 0 ]; then
                  [ `cat /etc/hosts | grep -wc "fetch-domain-hosts"` != 0 ] && sed -i "/# fetch-domain-hosts begin/Q" /etc/hosts
               fi
           done
        fi
    done
}

write_domain_host(){
    if [ `cat /etc/hosts | grep -wc "fetch-domain-hosts"` = 0 ]; then
        echo "# fetch-domain-hosts begin" >> /etc/hosts
        for DOMAIN in ${DOMAIN_LIST[@]}; do
            DOMAIN_IP_LIST=`curl -X GET $DNS_API/$DOMAIN | jq -r '.records.A[].address'`
            for DOMAIN_IP in $DOMAIN_IP_LIST; do
                echo "$DOMAIN_IP $DOMAIN" >> /etc/hosts
            done
        done
        echo "# fetch-domain-hosts end" >> /etc/hosts
    fi
}

if [ $DOMAIN_HOST = 1 ]; then
    check_domain_host
    write_domain_host
else
    [ `cat /etc/hosts | grep -wc "fetch-domain-hosts"` != 0 ] && sed -i "/# fetch-domain-hosts begin/Q" /etc/hosts
fi
if [ $GITHUB_HOST = 1 ]; then
    if [ "$REMOTE_GITHUB_HOST_AT" != "" ]; then
        [ `cat /etc/hosts | grep -wc "fetch-github-hosts"` = 0 ] && curl $GITHUB_HOST_URL >> /etc/hosts
        if [[ "$REMOTE_GITHUB_HOST_AT" != "$LOCAL_GITHUB_HOST_AT" ]];then
            sed -i "/# fetch-github-hosts begin/Q" /etc/hosts && curl $GITHUB_HOST_URL >> /etc/hosts
        else
            echo "HOST无需更新"
        fi
    fi
else
    [ `cat /etc/hosts | grep -wc "fetch-github-hosts"` != 0 ] && sed -i "/# fetch-github-hosts begin/Q" /etc/hosts
fi