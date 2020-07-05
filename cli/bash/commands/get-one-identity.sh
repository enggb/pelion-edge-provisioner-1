# Copyright (c) 2019, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

set -e

if [ ! -z "$DEBUG" ]; then
    set -x
fi

. "$PEP_CLI_DIR/common.sh"

API_URL="https://api.us-east-1.mbedcloud.com"
GW_URL="https://gateways.us-east-1.mbedcloud.com"
RADIO_CONFIG="00"
LED_CONFIG="01"
CATEGORY="production"

cli_help_get_one_identity() {
  echo "
Usage: pep get-one-identity [<options>]

Options:
  -a <ip_or_dns>            pelion cloud api url (default: '$API_URL')
  -g <ip_or_dns>            pelion cloud gateway service address (default: '$GW_URL')
  -s <string_value>         serial number of the gateway
  -w <string_value>         hardware version of the gateway, refer configurations section in
                            $PEP_CLI_DIR/../lib/radioProfile.template.json
  -r <string_value>         radio configuration of the gateway, refer configurations section in
                            $PEP_CLI_DIR/../lib/radioProfile.template.json (default: '$RADIO_CONFIG')
  -l <string_value>         status led configuration of the gateway (default: '$LED_CONFIG')
  -c <string_value>         developer or production (default: '$CATEGORY')
  -i <ip>                   ip address of the gateway where factory-configurator-client is running
  -p <port_number>          port number at which factory-configurator-client listening
  -v                        verbose
  -h                        output usage information"
}

[ ! -n "$2" ] && cli_help_get_one_identity && exit 1

OPTIND=1

QUERY=""

while getopts 'a:g:s:w:r:l:c:i:p:hv' opt "${@:2}"; do
    case "$opt" in
        h|-help)
            cli_help_get_one_identity
            exit 0
            ;;
        a)
            API_URL="$OPTARG"
            ;;
        g)
            GW_URL="$OPTARG"
            ;;
        s)
            SERIAL_NUMBER="$OPTARG"
            ;;
        w)
            HW_VERSION="$OPTARG"
            ;;
        r)
            RADIO_CONFIG="$OPTARG"
            ;;
        l)
            LED_CONFIG="$OPTARG"
            ;;
        c)
            CATEGORY="$OPTARG"
            ;;
        i)
            FCC_IP_ADDRESS="$OPTARG"
            ;;
        p)
            FCC_PORT="$OPTARG"
            ;;
        v)
            VERBOSE="-v"
            ;;
        *)
            cli_help_get_one_identity
            exit 1
            ;;
    esac
done

shift "$(($OPTIND-1))"

if [ -z "$FCC_IP_ADDRESS" ]; then
    cli_error "-i <ip> not specified!"
    exit 1
fi

if [ -z "$FCC_PORT" ]; then
    cli_error "-p <port_number> not specified!"
    exit 1
fi

if [ ! -z "$API_URL" ]; then
    QUERY="apiAddress=$API_URL"
fi

if [ ! -z "$GW_URL" ]; then
    QUERY="$QUERY&gatewayServicesAddress=$GW_URL"
fi

if [ ! -z "$SERIAL_NUMBER" ]; then
    QUERY="$QUERY&serialNumber=$SERIAL_NUMBER"
fi

if [ ! -z "$HW_VERSION" ]; then
    QUERY="$QUERY&hardwareVersion=$HW_VERSION"
fi

if [ ! -z "$RADIO_CONFIG" ]; then
    QUERY="$QUERY&radioConfig=$RADIO_CONFIG"
fi

if [ ! -z "$LED_CONFIG" ]; then
    QUERY="$QUERY&ledConfig=$LED_CONFIG"
fi

if [ ! -z "$CATEGORY" ]; then
    QUERY="$QUERY&category=$CATEGORY"
fi

if [ ! -z "$FCC_IP_ADDRESS" ]; then
    QUERY="$QUERY&ip=$FCC_IP_ADDRESS"
fi

if [ ! -z "$FCC_PORT" ]; then
    QUERY="$QUERY&port=$FCC_PORT"
fi

curl $PEP_SERVER_URL/$API_VERSION/identity?$QUERY $VERBOSE > "identity.json"
cat ./identity.json