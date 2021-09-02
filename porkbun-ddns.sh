#!/bin/bash

# crontab entry:    */15 * * * * /path/to/porkbun-ddhs.sh

# porkbun api key and secret
# create this key/secret pair at https://porkbun.com/account/api
apikey=
apisec=

# define domain name and record (sudomain) to update
# make sure that 'api access' is enabled for the domain on porkbun.com!
domain=
record=

if [ -z "$apikey" ] || [ -z "$apisec" ]; then echo "api key and secret code must be provided" && exit; fi
if [ -z "$domain" ] || [ -z "$record" ]; then echo "domain and record to update must be specified" && exit; fi

# ping porkbun api to get our current ip address
ourip=$(curl -s -X POST "https://porkbun.com/api/json/v3/ping" \
        -H "Content-Type: application/json" \
        --data "{ \"apikey\": \"$apikey\", \"secretapikey\": \"$apisec\" }" | grep -Po '(?<="yourIp":")[^"]+')
if [ -z "$ourip" ]; then echo "could not get our external ip address from porkbun api -- please check internet connectivity and api credentials" && exit; fi

# get current dns record
olddns=$(curl -s -X POST "https://porkbun.com/api/json/v3/dns/retrieveByNameType/$domain/A/$record" \
        -H "Content-Type: application/json" \
        --data "{ \"apikey\": \"$apikey\", \"secretapikey\": \"$apisec\" }" | grep -Po '(?<="content":")[^"]+')

# update dns record if necessary
if [[ $olddns != $ourip ]]; then
  curl -X POST "https://porkbun.com/api/json/v3/dns/editByNameType/$domain/A/$record" \
    -H "Content-Type: application/json" \
    --data "{ \"apikey\": \"$apikey\", \"secretapikey\": \"$apisec\", \"content\": \"$ourip\", \"ttl\": \"300\" }"
fi
