Microservice to validate network state (when devices run Junos). Based on Ansible and Docker 

```
$ tree inputs
inputs
├── audit_option.yaml
├── hosts.ini
└── host_vars
    ├── demo-qfx5110-11
    │   └── validation.yml
    └── demo-qfx5110-12
        └── validation.yml

```
```
$ more inputs/hosts.ini 
[spines]
demo-qfx10k2-14   ansible_host=172.25.90.67
demo-qfx10k2-15   ansible_host=172.25.90.68
demo-qfx5110-9    ansible_host=172.25.90.63
demo-qfx5110-10   ansible_host=172.25.90.64

[leaves]
demo-qfx5110-11   ansible_host=172.25.90.65
demo-qfx5110-12   ansible_host=172.25.90.66

[all:vars]
netconf_port=830
ansible_ssh_user=ansible
ansible_ssh_pass=juniper123
```

```
$  more inputs/audit_option.yaml 
---
audit:
  mode:
    loose: True
```
```
$ more inputs/host_vars/demo-qfx5110-11/validation.yml 
# used to validate management ports are reachable from your server

management_ports: 
    - 22
    - 830


# used to validate device model 
# compare collected device model VS expected device model (described below)
# examples QFX5100-48S, qfx5110-32q, QFX10002-36Q
device_model: qfx5110-32q


# used to validate SW release
# compare collected SW release VS expected SW release (described below)
sw_release: 18.2R1-S4.1


# used to validate Interfaces status
# interfaces between spines and leaves are expected to be administratively up and operationaly up
# non used interfaces are expected to be administratively down

interfaces:
  admin_up_and_oper_up:
    - et-0/0/0 
    - et-0/0/1
    - et-0/0/2
    - et-0/0/3
  admin_down:
    - xe-0/0/6:3
  admin_up:
    - xe-0/0/6:1
    - xe-0/0/6:2
    - ae100
 

# used to Validate physical topology
# compare the actual LLDP neighbors vs the expected ones (described below)
# can be used to validate how devices are connected between them (connection between spines and leaves as example)
# can be used to validate how servers running LLDP are connected to Junos devices (connection of a server to an access port of a leaf as example)

LLDP_neighbors:
    - local_interface: et-0/0/0
      remote_name: demo-qfx10k2-14
    - local_interface: et-0/0/1
      remote_name: demo-qfx10k2-15
    - local_interface: et-0/0/2
      remote_name: demo-qfx5110-9
    - local_interface: et-0/0/3
      remote_name: demo-qfx5110-10 


# used to validate these VLANs exist

vlans:
  - name: tenant1_dmz
  - name: tenant1_trust
  - name: tenant1_untrust
  - name: tenant2_dmz
  - name: tenant2_trust
  - name: tenant2_untrust
  - name: tenant3_dmz
  - name: tenant3_trust
  - name: tenant3_untrust


# used to validate BGP
# works with both EBGP and IBGP
# validate the device can ping his BGP peers
# validate sessions state is Established
# validate the number of routes learnt from `peer_ip` is greater than a certain value 

BGP_neighbors:
    - peer_ip: 10.0.0.1
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 10.0.0.2
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 10.0.0.11
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 10.0.0.12
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.0
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.4
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.8
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.12 
      number_of_routes_learnt_greater_than: 2


# used to validate the device can run these PING (ttl=1)

PING:
  - local_ip: 10.0.0.21
    peer_ip: 10.0.0.1
  - local_ip: 10.0.0.21
    peer_ip: 10.0.0.2
  - local_ip: 10.0.0.21
    peer_ip: 10.0.0.11
  - local_ip: 10.0.0.21
    peer_ip: 10.0.0.12
  - local_ip: 172.16.0.1
    peer_ip: 172.16.0.0
  - local_ip: 172.16.0.5
    peer_ip: 172.16.0.4
  - local_ip: 172.16.0.9 
    peer_ip: 172.16.0.8
  - local_ip: 172.16.0.13
    peer_ip: 172.16.0.12



# Used to validate VTEP endpoints address. Used for VXLAN data plane validation 
# Use output of `show interfaces vtep` command and check if below remote endpoint address are presents

vtep:
  - address: "10.0.0.21"
  - address: "10.0.0.22"


```
```
$ more inputs/host_vars/demo-qfx5110-12/validation.yml 
# used to validate management ports are reachable from your server

management_ports: 
    - 22
    - 830


# used to validate device model 
# compare collected device model VS expected device model (described below)
# examples QFX5100-48S, qfx5110-32q, QFX10002-36Q
device_model: qfx5110-32q


# used to validate SW release
# compare collected SW release VS expected SW release (described below)
sw_release: 17.3R3.9


# used to validate Interfaces status
# interfaces between spines and leaves are expected to be administratively up and operationaly up
# non used interfaces are expected to be administratively down

interfaces:
  admin_up_and_oper_up:
    - et-0/0/0 
    - et-0/0/1
    - et-0/0/2
    - et-0/0/3
  admin_down:
    - xe-0/0/6:3
  admin_up:
    - xe-0/0/6:1
    - xe-0/0/6:2
    - ae100
 

# used to Validate physical topology
# compare the actual LLDP neighbors vs the expected ones (described below)
# can be used to validate how devices are connected between them (connection between spines and leaves as example)
# can be used to validate how servers running LLDP are connected to Junos devices (connection of a server to an access port of a leaf as example)

LLDP_neighbors:
    - local_interface: et-0/0/0
      remote_name: demo-qfx10k2-14
    - local_interface: et-0/0/1
      remote_name: demo-qfx10k2-15
    - local_interface: et-0/0/2
      remote_name: demo-qfx5110-9
    - local_interface: et-0/0/3
      remote_name: demo-qfx5110-10 


# used to validate these VLANs exist

vlans:
  - name: tenant1_dmz
  - name: tenant1_trust
  - name: tenant1_untrust
  - name: tenant2_dmz
  - name: tenant2_trust
  - name: tenant2_untrust
  - name: tenant3_dmz
  - name: tenant3_trust
  - name: tenant3_untrust


# used to validate BGP
# works with both EBGP and IBGP
# validate the device can ping his BGP peers
# validate sessions state is Established
# validate the number of routes learnt from `peer_ip` is greater than a certain value 

BGP_neighbors:
    - peer_ip: 10.0.0.1
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 10.0.0.2
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 10.0.0.11
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 10.0.0.12
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.2
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.6
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.10
      number_of_routes_learnt_greater_than: 2
    - peer_ip: 172.16.0.14 
      number_of_routes_learnt_greater_than: 2


# used to validate the device can run these PING (ttl=1)

PING:
  - local_ip: 10.0.0.22
    peer_ip: 10.0.0.1
  - local_ip: 10.0.0.22
    peer_ip: 10.0.0.2
  - local_ip: 10.0.0.22
    peer_ip: 10.0.0.11
  - local_ip: 10.0.0.22
    peer_ip: 10.0.0.12
  - local_ip: 172.16.0.3
    peer_ip: 172.16.0.2
  - local_ip: 172.16.0.7
    peer_ip: 172.16.0.6
  - local_ip: 172.16.0.11 
    peer_ip: 172.16.0.10
  - local_ip: 172.16.0.15
    peer_ip: 172.16.0.14



# Used to validate VTEP endpoints address. Used for VXLAN data plane validation 
# Use output of `show interfaces vtep` command and check if below remote endpoint address are presents

vtep:
  - address: "10.0.0.21"
  - address: "10.0.0.22"

```
