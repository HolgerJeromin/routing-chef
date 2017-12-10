#
# Cookbook Name:: apache
# Recipe:: ssl
#
# Copyright 2011, OpenStreetMap Foundation
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
#

certificate = node[:apache][:ssl][:certificate]

node.default[:ssl][:certificates] = node[:ssl][:certificates] | [ certificate ]

include_recipe "apache"

apache_module "socache_shmcb" do
  only_if { node[:lsb][:release].to_f >= 14.04 }
end

apache_module "ssl"

apache_conf "ssl" do
  template "ssl.erb"
  variables :certificate => certificate
  notifies :reload, "service[apache2]"
end

service "apache2" do
  action :nothing
  subscribes :restart, "cookbook_file[/etc/letsencrypt/live/osm.ch/fullchain.pem]"
  subscribes :restart, "cookbook_file[/etc/letsencrypt/live/osm.ch/cert.pem]"
  subscribes :restart, "file[/etc/letsencrypt/live/osm.ch/privkey.pem]"
end
