![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ksator/collect-junos-configuration.svg) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ksator/collect-junos-configuration.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/ksator/collect-junos-configuration.svg) ![MicroBadger Layers](https://img.shields.io/microbadger/layers/ksator/collect-junos-configuration.svg) ![MicroBadger Size](https://img.shields.io/microbadger/image-size/ksator/collect-junos-configuration.svg)

# Description 

This microservice collects Junos configuration    
It uses Docker and Ansible.  
This microservice: 
- instanciates a container
- executes the service (collects Junos configuration)
- stops the container 
- removes the container

The Docker image is https://hub.docker.com/r/ksator/collect-junos-configuration 

# Usage

## Install Docker

## Pull the Docker image
```
$ docker pull ksator/collect-junos-configuration


```
Verify
```
$ docker images ksator/collect-junos-configuration
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
ksator/collect-junos-configuration   latest              972f17f4a0c0        14 minutes ago      543MB

```

## Create the microservice inputs

Create this structure: 
- An `inputs` directory. With these files: 
  - An Ansible Inventory file (`hosts.ini`) with following variables:
    - `ansible_host`: IP of the device
    - `ansible_ssh_user`: Username to use for the connection
    - `ansible_ssh_pass`: Password to use for the connection
  - A YAML file (`format_to_use_when_collecting_configuration.yml`) to indicate the desired format for the Junos configuration. 
    - The default format is text. 
    - Supported formats are: 
      - text
      - json
      - xml
      - set  
  
  
```
$ ls inputs/
format_to_use_when_collecting_configuration.yml  hosts.ini
```

Ansible inventory example: 
```
$ more inputs/hosts.ini
[spines]
demo-qfx10k2-14   ansible_host=172.25.90.67
demo-qfx10k2-15   ansible_host=172.25.90.68

[leaves]
demo-qfx5110-9    ansible_host=172.25.90.63
demo-qfx5110-10   ansible_host=172.25.90.64

[all:vars]
netconf_port=830
ansible_ssh_user=ansible
ansible_ssh_pass=juniper123
```

Configure the desired format for the Junos configuration (text, json, xml, set)   
Example:   
```
$ more inputs/format_to_use_when_collecting_configuration.yml

---
configuration:
  format: text

```


## Run the microservice

This will instanciate a container, execute the service, stop the container and remove the container.    
```
$ docker run -it --rm -v ${PWD}/inputs:/inputs -v ${PWD}/outputs:/outputs ksator/collect-junos-configuration

Collect Junos configuration

PLAY [collect junos configuration from devices] ***********************************************************************************************************************************************************************************************************************************

TASK [include_vars] ***************************************************************************************************************************************************************************************************************************************************************
ok: [demo-qfx5110-9]
ok: [demo-qfx5110-10]
ok: [demo-qfx10k2-14]
ok: [demo-qfx10k2-15]

TASK [include_vars] ***************************************************************************************************************************************************************************************************************************************************************
ok: [demo-qfx5110-9]
ok: [demo-qfx5110-10]
ok: [demo-qfx10k2-15]
ok: [demo-qfx10k2-14]

TASK [collect-configuration : Create output directory for each device] ************************************************************************************************************************************************************************************************************
changed: [demo-qfx5110-9]
changed: [demo-qfx10k2-15]
changed: [demo-qfx5110-10]
changed: [demo-qfx10k2-14]

TASK [collect-configuration : Collect configuration in text format from devices] **************************************************************************************************************************************************************************************************
ok: [demo-qfx5110-9]
ok: [demo-qfx5110-10]
ok: [demo-qfx10k2-15]
ok: [demo-qfx10k2-14]

TASK [collect-configuration : Copy collected configuration in a local directory] **************************************************************************************************************************************************************************************************
changed: [demo-qfx10k2-15]
changed: [demo-qfx5110-9]
changed: [demo-qfx10k2-14]
changed: [demo-qfx5110-10]

TASK [collect-configuration : Collect configuration in set format from devices] ***************************************************************************************************************************************************************************************************
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]

TASK [collect-configuration : copy collected configuration in a local directory] **************************************************************************************************************************************************************************************************
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]

TASK [collect-configuration : Collect configuration in json format from devices] **************************************************************************************************************************************************************************************************
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]

TASK [collect-configuration : copy collected configuration in a local directory] **************************************************************************************************************************************************************************************************
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]

TASK [collect-configuration : Collect configuration in xml format from devices] ***************************************************************************************************************************************************************************************************
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]

TASK [collect-configuration : copy collected configuration in a local directory] **************************************************************************************************************************************************************************************************
skipping: [demo-qfx5110-9]
skipping: [demo-qfx5110-10]
skipping: [demo-qfx10k2-14]
skipping: [demo-qfx10k2-15]

PLAY RECAP ************************************************************************************************************************************************************************************************************************************************************************
demo-qfx10k2-14            : ok=5    changed=2    unreachable=0    failed=0   
demo-qfx10k2-15            : ok=5    changed=2    unreachable=0    failed=0   
demo-qfx5110-10            : ok=5    changed=2    unreachable=0    failed=0   
demo-qfx5110-9             : ok=5    changed=2    unreachable=0    failed=0   

```
List the containers.  
The container doesnt exist anymore
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```
```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```


## Check the microservice output 

Here's the output generated
```
$ tree outputs/
outputs/
├── demo-qfx10k2-14
│   └── configuration.conf
├── demo-qfx10k2-15
│   └── configuration.conf
├── demo-qfx5110-10
│   └── configuration.conf
└── demo-qfx5110-9
    └── configuration.conf

4 directories, 4 files
```
