#!/bin/sh

URL="http://code.imnks.com/mp2020/hosts"
REMOTE_HOST_LIST=`curl -s $URL | grep -v "#\|"127.0.0.1"\|::1\|^$"`
LOCAL_HOST_AMOUNT=`cat /etc/hosts | grep -v "#\|"127.0.0.1"\|::1\|^$" | wc -l`
REMOTE_HOST_AT=`curl -s $URL | grep IMNKS.COM`
LOCAL_HOST_AT=`cat /etc/hosts | grep IMNKS.COM`

write_host(){
    for HOST in "$REMOTE_HOST_LIST"; do
       echo "$HOST" >> /etc/hosts
    done
}

if [ $LOCAL_HOST_AMOUNT = 0 ];then
    write_host
    echo $REMOTE_HOST_AT >> /etc/hosts
else
    if [[ "$REMOTE_HOST_AT" != "$LOCAL_HOST_AT" ]];then
        LOCAL_HOST_LIST=`cat /etc/hosts | grep -v "#\|"127.0.0.1"\|::1\|^$"`
        for HOST in $LOCAL_HOST_LIST; do
            sed -i "/$HOST/d" /etc/hosts
        done
        [ "$LOCAL_HOST_AT" != "" ] && sed -i "/$LOCAL_HOST_AT/d" /etc/hosts
        write_host
        echo $REMOTE_HOST_AT >> /etc/hosts
    else
        echo "HOSTS无需更新"
    fi
fi
        
