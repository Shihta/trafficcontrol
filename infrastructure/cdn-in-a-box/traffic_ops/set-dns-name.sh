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
#

base_data_dir="/traffic_ops_data"

set-cdn-name() {
  echo "$1 $2"
  cat "$2" | jq '. + {"'"$1"'":"'"$CDN_NAME"'"}' > "$2.tmp" && mv "$2.tmp" "$2"
}

JSONS=(
deliveryservices/010-ciab.json
profiles/040-CCR_CIAB.json
profiles/070-RASCAL-Traffic_Monitor.json
profiles/010-ATS_EDGE_TIER_CACHE.json
profiles/020-ATS_MID_TIER_CACHE.json
)

for ((i=0; i<${#JSONS[@]}; i++)); do
  set-cdn-name "cdnName" "$base_data_dir/${JSONS[$i]}"
done
set-cdn-name "name" "$base_data_dir/cdns/010-CDN-in-a-Box.json"

