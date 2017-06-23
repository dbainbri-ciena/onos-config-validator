#!/bin/ash

ONOS=${ONOS:-karaf:karaf@fabric-controller:8181}
DESIRED_CONFIG=${DESIRED_CONFIG:=/desired.json}
WAIT=${WAIT:-60}

echo "$(date) [INFO]: ONOS='$ONOS', DESIRED_CONFIG='$DESIRED_CONFIG'"

WANT=$(mktemp)
HAVE=$(mktemp)

while true; do
    curl -XGET --fail --connect-timeout 3 -sSL http://$ONOS/onos/v1/network/configuration  > $HAVE #| jq -S . > $HAVE
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        echo "$(date) [ERROR]: Unable to fetch current configuration: $STATUS"
        sleep $WAIT
        continue
    fi

    cat $DESIRED_CONFIG > $WANT
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        echo "$(date) [ERROR]: Unable to read desired configuration file: $STATUS"
        sleep $WAIT
        continue
    fi

    STATUS=0

    KEYS=$(cat $WANT | jq "keys" | jq -r '.[]')

    TMPA=$(mktemp)
    TMPB=$(mktemp)
    TMPC=$(mktemp)

    for KEY in $KEYS; do
        cat $WANT | jq -S ".$KEY" > $TMPA
        cat $HAVE | jq -S ".$KEY" > $TMPB

        WANT_KEYS=$(cat $TMPA | jq "keys" | jq -r '.[]')
        for WANT_KEY in $WANT_KEYS; do
            cat $WANT | jq -S ".$KEY.\"$WANT_KEY\"" > $TMPA-A
            cat $HAVE | jq -S ".$KEY.\"$WANT_KEY\"" > $TMPB-A
    
            diff --ignore-all-space --ignore-blank-lines $TMPA-A $TMPB-A > $TMPC 2>&1
            if [ $? -ne 0 ]; then
                echo "$(date) [INFO]: DIFFERENCE in $KEY.$WANT_KEY"
                cat $TMPC 
                STATUS=$(expr $STATUS + 1)
            fi
        done
    done

    # Check if need to push / re-push config
    if [ $STATUS -eq 0 ]; then
        echo "$(date) [INFO]: Operational confioguration in ONOS @ $ONOS matches desired configuration"
    else
        echo "$(date) [INFO]: Pushing configuration to ONOS @ $ONOS"
        curl --connect-timeout 3 --fail -XPOST -H 'Content-type: application/json' -sSL http://$ONOS/onos/v1/network/configuration -d @$WANT > $TMPA 2>&1
        STATUS=$?
        if [ $STATUS -ne 0 ]; then
            echo "$(date) [ERROR]: Failed pushing configuration to 'http://$ONOS/onos/v1/network/configuration'"
            cat $TMPA
        fi
    fi
    sleep $WAIT
done
