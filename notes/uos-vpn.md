University of Southampton VPN setup using NetworkManager GUI:

* Left-click on the applet and navigate to "VPN Connections" -> "Configure VPN...".
* Click "Add".
* Select "Cisco Compatible VPN (vpnc)" and click "Create...".
* Fill in the fields on the "VPN" tab:
  * Connection name (whatever you want to use to identify this network interface)
  * Gateway: `globalprotect.soton.ac.uk`
  * Username: `kad2g15`
  * User password: use drop-down to select how you want the password to be stored, and enter it here if desired
  * Group name: `soton`
  * Group password: select "Store the password for all users" and enter `soton`
  * Ensure "Use hybrid authentication" is un-ticked.
* On the "IPv4 Settings" tab, click "Routes...".
* Ensure "Use this connection only for resources on its network" is ticked.
* Click "Add" and fill in the fields as follows:
  * Address: `152.78.0.0`
  * Netmask: `255.255.0.0` (together with the address this specifies the set of IP addresses that should be accessed through the VPN)
  * Gateway: leave blank
  * Metric: `50` (a number indicating the priority of the route; lower metrics take priority over higher metrics; we want this route to take priority over the default wired connection, which has metric 100)
* Click "Ok".
* Click "Save".
* Click "Close".
* Left-click on the applet and connect to the new VPN connection.
