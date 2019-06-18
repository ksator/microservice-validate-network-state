![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ksator/validate-network-state.svg) 
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ksator/validate-network-state.svg) 
![Docker Pulls](https://img.shields.io/docker/pulls/ksator/validate-network-state.svg) 
![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/ksator/validate-network-state/latest.svg) 
![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/ksator/validate-network-state/latest.svg)

# Description

This microservice validates network state (when devices run Junos).  
It is based on Ansible and Docker 

It:
- connects to the network devices
- collects the actual state of the network devices
- compare the actual state with the desired state (described by a human or a program in the `inputs` directory) 

No commit is done on the devices.  

This microservice currently supports these features with Junos devices: 
- validate management ip address is reachable
- validate management ports are reachable
- validate device model 
- validate software release 
- validate interfaces status (both admin status and operational status) 
- validate physical topology
- validate VLANs configuration
- validate BGP (works with both EBGP and IBGP)  
  - validate the device can ping his BGP peers
  - validate sessions state is Established
  - validate the number of routes received by peers is greater than a certain value 
- validate ip reachability (running PING on Junos devices, from source addresses located in the device to destination addresses not located in the device)
- validate VTEP endpoints address (used for VXLAN data plane validation)

The desired state is described in the `inputs` directory.  
If you do not provide a description of the desired state for a feature, the tests related to this feature will be skept. As example if you do not describe the physical topology, the microservice will skip the physical topology validation  
  
This microservice:
- instanciates a container
- executes the service
- stops the container
- removes the container

The Docker image is [ksator/validate-network-state](https://cloud.docker.com/repository/docker/ksator/validate-network-state)

# Usage

## Install Docker

## Pull the Docker image

```
$ docker pull ksator/validate-network-state
```
Verify
```
$ docker images ksator/validate-network-state
REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
ksator/validate-network-state   latest              a762d1a736d2        2 hours ago         543MB
```
## Create the microservice inputs

Create this structure:
- An inputs directory. With these files: 
   - An Ansible Inventory file (hosts.ini) with following variables:
     - ansible_host: IP of the device
     - ansible_ssh_user: Username to use for the connection
     - ansible_ssh_pass: Password to use for the connection
    - a file `audit_option.yaml` to indicate the ansible behavior when a test fails. By the defaut, when an ansible task fails for an ansible host, that ansible host is removed from the ansible inventory for the next tasks of the playbook. 
      - if you set the audit.mode.loose to False, you keep the Ansible default behavior
      - if you prefer to keep that faulty ansible host in the inventory during the next tests, set the audit.mode.loose to True.   
    - a directory `host_vars` with a subdirectory for each device
      - the device subdirectory  has one or several yaml files with the device specific variables  

`Inputs` directory structure example:  
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
Ansible inventory example:
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
Indicate the Ansible behavior when an Ansible task fails for an Ansible host 
```
$  more inputs/audit_option.yaml 
---
audit:
  mode:
    loose: True
```
Indicate the device specific variables for each Ansible host you want to test  

Example for the device demo-qfx5110-11
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
Example for the device demo-qfx5110-12 
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
## Run the microservice

```
$ docker run -it --rm -v ${PWD}/inputs/host_vars:/host_vars -v ${PWD}/inputs:/inputs -v ${PWD}/outputs:/outputs ksator/validate-network-state
Validate Junos devices state

PLAY [Validate Junos devices state] *************************************************************************************************************************

TASK [include_vars] *****************************************************************************************************************************************
ok: [demo-qfx5110-11]
ok: [demo-qfx10k2-14]
ok: [demo-qfx5110-12]
ok: [demo-qfx5110-9]
ok: [demo-qfx10k2-15]
ok: [demo-qfx5110-10]

TASK [validate-management-ports-reachability : Check management ports reachability from your server] ********************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-11] => (item=22)
ok: [demo-qfx5110-12] => (item=22)
ok: [demo-qfx5110-12] => (item=830)
ok: [demo-qfx5110-11] => (item=830)

TASK [validate-device-model-and-SW-release : Retrieve junos facts from devices] *****************************************************************************
ok: [demo-qfx5110-11]
ok: [demo-qfx5110-12]
ok: [demo-qfx5110-9]
ok: [demo-qfx10k2-14]
ok: [demo-qfx10k2-15]
ok: [demo-qfx5110-10]

TASK [validate-device-model-and-SW-release : Print some junos facts] ****************************************************************************************
ok: [demo-qfx5110-11] => {
    "msg": "device demo-qfx5110-11 is a qfx5110-32q running junos version 18.2R1-S4.1"
}
ok: [demo-qfx5110-12] => {
    "msg": "device demo-qfx5110-12 is a qfx5110-32q running junos version 17.3R3.9"
}
ok: [demo-qfx10k2-14] => {
    "msg": "device demo-qfx10k2-14 is a qfx10002-36q running junos version 17.4R1-S3.3"
}
ok: [demo-qfx10k2-15] => {
    "msg": "device demo-qfx10k2-15 is a qfx10002-36q running junos version 17.4R1-S3.3"
}
ok: [demo-qfx5110-9] => {
    "msg": "device demo-qfx5110-9 is a qfx5110-32q running junos version 17.3R3.9"
}
ok: [demo-qfx5110-10] => {
    "msg": "device demo-qfx5110-10 is a qfx5110-32q running junos version 17.3R3.9"
}

TASK [validate-device-model-and-SW-release : validate device model] *****************************************************************************************
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-11] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [demo-qfx5110-12] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [validate-device-model-and-SW-release : validate software version] *************************************************************************************
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx5110-10]
skipping: [demo-qfx5110-9]
ok: [demo-qfx5110-11] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [demo-qfx5110-12] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [validate-interfaces-status : validate interfaces status is admin up] **********************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item=et-0/0/0)
ok: [demo-qfx5110-11] => (item=et-0/0/0)
ok: [demo-qfx5110-12] => (item=et-0/0/1)
ok: [demo-qfx5110-11] => (item=et-0/0/1)
ok: [demo-qfx5110-12] => (item=et-0/0/2)
ok: [demo-qfx5110-11] => (item=et-0/0/2)
ok: [demo-qfx5110-12] => (item=et-0/0/3)
ok: [demo-qfx5110-11] => (item=et-0/0/3)
ok: [demo-qfx5110-12] => (item=xe-0/0/6:1)
ok: [demo-qfx5110-11] => (item=xe-0/0/6:1)
ok: [demo-qfx5110-12] => (item=xe-0/0/6:2)
ok: [demo-qfx5110-11] => (item=xe-0/0/6:2)
ok: [demo-qfx5110-12] => (item=ae100)
ok: [demo-qfx5110-11] => (item=ae100)

TASK [validate-interfaces-status : validate interfaces status is operationaly up] ***************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item=et-0/0/0)
ok: [demo-qfx5110-11] => (item=et-0/0/0)
ok: [demo-qfx5110-12] => (item=et-0/0/1)
ok: [demo-qfx5110-11] => (item=et-0/0/1)
ok: [demo-qfx5110-12] => (item=et-0/0/2)
ok: [demo-qfx5110-11] => (item=et-0/0/2)
ok: [demo-qfx5110-12] => (item=et-0/0/3)
ok: [demo-qfx5110-11] => (item=et-0/0/3)

TASK [validate-interfaces-status : validate interfaces status is admin down] ********************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item=xe-0/0/6:3)
ok: [demo-qfx5110-11] => (item=xe-0/0/6:3)

TASK [validate-lldp-neighbors : validate lldp neighbors are the ones we excpect] ****************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item={u'local_interface': u'et-0/0/0', u'remote_name': u'demo-qfx10k2-14'})
ok: [demo-qfx5110-11] => (item={u'local_interface': u'et-0/0/0', u'remote_name': u'demo-qfx10k2-14'})
ok: [demo-qfx5110-12] => (item={u'local_interface': u'et-0/0/1', u'remote_name': u'demo-qfx10k2-15'})
ok: [demo-qfx5110-11] => (item={u'local_interface': u'et-0/0/1', u'remote_name': u'demo-qfx10k2-15'})
ok: [demo-qfx5110-12] => (item={u'local_interface': u'et-0/0/2', u'remote_name': u'demo-qfx5110-9'})
ok: [demo-qfx5110-11] => (item={u'local_interface': u'et-0/0/2', u'remote_name': u'demo-qfx5110-9'})
ok: [demo-qfx5110-12] => (item={u'local_interface': u'et-0/0/3', u'remote_name': u'demo-qfx5110-10'})
ok: [demo-qfx5110-11] => (item={u'local_interface': u'et-0/0/3', u'remote_name': u'demo-qfx5110-10'})

TASK [validate-vlans-configuration : validate vlan] *********************************************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item={u'name': u'tenant1_dmz'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant1_dmz'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant1_trust'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant1_trust'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant1_untrust'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant1_untrust'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant2_dmz'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant2_dmz'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant2_trust'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant2_trust'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant2_untrust'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant2_untrust'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant3_dmz'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant3_dmz'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant3_trust'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant3_trust'})
ok: [demo-qfx5110-12] => (item={u'name': u'tenant3_untrust'})
ok: [demo-qfx5110-11] => (item={u'name': u'tenant3_untrust'})

TASK [validate-bgp-sessions : validate devices can ping their bgp peers] ************************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.2'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.0'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.6'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.4'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.10'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.8'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.14'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.12'})

TASK [validate-bgp-sessions : validate bgp sessions are Established] ****************************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.2'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.0'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.6'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.4'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.10'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.8'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.14'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.12'})

TASK [validate-bgp-sessions : validate the number of BGP routes received] ***********************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.2'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.0'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.6'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.4'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.10'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.8'})
ok: [demo-qfx5110-12] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.14'})
ok: [demo-qfx5110-11] => (item={u'number_of_routes_learnt_greater_than': 2, u'peer_ip': u'172.16.0.12'})

TASK [validate-ip-reachability-using-ping-from-Junos-device : ping from Junos devices] **********************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-12] => (item={u'local_ip': u'10.0.0.22', u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'10.0.0.21', u'peer_ip': u'10.0.0.1'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'10.0.0.21', u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-12] => (item={u'local_ip': u'10.0.0.22', u'peer_ip': u'10.0.0.2'})
ok: [demo-qfx5110-12] => (item={u'local_ip': u'10.0.0.22', u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'10.0.0.21', u'peer_ip': u'10.0.0.11'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'10.0.0.21', u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-12] => (item={u'local_ip': u'10.0.0.22', u'peer_ip': u'10.0.0.12'})
ok: [demo-qfx5110-12] => (item={u'local_ip': u'172.16.0.3', u'peer_ip': u'172.16.0.2'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'172.16.0.1', u'peer_ip': u'172.16.0.0'})
ok: [demo-qfx5110-12] => (item={u'local_ip': u'172.16.0.7', u'peer_ip': u'172.16.0.6'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'172.16.0.5', u'peer_ip': u'172.16.0.4'})
ok: [demo-qfx5110-12] => (item={u'local_ip': u'172.16.0.11', u'peer_ip': u'172.16.0.10'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'172.16.0.9', u'peer_ip': u'172.16.0.8'})
ok: [demo-qfx5110-12] => (item={u'local_ip': u'172.16.0.15', u'peer_ip': u'172.16.0.14'})
ok: [demo-qfx5110-11] => (item={u'local_ip': u'172.16.0.13', u'peer_ip': u'172.16.0.12'})

TASK [validate-vtep-endpoints : collect interfaces vtep] ****************************************************************************************************
ok: [demo-qfx5110-12]
ok: [demo-qfx5110-9]
ok: [demo-qfx10k2-14]
ok: [demo-qfx10k2-15]
ok: [demo-qfx5110-10]
ok: [demo-qfx5110-11]

TASK [validate-vtep-endpoints : validate VTEP remote endpoints address] *************************************************************************************
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
ok: [demo-qfx5110-11] => (item={u'address': u'10.0.0.21'}) => {
    "changed": false,
    "item": {
        "address": "10.0.0.21"
    },
    "msg": "All assertions passed"
}
ok: [demo-qfx5110-11] => (item={u'address': u'10.0.0.22'}) => {
    "changed": false,
    "item": {
        "address": "10.0.0.22"
    },
    "msg": "All assertions passed"
}
ok: [demo-qfx5110-12] => (item={u'address': u'10.0.0.21'}) => {
    "changed": false,
    "item": {
        "address": "10.0.0.21"
    },
    "msg": "All assertions passed"
}
ok: [demo-qfx5110-12] => (item={u'address': u'10.0.0.22'}) => {
    "changed": false,
    "item": {
        "address": "10.0.0.22"
    },
    "msg": "All assertions passed"
}

PLAY RECAP **************************************************************************************************************************************************
demo-qfx10k2-14            : ok=4    changed=0    unreachable=0    failed=0
demo-qfx10k2-15            : ok=4    changed=0    unreachable=0    failed=0
demo-qfx5110-10            : ok=4    changed=0    unreachable=0    failed=0
demo-qfx5110-11            : ok=17   changed=0    unreachable=0    failed=0
demo-qfx5110-12            : ok=17   changed=0    unreachable=0    failed=0
demo-qfx5110-9             : ok=4    changed=0    unreachable=0    failed=0


```
