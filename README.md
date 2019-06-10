# Description 

This microservice loads Junos configuration files on devices  
It uses Docker and Ansible.  
This microservice: 
- instanciates a container
- executes the service 
- stops the container 
- removes the container

The Docker image is https://hub.docker.com/r/ksator/load_junos_configuration  

# Usage

## Install Docker

## Pull the Docker image
```
$ docker pull ksator/load_junos_configuration  
```
Verify
```
$ docker images ksator/load_junos_configuration  
```

## Create the microservice inputs

Create this structure: 
- An `inputs` directory. With these files: 
  - An Ansible Inventory file (`hosts.ini`) with following variables:
    - `ansible_host`: IP of the device
    - `ansible_ssh_user`: Username to use for the connection
    - `ansible_ssh_pass`: Password to use for the connection
  - a directory ```configuration_files``` with Junos configuration files
    - All formats (xml, set, text, json) are supported. The format is determined by the file extension (.conf, .xml, .set, .json)
  - A YAML file (`type_to_use_when_loading_configuration.yml `) to indicate how do you want to load the configuration (replace, merge, overwrite)  
  
```
$ ls inputs
configuration_files  hosts.ini  type_to_use_when_loading_configuration.yml
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

Junos configuration files example:   
```
$ ls inputs/configuration_files/
demo-qfx10k2-14.conf  demo-qfx10k2-15  demo-qfx5110-10  demo-qfx5110-9
```
```
$ more inputs/configuration_files/demo-qfx10k2-14.conf 
system {
	services {
		extension-service {
		    request-response {
		        grpc {
		            clear-text {
		                port 32766;
		            }
		            skip-authentication;
		        }
		    }
		    notification {
		        allow-clients {
		            address 0.0.0.0/0;
		        }
		    }
		}
	}
}
```
Indicate how do you want to load the configuration 
```
$ more inputs/type_to_use_when_loading_configuration.yml 
load_type: "merge"

```
## Run the microservice

This will instanciate a container, execute the service, stop the container and remove the container.    
```
$ docker run -it --rm -v ${PWD}/inputs:/inputs -v ${PWD}/outputs:/outputs ksator/load_junos_configuration

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
```
```
$ more outputs/
```
