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

set -x

iptables -F
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 60.248.0.0/16 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 118.160.0.0/13 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 42.64.0.0/12 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 127.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 172.16.0.0/12 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 192.168.0.0/16 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 34.80.0.0/13 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -s 35.247.0.0/16 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP
# iptables -L -nv
