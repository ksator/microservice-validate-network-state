Role to deploy Junos configuration  

Supports all formats (xml, set, text, json). The format is determined by the file extension (.conf, .xml, .set, .json)

There is a Jinja pre processing of the tasks defined in YAML.  
```
---
  - name: Create output directory for each device
    file:
      path: "{{save_dir}}"
      state: directory

  - name: load and commit configuration
    juniper_junos_config:
      provider: "{{ credentials }}"
      load: "{{ load_type }}"
      src: "{{ junos_conf_dir }}/{{ inventory_hostname }}.conf"
      diff: true
      diffs_file: "{{ save_dir }}/configuration_diff.log"
      check: true
      commit: true

```
This role is using variables:
- ```junos_conf_dir``` 
- ```credentials``` 
- ```load_type```
- ```save_dir``` 

The variable ```credentials ``` is defined [here](https://github.com/ksator/microservice-load-junos-configuration/blob/master/group_vars/all/network_authentication.yaml) 

The variable ```save_dir``` and ```junos_conf_dir``` are defined [here](https://github.com/ksator/microservice-load-junos-configuration/blob/master/repository.cfg) 

The variable ```load_type``` is defined in the ```inputs``` directory (```type_to_use_when_loading_configuration.yml``` file)  
) 

