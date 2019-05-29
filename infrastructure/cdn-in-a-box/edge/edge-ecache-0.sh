#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -e
set -x
set -m

set-dns.sh
insert-self-into-dns.sh

source /to-access.sh

# Wait on SSL certificate generation
until [[ -f "$X509_CA_ENV_FILE" ]]
do
  echo "Waiting on Shared SSL certificate generation"
  sleep 3
done

# Source the CIAB-CA shared SSL environment
until [[ -n "$X509_GENERATION_COMPLETE" ]]
do
  echo "Waiting on X509 vars to be defined"
  sleep 1
  source "$X509_CA_ENV_FILE"
done

# Trust the CIAB-CA at the System level
cp $X509_CA_CERT_FULL_CHAIN_FILE /etc/pki/ca-trust/source/anchors
update-ca-trust extract

while ! to-ping 2>/dev/null; do
	echo "waiting for Traffic Ops"
	sleep 5
done

export TO_USER=$TO_ADMIN_USER
export TO_PASSWORD=$TO_ADMIN_PASSWORD

# wait until the CDN has been registered
found=
while [[ -z $found ]]; do
    echo 'waiting for enroller setup'
    sleep 3
    found=$(to-get "api/1.3/cdns?name=$CDN_NAME" | jq -r '.response[].name')
done

set +e
ret=$(to-post "api/1.1/cachegroups" /opt/jsons/cachegroup-edge.json)
echo "ret_code=$?"
echo $ret

to-setenv-before-enroll "QCT_CG_Edge_Remote_0" "QCT_EDGE_TIER_CACHE" "EDGE" "REPORTED"

to-enroll edge $CDN_NAME "QCT_CG_Edge_Remote_0" "" "" "QCT_EDGE_TIER_CACHE" "192.168.1.10" || (while true; do echo "enroll failed."; sleep 3 ; done)

hn=$(hostname -s)
cat /shared/enroller/servers/${hn}.json
ret=$(to-post "api/1.3/servers" /shared/enroller/servers/${hn}.json)
echo $ret

server_id=$(to-get "api/1.4/servers?hostName=$hn" |jq '.response[0].id')

# tail -f /dev/null

# Leaves the container hanging open in the event of a failure for debugging purposes
traffic_ops_ort -kl ALL BADASS || { echo "Failed"; }

envsubst < "/etc/cron.d/traffic_ops_ort-cron-template" > "/var/spool/cron/root" && rm -f "/etc/cron.d/traffic_ops_ort-cron-template"
crontab "/var/spool/cron/root"

crond -im off

touch /var/log/trafficserver/diags.log
ds_id=$(to-get "api/1.4/deliveryservices?xmlId=st" |jq '.response[0].id')
linkreq="{ \"dsId\": $ds_id , \"replace\": false, \"servers\": [ $server_id ] }"
ret=$(to-post "api/1.4/deliveryserviceserver" "$linkreq")
echo $ret
if [[ "$AUTO_SNAPQUEUE_ENABLED" = true ]]; then
  to-auto-snapqueue "edge-ecache-0,edge-tm-0" $CDN_NAME
fi

envsubst < /etc/trafficserver/td-agent-extended2.tmp > /etc/trafficserver/td-agent-extended2.conf
td-agent -c /etc/trafficserver/td-agent-extended2.conf &

tail -Fn +1 /var/log/trafficserver/diags.log
