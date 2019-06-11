
Role to test Junos configuration  

Supports all formats (xml, set, text, json). The format is determined by the file extension (.conf, .xml, .set, .json)

There is a Jinja pre processing of the [tasks](https://github.com/ksator/microservice-test-junos-configuration/blob/master/roles/test-configuration/tasks/main.yml) defined in YAML.  

This role is using variables:
- ```junos_conf_dir``` 
- ```credentials``` 
- ```load_type```
- ```save_dir``` 

The variable ```credentials ``` is defined [here](https://github.com/ksator/microservice-test-junos-configuration/blob/master/group_vars/all/network_authentication.yaml) 

The variable ```save_dir``` and ```junos_conf_dir``` are defined [here](https://github.com/ksator/microservice-test-junos-configuration/blob/master/repository.cfg) 

The variable ```load_type``` is defined in the ```inputs``` directory (```type_to_use_when_loading_configuration.yml``` file)  
 

