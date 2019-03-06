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
FROM ubuntu:18.04

ENV BIND_USER=bind \
    DATA_DIR=/data

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y vim net-tools bind9 bind9-host dnsutils \
 && rm -rf /var/lib/apt/lists/*

COPY dns/entrypoint.sh /sbin/entrypoint.sh
COPY dns/named.conf.local dns/named.conf.options dns/zone.ciab.test /etc/bind/
COPY traffic_ops/to-access.sh enroller/server_template.json /

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/named"]
