#
# Cookbook Name:: keepalived
# Recipe:: ip_nonlocal_bind
#
# Copyright 2012, Coroutine LLC
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

# is there a swift-nodes databag?
# if not then nothing to do...
begin
  swift_nodes_db = data_bag_item("crowbar", "swift-nodes") 
  db_haproxy_proposal = swift_nodes_db["haproxy-proposal"]
  db_swift_proxies = swift_nodes_db["proxy-nodes"]
  Chef::Log.info("HAProxy:update_for_swift - db_haproxy_proposal - #{db_haproxy_proposal}") 
  Chef::Log.info("HAProxy:update_for_swift - db_swift_proxies - #{db_swift_proxies}") 
  if db_swift_proxies == ""
    Chef::Log.info("HAProxy:update_for_swift - no swift proxy nodes found") 
    swift_detected = false
  else
    # update haproxy configuration
    # collect swift node names & addresses
    swift_detected = true
    swift_nodes = Array.new
    admin_net_db = data_bag_item('crowbar', 'admin_network')
    public_net_db = data_bag_item('crowbar', 'public_network')
    swift_proxy_servers = db_swift_proxies.split(';')    
    swift_proxy_servers.length.times do |i|
      Chef::Log.info("HAProxy:update_for_swift - swift proxy - #{swift_proxy_servers[i]}")  
      swift_proxy_server_adminip = admin_net_db["allocated_by_name"]["#{swift_proxy_servers[i]}"]["address"]
      swift_nodes << "  server " + swift_proxy_servers[i] + " " + swift_proxy_server_adminip + ":8081 check"
    end  
    
    # collect controller node names & addresses
    adminfixedip_db = data_bag_item('crowbar', "bc-haproxy-" + db_haproxy_proposal)
    admincont1 = adminfixedip_db["deployment"]["haproxy"]["elements"]["haproxy"][0]
    admincont2 = adminfixedip_db["deployment"]["haproxy"]["elements"]["slave"][0]
    admincont3 = adminfixedip_db["deployment"]["haproxy"]["elements"]["slave"][1]
    cont1_admin_ip = admin_net_db["allocated_by_name"]["#{admincont1}"]["address"]
    cont2_admin_ip = admin_net_db["allocated_by_name"]["#{admincont2}"]["address"]
    cont3_admin_ip = admin_net_db["allocated_by_name"]["#{admincont3}"]["address"]

    # get public & admin vips
    domain = swift_proxy_servers[1].split('.')
    haproxy_service_name = "haproxy-config-" + db_haproxy_proposal + "." + domain[1] + "." + domain[2]
    public_vip = public_net_db["allocated_by_name"]["#{haproxy_service_name}"]["address"]
    admin_vip = admin_net_db["allocated_by_name"]["#{haproxy_service_name}"]["address"]
    Chef::Log.info("HAProxy:update_for_swift - admin_vip - #{admin_vip}") 
    Chef::Log.info("HAProxy:update_for_swift - public_vip - #{public_vip}") 
    
    # update haproxy.cfg
    template "/etc/haproxy/haproxy.cfg" do
        source "haproxy.cfg.erb"
        mode "0644"
        variables( {
        :admin_ip => admin_vip,
        :admincont1 => admincont1,
        :admincont2 => admincont2,
        :admincont3 => admincont3,
        :cont1_admin_ip => cont1_admin_ip,
        :cont2_admin_ip => cont2_admin_ip,
        :cont3_admin_ip => cont3_admin_ip,
        :public_ip => public_vip,
        :swift_detected => swift_detected,
        :swift_servers => swift_nodes
        } )
    end

    # haproxy service restart
    execute "reloadhaproxy" do
     command "haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)"
    end
  
  end
rescue
  Chef::Log.info("HAProxy:update_for_swift(in rescue code) - perhaps data bag swift-nodes not found?")
end
