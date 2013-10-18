Welcome to a Barclamp for the Crowbar Framework project
=======================================================

The code and documentation is distributed under the Apache 2 license (http://www.apache.org/licenses/LICENSE-2.0.html). Contributions back to the source are encouraged.

The Crowbar Framework (https://github.com/dellcloudedge/crowbar) was developed by the Dell CloudEdge Solutions Team (http://dell.com/openstack) as a OpenStack installer (http://OpenStack.org) but has evolved as a much broader function tool. 
A Barclamp is a module component that implements functionality for Crowbar.  Core barclamps operate the essential functions of the Crowbar deployment mechanics while other barclamps extend the system for specific applications.

* This functonality of this barclamp DOES NOT stand alone, the Crowbar Framework is required * 

About this barclamp
-------------------

Information for this barclamp is maintained on the Crowbar Framework Wiki: https://github.com/dellcloudedge/crowbar/wiki

This barclamp is intended for use with all the other HA components for Openstack, each component will be added to this readme file when complete, this is also only fit for Grizzly and will be re-factored for Havana.

All the barclamps must be installed in sequence and the list below is that sequence.
https://github.com/crowbar/barclamp-openstack-titanium-base - This Barclamp will apply a menu item to Crowbar of which all other HA barclamps will be presented.
https://github.com/crowbar/barclamp-openstack-titanium-loadbalancer - This is the load balancer barclamps

