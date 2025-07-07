/interface bridge
add auto-mac=yes name=GuestBridge port-cost-mode=short
add auto-mac=yes comment=defconf name=bridge port-cost-mode=short

/interface ethernet
set [ find default-name=ether1 ] l2mtu=1598
set [ find default-name=ether2 ] l2mtu=1598
set [ find default-name=ether3 ] l2mtu=1598
set [ find default-name=ether4 ] l2mtu=1598
set [ find default-name=ether5 ] l2mtu=1598
set [ find default-name=sfp-sfpplus1 ] advertise="10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full,1G-baseX,2.5G-baseT,2.5G-baseX,5G-baseT,10G-baseT,10G-baseSR-LR,10G-baseCR" name=sfp-sfpplus1_WAN
set [ find default-name=sfp-sfpplus2 ] advertise="10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full,1G-baseX,2.5G-baseT,2.5G-baseX,5G-baseT,10G-baseT,10G-baseSR-LR,10G-baseCR" name=sfp-sfpplus2_LAN

/interface vlan
add interface=sfp-sfpplus2_LAN name=LTEInternetWAN vlan-id=6
add interface=sfp-sfpplus2_LAN name=vlanGuest vlan-id=2

/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN

/ip pool
add name=dhcp ranges=192.168.66.100-192.168.66.0.254

/ip dhcp-server
add address-pool=dhcp interface=bridge name=defconf

/ip neighbor discovery-settings
set discover-interface-list=LAN

/interface bridge port
add bridge=GuestBridge interface=vlanGuest internal-path-cost=10 path-cost=10
add bridge=bridge interface=sfp-sfpplus2_LAN internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether2 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether3 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether4 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether5 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether6 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether7 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether8 internal-path-cost=10 path-cost=10

/something to remove
add some content
add some content
add some content

/something to change
add some content
add find this
add some content

/ipv6 settings
set accept-router-advertisements=yes

/interface list member
add comment=WAN interface=ether1 list=WAN
add comment=LAN interface=bridge list=LAN

/ip address
add address=192.168.66.1/24 comment=defconf interface=bridge network=192.168.66.0

/ip dhcp-client
add comment=defconf interface=ether1

/ip dhcp-server network
add address=192.168.66.1/24 comment=defconf gateway=192.168.66.1 netmask=24

/ip dns
set allow-remote-requests=yes

/ip firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN

add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related hw-offload=yes
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN

/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=\
    out,none out-interface-list=WAN

/ipv6 address
add address=::1 from-pool=pool-ipv6 interface=bridge

/ipv6 dhcp-client
add interface=ether1 pool-name=pool-ipv6 request=prefix use-interface-duid=yes \
    use-peer-dns=no

/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6

/ipv6 firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" port=\
    33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=!LAN

/ipv6 nd
set [ find default=yes ] hop-limit=64 interface=\
    bridge ra-preference=high

/system clock
set time-zone-name=Pacific/Auckland